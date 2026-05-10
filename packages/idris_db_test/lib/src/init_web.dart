import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/src/common.dart';

var _setUp = false;
Future<void> prepareTest() async {
  if (!_setUp) {
    await IdrisDb.initialize('http://localhost:3000/IdrisDb.wasm');
    testTempPath = '/idris_db_test';
    _setUp = true;
  }
}
