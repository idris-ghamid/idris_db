import 'dart:math';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'filter_bool_test.g.dart';

@collection
class BoolModel {
  BoolModel(this.field);

  int id = Random().nextInt(99999);

  bool? field;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is BoolModel && other.id == id && other.field == field;
  }
}

void main() {
  group('Bool filter', () {
    late IdrisDb IdrisDb;
    late IdrisDbCollection<int, BoolModel> col;

    late BoolModel objNull;
    late BoolModel objFalse;
    late BoolModel objTrue;
    late BoolModel objFalse2;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([BoolModelSchema]);
      col = IdrisDb.boolModels;

      objNull = BoolModel(null);
      objFalse = BoolModel(false);
      objTrue = BoolModel(true);
      objFalse2 = BoolModel(false);

      IdrisDb.write((IdrisDb) {
        col.putAll([objNull, objFalse, objTrue, objFalse2]);
      });
    });

    IdrisDbTest('.equalTo()', () {
      expect(col.where().fieldEqualTo(true).findAll(), [objTrue]);
      expect(col.where().fieldEqualTo(false).findAll().toSet(), {
        objFalse,
        objFalse2,
      });
      expect(col.where().fieldEqualTo(null).findAll(), [objNull]);
    });

    IdrisDbTest('.isNull()', () {
      expect(col.where().fieldIsNull().findAll(), [objNull]);
    });

    IdrisDbTest('.isNotNull()', () {
      expect(col.where().fieldIsNotNull().findAll().toSet(), {
        objFalse,
        objTrue,
        objFalse2,
      });
    });
  });
}
