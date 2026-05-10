part of 'package:idris_db/idris_db.dart';

class _IdrisDbImpl extends IdrisDb {
  factory _IdrisDbImpl.open({
    required List<IdrisDbGeneratedSchema> schemas,
    required String name,
    required IdrisDbEngine engine,
    required String directory,
    required int? maxSizeMiB,
    required String? encryptionKey,
    required CompactCondition? compactOnLaunch,
    String? library,
  }) {
    // IdrisDbCore._initialize can return FutureOr<void> which may complete async
    // ignore: discarded_futures
    IdrisDbCore._initialize(library: library);

    var effectiveMaxSizeMiB = maxSizeMiB;
    if (engine == IdrisDbEngine.IdrisDb) {
      if (encryptionKey != null) {
        throw ArgumentError(
          'IdrisDb engine does not support encryption. Please '
          'set the engine to IdrisDbEngine.sqlite.',
        );
      }
      effectiveMaxSizeMiB ??= IdrisDb.defaultMaxSizeMiB;
    } else {
      if (compactOnLaunch != null) {
        throw ArgumentError('SQLite engine does not support compaction.');
      }
      effectiveMaxSizeMiB ??= 0;
    }

    final allSchemas = <IdrisDbGeneratedSchema>{
      ...schemas,
      ...schemas.expand((e) => e.allEmbeddedSchemas),
    };
    final schemaJson = jsonEncode(
      allSchemas.map((e) => e.schema.toJson()).toList(),
    );

    final instanceId = IdrisDb.fastHash(name);
    // Check if instance already exists to avoid creating duplicates
    final instance = _IdrisDbImpl._instances[instanceId];
    if (instance != null) {
      return instance;
    }

    final namePtr = IdrisDbCore._toNativeString(name);
    final directoryPtr = IdrisDbCore._toNativeString(directory);
    final schemaPtr = IdrisDbCore._toNativeString(schemaJson);
    final encryptionKeyPtr = encryptionKey != null
        ? IdrisDbCore._toNativeString(encryptionKey)
        : nullptr;

    final idrisDbPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIdrisDbInstance>>();
    IdrisDbCore.b
        .IDRISDB_open_instance(
          idrisDbPtrPtr,
          instanceId,
          namePtr,
          directoryPtr,
          engine == IdrisDbEngine.sqlite,
          schemaPtr,
          effectiveMaxSizeMiB,
          encryptionKeyPtr,
          compactOnLaunch != null ? compactOnLaunch.minFileSize ?? 0 : -1,
          compactOnLaunch != null ? compactOnLaunch.minBytes ?? 0 : -1,
          compactOnLaunch != null ? compactOnLaunch.minRatio ?? 0 : double.nan,
        )
        .checkNoError();

    return _IdrisDbImpl._(instanceId, idrisDbPtrPtr.ptrValue, allSchemas.toList());
  }
  factory _IdrisDbImpl.get({
    required int instanceId,
    required List<IdrisDbGeneratedSchema> schemas,
    String? library,
  }) {
    // IdrisDbCore._initialize can return FutureOr<void> which may complete async
    // ignore: discarded_futures
    IdrisDbCore._initialize(library: library);
    var ptr = IdrisDbCore.b.IDRISDB_get_instance(instanceId, false);
    if (ptr.isNull) {
      ptr = IdrisDbCore.b.IDRISDB_get_instance(instanceId, true);
    }
    if (ptr.isNull) {
      throw IdrisDbNotReadyError(
        'Instance has not been opened yet. Make sure to '
        'call IdrisDb.open() before using IdrisDb.get().',
      );
    }

    return _IdrisDbImpl._(instanceId, ptr, schemas);
  }
  factory _IdrisDbImpl.getByName({
    required String name,
    required List<IdrisDbGeneratedSchema> schemas,
  }) {
    final instanceId = IdrisDb.fastHash(name);
    final instance = _IdrisDbImpl._instances[instanceId];
    if (instance != null) {
      return instance;
    }

    return _IdrisDbImpl.get(instanceId: instanceId, schemas: schemas);
  }
  _IdrisDbImpl._(
    this.instanceId,
    Pointer<CIdrisDbInstance> ptr,
    this.generatedSchemas,
  ) : _ptr = ptr {
    for (final schema in generatedSchemas) {
      if (schema.isEmbedded) {
        continue;
      }
      // Type parameters need to match the schema's generic types
      collections[schema.converter.type] = schema.converter.withType(<ID, OBJ>(
        converter,
      ) {
        return _IdrisDbCollectionImpl<ID, OBJ>(
          this,
          schema.schema,
          collections.length,
          converter,
        );
      });
    }

    _instances[instanceId] = this;
  }

  static final _instances = <int, _IdrisDbImpl>{};

  final int instanceId;
  final List<IdrisDbGeneratedSchema> generatedSchemas;
  // Dynamic types needed for storing mixed collection types
  final collections = <Type, _IdrisDbCollectionImpl<dynamic, dynamic>>{};

