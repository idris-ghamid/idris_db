import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'change_field_embedded_test.g.dart';

@collection
@Name('Col')
class Model1 {
  Model1(this.id, this.value);

  int id;

  Embedded1? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Model1 && other.id == id && other.value == value;
}

@collection
@Name('Col')
class Model2 {
  Model2(this.id, this.value);

  int id;

  Embedded2? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Model2 && other.id == id && other.value == value;
}

@embedded
class Embedded1 {
  Embedded1([this.value]);

  String? value;
}

@embedded
class Embedded2 {
  Embedded2([this.value]);

  String? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) => other is Embedded2 && other.value == value;
}

void main() {
  IdrisDbTest('Change field embedded', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Model1Schema]);
    final idrisDbName = IDRISDB1.name;
    IDRISDB1.write((IdrisDb) {
      return IDRISDB1.model1s.putAll([
        Model1(1, Embedded1('a')),
        Model1(2, Embedded1('b')),
      ]);
    });
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Model2Schema], name: idrisDbName);
    expect(IDRISDB2.model2s.where().findAll(), [Model2(1, null), Model2(2, null)]);
    IDRISDB2.write((IdrisDb) {
      return IDRISDB2.model2s.put(Model2(1, Embedded2('abc')));
    });
    expect(IDRISDB2.close(), true);

    final IDRISDB3 = await openTempIDRISDB([Model1Schema], name: idrisDbName);
    expect(IDRISDB3.model1s.where().findAll(), [Model1(1, null), Model1(2, null)]);
  });
}
