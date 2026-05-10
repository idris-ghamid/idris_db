// ignore_for_file: non_nullable_equals_parameter

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'crud_test.g.dart';

@collection
class IntModel {
  IntModel(this.id, this.value);

  final int id;

  final String value;

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) {
    if (other is IntModel) {
      return other.id == id && other.value == value;
    } else {
      return false;
    }
  }
}

@collection
class StringModel {
  StringModel(this.id);

  final String id;

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) {
    if (other is StringModel) {
      return other.id == id;
    } else {
      return false;
    }
  }
}

void main() {
  group('CRUD', () {
    final intM1 = IntModel(1, 'This is a new model');
    final intM2 = IntModel(2, 'This is another new model');
    final intM3 = IntModel(3, 'Yet another one');
    final strM1 = StringModel('M1');
    final strM2 = StringModel('M2');
    final strM3 = StringModel('M3');
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([IntModelSchema, StringModelSchema]);
    });

    group('int id', () {
      IdrisDbTest('get()', () {
        expect(IdrisDb.intModels.get(intM1.id), null);
        expect(IdrisDb.intModels.get(intM2.id), null);

        IdrisDb.write((IdrisDb) {
          IdrisDb.intModels.put(intM1);
          expect(IdrisDb.intModels.get(intM1.id), intM1);
          expect(IdrisDb.intModels.get(intM2.id), null);

          IdrisDb.intModels.put(intM2);
          expect(IdrisDb.intModels.get(intM1.id), intM1);
          expect(IdrisDb.intModels.get(intM2.id), intM2);
        });

        expect(IdrisDb.intModels.get(intM1.id), intM1);
        expect(IdrisDb.intModels.get(intM2.id), intM2);
      });

      IdrisDbTest('put()', () {
        expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
          null,
          null,
          null,
        ]);

        IdrisDb.write((IdrisDb) {
          IdrisDb.intModels.put(intM1);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            null,
            null,
          ]);

          IdrisDb.intModels.put(intM3);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            null,
            intM3,
          ]);

          IdrisDb.intModels.put(intM2);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            intM2,
            intM3,
          ]);
        });

        expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
          intM1,
          intM2,
          intM3,
        ]);
      });

      IdrisDbTest('getAll()', () {
        expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
          null,
          null,
          null,
        ]);

        IdrisDb.write((IdrisDb) {
          IdrisDb.intModels.put(intM1);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            null,
            null,
          ]);

          IdrisDb.intModels.put(intM3);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            null,
            intM3,
          ]);
        });

        expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
          intM1,
          null,
          intM3,
        ]);
      });

      IdrisDbTest('putAll()', () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.intModels.putAll([intM1, intM3, intM1]);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            null,
            intM3,
          ]);

          IdrisDb.intModels.putAll([intM2, intM2]);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            intM2,
            intM3,
          ]);

          IdrisDb.intModels.putAll([]);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            intM1,
            intM2,
            intM3,
          ]);
        });

        expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
          intM1,
          intM2,
          intM3,
        ]);
      });

      IdrisDbTest('delete()', () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.intModels.putAll([intM1, intM2]);
          expect(IdrisDb.intModels.delete(intM2.id), true);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id]), [intM1, null]);

          expect(IdrisDb.intModels.delete(intM2.id), false);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id]), [intM1, null]);
        });

        expect(IdrisDb.intModels.getAll([intM1.id, intM2.id]), [intM1, null]);
      });

      IdrisDbTest('deleteAll()', () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.intModels.putAll([intM1, intM2, intM3]);
          expect(IdrisDb.intModels.deleteAll([intM1.id, intM3.id]), 2);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            null,
            intM2,
            null,
          ]);

          expect(IdrisDb.intModels.deleteAll([intM1.id, intM2.id]), 1);
          expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
            null,
            null,
            null,
          ]);
        });

        expect(IdrisDb.intModels.getAll([intM1.id, intM2.id, intM3.id]), [
          null,
          null,
          null,
        ]);
      });
    });

    group('String id', () {
      IdrisDbTest('get()', () {
        expect(IdrisDb.stringModels.get(strM1.id), null);
        expect(IdrisDb.stringModels.get(strM2.id), null);

        IdrisDb.write((IdrisDb) {
          IdrisDb.stringModels.put(strM1);
          expect(IdrisDb.stringModels.get(strM1.id), strM1);
          expect(IdrisDb.stringModels.get(strM2.id), null);

          IdrisDb.stringModels.put(strM2);
          expect(IdrisDb.stringModels.get(strM1.id), strM1);
          expect(IdrisDb.stringModels.get(strM2.id), strM2);
        });

        expect(IdrisDb.stringModels.get(strM1.id), strM1);
        expect(IdrisDb.stringModels.get(strM2.id), strM2);
      });

      IdrisDbTest('put()', () {
        expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id]), [null, null]);

        IdrisDb.write((IdrisDb) {
          IdrisDb.stringModels.put(strM1);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id]), [strM1, null]);

          IdrisDb.stringModels.put(strM2);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id]), [
            strM1,
            strM2,
          ]);
        });

        expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id]), [strM1, strM2]);
      });

      IdrisDbTest('getAll()', () {
        expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
          null,
          null,
          null,
        ]);

        IdrisDb.write((IdrisDb) {
          IdrisDb.stringModels.put(strM1);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
            strM1,
            null,
            null,
          ]);

          IdrisDb.stringModels.put(strM3);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
            strM1,
            null,
            strM3,
          ]);
        });

        expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
          strM1,
          null,
          strM3,
        ]);
      });

      IdrisDbTest('putAll()', () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.stringModels.putAll([strM1, strM3, strM1]);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
            strM1,
            null,
            strM3,
          ]);

          IdrisDb.stringModels.putAll([strM2, strM2]);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
            strM1,
            strM2,
            strM3,
          ]);

          IdrisDb.stringModels.putAll([]);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
            strM1,
            strM2,
            strM3,
          ]);
        });

        expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
          strM1,
          strM2,
          strM3,
        ]);
      });

      IdrisDbTest('delete()', () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.stringModels.putAll([strM1, strM2]);
          expect(IdrisDb.stringModels.delete(strM2.id), true);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id]), [strM1, null]);

          expect(IdrisDb.stringModels.delete(strM2.id), false);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id]), [strM1, null]);
        });

        expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id]), [strM1, null]);
      });

      IdrisDbTest('deleteAll()', () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.stringModels.putAll([strM1, strM2, strM3]);
          expect(IdrisDb.stringModels.deleteAll([strM1.id, strM3.id]), 2);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
            null,
            strM2,
            null,
          ]);

          expect(IdrisDb.stringModels.deleteAll([strM1.id, strM2.id]), 1);
          expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
            null,
            null,
            null,
          ]);
        });

        expect(IdrisDb.stringModels.getAll([strM1.id, strM2.id, strM3.id]), [
          null,
          null,
          null,
        ]);
      });
    });

    IdrisDbTest('count()', () {
      expect(IdrisDb.intModels.count(), 0);
      expect(IdrisDb.stringModels.count(), 0);

      IdrisDb.write((IdrisDb) {
        IdrisDb.intModels.put(intM1);
        expect(IdrisDb.intModels.count(), 1);
        expect(IdrisDb.stringModels.count(), 0);

        IdrisDb.stringModels.put(strM1);
        expect(IdrisDb.intModels.count(), 1);
        expect(IdrisDb.stringModels.count(), 1);

        IdrisDb.intModels.put(intM2);
        expect(IdrisDb.intModels.count(), 2);
        expect(IdrisDb.stringModels.count(), 1);

        IdrisDb.stringModels.put(strM2);
        expect(IdrisDb.intModels.count(), 2);
        expect(IdrisDb.stringModels.count(), 2);
      });

      expect(IdrisDb.intModels.count(), 2);
      expect(IdrisDb.stringModels.count(), 2);
    });

    IdrisDbTest('clear()', () {
      IdrisDb.write((IdrisDb) {
        IdrisDb.intModels.putAll([intM1, intM2]);
        IdrisDb.stringModels.putAll([strM1, strM2]);
        expect(IdrisDb.intModels.count(), 2);
        expect(IdrisDb.stringModels.count(), 2);

        IdrisDb.intModels.clear();
        expect(IdrisDb.intModels.count(), 0);
        expect(IdrisDb.stringModels.count(), 2);

        IdrisDb.intModels.putAll([intM1, intM2]);
        IdrisDb.stringModels.clear();
        expect(IdrisDb.intModels.count(), 2);
        expect(IdrisDb.stringModels.count(), 0);
      });

      expect(IdrisDb.intModels.count(), 2);
      expect(IdrisDb.stringModels.count(), 0);
    });

    IdrisDbTest('Accessing closed query throws StateError', () {
      final query = IdrisDb.intModels.where().build();
      query.close();

      expect(query.findAll, throwsStateError);
    });

    IdrisDbTest('collection() throws for unregistered type', () {
      expect(() => IdrisDb.collection<String, IntModel>(), throwsArgumentError);
    });

    IdrisDbTest('collectionByIndex() returns correct collection', () {
      // ignore: experimental_member_use
      final col0 = IdrisDb.collectionByIndex<int, IntModel>(0);
      expect(col0, isNotNull);
      expect(col0.schema.name, 'IntModel');

      // ignore: experimental_member_use
      final col1 = IdrisDb.collectionByIndex<String, StringModel>(1);
      expect(col1, isNotNull);
      expect(col1.schema.name, 'StringModel');
    });

    IdrisDbTest('collectionByIndex() throws for wrong type params', () {
      expect(
        // ignore: experimental_member_use
        () => IdrisDb.collectionByIndex<String, StringModel>(0),
        throwsArgumentError,
      );
    });
  });
}
