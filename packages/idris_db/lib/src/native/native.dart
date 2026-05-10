import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:idris_db/idris_db.dart';
import 'package:idris_db/src/native/bindings.dart';

export 'dart:isolate';

export 'bindings.dart';
export 'ffi.dart';

/// @nodoc
FutureOr<IdrisDbCoreBindings> initializePlatformBindings([String? library]) {
  late IdrisDbCoreBindings bindings;
  try {
    library ??= Platform.isIOS ? null : library ?? Abi.current().localName;

    DynamicLibrary dylib;
    if (Platform.isIOS) {
      dylib = DynamicLibrary.process();
    } else {
      try {
        dylib = DynamicLibrary.open(library!);
      } catch (e) {
        if (Platform.isMacOS) {
          dylib = DynamicLibrary.process();
        } else {
          rethrow;
        }
      }
    }
    bindings = IdrisDbCoreBindings(dylib);
  } catch (e) {
    throw IdrisDbNotReadyError(
      'Could not initialize IdrisDbCore library for processor architecture '
      '"${Abi.current()}". If you create a Flutter app, make sure to add '
      'idris_db_flutter_libs to your dependencies. For Dart-only apps or unit '
      'tests, make sure to place the correct IdrisDb binary in the correct '
      'directory.\n$e',
    );
  }

  final coreVersion = bindings.IDRISDB_version().cast<Utf8>().toDartString();
  if (coreVersion != IdrisDb.version && coreVersion != 'debug') {
    throw IdrisDbNotReadyError(
      'Incorrect IdrisDb Core version: Required ${IdrisDb.version} found '
      '$coreVersion. Make sure to use the latest '
      'idris_db_flutter_libs. If you have a Dart only project, make '
      'sure that old IdrisDb Core binaries are deleted.',
    );
  }

  bindings.IDRISDB_connect_dart_api(NativeApi.initializeApiDLData);

  return bindings;
}

/// @nodoc
const tryInline = pragma('vm:prefer-inline');

extension on Abi {
  String get localName {
    switch (Abi.current()) {
      case Abi.androidArm:
      case Abi.androidArm64:
      case Abi.androidX64:
        return 'libIDRISDB.so';
      case Abi.macosArm64:
      case Abi.macosX64:
        return 'libIDRISDB.dylib';
      case Abi.linuxX64:
        return 'libIDRISDB.so';
      case Abi.windowsArm64:
      case Abi.windowsX64:
        return 'IdrisDb.dll';
      case Abi.androidIA32:
        throw IdrisDbNotReadyError(
          'Unsupported processor architecture. X86 Android emulators are not '
          'supported. Please use an x86_64 emulator instead. All physical '
          'Android devices are supported including 32bit ARM.',
        );
      default:
        throw IdrisDbNotReadyError(
          'Unsupported processor architecture "${Abi.current()}". '
          'Please open an issue on GitHub to request it.',
        );
    }
  }
}

/// @nodoc
int platformFastHash(String string) {
  // This is native code, JS rounding is not applicable
  // ignore: avoid_js_rounded_ints
  var hash = 0xcbf29ce484222325;

  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

/// @nodoc
@tryInline
Future<T> runIsolate<T>(String debugName, FutureOr<T> Function() computation) {
  return Isolate.run(computation, debugName: debugName);
}
