// ignore_for_file: avoid_redundant_argument_values

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'update_test.g.dart';

@collection
class Model {
  Model({
    required this.id,
    required this.boolProp,
    required this.nullableBoolProp,
    required this.byteProp,
    required this.shortProp,
    required this.longProp,
    required this.floatProp,
    required this.doubleProp,
    required this.stringProp,
    required this.nullableStringProp,
    required this.dateProp,
  });

  final int id;

  final bool boolProp;

  final bool? nullableBoolProp;

  final byte byteProp;

  final short shortProp;

  final int longProp;

  final float floatProp;

  final double doubleProp;

  final String stringProp;

  final String? nullableStringProp;

  final DateTime dateProp;

  Model copyWith({
    int? id,
    bool? boolProp,
    bool? nullableBoolProp,
    byte? byteProp,
    short? shortProp,
    int? longProp,
    float? floatProp,
    double? doubleProp,
    String? stringProp,
    String? nullableStringProp,
    DateTime? dateProp,
  }) {
    return Model(
      id: id ?? this.id,
      boolProp: boolProp ?? this.boolProp,
      nullableBoolProp: nullableBoolProp ?? this.nullableBoolProp,
      byteProp: byteProp ?? this.byteProp,
      shortProp: shortProp ?? this.shortProp,
      longProp: longProp ?? this.longProp,
      floatProp: floatProp ?? this.floatProp,
      doubleProp: doubleProp ?? this.doubleProp,
      stringProp: stringProp ?? this.stringProp,
      nullableStringProp: nullableStringProp ?? this.nullableStringProp,
      dateProp: dateProp ?? this.dateProp,
    );
  }

  // Helper for tests to set nullable fields to null
  Model copyWithNull({
    bool nullableBoolProp = false,
    bool nullableStringProp = false,
  }) {
    return Model(
      id: id,
      boolProp: boolProp,
      nullableBoolProp: nullableBoolProp ? null : this.nullableBoolProp,
      byteProp: byteProp,
      shortProp: shortProp,
      longProp: longProp,
      floatProp: floatProp,
      doubleProp: doubleProp,
      stringProp: stringProp,
      nullableStringProp: nullableStringProp ? null : this.nullableStringProp,
      dateProp: dateProp,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Model &&
      other.id == id &&
      other.boolProp == boolProp &&
      other.nullableBoolProp == nullableBoolProp &&
      other.byteProp == byteProp &&
      other.shortProp == shortProp &&
      other.longProp == longProp &&
      other.floatProp == floatProp &&
      other.doubleProp == doubleProp &&
      other.stringProp == stringProp &&
      other.nullableStringProp == nullableStringProp &&
      other.dateProp == dateProp;
}

void main() {
  group('Update', () {
    late IdrisDb IdrisDb;
    late Model model;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema]);

      model = Model(
        id: 12,
        boolProp: true,
        nullableBoolProp: false,
        byteProp: 1,
        shortProp: 2,
        longProp: 3,
        floatProp: 4,
        doubleProp: 5,
        stringProp: 'hello',
        nullableStringProp: 'world',
        dateProp: DateTime.fromMillisecondsSinceEpoch(
          200,
          isUtc: true,
        ).toLocal(),
      );
      IdrisDb.write((IdrisDb) => IdrisDb.models.put(model));
    });

    group('update()', () {
      IdrisDbTest('bool change', () {
        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, boolProp: false), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(boolProp: false));
      });

      IdrisDbTest('bool change to null', () {
        IdrisDb.write((IdrisDb) {
          expect(
            IdrisDb.models.update(id: model.id, nullableBoolProp: null),
            true,
          );
        });
        expect(
          IdrisDb.models.get(model.id),
          model.copyWithNull(nullableBoolProp: true),
        );
      });

      IdrisDbTest('byte change', () {
        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, byteProp: 2), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(byteProp: 2));
      });

      IdrisDbTest('short change', () {
        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, shortProp: 3), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(shortProp: 3));
      });

      IdrisDbTest('long change', () {
        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, longProp: 4), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(longProp: 4));
      });

      IdrisDbTest('float change', () {
        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, floatProp: 5), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(floatProp: 5));
      });

      IdrisDbTest('double change', () {
        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, doubleProp: 6), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(doubleProp: 6));
      });

      IdrisDbTest('string change', () {
        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, stringProp: 'world'), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(stringProp: 'world'));

        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, stringProp: ''), true);
        });
        expect(IdrisDb.models.get(model.id), model.copyWith(stringProp: ''));

        IdrisDb.write((IdrisDb) {
          expect(IdrisDb.models.update(id: model.id, stringProp: 'loooong'), true);
        });
        expect(
          IdrisDb.models.get(model.id),
          model.copyWith(stringProp: 'loooong'),
        );
      });

      IdrisDbTest('nullable string change', () {
        IdrisDb.write((IdrisDb) {
          expect(
            IdrisDb.models.update(id: model.id, nullableStringProp: null),
            true,
          );
        });
        expect(
          IdrisDb.models.get(model.id),
          model.copyWithNull(nullableStringProp: true),
        );

        IdrisDb.write((IdrisDb) {
          expect(
            IdrisDb.models.update(id: model.id, nullableStringProp: 'testaaaa'),
            true,
          );
        });
        expect(
          IdrisDb.models.get(model.id),
          model.copyWith(nullableStringProp: 'testaaaa'),
        );
      });

      IdrisDbTest('date change', () {
        IdrisDb.write((IdrisDb) {
          expect(
            IdrisDb.models.update(
              id: model.id,
              dateProp: DateTime.fromMillisecondsSinceEpoch(300, isUtc: true),
            ),
            true,
          );
        });

        expect(
          IdrisDb.models.get(model.id),
          model.copyWith(
            dateProp: DateTime.fromMillisecondsSinceEpoch(
              300,
              isUtc: true,
            ).toLocal(),
          ),
        );
      });
    });
    group('query updateProperties()', () {
      IdrisDbTest('updates matching documents', () {
        final count = IdrisDb.write(
          (IdrisDb) =>
              IdrisDb.models.where().longPropEqualTo(3).updateAll(longProp: 999),
        );
        expect(count, 1);
        expect(IdrisDb.models.get(model.id)?.longProp, 999);
      });

      IdrisDbTest('returns 0 when no match', () {
        final count = IdrisDb.write(
          (IdrisDb) => IdrisDb.models
              .where()
              .longPropEqualTo(9999)
              .updateAll(longProp: 100),
        );
        expect(count, 0);
      });
    });
  });
}
