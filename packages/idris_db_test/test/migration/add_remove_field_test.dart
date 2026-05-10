import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'add_remove_field_test.g.dart';

@collection
@Name('Col')
class Col1 {
  Col1(this.id, this.value);

  int id;

  String? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Col1 && id == other.id && value == other.value;
}

@collection
@Name('Col')
class Col2 {
  Col2(this.id, this.value, this.newValues);

  int id;

  String? value;

  List<String>? newValues;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Col2 &&
      id == other.id &&
      value == other.value &&
      listEquals(newValues, other.newValues);
}

void main() {
  IdrisDbTest('Add field', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Col1Schema]);
    final idrisDbName = IDRISDB1.name;
    IDRISDB1.write((IdrisDb) {
      return IdrisDb.col1s.putAll([Col1(1, 'value1'), Col1(2, 'value2')]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Col2Schema], name: idrisDbName);
    expect(IDRISDB2.col2s.where().findAll(), [
      Col2(1, 'value1', null),
      Col2(2, 'value2', null),
    ]);
    IDRISDB2.write((IdrisDb) {
      return IdrisDb.col2s.putAll([
        Col2(1, 'value3', ['hi']),
        Col2(3, 'value4', []),
      ]);
    });
    expect(IDRISDB2.col2s.where().findAll(), [
      Col2(1, 'value3', ['hi']),
      Col2(2, 'value2', null),
      Col2(3, 'value4', []),
    ]);
    expect(IDRISDB2.close(), true);

    final IDRISDB3 = await openTempIDRISDB([Col1Schema], name: idrisDbName);
    expect(IDRISDB3.col1s.where().findAll(), [
      Col1(1, 'value3'),
      Col1(2, 'value2'),
      Col1(3, 'value4'),
    ]);
  });

  IdrisDbTest('Remove field', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Col2Schema]);
    final idrisDbName = IDRISDB1.name;
    IDRISDB1.write((IdrisDb) {
      return IdrisDb.col2s.putAll([
        Col2(1, 'value1', ['hi']),
        Col2(2, 'value2', ['val2', 'val22']),
      ]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Col1Schema], name: idrisDbName);
    expect(IDRISDB2.col1s.where().findAll(), [
      Col1(1, 'value1'),
      Col1(2, 'value2'),
    ]);
    IDRISDB2.write((IdrisDb) {
      return IdrisDb.col1s.put(Col1(1, 'value3'));
    });
    expect(IDRISDB2.col1s.where().findAll(), [
      Col1(1, 'value3'),
      Col1(2, 'value2'),
    ]);
  });
}
