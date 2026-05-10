part of 'package:idris_db/idris_db.dart';

abstract class _IdrisDbConnect {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      printEmojis: false,
    ),
  );

  static const Map<
    ConnectAction,
    Future<dynamic> Function(Map<String, dynamic> _)
  >
  _handlers = {
    ConnectAction.listInstances: _listInstances,
    ConnectAction.getSchemas: _getSchemas,
    ConnectAction.watchInstance: _watchInstance,
    ConnectAction.executeQuery: _executeQuery,
    ConnectAction.deleteQuery: _deleteQuery,
    ConnectAction.importJson: _importJson,
    ConnectAction.exportJson: _exportJson,
    ConnectAction.editProperty: _editProperty,
  };

  static final _instances = <String, IdrisDb>{};
  static var _initialized = false;

  static final _querySubscription = <StreamSubscription<void>>[];
  static final _collectionSubscriptions = <StreamSubscription<void>>[];

  static void initialize(IdrisDb IdrisDb) {
    if (!_initialized) {
      _initialized = true;
      _printConnection();
      _registerHandlers();
    }

    if (!_instances.containsKey(IdrisDb.name)) {
      _instances[IdrisDb.name] = IdrisDb;
      postEvent(ConnectEvent.instancesChanged.event, {});
    }
  }

  static void _registerHandlers() {
    for (final handler in _handlers.entries) {
      registerExtension(handler.key.method, (method, parameters) async {
        try {
          final args = parameters.containsKey('args')
              ? jsonDecode(parameters['args']!) as Map<String, dynamic>
              : <String, dynamic>{};
          final result = <String, dynamic>{'result': await handler.value(args)};
          return ServiceExtensionResponse.result(jsonEncode(result));
        } on Exception catch (e) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            e.toString(),
          );
        }
      });
    }
  }

  static void _printConnection() {
    unawaited(
      Service.getInfo().then((info) {
        final serviceUri = info.serverUri;
        if (serviceUri == null) {
          return;
        }
        final port = serviceUri.port;
        var path = serviceUri.path;
        if (path.endsWith('/')) {
          path = path.substring(0, path.length - 1);
        }
        if (path.endsWith('=')) {
          path = path.substring(0, path.length - 1);
        }
        final url =
            'https://IDRISDBplusinspector.ahmetaydin.dev/${IdrisDb.version}/#/$port$path';
        final width = url.length + 2;
        String line(String text, String fill) {
          final fillCount = width - text.length;
          final left = List.filled(fillCount ~/ 2, fill);
          final right = List.filled(fillCount - left.length, fill);
          return left.join() + text + right.join();
        }

        final message =
            '''
      ╔${line('', '═')}╗
      ║${line('IdrisDb CONNECT STARTED', ' ')}║
      ╟${line('', '─')}╢
      ║${line('Open the link to connect to the IdrisDb', ' ')}║
      ║${line('Inspector while this build is running.', ' ')}║
      ╟${line('', '─')}╢
      ║${line(url, ' ')}║
      ╚${line('', '═')}╝''';
        _logger.w(message);
      }),
    );
  }

  static Future<dynamic> _getSchemas(Map<String, dynamic> params) async {
    final p = ConnectInstancePayload.fromJson(params);
    final IdrisDb = _instances[p.instance]!;
    return ConnectSchemasPayload(IdrisDb.schemas);
  }

  static Future<dynamic> _listInstances(Map<String, dynamic> _) async {
    return ConnectInstanceNamesPayload(_instances.keys.toList());
  }

  static Future<dynamic> _watchInstance(Map<String, dynamic> params) async {
    for (final sub in _collectionSubscriptions) {
      unawaited(sub.cancel());
    }

    _collectionSubscriptions.clear();
    if (params.isEmpty) {
      return true;
    }

    final p = ConnectInstancePayload.fromJson(params);
    final IdrisDb = _instances[p.instance]!;

    void sendCollectionInfo(IdrisDbCollection<dynamic, dynamic> collection) {
      final count = collection.count();
      final size = collection.getSize(includeIndexes: true);
      final collectionInfo = ConnectCollectionInfoPayload(
        instance: collection.idrisDb.name,
        collection: collection.schema.name,
        size: size,
        count: count,
      );
      postEvent(
        ConnectEvent.collectionInfoChanged.event,
        collectionInfo.toJson(),
      );
    }

    for (var i = 0; i < IdrisDb.schemas.length; i++) {
      if (IdrisDb.schemas[i].embedded) {
        break;
      }

      final collection = IdrisDb.collectionByIndex<dynamic, dynamic>(i);
      final sub = collection.watchLazy(fireImmediately: true).listen((_) {
        sendCollectionInfo(collection);
      });
      _collectionSubscriptions.add(sub);
    }
  }

  static Future<dynamic> _executeQuery(Map<String, dynamic> params) async {
    for (final sub in _querySubscription) {
      unawaited(sub.cancel());
    }
    _querySubscription.clear();

    final cQuery = ConnectQueryPayload.fromJson(params);
    final IdrisDb = _instances[cQuery.instance]!;
    final query = cQuery.toQuery(IdrisDb);

    _querySubscription.add(
      query.watchLazy().listen((_) {
        postEvent(ConnectEvent.queryChanged.event, {});
      }),
    );

    final count = query.count();
    final objects = await IdrisDb.readAsync((IdrisDb) {
      return query.exportJson(offset: cQuery.offset, limit: cQuery.limit);
    });
    query.close();

    return ConnectObjectsPayload(
      instance: cQuery.instance,
      collection: cQuery.collection,
      objects: objects,
      count: count,
    );
  }

  static Future<dynamic> _deleteQuery(Map<String, dynamic> params) async {
    final cQuery = ConnectQueryPayload.fromJson(params);
    final IdrisDb = _instances[cQuery.instance]!;
    final query = cQuery.toQuery(IdrisDb);
    await IdrisDb.writeAsync((IdrisDb) {
      query
        ..deleteAll()
        ..close();
    });
  }

  static Future<dynamic> _importJson(Map<String, dynamic> params) {
    final p = ConnectObjectsPayload.fromJson(params);
    final IdrisDb = _instances[p.instance]!;
    final colIndex = IdrisDb.schemas.indexWhere((e) => e.name == p.collection);
    return IdrisDb.writeAsync((IdrisDb) {
      IdrisDb.collectionByIndex<dynamic, dynamic>(colIndex).importJson(p.objects);
    });
  }

  static Future<dynamic> _exportJson(Map<String, dynamic> params) async {
    final cQuery = ConnectQueryPayload.fromJson(params);
    final IdrisDb = _instances[cQuery.instance]!;
    final query = cQuery.toQuery(IdrisDb);

    final count = query.count();
    final objects = await IdrisDb.readAsync((IdrisDb) {
      return query.exportJson(offset: cQuery.offset, limit: cQuery.limit);
    });
    query.close();

    return ConnectObjectsPayload(
      instance: cQuery.instance,
      collection: cQuery.collection,
      objects: objects,
      count: count,
    );
  }

  static Future<dynamic> _editProperty(Map<String, dynamic> params) async {
    final cEdit = ConnectEditPayload.fromJson(params);
    final IdrisDb = _instances[cEdit.instance]!;
    final keys = cEdit.path.split('.');

    final colIndex = IdrisDb.schemas.indexWhere((e) => e.name == cEdit.collection);
    final colSchema = IdrisDb.schemas[colIndex];
    final idIndex = colSchema.getPropertyIndex(colSchema.idName!);
    final query = IdrisDb
        .collectionByIndex<dynamic, dynamic>(colIndex)
        .buildQuery<dynamic>(
          filter: EqualCondition(
            property: idIndex == -1 ? 0 : idIndex,
            value: cEdit.id,
          ),
        );

    final objects = query.exportJson();
    if (objects.isNotEmpty) {
      dynamic object = objects.first;
      for (var i = 0; i < keys.length; i++) {
        if (i == keys.length - 1 && object is Map) {
          object[keys[i]] = cEdit.value;
        } else if (object is Map) {
          object = object[keys[i]];
        } else if (object is List) {
          object = object[int.parse(keys[i])];
        }
      }

      await IdrisDb.writeAsync(
        (IdrisDb) => IdrisDb
            .collectionByIndex<dynamic, dynamic>(colIndex)
            .importJson(objects),
      );
    }
  }
}
