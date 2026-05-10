part of 'package:idris_db/idris_db.dart';

/// Superclass of all IdrisDb errors.
sealed class IdrisDbError extends Error {
  /// Name of the error.
  String get name;

  /// Error message.
  String get message;

  @override
  String toString() {
    return '$name: $message';
  }
}

/// Invalid or protected path error.
class PathError extends IdrisDbError {
  /// Creates a path error.
  PathError();

  @override
  final name = 'PathError';

  @override
  final message =
      'The specified path does not exist or cannot be used by IdrisDb '
      'for example because it is a file.';
}

/// An active write transaction is required for this operation.
class WriteTxnRequiredError extends IdrisDbError {
  /// Creates a write transaction required error.
  WriteTxnRequiredError();

  @override
  String get name => 'WriteTxnRequiredError';

  @override
  String get message => 'This operation requires an active write transaction.';
}

/// Database file is incompatible with this version of IdrisDb.
class VersionError extends IdrisDbError {
  /// Creates a version error.
  VersionError();

  @override
  String get name => 'VersionError';

  @override
  String get message =>
      'The database version is not compatible with this '
      'version of IdrisDb. Please check if you need to migrate the database.';
}

/// The object is too large to be stored in IdrisDb.
class ObjectLimitReachedError extends IdrisDbError {
  /// Creates an object limit reached error.
  ObjectLimitReachedError();

  @override
  String get name => 'ObjectLimitReachedError';

  @override
  String get message =>
      'The maximum size of an object was exceeded. All '
      'objects in IdrisDb including all nested lists and objects must be smaller '
      'than 16MB.';
}

/// Invalid IdrisDb instance.
class InstanceMismatchError extends IdrisDbError {
  /// Creates an instance mismatch error.
  InstanceMismatchError();

  @override
  String get name => 'InstanceMismatchError';

  @override
  String get message =>
      'Provided resources do not belong to this IdrisDb '
      'instance. This can happen when you try to use a query or transaction '
      'from a different IdrisDb instance.';
}

/// Something went wrong during encryption/decryption. Most likely the
/// encryption key is wrong.
class EncryptionError extends IdrisDbError {
  /// Creates an encryption error.
  EncryptionError();

  @override
  String get name => 'EncryptionError';

  @override
  String get message =>
      'Could not encrypt/decrypt the database. Make sure '
      'that the encryption key is correct and that the database is not '
      'corrupted.';
}

/// The database is full.
class DatabaseFullError extends IdrisDbError {
  /// Creates a database full error.
  DatabaseFullError();

  @override
  final name = 'DatabaseFullError';

  @override
  final message =
      'The database is full. Pleas increase the maxSizeMiB parameter '
      'when opening IdrisDb. Alternatively you can compact the database by '
      'specifying a CompactCondition when opening IdrisDb.';
}

/// IdrisDb has not been initialized correctly.
class IdrisDbNotReadyError extends IdrisDbError {
  /// @nodoc
  @protected
  IdrisDbNotReadyError(this.message);

  @override
  String get name => 'IdrisDbNotReadyError';

  @override
  final String message;
}

/// Unknown error returned by the database engine.
class DatabaseError extends IdrisDbError {
  /// @nodoc
  @protected
  DatabaseError(this.message);

  @override
  String get name => 'IdrisDbError';

  @override
  final String message;
}
