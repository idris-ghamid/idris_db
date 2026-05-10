part of 'package:idris_db/idris_db.dart';

class _IdrisDbCollectionImpl<ID, OBJ> extends IdrisDbCollection<ID, OBJ> {
  _IdrisDbCollectionImpl(
    this.idrisDb,
    this.schema,
    this.collectionIndex,
    this.converter,
  );

  @override
  final _IdrisDbImpl idrisDb;

  @override
  final IdrisDbSchema schema;

  final int collectionIndex;
  final IDRISDBObjectConverter<ID, OBJ> converter;

  @override
  int autoIncrement() {
    if (0 is ID) {
      return IdrisDbCore.b.IDRISDB_auto_increment(idrisDb.getPtr(), collectionIndex);
    } else {
      throw UnsupportedError(
        'Collections with String IDs do not support auto increment.',
      );
    }
  }

  @override
  List<OBJ?> getAll(List<ID> ids) {
    final objects = List<OBJ?>.filled(ids.length, null, growable: true);
    return idrisDb.getTxn((idrisDbPtr, txnPtr) {
      final cursorPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIDRISDBCursor>>();

      IdrisDbCore.b
          .IDRISDB_cursor(idrisDbPtr, txnPtr, collectionIndex, cursorPtrPtr)
          .checkNoError();

      final cursorPtr = cursorPtrPtr.ptrValue;
      Pointer<CIdrisDbReader> readerPtr = nullptr;
      for (var i = 0; i < ids.length; i++) {
        final id = _idToInt(ids[i]);
        readerPtr = IdrisDbCore.b.IDRISDB_cursor_next(cursorPtr, id, readerPtr);
        if (!readerPtr.isNull) {
          objects[i] = converter.deserialize(readerPtr);
        }
      }
      IdrisDbCore.b.IDRISDB_cursor_free(cursorPtr, readerPtr);
      return objects;
    });
  }

  @override
  void putAll(List<OBJ> objects) {
    if (objects.isEmpty) return;

    return idrisDb.getWriteTxn(consume: true, (idrisDbPtr, txnPtr) {
      final writerPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIdrisDbWriter>>();

      IdrisDbCore.b
          .IDRISDB_insert(
            idrisDbPtr,
            txnPtr,
            collectionIndex,
            objects.length,
            writerPtrPtr,
          )
          .checkNoError();

      final insertPtr = writerPtrPtr.ptrValue;
      try {
        for (final object in objects) {
          final id = converter.serialize(insertPtr, object);
          IdrisDbCore.b.IDRISDB_insert_save(insertPtr, id).checkNoError();
        }
      } catch (e) {
        IdrisDbCore.b.IDRISDB_insert_abort(insertPtr);
        rethrow;
      }

      final txnPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIdrisDbTxn>>();
      IdrisDbCore.b.IDRISDB_insert_finish(insertPtr, txnPtrPtr).checkNoError();

      return (null, txnPtrPtr.ptrValue);
    });
  }

  @override
  int updateProperties(List<ID> ids, Map<int, dynamic> changes) {
    if (ids.isEmpty) return 0;

    final updatePtr = IdrisDbCore.b.IDRISDB_update_new();
    for (final propertyId in changes.keys) {
      final value = _idrisDbValue(changes[propertyId]);
      IdrisDbCore.b.IDRISDB_update_add_value(updatePtr, propertyId, value);
    }

    return idrisDb.getWriteTxn((idrisDbPtr, txnPtr) {
      var count = 0;
      final updatedPtr = IdrisDbCore.boolPtr;
      for (final id in ids) {
        IdrisDbCore.b
            .IDRISDB_update(
              idrisDbPtr,
              txnPtr,
              collectionIndex,
              _idToInt(id),
              updatePtr,
              updatedPtr,
            )
            .checkNoError();

        if (updatedPtr.boolValue) {
          count++;
        }
      }

      return (count, txnPtr);
    });
  }

  @override
  bool delete(ID id) {
    return idrisDb.getWriteTxn((idrisDbPtr, txnPtr) {
      IdrisDbCore.b
          .IDRISDB_delete(
            idrisDbPtr,
            txnPtr,
            collectionIndex,
            _idToInt(id),
            IdrisDbCore.boolPtr,
          )
          .checkNoError();

      return (IdrisDbCore.boolPtr.boolValue, txnPtr);
    });
  }

