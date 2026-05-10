part of 'package:idris_db/idris_db.dart';

class _IdrisDbQueryImpl<T> extends IdrisDbQuery<T> {
  _IdrisDbQueryImpl({
    required int instanceId,
    required int ptrAddress,
    required Deserialize<T> deserialize,
    List<int>? properties,
  }) : _instanceId = instanceId,
       _ptrAddress = ptrAddress,
       _properties = properties,
       _deserialize = deserialize;

  final int _instanceId;
  final List<int>? _properties;
  final Deserialize<T> _deserialize;
  int _ptrAddress;

  Pointer<CIDRISDBQuery> get _ptr {
    final ptr = ptrFromAddress<CIDRISDBQuery>(_ptrAddress);
    if (ptr.isNull) {
      throw StateError('Query has already been closed.');
    }
    return ptr;
  }

  @override
  _IdrisDbImpl get idrisDb => _IdrisDbImpl.instance(_instanceId);

  List<E> _findAll<E>(Deserialize<E> deserialize, {int? offset, int? limit}) {
    if (limit == 0) {
      throw ArgumentError('Limit must be greater than 0.');
    }

    return idrisDb.getTxn((idrisDbPtr, txnPtr) {
      final cursorPtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIdrisDbQueryCursor>>();
      IdrisDbCore.b
          .IDRISDB_query_cursor(
            idrisDbPtr,
            txnPtr,
            _ptr,
            cursorPtrPtr,
            offset ?? 0,
            limit ?? 0,
          )
          .checkNoError();
      final cursorPtr = cursorPtrPtr.ptrValue;

      Pointer<CIdrisDbReader> readerPtr = nullptr;
      final values = <E>[];
      while (true) {
        readerPtr = IdrisDbCore.b.IDRISDB_query_cursor_next(cursorPtr, readerPtr);
        if (readerPtr.isNull) break;
        values.add(deserialize(readerPtr));
      }
      IdrisDbCore.b.IDRISDB_query_cursor_free(cursorPtr, readerPtr);
      return values;
    });
  }

  @override
  List<T> findAll({int? offset, int? limit}) {
    return _findAll(_deserialize, offset: offset, limit: limit);
  }

  @override
  int updateProperties(Map<int, dynamic> changes, {int? offset, int? limit}) {
    if (limit == 0) {
      throw ArgumentError('Limit must be greater than 0.');
    }

    return idrisDb.getWriteTxn((idrisDbPtr, txnPtr) {
      final updatePtr = IdrisDbCore.b.IDRISDB_update_new();
      for (final propertyId in changes.keys) {
        final value = _idrisDbValue(changes[propertyId]);
        IdrisDbCore.b.IDRISDB_update_add_value(updatePtr, propertyId, value);
      }

      IdrisDbCore.b
          .IDRISDB_query_update(
            idrisDbPtr,
            txnPtr,
            _ptr,
            offset ?? 0,
            limit ?? 0,
            updatePtr,
            IdrisDbCore.countPtr,
          )
          .checkNoError();

      return (IdrisDbCore.countPtr.u32Value, txnPtr);
    });
  }

  @override
  int deleteAll({int? offset, int? limit}) {
    if (limit == 0) {
      throw ArgumentError('Limit must be greater than 0.');
    }

    return idrisDb.getWriteTxn((idrisDbPtr, txnPtr) {
      IdrisDbCore.b
          .IDRISDB_query_delete(
            idrisDbPtr,
            txnPtr,
            _ptr,
            offset ?? 0,
            limit ?? 0,
            IdrisDbCore.countPtr,
          )
          .checkNoError();
      return (IdrisDbCore.countPtr.u32Value, txnPtr);
    });
  }

  @override
  List<Map<String, dynamic>> exportJson({int? offset, int? limit}) {
    final bufferPtrPtr = malloc<Pointer<Uint8>>()..ptrValue = nullptr;
    final bufferSizePtr = malloc<Uint32>();

    Map<String, dynamic> deserialize(IDRISDBReader reader) {
      final jsonSize = IdrisDbCore.b.IDRISDB_read_to_json(
        reader,
        bufferPtrPtr,
        bufferSizePtr,
      );
      final bufferPtr = bufferPtrPtr.ptrValue;
      if (bufferPtr == nullptr) {
        throw StateError('Error while exporting JSON.');
      } else {
        final jsonBytes = bufferPtr.asU8List(jsonSize);
        return jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
      }
    }

    try {
      return _findAll(deserialize, offset: offset, limit: limit);
    } finally {
      free(bufferPtrPtr);
      free(bufferSizePtr);
    }
  }

  @override
  R? aggregate<R>(Aggregation op) {
    final aggregation = switch (op) {
      Aggregation.count => AGGREGATION_COUNT,
      Aggregation.isEmpty => AGGREGATION_IS_EMPTY,
      Aggregation.min => AGGREGATION_MIN,
      Aggregation.max => AGGREGATION_MAX,
      Aggregation.sum => AGGREGATION_SUM,
      Aggregation.average => AGGREGATION_AVERAGE,
    };

    return idrisDb.getTxn((idrisDbPtr, txnPtr) {
      final valuePtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CIDRISDBValue>>();
      IdrisDbCore.b
          .IDRISDB_query_aggregate(
            idrisDbPtr,
            txnPtr,
            _ptr,
            aggregation,
            _properties?.firstOrNull ?? 0,
            valuePtrPtr,
          )
          .checkNoError();

      final valuePtr = valuePtrPtr.ptrValue;
      if (valuePtr == nullptr) return null;

      try {
        if (true is R) {
          return (IdrisDbCore.b.IDRISDB_value_get_bool(valuePtr) != 0) as R;
        } else if (0.5 is R) {
          return IdrisDbCore.b.IDRISDB_value_get_real(valuePtr) as R;
        } else if (0 is R) {
          return IdrisDbCore.b.IDRISDB_value_get_integer(valuePtr) as R;
        } else if (DateTime.now() is R) {
          return DateTime.fromMillisecondsSinceEpoch(
                IdrisDbCore.b.IDRISDB_value_get_integer(valuePtr),
                isUtc: true,
              ).toLocal()
              as R;
        } else if ('' is R) {
          final length = IdrisDbCore.b.IDRISDB_value_get_string(
            valuePtr,
            IdrisDbCore.stringPtrPtr,
          );
          if (IdrisDbCore.stringPtr.isNull) {
            return null;
          } else {
            return utf8.decode(IdrisDbCore.stringPtr.asU8List(length)) as R;
          }
        } else {
          throw ArgumentError('Unsupported aggregation type: $R');
        }
      } finally {
        IdrisDbCore.b.IDRISDB_value_free(valuePtr);
      }
    });
  }

  @override
  Stream<List<T>> watch({
    bool fireImmediately = false,
    int? offset,
    int? limit,
  }) {
    return watchLazy(
      fireImmediately: fireImmediately,
    ).asyncMap((event) => findAllAsync(offset: offset, limit: limit));
  }

  @override
  Stream<void> watchLazy({bool fireImmediately = false}) {
    if (IdrisDbCore.kIsWeb) {
      throw UnsupportedError('Watchers are not supported on the web');
    }

    final port = ReceivePort();
    final handlePtrPtr = IdrisDbCore.ptrPtr.cast<Pointer<CWatchHandle>>();

    IdrisDbCore.b
        .IDRISDB_watch_query(
          idrisDb.getPtr(),
          _ptr,
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
  void close() {
    IdrisDbCore.b.IDRISDB_query_free(_ptr);
    _ptrAddress = 0;
  }
}
