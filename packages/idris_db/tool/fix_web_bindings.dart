import 'dart:io';

const path = 'lib/src/web/bindings.dart';

void main() {
  var content = File(path).readAsStringSync();

  content = content.replaceFirst("import 'dart:ffi' as ffi;", '''
import 'package:idris_db/src/web/ffi.dart' as ffi;
import 'package:idris_db/src/web/interop.dart';

extension IDRISDBBindingsX on JSIDRISDB {
''');

  content = content.replaceFirst('final', '''
}

final
''');

  File(path).writeAsStringSync(content);
}
