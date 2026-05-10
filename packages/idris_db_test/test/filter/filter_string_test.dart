import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'filter_string_test.g.dart';

@collection
class StringModel {
  StringModel(this.id, this.field);

  final int id;

  String? field;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is StringModel && field == other.field;

  @override
  String toString() {
    return 'StringModel{id: $id, field: $field}';
  }
}

void main() {
  group('String filter', () {
    late IdrisDb IdrisDb;

    late StringModel objEmpty;
    late StringModel obj1;
    late StringModel obj2;
    late StringModel obj3;
    late StringModel obj4;
    late StringModel obj5;
    late StringModel obj6;
    late StringModel objNull;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([StringModelSchema]);

      objEmpty = StringModel(0, '');
      obj1 = StringModel(1, 'string 1');
      obj2 = StringModel(2, 'string 2');
      obj3 = StringModel(3, 'string 3');
      obj4 = StringModel(4, 'string 4');
      obj5 = StringModel(5, 'string 5');
      obj6 = StringModel(6, 'string 5');
      objNull = StringModel(7, null);

      IdrisDb.write(
        (IdrisDb) => IdrisDb.stringModels.putAll([
          objEmpty,
          obj1,
          obj2,
          obj3,
          obj4,
          obj5,
          obj6,
          objNull,
        ]),
      );
    });

    IdrisDbTest('.equalTo()', () {
      expect(IdrisDb.stringModels.where().fieldEqualTo('string 2').findAll(), [
        obj2,
      ]);
      expect(IdrisDb.stringModels.where().fieldEqualTo(null).findAll(), [objNull]);
      expect(
        IdrisDb.stringModels.where().fieldEqualTo('string 6').findAll(),
        isEmpty,
      );
      expect(IdrisDb.stringModels.where().fieldEqualTo('').findAll(), [objEmpty]);
    });

    IdrisDbTest('.isNull()', () {
      expect(IdrisDb.stringModels.where().fieldIsNull().findAll(), [objNull]);
    });

    IdrisDbTest('.startsWith()', () {
      expect(IdrisDb.stringModels.where().fieldStartsWith('string').findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldStartsWith('').findAll(), [
        objEmpty,
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldStartsWith('S').findAll(), isEmpty);
    });

    IdrisDbTest('.endsWith()', () {
      expect(IdrisDb.stringModels.where().fieldEndsWith('5').findAll(), [
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldEndsWith('').findAll(), [
        objEmpty,
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldEndsWith('8').findAll(), isEmpty);
    });

    IdrisDbTest('.contains()', () {
      expect(IdrisDb.stringModels.where().fieldContains('ing').findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldContains('').findAll(), [
        objEmpty,
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldContains('x').findAll(), isEmpty);
    });

    IdrisDbTest('.greaterThan()', () {
      expect(IdrisDb.stringModels.where().fieldGreaterThan('string 0').findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);

      expect(IdrisDb.stringModels.where().fieldGreaterThan('string 1').findAll(), [
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);

      expect(IdrisDb.stringModels.where().fieldGreaterThan('string 2').findAll(), [
        obj3,
        obj4,
        obj5,
        obj6,
      ]);

      expect(IdrisDb.stringModels.where().fieldGreaterThan('string 3').findAll(), [
        obj4,
        obj5,
        obj6,
      ]);

      expect(IdrisDb.stringModels.where().fieldGreaterThan('string 4').findAll(), [
        obj5,
        obj6,
      ]);

      expect(
        IdrisDb.stringModels.where().fieldGreaterThan('string 5').findAll(),
        isEmpty,
      );
    });

    IdrisDbTest('.lessThan()', () {
      expect(IdrisDb.stringModels.where().fieldLessThan('string 0').findAll(), [
        objEmpty,
        objNull,
      ]);

      expect(IdrisDb.stringModels.where().fieldLessThan('string 1').findAll(), [
        objEmpty,
        objNull,
      ]);

      expect(IdrisDb.stringModels.where().fieldLessThan('string 2').findAll(), [
        objEmpty,
        obj1,
        objNull,
      ]);

      expect(IdrisDb.stringModels.where().fieldLessThan('string 3').findAll(), [
        objEmpty,
        obj1,
        obj2,
        objNull,
      ]);

      expect(IdrisDb.stringModels.where().fieldLessThan('string 4').findAll(), [
        objEmpty,
        obj1,
        obj2,
        obj3,
        objNull,
      ]);

      expect(IdrisDb.stringModels.where().fieldLessThan('string 5').findAll(), [
        objEmpty,
        obj1,
        obj2,
        obj3,
        obj4,
        objNull,
      ]);

      expect(IdrisDb.stringModels.where().fieldLessThan('string 6').findAll(), [
        objEmpty,
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
        objNull,
      ]);
    });

    IdrisDbTest('.between()', () {
      expect(
        IdrisDb.stringModels
            .where()
            .fieldBetween('string 2', 'string 4')
            .findAll(),
        [obj2, obj3, obj4],
      );

      expect(IdrisDb.stringModels.where().fieldBetween('', 'string 2').findAll(), [
        objEmpty,
        obj1,
        obj2,
      ]);
    });

    IdrisDbTest('.matches()', () {
      expect(IdrisDb.stringModels.where().fieldMatches('*ng 5').findAll(), [
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldMatches('????????').findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);
      expect(IdrisDb.stringModels.where().fieldMatches('').findAll(), [objEmpty]);

      expect(IdrisDb.stringModels.where().fieldMatches('*4?').findAll(), isEmpty);
    });

    IdrisDbTest('.isEmpty()', () {
      expect(IdrisDb.stringModels.where().fieldIsEmpty().findAll(), [objEmpty]);
    });

    IdrisDbTest('.isNotEmpty()', () {
      expect(IdrisDb.stringModels.where().fieldIsNotEmpty().findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);
    });
  });
}
