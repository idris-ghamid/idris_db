import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'change_field_type_test.g.dart';

@collection
@Name('Col')
class Model1 {
  Model1(this.id, this.value, this.str);

  int id;

  String? value;

  String str;

  @override
  bool operator ==(Object other) =>
      other is Model1 &&
      id == other.id &&
      value == other.value &&
      str == other.str;

  @override
  int get hashCode => Object.hash(id, value, str);
}

@collection
@Name('Col')
class Model2 {
  Model2(this.id, this.value, this.str);

  int id;

  int? value;
  String str;

  @override
  bool operator ==(Object other) =>
      other is Model2 &&
      id == other.id &&
      value == other.value &&
      str == other.str;

  @override
  int get hashCode => Object.hash(id, value, str);
}

void main() {
  IdrisDbTest('Change field type', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Model1Schema]);
    final idrisDbName = IDRISDB1.name;
    final obj1A = Model1(1, 'a', 'OBJ1');
    final obj1B = Model1(2, 'bbb', 'OBJ2');
    IDRISDB1.write((IdrisDb) {
      return IdrisDb.model1s.putAll([obj1A, obj1B]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Model2Schema], name: idrisDbName);
    final obj2A = Model2(1, null, 'OBJ1');
    final obj2B = Model2(2, null, 'OBJ2');
    IDRISDB2.model2s.verify([obj2A, obj2B]);
    final obj2C = Model2(1, 123, 'OBJ3');
    IDRISDB2.write((IdrisDb) {
      return IdrisDb.model2s.put(obj2C);
    });
    IDRISDB2.model2s.verify([obj2C, obj2B]);
  });
}
