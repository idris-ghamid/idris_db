import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'name_test.g.dart';

@collection
@Name('NameModelN')
class NameModel {
  NameModel(this.id);

  @Name('idN')
  int id;

  @Index()
  @Name('valueN')
  String? value;

  @Name('otherValueN')
  String? otherValue;
}

void main() {
  group('Name', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([NameModelSchema]);
    });

    IdrisDbTest('json', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.nameModels.put(
          NameModel(1)
            ..value = 'test'
            ..otherValue = 'test2',
        ),
      );

      expect(IdrisDb.nameModels.where().exportJson(), [
        {'idN': 1, 'valueN': 'test', 'otherValueN': 'test2'},
      ]);
    });
  });
}
