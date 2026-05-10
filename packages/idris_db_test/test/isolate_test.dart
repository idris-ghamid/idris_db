@TestOn('vm')
library;

import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'isolate_test.g.dart';

@collection
class TestModel {
  @Id()
  late int id;

  String? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is TestModel && other.id == id && other.value == value;
  }
}

final TestModel _obj1 = TestModel()
  ..id = 1
  ..value = 'Model 1';
final TestModel _obj2 = TestModel()
  ..id = 2
  ..value = 'Model 2';
final TestModel _obj3 = TestModel()
  ..id = 3
  ..value = 'Model 3';

void main() {
  IdrisDbTest('Isolate test', () async {
    final name = getRandomName();
    final IdrisDb = await openTempIDRISDB([TestModelSchema], name: name);

    IdrisDb.write((IdrisDb) {
      IdrisDb.testModels.putAll([_obj1, _obj2]);
    });

    final rootIsolateToken = RootIsolateToken.instance!;
    await Isolate.run(() async {
      BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
      await prepareTest();

      final IdrisDb = IdrisDb.get(schemas: [TestModelSchema], name: name);

      final current = IdrisDb.testModels.where().findAll();
      assert(
        current[0] == _obj1 && current[1] == _obj2,
        'Did not find objects',
      );

      IdrisDb.write((IdrisDb) {
        IdrisDb.testModels.delete(2);
        IdrisDb.testModels.put(_obj3);
      });

      assert(!IdrisDb.close(), 'Instance was closed incorrectly');
    });

    expect(IdrisDb.testModels.where().findAll(), [_obj1, _obj3]);
    expect(IdrisDb.close(deleteFromDisk: true), true);
  });
}
