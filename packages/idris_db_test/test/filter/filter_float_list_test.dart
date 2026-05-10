import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'filter_float_list_test.g.dart';

@collection
class FloatModel {
  FloatModel(this.id, this.list);

  final int id;

  List<float?>? list;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is FloatModel &&
      id == other.id &&
      doubleListEquals(other.list, list);
}

void main() {
  group('Float list filter', () {
    late IdrisDb IdrisDb;
    late IdrisDbCollection<int, FloatModel> col;

    late FloatModel objEmpty;
    late FloatModel obj1;
    late FloatModel obj2;
    late FloatModel obj3;
    late FloatModel objNull;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([FloatModelSchema]);
      col = IdrisDb.floatModels;

      objEmpty = FloatModel(0, []);
      obj1 = FloatModel(1, [1.1, 3.3]);
      obj2 = FloatModel(2, [null]);
      obj3 = FloatModel(3, [null, -1000]);
      objNull = FloatModel(4, null);

      IdrisDb.write((IdrisDb) {
        col.putAll([objEmpty, obj1, obj2, obj3, objNull]);
      });
    });

    IdrisDbTest('.elementEqualTo()', () {
      expect(col.where().listElementEqualTo(1.1).findAll(), [obj1]);
      expect(col.where().listElementEqualTo(4).findAll(), isEmpty);
      expect(col.where().listElementEqualTo(null).findAll(), [obj2, obj3]);
    });

    IdrisDbTest('.elementGreaterThan()', () {
      expect(col.where().listElementGreaterThan(3.3).findAll(), isEmpty);
      expect(col.where().listElementGreaterThan(4).findAll(), isEmpty);
      expect(col.where().listElementGreaterThan(null).findAll(), [obj1, obj3]);
    });

    IdrisDbTest('.elementGreaterThanOrEqualTo()', () {
      expect(col.where().listElementGreaterThanOrEqualTo(3.3).findAll(), [
        obj1,
      ]);
      expect(
        col
            .where()
            .listElementGreaterThanOrEqualTo(3.4, epsilon: 0.2)
            .findAll(),
        [obj1],
      );
      expect(col.where().listElementGreaterThanOrEqualTo(null).findAll(), [
        obj1,
        obj2,
        obj3,
      ]);
    });

    IdrisDbTest('.elementLessThan()', () {
      expect(col.where().listElementLessThan(1.1).findAll(), [obj2, obj3]);
      expect(col.where().listElementLessThan(null).findAll(), isEmpty);
    });

    IdrisDbTest('.elementLessThanOrEqualTo()', () {
      expect(col.where().listElementLessThanOrEqualTo(1.1).findAll(), [
        obj1,
        obj2,
        obj3,
      ]);
      expect(
        col.where().listElementLessThanOrEqualTo(1, epsilon: 0.2).findAll(),
        [obj1, obj2, obj3],
      );
      expect(col.where().listElementLessThanOrEqualTo(null).findAll(), [
        obj2,
        obj3,
      ]);
    });

    IdrisDbTest('.anyBetween()', () {
      expect(col.where().listElementBetween(1, 5).findAll(), [obj1]);
      expect(col.where().listElementBetween(null, 1.1).findAll(), [
        obj1,
        obj2,
        obj3,
      ]);
      expect(col.where().listElementBetween(5, 10).findAll(), isEmpty);
      expect(col.where().listElementBetween(null, null).findAll(), [
        obj2,
        obj3,
      ]);
    });

    IdrisDbTest('.elementIsNull()', () {
      expect(col.where().listElementIsNull().findAll(), [obj2, obj3]);
    });

    IdrisDbTest('.elementIsNotNull()', () {
      expect(col.where().listElementIsNotNull().findAll(), [obj1, obj3]);
    });

    IdrisDbTest('.isNull()', () {
      expect(col.where().listIsNull().findAll(), [objNull]);
    });

    IdrisDbTest('.isNotNull()', () {
      expect(col.where().listIsNotNull().findAll(), [
        objEmpty,
        obj1,
        obj2,
        obj3,
      ]);
    });
  });
}
