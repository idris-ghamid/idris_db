part of 'package:idris_db/idris_db.dart';

/// @nodoc
abstract final class IdrisDbCore {
  /// Whether the code is running on the web platform.
  static const bool kIsWeb =
      bool.fromEnvironment('dart.library.js_util') ||
      bool.fromEnvironment('dart.library.js_interop');

  static var _initialized = false;
  static String? _library;
  static var _webPersistenceReady = false;
  static Future<void>? _webPersistencePending;

  /// The IdrisDb core bindings.
  static late final IdrisDbCoreBindings b;

  /// Pointer to a pointer for native operations.
  static Pointer<Pointer<NativeType>> ptrPtr = malloc<Pointer<NativeType>>();

  /// Pointer to a uint32 for count operations.
  static Pointer<Uint32> countPtr = malloc<Uint32>();

  /// Pointer to a bool for boolean operations.
  static Pointer<Bool> boolPtr = malloc<Bool>();

  /// Pointer to a pointer to uint8 for string operations.
  static final Pointer<Pointer<Uint8>> stringPtrPtr = ptrPtr
      .cast<Pointer<Uint8>>();

  /// Gets the string pointer value.
  static Pointer<Uint8> get stringPtr => stringPtrPtr.ptrValue;

  /// Pointer to a pointer to CIdrisDbReader for reader operations.
  static final Pointer<Pointer<CIdrisDbReader>> readerPtrPtr = ptrPtr
      .cast<Pointer<CIdrisDbReader>>();

  /// Gets the reader pointer value.
  static Pointer<CIdrisDbReader> get readerPtr => readerPtrPtr.ptrValue;

  static Pointer<Uint16> _nativeStringPtr = nullptr;
  static int _nativeStringPtrLength = 0;

  static FutureOr<void> _initialize({String? library, bool explicit = false}) {
    if (_initialized) {
      return null;
    }

    if (kIsWeb && !explicit) {
      throw IdrisDbNotReadyError(
        'On web you have to call IdrisDb.initialize() '
        'manually before using IdrisDb.',
      );
    }

    final result = initializePlatformBindings(library);

    if (result is Future<IdrisDbCoreBindings>) {
      return result.then((bindings) async {
        b = bindings;
        _library = library;
        if (kIsWeb) {
          await _ensureWebPersistence();
        }
        _initialized = true;
      });
    } else {
      b = result;
      _library = library;
      if (kIsWeb) {
        return _ensureWebPersistence().then((_) {
          _initialized = true;
        });
      }
      _initialized = true;
      return null;
    }
  }

  static void _free() {
    free(ptrPtr);
    free(countPtr);
    free(boolPtr);
    if (!_nativeStringPtr.isNull) {
      free(_nativeStringPtr);
    }
  }

  static Pointer<CString> _toNativeString(String str) {
    if (_nativeStringPtrLength < str.length) {
      if (_nativeStringPtr != nullptr) {
        free(_nativeStringPtr);
      }
      _nativeStringPtr = malloc<Uint16>(str.length);
      _nativeStringPtrLength = str.length;
    }

    final list = _nativeStringPtr.asU16List(str.length);
    for (var i = 0; i < str.length; i++) {
      list[i] = str.codeUnitAt(i);
    }

    return b.IDRISDB_string(_nativeStringPtr, str.length);
  }

  @tryInline
  /// Reads an ID value from the reader.
  static int readId(Pointer<CIdrisDbReader> reader) {
    return b.IDRISDB_read_id(reader);
  }

  @tryInline
  /// Reads a null check from the reader at the given index.
  static bool readNull(Pointer<CIdrisDbReader> reader, int index) {
    return b.IDRISDB_read_null(reader, index) != 0;
  }

  @tryInline
  /// Reads a boolean value from the reader at the given index.
  static bool readBool(Pointer<CIdrisDbReader> reader, int index) {
    return b.IDRISDB_read_bool(reader, index) != 0;
  }

  @tryInline
  /// Reads a byte value from the reader at the given index.
  static int readByte(Pointer<CIdrisDbReader> reader, int index) {
    return b.IDRISDB_read_byte(reader, index);
  }

  @tryInline
  /// Reads an integer value from the reader at the given index.
  static int readInt(Pointer<CIdrisDbReader> reader, int index) {
    return b.IDRISDB_read_int(reader, index);
  }

  @tryInline
  /// Reads a float value from the reader at the given index.
  static double readFloat(Pointer<CIdrisDbReader> reader, int index) {
    return b.IDRISDB_read_float(reader, index);
  }

  @tryInline
  /// Reads a long value from the reader at the given index.
  static int readLong(Pointer<CIdrisDbReader> reader, int index) {
    return b.IDRISDB_read_long(reader, index);
  }

  @tryInline
  /// Reads a double value from the reader at the given index.
  static double readDouble(Pointer<CIdrisDbReader> reader, int index) {
    return b.IDRISDB_read_double(reader, index);
  }

  @tryInline
  /// Reads a string value from the reader at the given index.
  static String? readString(Pointer<CIdrisDbReader> reader, int index) {
    final length = b.IDRISDB_read_string(reader, index, stringPtrPtr, boolPtr);
    if (stringPtr.isNull) {
      return null;
    } else {
      final bytes = stringPtr.asU8List(length);
      if (boolPtr.boolValue) {
        return String.fromCharCodes(bytes);
      } else {
        return utf8.decode(bytes);
      }
    }
  }

