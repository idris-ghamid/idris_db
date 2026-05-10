import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/src/common.dart';
import 'package:test/test.dart';

part 'index_test.g.dart';

@collection
class UniqueModel {
  UniqueModel({required this.id, this.value});

  final int id;

  @Index(unique: true)
  final String? value;

  @override
  bool operator ==(other) =>
      other is UniqueModel && id == other.id && value == other.value;
}

void main() {
  group('Index', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([UniqueModelSchema]);
    });

    IdrisDbTest('unique values override each other', () {
      IdrisDb.write((IdrisDb) {
        IdrisDb.uniqueModels.putAll([
          UniqueModel(id: 1, value: 'a'),
          UniqueModel(id: 2, value: 'b'),
          UniqueModel(id: 3, value: 'c'),
          UniqueModel(id: 4, value: 'b'),
        ]);
      });

      expect(IdrisDb.uniqueModels.where().findAll(), [
        UniqueModel(id: 1, value: 'a'),
        UniqueModel(id: 3, value: 'c'),
        UniqueModel(id: 4, value: 'b'),
      ]);

      IdrisDb.write((IdrisDb) {
        IdrisDb.uniqueModels.put(UniqueModel(id: 5, value: 'a'));
      });
      expect(IdrisDb.uniqueModels.where().findAll(), [
        UniqueModel(id: 3, value: 'c'),
        UniqueModel(id: 4, value: 'b'),
        UniqueModel(id: 5, value: 'a'),
      ]);
    });

    IdrisDbTest('unique nulls do not override each other', () {
      IdrisDb.write((IdrisDb) {
        IdrisDb.uniqueModels.putAll([UniqueModel(id: 1), UniqueModel(id: 2)]);
      });

      expect(IdrisDb.uniqueModels.where().findAll(), [
        UniqueModel(id: 1),
        UniqueModel(id: 2),
      ]);
    });
  });
}
