import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'add_remove_embedded_field_test.g.dart';

@collection
@Name('Col')
class Col1 {
  Col1(this.id, this.value);

  int id;

  Embedded1? value;

  @override
  bool operator ==(Object other) =>
      other is Col1 && id == other.id && value == other.value;
}

@embedded
@Name('Embedded')
class Embedded1 {
  Embedded1([this.value]);

  String? value;

  @override
  bool operator ==(Object other) => other is Embedded1 && value == other.value;
}

@collection
@Name('Col')
class Col2 {
  Col2(this.id, this.value);

  int id;

  Embedded2? value;

  @override
  bool operator ==(Object other) =>
      other is Col2 && id == other.id && value == other.value;
}

@embedded
@Name('Embedded')
class Embedded2 {
  Embedded2([this.newValue, this.value]);

  int? newValue;

  String? value;

  @override
  bool operator ==(Object other) =>
      other is Embedded2 && value == other.value && newValue == other.newValue;
}

void main() {
  IdrisDbTest('Add field', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Col1Schema]);
    final idrisDbName = IDRISDB1.name;
    IDRISDB1.write((IdrisDb) {
      return IdrisDb.col1s.putAll([
        Col1(1, Embedded1('value1')),
        Col1(2, Embedded1('value2')),
      ]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Col2Schema], name: idrisDbName);
    IDRISDB2.col2s.verify([
      Col2(1, Embedded2(null, 'value1')),
      Col2(2, Embedded2(null, 'value2')),
    ]);
    IDRISDB2.write((IdrisDb) {
      return IdrisDb.col2s.putAll([
        Col2(1, Embedded2(1, 'value4')),
        Col2(3, Embedded2(3, 'value5')),
      ]);
    });
    IDRISDB2.col2s.verify([
      Col2(1, Embedded2(1, 'value4')),
      Col2(2, Embedded2(null, 'value2')),
      Col2(3, Embedded2(3, 'value5')),
    ]);
    expect(IDRISDB2.close(), true);

    final IDRISDB3 = await openTempIDRISDB([Col1Schema], name: idrisDbName);
    IDRISDB3.col1s.verify([
      Col1(1, Embedded1('value4')),
      Col1(2, Embedded1('value2')),
      Col1(3, Embedded1('value5')),
    ]);
    expect(IDRISDB3.close(), true);
  });

  IdrisDbTest('Remove field', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Col2Schema]);
    final idrisDbName = IDRISDB1.name;
    IDRISDB1.write((IdrisDb) {
      return IdrisDb.col2s.putAll([
        Col2(1, Embedded2(1, 'value1')),
        Col2(2, Embedded2(2, 'value2')),
      ]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Col1Schema], name: idrisDbName);
    IDRISDB2.col1s.verify([
      Col1(1, Embedded1('value1')),
      Col1(2, Embedded1('value2')),
    ]);
    IDRISDB2.write((IdrisDb) {
      return IdrisDb.col1s.put(Col1(1, Embedded1('value3')));
    });
    IDRISDB2.col1s.verify([
      Col1(1, Embedded1('value3')),
      Col1(2, Embedded1('value2')),
    ]);
    expect(IDRISDB2.close(), true);
  });
}
