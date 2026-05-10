import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'add_remove_index_test.g.dart';

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

  @Index(unique: true)
  String? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Col2 && id == other.id && value == other.value;
}

void main() {
  IdrisDbTest('Add remove index', () async {
    final IDRISDB1 = await openTempIDRISDB([Col1Schema]);
    final idrisDbName = IDRISDB1.name;
    IDRISDB1.write((IdrisDb) {
      return IdrisDb.col1s.putAll([Col1(1, 'a'), Col1(2, 'b')]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Col2Schema], name: idrisDbName);
    expect(IDRISDB2.col2s.where().findAll(), [Col2(1, 'a'), Col2(2, 'b')]);
    expect(IDRISDB2.col2s.where().valueEqualTo('a').findAll(), [Col2(1, 'a')]);
    IDRISDB2.write((IdrisDb) {
      return IDRISDB2.col2s.putAll([Col2(1, 'c'), Col2(3, 'd')]);
    });
    expect(IDRISDB2.close(), true);

    final IDRISDB3 = await openTempIDRISDB([Col1Schema], name: idrisDbName);
    expect(IDRISDB3.col1s.where().findAll(), [
      Col1(1, 'c'),
      Col1(2, 'b'),
      Col1(3, 'd'),
    ]);
  });
}
