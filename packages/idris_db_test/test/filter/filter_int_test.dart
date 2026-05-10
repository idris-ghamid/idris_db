import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'filter_int_test.g.dart';

@collection
class IntModel {
  IntModel(this.id, this.field);

  final int id;

  short? field = 0;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is IntModel && id == other.id && other.field == field;
  }
}

void main() {
  group('Int filter', () {
    late IdrisDb IdrisDb;
    late IdrisDbCollection<int, IntModel> col;

    late IntModel obj0;
    late IntModel obj1;
    late IntModel obj2;
    late IntModel obj3;
    late IntModel objNull;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([IntModelSchema]);
      col = IdrisDb.intModels;

      obj0 = IntModel(0, -1234);
      obj1 = IntModel(1, 1);
      obj2 = IntModel(2, 2);
      obj3 = IntModel(3, 1);
      objNull = IntModel(4, null);

      IdrisDb.write((IdrisDb) {
        IdrisDb.intModels.putAll([obj0, obj1, obj2, obj3, objNull]);
      });
    });

    IdrisDbTest('.equalTo()', () {
      expect(col.where().fieldEqualTo(2).findAll(), [obj2]);
      expect(col.where().fieldEqualTo(null).findAll(), [objNull]);
      expect(col.where().fieldEqualTo(5).findAll(), isEmpty);
    });

    IdrisDbTest('.greaterThan()', () {
      expect(col.where().fieldGreaterThan(1).findAll(), [obj2]);
      expect(col.where().fieldGreaterThan(null).findAll(), [
        obj0,
        obj1,
        obj2,
        obj3,
      ]);
      expect(col.where().fieldGreaterThan(4).findAll(), isEmpty);
    });

    IdrisDbTest('.greaterThanOrEqualTo()', () {
      expect(col.where().fieldGreaterThanOrEqualTo(1).findAll(), [
        obj1,
        obj2,
        obj3,
      ]);
      expect(col.where().fieldGreaterThanOrEqualTo(null).findAll(), [
        obj0,
        obj1,
        obj2,
        obj3,
        objNull,
      ]);
    });

    IdrisDbTest('.lessThan()', () {
      expect(col.where().fieldLessThan(1).findAll(), [obj0, objNull]);
      expect(col.where().fieldLessThan(null).findAll(), isEmpty);
    });

    IdrisDbTest('.lessThanOrEqualTo()', () {
      expect(col.where().fieldLessThanOrEqualTo(null).findAll(), [objNull]);
    });

    IdrisDbTest('.between()', () {
      expect(col.where().fieldBetween(1, 2).findAll(), [obj1, obj2, obj3]);
      expect(col.where().fieldBetween(null, 1).findAll(), [
        obj0,
        obj1,
        obj3,
        objNull,
      ]);
      expect(col.where().fieldBetween(5, 6).findAll(), isEmpty);
    });

    IdrisDbTest('.isNull()', () {
      expect(col.where().fieldIsNull().findAll(), [objNull]);
    });

    IdrisDbTest('.isNotNull()', () {
      expect(col.where().fieldIsNotNull().findAll(), [obj0, obj1, obj2, obj3]);
    });
  });
}