  @tryInline
  /// Reads an object from the reader at the given index.
  static Pointer<CIdrisDbReader> readObject(
    Pointer<CIdrisDbReader> reader,
    int index,
  ) {
    return b.IDRISDB_read_object(reader, index);
  }

  @tryInline
  /// Reads a list from the reader at the given index.
  static int readList(
    Pointer<CIdrisDbReader> reader,
    int index,
    Pointer<Pointer<CIdrisDbReader>> listReader,
  ) {
    return b.IDRISDB_read_list(reader, index, listReader);
  }

  @tryInline
  /// Frees the reader.
  static void freeReader(Pointer<CIdrisDbReader> reader) {
    b.IDRISDB_read_free(reader);
  }

  @tryInline
  /// Writes a null value to the writer at the given index.
  static void writeNull(Pointer<CIdrisDbWriter> writer, int index) {
    b.IDRISDB_write_null(writer, index);
  }

  @tryInline
  /// Writes a boolean value to the writer at the given index.
  static void writeBool(
    Pointer<CIdrisDbWriter> writer,
    int index, {
    required bool value,
  }) {
    b.IDRISDB_write_bool(writer, index, value);
  }

  @tryInline
  /// Writes a byte value to the writer at the given index.
  static void writeByte(Pointer<CIdrisDbWriter> writer, int index, int value) {
    b.IDRISDB_write_byte(writer, index, value);
  }

  @tryInline
  /// Writes an integer value to the writer at the given index.
  static void writeInt(Pointer<CIdrisDbWriter> writer, int index, int value) {
    b.IDRISDB_write_int(writer, index, value);
  }

  @tryInline
  /// Writes a float value to the writer at the given index.
  static void writeFloat(Pointer<CIdrisDbWriter> writer, int index, double value) {
    b.IDRISDB_write_float(writer, index, value);
  }

  @tryInline
  /// Writes a long value to the writer at the given index.
  static void writeLong(Pointer<CIdrisDbWriter> writer, int index, int value) {
    b.IDRISDB_write_long(writer, index, value);
  }

  @tryInline
  /// Writes a double value to the writer at the given index.
  static void writeDouble(
    Pointer<CIdrisDbWriter> writer,
    int index,
    double value,
  ) {
    b.IDRISDB_write_double(writer, index, value);
  }

  @tryInline
  /// Writes a string value to the writer at the given index.
  static void writeString(
    Pointer<CIdrisDbWriter> writer,
    int index,
    String value,
  ) {
    final valuePtr = _toNativeString(value);
    b.IDRISDB_write_string(writer, index, valuePtr);
  }

  @tryInline
  /// Begins writing an object to the writer at the given index.
  static Pointer<CIdrisDbWriter> beginObject(
    Pointer<CIdrisDbWriter> writer,
    int index,
  ) {
    return b.IDRISDB_write_object(writer, index);
  }

  @tryInline
  /// Ends writing an object to the writer.
  static void endObject(
    Pointer<CIdrisDbWriter> writer,
    Pointer<CIdrisDbWriter> objectWriter,
  ) {
    b.IDRISDB_write_object_end(writer, objectWriter);
  }

  static Future<void> _ensureWebPersistence() async {
    if (!kIsWeb || _webPersistenceReady) {
      return;
    }

    if (_webPersistencePending != null) {
      await _webPersistencePending;
      return;
    }

    final future = _initializeWebPersistence();
    _webPersistencePending = future;
    try {
      await future;
    } finally {
      _webPersistencePending = null;
    }
  }

  static Future<void> _initializeWebPersistence() async {
    final directoryPtr = _toNativeString('IdrisDb');
    final handle = b.IDRISDB_web_persistence_start(directoryPtr);
    const pollInterval = Duration(milliseconds: 15);

    while (true) {
      final status = b.IDRISDB_web_persistence_poll(handle);
      if (status == 0) {
        await Future<void>.delayed(pollInterval);
        continue;
      }

      if (status == 1) {
        _webPersistenceReady = true;
        return;
      }

      final error =
          _currentErrorMessage() ??
          'Failed to initialize IdrisDb web persistence backend.';
      throw DatabaseError(error);
    }
  }

  static String? _currentErrorMessage() {
    final length = b.IDRISDB_get_error(stringPtrPtr);
    final ptr = stringPtr;
    if (length == 0 || ptr.isNull) {
      return null;
    }
    return utf8.decode(ptr.asU8List(length));
  }

  @tryInline
  /// Begins writing a list to the writer at the given index.
  static Pointer<CIdrisDbWriter> beginList(
    Pointer<CIdrisDbWriter> writer,
    int index,
    int length,
  ) {
    return b.IDRISDB_write_list(writer, index, length);
  }

  @tryInline
  /// Ends writing a list to the writer.
  static void endList(
    Pointer<CIdrisDbWriter> writer,
    Pointer<CIdrisDbWriter> listWriter,
  ) {
    b.IDRISDB_write_list_end(writer, listWriter);
  }
}

/// @nodoc
extension PointerX on Pointer<void> {
  @tryInline
  /// Returns true if the pointer is null.
  bool get isNull => address == 0;
}
