part of 'package:idris_db/idris_db.dart';

/// The IdrisDb storage engine.
enum IdrisDbEngine {
  /// The native IdrisDb storage engine.
  IdrisDb,

  /// The SQLite storage engine.
  sqlite,
}

/// An IdrisDb database instance.
@pragma('vm:isolate-unsendable')
abstract class IdrisDb {
  /// @nodoc
  @protected
  IdrisDb();

  /// The default IdrisDb instance name.
  static const String defaultName = 'default';

  /// The default max IdrisDb size.
  static const int defaultMaxSizeMiB = 128;

  /// The current IdrisDb version.
  static const String version = '0.0.0-placeholder';

  /// Use this value for the `directory` parameter to create an in-memory
  /// database.
  static const String sqliteInMemory = ':memory:';

  /// Initialize IdrisDb manually. This is required if you target web.
  ///
  /// On native platforms you can provide a custom path to the IdrisDb Core
  /// [library].
  static FutureOr<void> initialize([String? library]) {
    return IdrisDbCore._initialize(library: library, explicit: true);
  }

  /// Get an already opened IdrisDb instance by its name.
  ///
  /// This method is especially useful to get an IdrisDb instance from an isolate.
  /// It is much faster than using [open].
  static IdrisDb get({
    required List<IdrisDbGeneratedSchema> schemas,
    String name = IdrisDb.defaultName,
  }) {
    return _IdrisDbImpl.getByName(name: name, schemas: schemas);
  }

  /// Open a new IdrisDb instance.
  ///
  /// {@template IDRISDB_open}
  /// You have to provide a list of all collection [schemas] that you want to
  /// use in this instance as well as a [directory] where the database file
  /// should be stored.
  ///
  /// Use [IdrisDb.sqliteInMemory] as the directory to create an in-memory
  /// database.
  ///
  /// You can optionally provide a [name] for this instance. This is needed if
  /// you want to open multiple instances.
  ///
  /// If [encryptionKey] is provided, the database will be encrypted with the
  /// provided key. Opening an encrypted database with an incorrect key will
  /// result in an error. Only the SQLite storage engine supports encryption.
  ///
  /// [maxSizeMiB] is the maximum size of the database file in MiB. It is
  /// recommended to set this value as low as possible. Older devices might
  /// not be able to grant the requested amount of virtual memory. In that case
  /// IdrisDb will try to use as much memory as possible.
  ///
  /// [compactOnLaunch] is a condition that triggers a database compaction
  /// on launch when the specified conditions are met. Only the IdrisDb storage
  /// engine supports compaction.
  ///
  /// [inspector] enables the IdrisDb inspector when the app is running in debug
  /// mode. In release mode the inspector is always disabled.
  /// {@endtemplate}
  static IdrisDb open({
    required List<IdrisDbGeneratedSchema> schemas,
    required String directory,
    String name = IdrisDb.defaultName,
    IdrisDbEngine engine = IdrisDbEngine.IdrisDb,
    int? maxSizeMiB = IdrisDb.defaultMaxSizeMiB,
    String? encryptionKey,
    CompactCondition? compactOnLaunch,
    bool inspector = true,
  }) {
    final IdrisDb = _IdrisDbImpl.open(
      schemas: schemas,
      directory: directory,
      name: name,
      engine: engine,
      maxSizeMiB: maxSizeMiB,
      encryptionKey: encryptionKey,
      compactOnLaunch: compactOnLaunch,
    );

    /// Tree shake the inspector for profile and release builds.
    assert(() {
      if (!IdrisDbCore.kIsWeb && inspector) {
        _IdrisDbConnect.initialize(IdrisDb);
      }
      return true;
    }(), 'IdrisDb inspector initialization');

    return IdrisDb;
  }

  /// Open a new IdrisDb instance asynchronously.
  ///
  /// {@macro IDRISDB_open}
  static Future<IdrisDb> openAsync({
    required List<IdrisDbGeneratedSchema> schemas,
    required String directory,
    String name = IdrisDb.defaultName,
    IdrisDbEngine engine = IdrisDbEngine.IdrisDb,
    int? maxSizeMiB = IdrisDb.defaultMaxSizeMiB,
    String? encryptionKey,
    CompactCondition? compactOnLaunch,
    bool inspector = true,
  }) async {
    final IdrisDb = await _IdrisDbImpl.openAsync(
      schemas: schemas,
      directory: directory,
      name: name,
      engine: engine,
      maxSizeMiB: maxSizeMiB,
      encryptionKey: encryptionKey,
      compactOnLaunch: compactOnLaunch,
    );

    /// Tree shake the inspector for profile and release builds.
    assert(() {
      if (!IdrisDbCore.kIsWeb && inspector) {
        _IdrisDbConnect.initialize(IdrisDb);
      }
      return true;
    }(), 'IdrisDb inspector initialization');

    return IdrisDb;
  }

  /// Name of the instance.
  String get name;

  /// The directory containing the database file.
  String get directory;

  /// Whether this instance is open and active.
  ///
  /// The instance is open until [close] is called. After that, all operations
  /// will throw an [IdrisDbNotReadyError].
  bool get isOpen;

  /// Get the schemas of all collections and embedded objects in this instance.
  List<IdrisDbSchema> get schemas;

  /// Get a collection by its type.
  ///
  /// You should use the generated extension methods instead. A collection
  /// `User` can be accessed with `IdrisDb.users`.
  IdrisDbCollection<ID, OBJ> collection<ID, OBJ>();

