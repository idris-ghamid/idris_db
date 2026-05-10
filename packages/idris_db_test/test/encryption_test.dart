import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'encryption_test.g.dart';

@collection
class Model {
  Model(this.name);

  @id
  final String name;

  @override
  bool operator ==(Object other) => other is Model && name == other.name;
}

void main() {
  group('Encryption', () {
    IdrisDbTest('Correct key', IdrisDb: false, web: false, () async {
      final idrisDbName = getRandomName();
      final IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        encryptionKey: 'test',
      );
      IdrisDb.write((IdrisDb) {
        IdrisDb.models.putAll([Model('test1'), Model('test2')]);
      });
      expect(IdrisDb.close(), true);

      final IDRISDB2 = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        encryptionKey: 'test',
        closeAutomatically: false,
      );
      expect(IDRISDB2.models.where().findAll(), [Model('test1'), Model('test2')]);
    });

    IdrisDbTest('Wrong key', IdrisDb: false, web: false, () async {
      final idrisDbName = getRandomName();
      final IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        encryptionKey: 'test',
      );
      IdrisDb.write((IdrisDb) {
        IdrisDb.models.put(Model('test'));
      });
      expect(IdrisDb.close(), true);

      await expectLater(
        () =>
            openTempIDRISDB([ModelSchema], name: idrisDbName, encryptionKey: 'test2'),
        throwsA(isA<EncryptionError>()),
      );
    });

    test('IdrisDb engine does not support encryption', () async {
      await prepareTest();
      expect(
        () => IdrisDb.open(
          schemas: [ModelSchema],
          name: 'test_enc_${DateTime.now().millisecondsSinceEpoch}',
          directory: testTempPath ?? '.',
          encryptionKey: 'testkey',
        ),
        throwsArgumentError,
      );
    });
  });
}
