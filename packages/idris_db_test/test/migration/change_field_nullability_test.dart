import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'change_field_nullability_test.g.dart';

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
  Col2(this.id, this.value);

  int id;

  late String value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Col2 && id == other.id && value == other.value;
}

void main() {
  IdrisDbTest('Change field nullability', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Col1Schema]);
    final idrisDbName = IDRISDB1.name;
    IDRISDB1.write((IdrisDb) {
      return IDRISDB1.col1s.putAll([Col1(1, 'a'), Col1(2, null)]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Col2Schema], name: idrisDbName);
    expect(IDRISDB2.col2s.where().findAll(), [Col2(1, 'a'), Col2(2, '')]);
    IDRISDB2.write((IdrisDb) {
      return IDRISDB2.col2s.put(Col2(1, 'c'));
    });
    expect(IDRISDB2.close(), true);

    final IDRISDB3 = await openTempIDRISDB([Col1Schema], name: idrisDbName);
    expect(IDRISDB3.col1s.where().findAll(), [Col1(1, 'c'), Col1(2, null)]);
  });
}
