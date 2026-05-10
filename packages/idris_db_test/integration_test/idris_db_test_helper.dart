import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _IDRISDBGetErrorNative = Pointer<Utf8> Function(Uint32);
typedef _IDRISDBGetError = Pointer<Utf8> Function(int);

void runDarwinTest() {
  if (Platform.isIOS || Platform.isMacOS) {
    testWidgets('DynamicLibrary.process() can call IDRISDB_get_error on Darwin', (
      tester,
    ) async {
      expect(() {
        final lib = DynamicLibrary.process();
        final IDRISDBGetError = lib
            .lookupFunction<_IDRISDBGetErrorNative, _IDRISDBGetError>(
              'IDRISDB_get_error',
            );
        IDRISDBGetError(0);
      }, returnsNormally);
    });
  }
}