  Pointer<CIdrisDbInstance>? _ptr;
  Pointer<CIdrisDbTxn>? _txnPtr;
  bool _txnWrite = false;

  static Future<IdrisDb> openAsync({
    required List<IdrisDbGeneratedSchema> schemas,
    required String directory,
    String name = IdrisDb.defaultName,
    IdrisDbEngine engine = IdrisDbEngine.IdrisDb,
    int? maxSizeMiB = IdrisDb.defaultMaxSizeMiB,
    String? encryptionKey,
    CompactCondition? compactOnLaunch,
  }) async {
    final library = IdrisDbCore._library;

    final receivePort = ReceivePort();
    final responses = StreamIterator(receivePort);
    final sendPort = receivePort.sendPort;
    final isolate = runIsolate('IdrisDb open async', () async {
      try {
        final instance = _IdrisDbImpl.open(
          schemas: schemas,
          directory: directory,
          name: name,
          engine: engine,
          maxSizeMiB: maxSizeMiB,
          encryptionKey: encryptionKey,
          compactOnLaunch: compactOnLaunch,
          library: library,
        );

        final receivePort = ReceivePort();
        sendPort.send(receivePort.sendPort);
        await receivePort.first;
        instance.close();
        sendPort.send('closed');
      } on Object catch (e) {
        sendPort.send(e);
      }
    });

    await responses.moveNext();
    final response = responses.current;
    if (response is SendPort) {
      final instance = IdrisDb.get(schemas: schemas, name: name);
      response.send(null);
      await responses.moveNext();
      final closeConfirmation = responses.current;
      await responses.cancel();
      receivePort.close();
      if (closeConfirmation != 'closed') {
        throw Exception('Unexpected response from background isolate');
      }
      unawaited(isolate);
      return instance;
    } else {
      await responses.cancel();
      receivePort.close();
      throw Exception(response);
    }
  }

  static _IdrisDbImpl instance(int instanceId) {
    // Getter for existing IdrisDb instance
    final instance = _instances[instanceId];
    if (instance == null) {
      throw IdrisDbNotReadyError(
        'IdrisDb instance has not been opened yet in this isolate. Call '
        'IdrisDb.get() or IdrisDb.open() before trying to access IdrisDb for the first '
        'time in a new isolate.',
      );
    }
    return instance;
  }

  @tryInline
  Pointer<CIdrisDbInstance> getPtr() {
    final ptr = _ptr;
    if (ptr == null) {
      throw IdrisDbNotReadyError('IdrisDb instance has already been closed.');
    } else {
      return ptr;
    }
  }

  @override
  late final String name = () {
    final length = IdrisDbCore.b.IDRISDB_get_name(getPtr(), IdrisDbCore.stringPtrPtr);
    return utf8.decode(IdrisDbCore.stringPtr.asU8List(length));
  }();

  @override
  late final String directory = () {
    final length = IdrisDbCore.b.IDRISDB_get_dir(getPtr(), IdrisDbCore.stringPtrPtr);
    return utf8.decode(IdrisDbCore.stringPtr.asU8List(length));
  }();

  @override
  late final List<IdrisDbSchema> schemas = generatedSchemas
      .map((e) => e.schema)
      .toList();

  @override
  bool get isOpen => _ptr != null;

  @override
  IdrisDbCollection<ID, OBJ> collection<ID, OBJ>() {
    final collection = collections[OBJ];
    if (collection is _IdrisDbCollectionImpl<ID, OBJ>) {
      return collection;
    } else {
      throw ArgumentError('Collection for type $OBJ not found');
    }
  }

  @override
  IdrisDbCollection<ID, OBJ> collectionByIndex<ID, OBJ>(int index) {
    final collection = collections.values.elementAt(index);
    if (collection is _IdrisDbCollectionImpl<ID, OBJ>) {
      return collection;
    } else {
      throw ArgumentError('Invalid type parameters for collection');
    }
  }

  @tryInline
  T getTxn<T>(
    T Function(Pointer<CIdrisDbInstance> idrisDbPtr, Pointer<CIdrisDbTxn> txnPtr)
    callback,
  ) {
    final txnPtr = _txnPtr;
    if (txnPtr != null) {
      return callback(_ptr!, txnPtr);
    } else {
      return read((IdrisDb) => callback(_ptr!, _txnPtr!));
    }
  }

  @tryInline
  T getWriteTxn<T>(
    (T, Pointer<CIdrisDbTxn>?) Function(
      Pointer<CIdrisDbInstance> idrisDbPtr,
      Pointer<CIdrisDbTxn> txnPtr,
    )
    callback, {
    bool consume = false,
  }) {
    final txnPtr = _txnPtr;
    if (txnPtr != null) {
      if (_txnWrite) {
        if (consume) {
          _txnPtr = null;
        }
        final (result, returnedPtr) = callback(_ptr!, txnPtr);
        _txnPtr = returnedPtr;
        return result;
      }
    }
    throw WriteTxnRequiredError();
  }

