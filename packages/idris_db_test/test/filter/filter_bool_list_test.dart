import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'filter_bool_list_test.g.dart';

@collection
class BoolModel {
  BoolModel(this.id, this.list);

  final int id;

  final List<bool?>? list;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is BoolModel && other.id == id && listEquals(list, other.list);
  }
}

void main() {
  group('Bool list filter', () {
    late IdrisDb IdrisDb;
    late IdrisDbCollection<int, BoolModel> col;

    late BoolModel objEmpty;
    late BoolModel obj1;
    late BoolModel obj2;
    late BoolModel obj3;
    late BoolModel obj4;
    late BoolModel objNull;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([BoolModelSchema]);
      col = IdrisDb.boolModels;

      objEmpty = BoolModel(0, []);
      obj1 = BoolModel(1, [true]);
      obj2 = BoolModel(2, [null, false]);
      obj3 = BoolModel(3, [true, false, true]);
      obj4 = BoolModel(4, [null]);
      objNull = BoolModel(5, null);

      IdrisDb.write((IdrisDb) {
        col.putAll([objEmpty, obj1, obj2, obj3, obj4, objNull]);
      });
    });

    IdrisDbTest('.elementEqualTo()', () {
      expect(col.where().listElementEqualTo(true).findAll(), [obj1, obj3]);
      expect(col.where().listElementEqualTo(null).findAll(), [obj2, obj4]);
      expect(col.where().listElementEqualTo(false).findAll(), [obj2, obj3]);
    });

    IdrisDbTest('.elementIsNull()', () {
      expect(col.where().listElementIsNull().findAll(), [obj2, obj4]);
    });

    IdrisDbTest('.elementIsNotNull()', () {
      expect(col.where().listElementIsNotNull().findAll(), [obj1, obj2, obj3]);
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
        obj4,
      ]);
    });
  });
}
