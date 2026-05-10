import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'add_remove_collection_test.g.dart';

@collection
class Model1 {
  Model1(this.id, this.value);

  int id;

  @Index()
  String? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Model1 && id == other.id && value == other.value;
}

@collection
class Model2 {
  Model2(this.id, this.value);

  int id;

  @Index()
  String? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Model2 && id == other.id && value == other.value;
}

void main() {
  IdrisDbTest('Add collection', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Model1Schema]);
    final idrisDbName = IDRISDB1.name;
    final obj1A = Model1(5, 'col1_a');
    final obj1B = Model1(15, 'col1_b');
    IDRISDB1.write((IdrisDb) {
      return IdrisDb.model1s.putAll([obj1A, obj1B]);
    });
    IDRISDB1.model1s.verify([obj1A, obj1B]);
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([
      Model1Schema,
      Model2Schema,
    ], name: idrisDbName);
    IDRISDB2.model1s.verify([obj1A, obj1B]);
    IDRISDB2.model2s.verify([]);
    final obj2 = Model2(99, 'col2_a');
    IDRISDB2.write((IdrisDb) {
      return IdrisDb.model2s.put(obj2);
    });
    IDRISDB2.model2s.verify([obj2]);
  });

  IdrisDbTest('Remove collection', web: false, () async {
    final IDRISDB1 = await openTempIDRISDB([Model1Schema, Model2Schema]);
    final idrisDbName = IDRISDB1.name;
    final obj1A = Model1(1, 'col1_a');
    final obj1B = Model1(2, 'col1_b');
    final obj2A = Model2(3, 'col2_a');
    final obj2B = Model2(4, 'col2_a');
    IDRISDB1.write((IdrisDb) {
      IdrisDb.model1s.putAll([obj1A, obj1B]);
      IdrisDb.model2s.putAll([obj2A, obj2B]);
    });
    IDRISDB1.model1s.verify([obj1A, obj1B]);
    IDRISDB1.model2s.verify([obj2A, obj2B]);
    expect(IDRISDB1.close(), true);

    final IDRISDB2 = await openTempIDRISDB([Model1Schema], name: idrisDbName);
    IDRISDB2.model1s.verify([obj1A, obj1B]);
    expect(IDRISDB2.close(), true);

    final IDRISDB3 = await openTempIDRISDB([
      Model1Schema,
      Model2Schema,
    ], name: idrisDbName);
    IDRISDB3.model1s.verify([obj1A, obj1B]);
    IDRISDB3.model2s.verify([]);
  });
}