  void _checkNotInTxn() {
    if (_txnPtr != null) {
      throw UnsupportedError('Nested transactions are not supported');
    }
  }

  @override
  T read<T>(T Function(IdrisDb IdrisDb) callback) {
    _checkNotInTxn();

    final ptr = getPtr();
    final txnPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIdrisDbTxn>>();
    IdrisDbCore.b.IDRISDB_txn_begin(ptr, txnPtrPtr, false).checkNoError();
    try {
      _txnPtr = txnPtrPtr.ptrValue;
      _txnWrite = false;
      return callback(this);
    } finally {
      IdrisDbCore.b.IDRISDB_txn_abort(ptr, _txnPtr!);
      _txnPtr = null;
    }
  }

  @override
  T write<T>(T Function(IdrisDb IdrisDb) callback) {
    _checkNotInTxn();

    final ptr = getPtr();
    final txnPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIdrisDbTxn>>();
    IdrisDbCore.b.IDRISDB_txn_begin(ptr, txnPtrPtr, true).checkNoError();
    try {
      _txnPtr = txnPtrPtr.ptrValue;
      _txnWrite = true;
      final result = callback(this);
      IdrisDbCore.b.IDRISDB_txn_commit(ptr, _txnPtr!).checkNoError();
      return result;
    } catch (_) {
      final txnPtr = _txnPtr;
      if (txnPtr != null) {
        IdrisDbCore.b.IDRISDB_txn_abort(ptr, txnPtr);
      }
      rethrow;
    } finally {
      _txnPtr = null;
    }
  }

  @override
  Future<T> readAsyncWith<T, P>(
    P param,
    T Function(IdrisDb IdrisDb, P param) callback, {
    String? debugName,
  }) {
    if (IdrisDbCore.kIsWeb) {
      throw UnsupportedError(
        'readAsync() is not supported on web '
        'because isolates are not available. Use the synchronous read() method '
        'instead:\n'
        '  IdrisDb.read((IdrisDb) => ...);\n'
        'Or use get()/getAll() directly:\n'
        '  final user = IdrisDb.users.get(id);',
      );
    }

    _checkNotInTxn();

    final instance = instanceId;
    final library = IdrisDbCore._library;
    final schemas = generatedSchemas;
    return runIsolate(
      debugName ?? 'IdrisDb async read',
      () => _IdrisDbAsync(
        instanceId: instance,
        schemas: schemas,
        write: false,
        param: param,
        callback: callback,
        library: library,
      ),
    );
  }

  @override
  Future<T> writeAsyncWith<T, P>(
    P param,
    T Function(IdrisDb IdrisDb, P param) callback, {
    String? debugName,
  }) async {
    if (IdrisDbCore.kIsWeb) {
      throw UnsupportedError(
        'writeAsync() is not supported on web because isolates '
        'are not available. Use the synchronous write() method instead:\n'
        '  IdrisDb.write((IdrisDb) => IdrisDb.users.put(user));',
      );
    }

    _checkNotInTxn();

    final instance = instanceId;
    final library = IdrisDbCore._library;
    final schemas = generatedSchemas.toList();
    return runIsolate(debugName ?? 'IdrisDb async write', () {
      return _IdrisDbAsync(
        instanceId: instance,
        schemas: schemas,
        write: true,
        param: param,
        callback: callback,
        library: library,
      );
    });
  }

  @override
  int getSize({bool includeIndexes = false}) {
    var size = 0;
    for (final collection in collections.values) {
      size += collection.getSize(includeIndexes: includeIndexes);
    }
    return size;
  }

  @override
  void copyToFile(String path) {
    final string = IdrisDbCore._toNativeString(path);
    IdrisDbCore.b.IDRISDB_copy(getPtr(), string).checkNoError();
  }

  @override
  void clear() {
    for (final collection in collections.values) {
      collection.clear();
    }
  }

  @override
  bool close({bool deleteFromDisk = false}) {
    final closed = IdrisDbCore.b.IDRISDB_close(getPtr(), deleteFromDisk);
    _ptr = null;
    _instances.remove(instanceId);
    return closed != 0;
  }

  @override
  void verify() {
    getTxn(
      (idrisDbPtr, txnPtr) =>
          IdrisDbCore.b.IDRISDB_verify(idrisDbPtr, txnPtr).checkNoError(),
    );
  }
}

T _IdrisDbAsync<T, P>({
  required int instanceId,
  required List<IdrisDbGeneratedSchema> schemas,
  required bool write,
  required P param,
  required T Function(IdrisDb idrisDb, P param) callback,
  String? library,
}) {
  final instance = _IdrisDbImpl.get(
    instanceId: instanceId,
    schemas: schemas,
    library: library,
  );
  try {
    if (write) {
      return instance.write((idb) => callback(idb, param));
    } else {
      return instance.read((idb) => callback(idb, param));
    }
  } finally {
    instance.close();
    IdrisDbCore._free();
  }
}