  @override
  int deleteAll(List<ID> ids) {
    if (ids.isEmpty) return 0;

    return idrisDb.getWriteTxn((idrisDbPtr, txnPtr) {
      var count = 0;
      for (final id in ids) {
        IdrisDbCore.b
            .IDRISDB_delete(
              idrisDbPtr,
              txnPtr,
              collectionIndex,
              _idToInt(id),
              IdrisDbCore.boolPtr,
            )
            .checkNoError();

        if (IdrisDbCore.boolPtr.boolValue) {
          count++;
        }
      }

      return (count, txnPtr);
    });
  }

  @override
  QueryBuilder<OBJ, OBJ, QStart> where() {
    return QueryBuilder(this);
  }

  @override
  int count() {
    return idrisDb.getTxn((idrisDbPtr, txnPtr) {
      IdrisDbCore.b.IDRISDB_count(
        idrisDbPtr,
        txnPtr,
        collectionIndex,
        IdrisDbCore.countPtr,
      );
      return IdrisDbCore.countPtr.u32Value;
    });
  }

  @override
  int getSize({bool includeIndexes = false}) {
    return idrisDb.getTxn((idrisDbPtr, txnPtr) {
      return IdrisDbCore.b.IDRISDB_get_size(
        idrisDbPtr,
        txnPtr,
        collectionIndex,
        includeIndexes,
      );
    });
  }

  @override
  int importJsonString(String json) {
    return idrisDb.getWriteTxn(consume: true, (idrisDbPtr, txnPtr) {
      final txnPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIdrisDbTxn>>()
        ..ptrValue = txnPtr;
      final nativeString = IdrisDbCore._toNativeString(json);
      IdrisDbCore.b
          .IDRISDB_import_json(
            idrisDbPtr,
            txnPtrPtr,
            collectionIndex,
            nativeString,
            IdrisDbCore.countPtr,
          )
          .checkNoError();
      return (IdrisDbCore.countPtr.u32Value, txnPtrPtr.ptrValue);
    });
  }

  @override
  void clear() {
    return idrisDb.getWriteTxn((idrisDbPtr, txnPtr) {
      IdrisDbCore.b.IDRISDB_clear(idrisDbPtr, txnPtr, collectionIndex);
      return (null, txnPtr);
    });
  }

  @override
  Stream<void> watchLazy({bool fireImmediately = false}) {
    if (IdrisDbCore.kIsWeb) {
      throw UnsupportedError('Watchers are not supported on the web');
    }

    final port = ReceivePort();
    final handlePtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CWatchHandle>>();

    IdrisDbCore.b
        .IDRISDB_watch_collection(
          idrisDb.getPtr(),
          collectionIndex,
          port.sendPort.nativePort,
          handlePtrPtr,
        )
        .checkNoError();

    final handlePtr = handlePtrPtr.ptrValue;
    final controller = StreamController<void>(
      onCancel: () {
        idrisDb.getPtr(); // Make sure IdrisDb is not closed
        IdrisDbCore.b.IDRISDB_stop_watching(handlePtr);
        port.close();
      },
    );
    if (fireImmediately) {
      controller.add(null);
    }

    unawaited(controller.addStream(port));
    return controller.stream;
  }

  @override
  Stream<ChangeDetail<T>> watchDetailed<T extends DocumentSerializable>({
    T Function(Map<String, dynamic> json)? documentParser,
  }) {
    if (IdrisDbCore.kIsWeb) {
      throw UnsupportedError('Detailed watchers are not supported on the web');
    }

    final port = ReceivePort();
    final handlePtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CWatchHandle>>();

    IdrisDbCore.b
        .IDRISDB_watch_collection_detailed(
          idrisDb.getPtr(),
          collectionIndex,
          port.sendPort.nativePort,
          handlePtrPtr,
        )
        .checkNoError();

    final handlePtr = handlePtrPtr.ptrValue;
    final controller = StreamController<ChangeDetail<T>>(
      onCancel: () {
        idrisDb.getPtr(); // Make sure IdrisDb is not closed
        IdrisDbCore.b.IDRISDB_stop_watching(handlePtr);
        port.close();
      },
    );

    // Listen to the port for JSON strings
    port.listen((data) {
      if (data is String) {
        final changeDetailMap = json.decode(data) as Map<String, dynamic>;
        final changeDetail = ChangeDetail<T>.fromJson(
          changeDetailMap,
          documentParser: documentParser,
        );
        controller.add(changeDetail);
      }
    });

    return controller.stream;
  }

