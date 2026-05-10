// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:async';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'transaction_test.g.dart';

@collection
class Model {
  Model(this.id, [this.value]);

  int id;

  final String? value;

  @override
  bool operator ==(Object other) =>
      other is Model && id == other.id && value == other.value;
}

void main() {
  group('Transaction', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema]);
    });

    IdrisDbTest('Sync txn cannot be opened in sync txn', () {
      IdrisDb.read((IdrisDb) {
        expect(() => IdrisDb.read((_) {}), throwsUnsupportedError);
        expect(() => IdrisDb.write((_) {}), throwsUnsupportedError);
      });

      IdrisDb.write((IdrisDb) {
        expect(() => IdrisDb.read((_) {}), throwsUnsupportedError);
        expect(() => IdrisDb.write((_) {}), throwsUnsupportedError);
      });
    });

    IdrisDbTest('Asyc txn cannot be opened in sync txn', () async {
      IdrisDb.read((IdrisDb) {
        expect(() => IdrisDb.readAsync((_) {}), throwsUnsupportedError);
        expect(
          () => IdrisDb.readAsyncWith<void, void>(null, (_, _) {}),
          throwsUnsupportedError,
        );
        expect(() => IdrisDb.writeAsync((_) {}), throwsUnsupportedError);
        expect(
          () => IdrisDb.writeAsyncWith<void, void>(null, (_, _) {}),
          throwsUnsupportedError,
        );
      });

      IdrisDb.write((IdrisDb) {
        expect(() => IdrisDb.readAsync((_) {}), throwsUnsupportedError);
        expect(
          () => IdrisDb.readAsyncWith<void, void>(null, (_, _) {}),
          throwsUnsupportedError,
        );
        expect(() => IdrisDb.writeAsync((_) {}), throwsUnsupportedError);
        expect(
          () => IdrisDb.writeAsyncWith<void, void>(null, (_, _) {}),
          throwsUnsupportedError,
        );
      });
    });

    IdrisDbTest('gets reverted on error', () {
      IdrisDb.write((IdrisDb) => IdrisDb.models.put(Model(1)));
      expect(IdrisDb.models.where().findAll(), [Model(1)]);

      void errorTxn() {
        IdrisDb.write((IdrisDb) {
          IdrisDb.models.put(Model(5));
          expect(IdrisDb.models.where().findAll(), [Model(1), Model(5)]);
          throw UnsupportedError('test');
        });
      }

      expect(errorTxn, throwsUnsupportedError);
      expect(IdrisDb.models.where().findAll(), [Model(1)]);

      unawaited(expectLater(errorTxn, throwsUnsupportedError));
      expect(IdrisDb.models.where().findAll(), [Model(1)]);

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(Model(5)));
      expect(IdrisDb.models.where().findAll(), [Model(1), Model(5)]);
    });

    IdrisDbTest('Write operations require write transaction', () {
      final col = IdrisDb.models;

      expect(() => col.put(Model(4)), throwsWriteTxnError());
      expect(() => col.putAll([Model(4)]), throwsWriteTxnError());
      expect(() => col.update(id: 4, value: 'test'), throwsWriteTxnError());
      expect(() => col.updateAll(id: [4], value: 't'), throwsWriteTxnError());
      expect(() => col.delete(4), throwsWriteTxnError());
      expect(() => col.deleteAll([4]), throwsWriteTxnError());
      expect(() => col.importJson([]), throwsWriteTxnError());
      expect(() => col.importJsonString('[]'), throwsWriteTxnError());
      expect(col.clear, throwsWriteTxnError());

      expect(() => col.where().deleteFirst(), throwsWriteTxnError());
      expect(() => col.where().deleteAll(), throwsWriteTxnError());
      expect(
        () => col.where().updateFirst(value: 'test'),
        throwsWriteTxnError(),
      );
      expect(() => col.where().updateAll(value: 'test'), throwsWriteTxnError());
    });

    IdrisDbTest('Query updateProperties requires write transaction', () {
      IdrisDb.write((IdrisDb) => IdrisDb.models.put(Model(1, 'test')));
      expect(
        () => IdrisDb.models.where().updateAll(value: 'new'),
        throwsWriteTxnError(),
      );
    });

    IdrisDbTest('Query deleteAll requires write transaction', () {
      IdrisDb.write((IdrisDb) => IdrisDb.models.put(Model(1, 'test')));
      final query = IdrisDb.models.where().build();
      expect(query.deleteAll, throwsWriteTxnError());
      query.close();
    });
  });
}
