import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'filter_byte_list_test.g.dart';

@collection
class ByteModel {
  ByteModel(this.id, this.list);

  final int id;

  final List<byte>? list;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is ByteModel && other.id == id && listEquals(list, other.list);
  }
}

void main() {
  group('Byte list filter', () {
    late IdrisDb IdrisDb;
    late IdrisDbCollection<int, ByteModel> col;

    late ByteModel objEmpty;
    late ByteModel obj1;
    late ByteModel obj2;
    late ByteModel obj3;
    late ByteModel obj4;
    late ByteModel objNull;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ByteModelSchema]);
      col = IdrisDb.byteModels;

      objEmpty = ByteModel(0, []);
      obj1 = ByteModel(1, [123]);
      obj2 = ByteModel(2, [0, 255]);
      obj3 = ByteModel(3, [1, 123, 3]);
      obj4 = ByteModel(4, [0, 255]);
      objNull = ByteModel(5, null);

      IdrisDb.write((IdrisDb) {
        col.putAll([objEmpty, obj1, obj2, obj3, obj4, objNull]);
      });
    });

    IdrisDbTest('.elementEqualTo()', () {
      expect(col.where().listElementEqualTo(0).findAll(), [obj2, obj4]);
      expect(col.where().listElementEqualTo(1).findAll(), [obj3]);
      expect(col.where().listElementEqualTo(55).findAll(), isEmpty);
    });

    IdrisDbTest('.elementGreaterThan()', () {
      expect(col.where().listElementGreaterThan(123).findAll(), [obj2, obj4]);
      expect(col.where().listElementGreaterThan(255).findAll(), isEmpty);
    });

    IdrisDbTest('.elementGreaterThanOrEqualTo()', () {
      expect(col.where().listElementGreaterThanOrEqualTo(123).findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
      ]);
    });

    IdrisDbTest('.elementLessThan()', () {
      expect(col.where().listElementLessThan(123).findAll(), [
        obj2,
        obj3,
        obj4,
      ]);
      expect(col.where().listElementLessThan(0).findAll(), isEmpty);
    });

    IdrisDbTest('.elementLessThanOrEqualTo()', () {
      expect(col.where().listElementLessThanOrEqualTo(123).findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
      ]);
    });

    IdrisDbTest('.elementBetween()', () {
      expect(col.where().listElementBetween(123, 255).findAll(), [
        obj1,
        obj2,
        obj3,
        obj4,
      ]);
      expect(col.where().listElementBetween(50, 100).findAll(), isEmpty);
    });

    IdrisDbTest('.isNull()', () {
      expect(col.where().listIsNull().findAll(), [objNull]);
    });
  });
}
