import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'multi_filter_test.g.dart';

@collection
class Model {
  Model(this.id, this.value);

  final int id;

  @Index()
  final int value;

  @override
  bool operator ==(Object other) => other is Model && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

void main() {
  group('Multi filters', () {
    late IdrisDb IdrisDb;

    late Model model0;
    late Model model1;
    late Model model2;
    late Model model3;

    setUp(() async {
      model0 = Model(0, 0);
      model1 = Model(1, 1);
      model2 = Model(2, 2);
      model3 = Model(3, 3);

      IdrisDb = await openTempIDRISDB([ModelSchema]);
      IdrisDb.write((IdrisDb) {
        return IdrisDb.models.putAll([model0, model1, model2, model3]);
      });
    });

    group('where anyOf', () {
      IdrisDbTest('zero elements', () {
        final q = IdrisDb.models.where().anyOf(
          <int>[],
          (q, element) => q.valueEqualTo(element),
        );
        expect(q.findAll(), [model0, model1, model2, model3]);
      });

      IdrisDbTest('one matching element', () {
        final q = IdrisDb.models.where().anyOf([
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model2]);
      });

      IdrisDbTest('two matching elements', () {
        final q = IdrisDb.models.where().anyOf([
          0,
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model0, model2]);
      });

      IdrisDbTest('one non-matching element', () {
        final q = IdrisDb.models.where().anyOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), isEmpty);
      });

      IdrisDbTest('one matching and one non-matching elements', () {
        final q = IdrisDb.models.where().anyOf([
          7,
          3,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model3]);
      });

      IdrisDbTest('one non-matching element', () {
        final q = IdrisDb.models.where().anyOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), isEmpty);
      });
    });

    group('filter anyOf', () {
      IdrisDbTest('zero elements', () {
        final q = IdrisDb.models.where().anyOf(
          <int>[],
          (q, element) => q.valueEqualTo(element),
        );
        expect(q.findAll(), [model0, model1, model2, model3]);

        final notQ = IdrisDb.models.where().not().anyOf(
          <int>[],
          (q, element) => q.valueEqualTo(element),
        );
        expect(notQ.findAll(), [model0, model1, model2, model3]);
      });

      IdrisDbTest('one matching element', () {
        final q = IdrisDb.models.where().anyOf([
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model2]);

        final notQ = IdrisDb.models.where().not().anyOf([
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model3]);
      });

      IdrisDbTest('two matching elements', () {
        final q = IdrisDb.models.where().anyOf([
          0,
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model0, model2]);

        final notQ = IdrisDb.models.where().not().anyOf([
          0,
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model1, model3]);
      });

      IdrisDbTest('one non-matching element', () {
        final q = IdrisDb.models.where().anyOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), isEmpty);

        final notQ = IdrisDb.models.where().not().anyOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model2, model3]);
      });

      IdrisDbTest('one matching and one non-matching elements', () {
        final q = IdrisDb.models.where().anyOf([
          7,
          3,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model3]);

        final notQ = IdrisDb.models.where().not().anyOf([
          7,
          3,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model2]);
      });

      IdrisDbTest('one non-matching element', () {
        final q = IdrisDb.models.where().anyOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), isEmpty);

        final notQ = IdrisDb.models.where().not().anyOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model2, model3]);
      });
    });

    group('filter allOf', () {
      IdrisDbTest('zero elements', () {
        final q = IdrisDb.models.where().allOf(
          <int>[],
          (q, element) => q.valueEqualTo(element),
        );
        expect(q.findAll(), [model0, model1, model2, model3]);

        final notQ = IdrisDb.models.where().not().allOf(
          <int>[],
          (q, element) => q.valueEqualTo(element),
        );
        expect(notQ.findAll(), [model0, model1, model2, model3]);
      });

      IdrisDbTest('one matching element', () {
        final q = IdrisDb.models.where().allOf([
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model2]);

        final notQ = IdrisDb.models.where().not().allOf([
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model3]);
      });

      IdrisDbTest('two matching elements', () {
        final q = IdrisDb.models.where().allOf([
          2,
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), [model2]);

        final notQ = IdrisDb.models.where().not().allOf([
          2,
          2,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model3]);
      });

      IdrisDbTest('one non-matching element', () {
        final q = IdrisDb.models.where().allOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), isEmpty);

        final notQ = IdrisDb.models.where().not().allOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model2, model3]);
      });

      IdrisDbTest('one matching and one non-matching elements', () {
        final q = IdrisDb.models.where().allOf([
          7,
          3,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), isEmpty);

        final notQ = IdrisDb.models.where().not().allOf([
          7,
          3,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model2, model3]);
      });

      IdrisDbTest('one non-matching element', () {
        final q = IdrisDb.models.where().allOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(q.findAll(), isEmpty);

        final notQ = IdrisDb.models.where().not().allOf([
          5,
        ], (q, element) => q.valueEqualTo(element));
        expect(notQ.findAll(), [model0, model1, model2, model3]);
      });
    });
  });
}
