import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'auto_increment_test.g.dart';

@collection
class Model {
  Model(this.id);

  final int id;
}

@collection
class StringModel {
  StringModel(this.id);

  final String id;
}

void main() {
  group('Auto increment', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema, StringModelSchema]);
    });

    IdrisDbTest('String ids not supported', () {
      expect(() => IdrisDb.stringModels.autoIncrement(), throwsUnsupportedError);
    });

    IdrisDbTest('increases', () {
      expect(IdrisDb.models.autoIncrement(), 1);
      expect(IdrisDb.models.autoIncrement(), 2);
      expect(IdrisDb.models.autoIncrement(), 3);
    });

    IdrisDbTest('adjusts after insert', () {
      expect(IdrisDb.models.autoIncrement(), 1);
      expect(IdrisDb.models.autoIncrement(), 2);
      expect(IdrisDb.models.autoIncrement(), 3);

      IdrisDb.write((IdrisDb) {
        IdrisDb.models.put(Model(100));
        IdrisDb.models.put(Model(200));
        IdrisDb.models.put(Model(300));
      });

      expect(IdrisDb.models.autoIncrement(), 301);
      expect(IdrisDb.models.autoIncrement(), 302);
      expect(IdrisDb.models.autoIncrement(), 303);
    });

    IdrisDbTest('persists', web: false, () async {
      final idrisDbName = IdrisDb.name;

      expect(IdrisDb.models.autoIncrement(), 1);
      IdrisDb.write((IdrisDb) {
        IdrisDb.models.put(Model(IdrisDb.models.autoIncrement()));
      });
      expect(IdrisDb.close(), true);

      IdrisDb = await openTempIDRISDB([ModelSchema], name: idrisDbName);
      expect(IdrisDb.models.autoIncrement(), 3);
    });
  });
}