  /// Get a collection by its index.
  ///
  /// The index is the order in which the collections were defined when opening
  /// the instance.
  ///
  /// It is not recommended to use this method. Use the generated extension
  /// methods instead. A collection `User` can be accessed with `IdrisDb.users`.
  @experimental
  IdrisDbCollection<ID, OBJ> collectionByIndex<ID, OBJ>(int index);

  /// Create a synchronous read transaction.
  ///
  /// Explicit read transactions are optional, but they allow you to do atomic
  /// reads and rely on a consistent state of the database inside the
  /// transaction. Internally IdrisDb always uses implicit read transactions for
  /// all read operations.
  ///
  /// It is recommended to use an explicit read transactions when you want to
  /// perform multiple subsequent read operations.
  ///
  /// Example:
  /// ```dart
  /// final (user, workspace) = IdrisDb.read((IdrisDb) {
  ///   final user = IdrisDb.users.where().findFirst();
  ///   final workspace = IdrisDb.workspaces.where().findFirst();
  ///   return (user, workspace);
  /// });
  /// ```
  T read<T>(T Function(IdrisDb IdrisDb) callback);

  /// Create a synchronous read-write transaction.
  ///
  /// Unlike read operations, write operations in IdrisDb must be wrapped in an
  /// explicit transaction.
  ///
  /// When a write transaction finishes successfully, it is automatically
  /// committed, and all changes are written to disk. If an error occurs, the
  /// transaction is aborted, and all the changes are rolled back. Transactions
  /// are “all or nothing”: either all the writes within a transaction succeed,
  /// or none of them take effect to guarantee data consistency.
  ///
  /// Example:
  /// ```dart
  /// IdrisDb.write((IdrisDb) {
  ///   final user = User(name: 'John');
  ///   IdrisDb.users.put(user);
  /// });
  /// ```
  T write<T>(T Function(IdrisDb IdrisDb) callback);

  /// Create an asynchronous read transaction.
  ///
  /// The code inside the callback will be executed in a separate isolate.
  ///
  /// Check out the [read] method for more information.
  Future<T> readAsync<T>(T Function(IdrisDb IdrisDb) callback, {String? debugName}) =>
      readAsyncWith(null, (IdrisDb, _) => callback(IdrisDb), debugName: debugName);

  /// Create an asynchronous read transaction and pass a parameter to the
  /// callback.
  ///
  /// The code inside the callback will be executed in a separate isolate.
  ///
  /// Check out the [read] method for more information.
  Future<T> readAsyncWith<T, P>(
    P param,
    T Function(IdrisDb IdrisDb, P param) callback, {
    String? debugName,
  });

  /// Create an asynchronous read-write transaction.
  ///
  /// The code inside the callback will be executed in a separate isolate.
  ///
  /// Check out the [write] method for more information.
  Future<T> writeAsync<T>(
    T Function(IdrisDb IdrisDb) callback, {
    String? debugName,
  }) => writeAsyncWith(null, (IdrisDb, _) => callback(IdrisDb), debugName: debugName);

  /// Create an asynchronous read-write transaction and pass a parameter to the
  /// callback.
  ///
  /// The code inside the callback will be executed in a separate isolate.
  ///
  /// Check out the [write] method for more information.
  Future<T> writeAsyncWith<T, P>(
    P param,
    T Function(IdrisDb IdrisDb, P param) callback, {
    String? debugName,
  });

  /// Returns the size of all the collections in bytes.
  ///
  /// For the native IdrisDb storage engine this method is extremely fast and
  /// independent of the number of objects in the instance.
  int getSize({bool includeIndexes = false});

  /// Copy a compacted version of the database to the specified file.
  ///
  /// If you want to backup your database, you should always use a compacted
  /// version. Compacted does not mean compressed.
  ///
  /// Do not run this method while other transactions are active to avoid
  /// unnecessary growth of the database.
  void copyToFile(String path);

  /// Remove all data in this instance.
  void clear();

  /// Releases an IdrisDb instance.
  ///
  /// If this is the only isolate that holds a reference to this instance, the
  /// IdrisDb instance will be closed. [deleteFromDisk] additionally removes all
  /// database files if enabled.
  ///
  /// Returns whether the instance was actually closed.
  bool close({bool deleteFromDisk = false});

  /// Verifies the integrity of the database. This method is not intended to be
  /// used by end users and should only be used by IdrisDb tests. Never call this
  /// method on a production database.
  @visibleForTesting
  void verify();

  /// FNV-1a 64bit hash algorithm optimized for Dart Strings
  static int fastHash(String string) {
    return platformFastHash(string);
  }

  /// Delete a database without opening it first.
  ///
  /// This is useful when you need to delete a corrupted or encrypted database
  /// that cannot be opened with the current encryption key.
  ///
  /// [name] is the name of the database instance.
  /// [directory] is the directory where the database files are stored.
  /// [engine] specifies whether it's an IdrisDb or SQLite database.
  static void deleteDatabase({
    required String name,
    required String directory,
    IdrisDbEngine engine = IdrisDbEngine.IdrisDb,
  }) {
    final namePtr = IdrisDbCore._toNativeString(name);
    final directoryPtr = IdrisDbCore._toNativeString(directory);

    IdrisDbCore.b
        .IDRISDB_delete_database(
          namePtr,
          directoryPtr,
          engine == IdrisDbEngine.sqlite,
        )
        .checkNoError();
  }
}