  @override
  Stream<OBJ?> watchObject(ID id, {bool fireImmediately = false}) {
    return watchObjectLazy(
      id,
      fireImmediately: fireImmediately,
    ).asyncMap((event) => getAsync(id));
  }

  @override
  Stream<void> watchObjectLazy(ID id, {bool fireImmediately = false}) {
    if (IdrisDbCore.kIsWeb) {
      throw UnsupportedError('Watchers are not supported on the web');
    }

    final port = ReceivePort();
    final handlePtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CWatchHandle>>();

    IdrisDbCore.b
        .IDRISDB_watch_object(
          idrisDb.getPtr(),
          collectionIndex,
          _idToInt(id),
          port.sendPort.nativePort,
          handlePtrPtr,
        )
        .checkNoError();

    final handlePtr = handlePtrPtr.ptrValue;
    final controller = StreamController<void>(
      onCancel: () {
        idrisDb.getPtr(); // Make sure IdrisDb is not closed
        IdrisDbCore.b.IDRISDB_stop_watching(handlePtr);
        port.close();
      },
    );

    if (fireImmediately) {
      controller.add(null);
    }

    unawaited(controller.addStream(port));
    return controller.stream;
  }

  @override
  IdrisDbQuery<R> buildQuery<R>({
    Filter? filter,
    List<SortProperty>? sortBy,
    List<DistinctProperty>? distinctBy,
    List<int>? properties,
  }) {
    if (properties != null && properties.length > 3) {
      throw ArgumentError('Only up to 3 properties are supported');
    }

    final builderPtrPtr = malloc<Pointer<CIDRISDBQueryBuilder>>();
    IdrisDbCore.b
        .IDRISDB_query_new(idrisDb.getPtr(), collectionIndex, builderPtrPtr)
        .checkNoError();

    final builderPtr = builderPtrPtr.ptrValue;
    if (filter != null) {
      final pointers = <Pointer<Never>>[];
      try {
        final filterPtr = _buildFilter(filter, pointers);
        IdrisDbCore.b.IDRISDB_query_set_filter(builderPtr, filterPtr);
      } finally {
        pointers.forEach(free);
      }
    }

    if (sortBy != null) {
      for (final sort in sortBy) {
        IdrisDbCore.b.IDRISDB_query_add_sort(
          builderPtr,
          sort.property,
          sort.sort == Sort.asc,
          sort.caseSensitive,
        );
      }
    }

    if (distinctBy != null) {
      for (final distinct in distinctBy) {
        IdrisDbCore.b.IDRISDB_query_add_distinct(
          builderPtr,
          distinct.property,
          distinct.caseSensitive,
        );
      }
    }

    late final R Function(Pointer<CIdrisDbReader>) deserialize;
    switch (properties?.length ?? 0) {
      case 0:
        deserialize = converter.deserialize as R Function(Pointer<CIdrisDbReader>);
      case 1:
        final property = properties![0];
        final deserializeProp = converter.deserializeProperty!;
        deserialize = (reader) => deserializeProp(reader, property) as R;
      case 2:
        final property1 = properties![0];
        final property2 = properties[1];
        final deserializeProp = converter.deserializeProperty!;
        deserialize = (reader) =>
            (
                  deserializeProp(reader, property1),
                  deserializeProp(reader, property2),
                )
                as R;
      case 3:
        final property1 = properties![0];
        final property2 = properties[1];
        final property3 = properties[2];
        final deserializeProp = converter.deserializeProperty!;
        deserialize = (reader) =>
            (
                  deserializeProp(reader, property1),
                  deserializeProp(reader, property2),
                  deserializeProp(reader, property3),
                )
                as R;
    }

    final queryPtr = IdrisDbCore.b.IDRISDB_query_build(builderPtr);
    return _IdrisDbQueryImpl(
      instanceId: idrisDb.instanceId,
      ptrAddress: queryPtr.address,
      properties: properties,
      deserialize: deserialize,
    );
  }
}

@tryInline
int _idToInt<OBJ>(OBJ id) {
  if (id is int) {
    return id;
  } else {
    return IdrisDb.fastHash(id as String);
  }
}
