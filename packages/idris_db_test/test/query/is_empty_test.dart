import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'is_empty_test.g.dart';

@collection
class Model {
  Model(this.id, this.value);

  final int id;

  final String? value;
}

void main() {
  group('Query isEmpty / isNotEmpty', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema]);

      IdrisDb.write(
        (IdrisDb) =>
            IdrisDb.models.putAll(List.generate(100, (i) => Model(i, 'model $i'))),
      );
    });

    IdrisDbTest('.isEmpty()', () {
      expect(IdrisDb.models.where().isEmpty(), false);
      expect(IdrisDb.models.where().valueStartsWith('model').isEmpty(), false);
      expect(IdrisDb.models.where().valueEqualTo('model 1').isEmpty(), false);
      expect(
        IdrisDb.models.where().valueStartsWith('non existing').isEmpty(),
        true,
      );
      expect(
        IdrisDb.models
            .where()
            .valueStartsWith('model 1')
            .and()
            .valueEqualTo('model 2')
            .isEmpty(),
        true,
      );
      expect(
        IdrisDb.models
            .where()
            .valueEqualTo('model 1')
            .or()
            .valueEqualTo('model 2')
            .isEmpty(),
        false,
      );

      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 99));
      expect(IdrisDb.models.where().isEmpty(), false);

      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll());
      expect(IdrisDb.models.where().isEmpty(), true);

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(Model(0, null)));
      expect(IdrisDb.models.where().isEmpty(), false);
    });
  });
}
