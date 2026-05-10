import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'filter_string_list_test.g.dart';

@collection
class StringModel {
  StringModel({
    required this.id,
    required this.strings,
    required this.nullableStrings,
    required this.stringsNullable,
    required this.nullableStringsNullable,
  });

  final int id;

  final List<String> strings;
  final List<String?> nullableStrings;
  final List<String>? stringsNullable;
  final List<String?>? nullableStringsNullable;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listEquals(strings, other.strings) &&
          listEquals(nullableStrings, other.nullableStrings) &&
          listEquals(stringsNullable, other.stringsNullable) &&
          listEquals(nullableStringsNullable, other.nullableStringsNullable);

  @override
  String toString() {
    return '''StringModel{id: $id, strings: $strings, nullableStrings: $nullableStrings, stringsNullable: $stringsNullable, nullableStringsNullable: $nullableStringsNullable}''';
  }
}

void main() {
  group('String list filter', () {
    late IdrisDb IdrisDb;

    late StringModel obj1;
    late StringModel obj2;
    late StringModel obj3;
    late StringModel obj4;
    late StringModel obj5;
    late StringModel obj6;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([StringModelSchema]);

      obj1 = StringModel(
        id: 1,
        strings: ['strings 1', 'strings 2', 'strings 3'],
        nullableStrings: ['nullable strings 1', null, 'nullable strings 3'],
        stringsNullable: ['strings nullable 1'],
        nullableStringsNullable: ['nullable strings nullable 1', null, null],
      );
      obj2 = StringModel(
        id: 2,
        strings: ['strings 2', 'strings 4'],
        nullableStrings: [
          'nullable strings 2',
          'nullable strings 3',
          'nullable strings 3',
        ],
        stringsNullable: null,
        nullableStringsNullable: null,
      );
      obj3 = StringModel(
        id: 3,
        strings: [],
        nullableStrings: [],
        stringsNullable: [],
        nullableStringsNullable: [],
      );
      obj4 = StringModel(
        id: 4,
        strings: ['strings 1', 'strings 5', 'strings 6'],
        nullableStrings: ['nullable strings 4', 'nullable strings 5'],
        stringsNullable: [
          'strings nullable 4',
          'strings nullable 5',
          'strings nullable 6',
        ],
        nullableStringsNullable: [null, null, null],
      );
      obj5 = StringModel(
        id: 5,
        strings: [
          'strings 3',
          'strings 4',
          'strings 5',
          'strings 6',
          'strings 7',
        ],
        nullableStrings: [
          null,
          'nullable strings 3',
          'nullable strings 4',
          'nullable strings 5',
          'nullable strings 6',
        ],
        stringsNullable: ['strings nullable 1'],
        nullableStringsNullable: null,
      );
      obj6 = StringModel(
        id: 6,
        strings: [''],
        nullableStrings: [
          '',
          'nullable strings 2',
          'nullable strings 5',
          'nullable strings 6',
        ],
        stringsNullable: ['strings nullable 4', 'strings nullable 5', ''],
        nullableStringsNullable: [
          null,
          '',
          'nullable strings nullable 3',
          'nullable strings nullable 5',
        ],
      );

      IdrisDb.write(
        (IdrisDb) =>
            IdrisDb.stringModels.putAll([obj1, obj2, obj3, obj4, obj5, obj6]),
      );
    });

    IdrisDbTest('.elementEqualTo()', () {
      expect(
        IdrisDb.stringModels.where().stringsElementEqualTo('strings 1').findAll(),
        [obj1, obj4],
      );
      expect(
        IdrisDb.stringModels.where().stringsElementEqualTo('strings 2').findAll(),
        [obj1, obj2],
      );
      expect(
        IdrisDb.stringModels.where().stringsElementEqualTo('strings 3').findAll(),
        [obj1, obj5],
      );
      expect(
        IdrisDb.stringModels.where().stringsElementEqualTo('strings 4').findAll(),
        [obj2, obj5],
      );
      expect(
        IdrisDb.stringModels.where().stringsElementEqualTo('strings 5').findAll(),
        [obj4, obj5],
      );
      expect(
        IdrisDb.stringModels.where().stringsElementEqualTo('strings 6').findAll(),
        [obj4, obj5],
      );
      expect(
        IdrisDb.stringModels.where().stringsElementEqualTo('strings 7').findAll(),
        [obj5],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsElementEqualTo('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEqualTo('nullable strings 1')
            .findAll(),
        [obj1],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEqualTo('nullable strings 2')
            .findAll(),
        [obj2, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEqualTo('nullable strings 3')
            .findAll(),
        [obj1, obj2, obj5],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEqualTo('nullable strings 4')
            .findAll(),
        [obj4, obj5],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEqualTo('nullable strings 5')
            .findAll(),
        [obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEqualTo('nullable strings 6')
            .findAll(),
        [obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEqualTo('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementEqualTo('strings nullable 1')
            .findAll(),
        [obj1, obj5],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementEqualTo('strings nullable 4')
            .findAll(),
        [obj4, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementEqualTo('strings nullable 5')
            .findAll(),
        [obj4, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementEqualTo('strings nullable 6')
            .findAll(),
        [obj4],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementEqualTo('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEqualTo(
              'nullable strings nullable 1',
            )
            .findAll(),
        [obj1],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEqualTo(
              'nullable strings nullable 3',
            )
            .findAll(),
        [obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEqualTo(
              'nullable strings nullable 5',
            )
            .findAll(),
        [obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEqualTo('non existing')
            .findAll(),
        isEmpty,
      );
    });

    IdrisDbTest('.elementStartWith()', () {
      expect(
        IdrisDb.stringModels.where().stringsElementStartsWith('strings').findAll(),
        [obj1, obj2, obj4, obj5],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsElementStartsWith('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementStartsWith('nullable')
            .findAll(),
        [obj1, obj2, obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementStartsWith('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementStartsWith('strings')
            .findAll(),
        [obj1, obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementEqualTo('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementStartsWith('nullable')
            .findAll(),
        [obj1, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementStartsWith('non existing')
            .findAll(),
        isEmpty,
      );
    });

    IdrisDbTest('.elementEndsWith()', () {
      expect(IdrisDb.stringModels.where().stringsElementEndsWith('1').findAll(), [
        obj1,
        obj4,
      ]);
      expect(IdrisDb.stringModels.where().stringsElementEndsWith('2').findAll(), [
        obj1,
        obj2,
      ]);
      expect(IdrisDb.stringModels.where().stringsElementEndsWith('3').findAll(), [
        obj1,
        obj5,
      ]);
      expect(IdrisDb.stringModels.where().stringsElementEndsWith('4').findAll(), [
        obj2,
        obj5,
      ]);
      expect(IdrisDb.stringModels.where().stringsElementEndsWith('5').findAll(), [
        obj4,
        obj5,
      ]);
      expect(IdrisDb.stringModels.where().stringsElementEndsWith('6').findAll(), [
        obj4,
        obj5,
      ]);
      expect(IdrisDb.stringModels.where().stringsElementEndsWith('7').findAll(), [
        obj5,
      ]);
      expect(
        IdrisDb.stringModels
            .where()
            .stringsElementEndsWith('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels.where().nullableStringsElementEndsWith('1').findAll(),
        [obj1],
      );
      expect(
        IdrisDb.stringModels.where().nullableStringsElementEndsWith('2').findAll(),
        [obj2, obj6],
      );
      expect(
        IdrisDb.stringModels.where().nullableStringsElementEndsWith('3').findAll(),
        [obj1, obj2, obj5],
      );
      expect(
        IdrisDb.stringModels.where().nullableStringsElementEndsWith('4').findAll(),
        [obj4, obj5],
      );
      expect(
        IdrisDb.stringModels.where().nullableStringsElementEndsWith('5').findAll(),
        [obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels.where().nullableStringsElementEndsWith('6').findAll(),
        [obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementEndsWith('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels.where().stringsNullableElementEndsWith('1').findAll(),
        [obj1, obj5],
      );
      expect(
        IdrisDb.stringModels.where().stringsNullableElementEndsWith('4').findAll(),
        [obj4, obj6],
      );
      expect(
        IdrisDb.stringModels.where().stringsNullableElementEndsWith('5').findAll(),
        [obj4, obj6],
      );
      expect(
        IdrisDb.stringModels.where().stringsNullableElementEndsWith('6').findAll(),
        [obj4],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementEndsWith('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEndsWith('1')
            .findAll(),
        [obj1],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEndsWith('3')
            .findAll(),
        [obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEndsWith('5')
            .findAll(),
        [obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementEndsWith('non existing')
            .findAll(),
        isEmpty,
      );
    });

    IdrisDbTest('.elementContains()', () {
      expect(
        IdrisDb.stringModels.where().stringsElementContains('ings').findAll(),
        [obj1, obj2, obj4, obj5],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsElementContains('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementContains('ings')
            .findAll(),
        [obj1, obj2, obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementContains('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementContains('ings')
            .findAll(),
        [obj1, obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementContains('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementContains('ings')
            .findAll(),
        [obj1, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementContains('non existing')
            .findAll(),
        isEmpty,
      );
    });

    IdrisDbTest('.elementMatches()', () {
      expect(
        IdrisDb.stringModels.where().stringsElementMatches('?????????').findAll(),
        [obj1, obj2, obj4, obj5],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsElementMatches('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementMatches('??????????????????')
            .findAll(),
        [obj1, obj2, obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementMatches('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementMatches('??????????????????')
            .findAll(),
        [obj1, obj4, obj5, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementMatches('non existing')
            .findAll(),
        isEmpty,
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementMatches(
              '???????????????????????????',
            )
            .findAll(),
        [obj1, obj6],
      );
      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementMatches('non existing')
            .findAll(),
        isEmpty,
      );
    });

    IdrisDbTest('.elementIsNull()', () {
      expect(
        IdrisDb.stringModels.where().nullableStringsElementIsNull().findAll(),
        [obj1, obj5],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementIsNull()
            .findAll(),
        [obj1, obj4, obj6],
      );
    });

    IdrisDbTest('.elementIsNotNull()', () {
      expect(
        IdrisDb.stringModels.where().nullableStringsElementIsNotNull().findAll(),
        [obj1, obj2, obj4, obj5, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementIsNotNull()
            .findAll(),
        [obj1, obj6],
      );
    });

    IdrisDbTest('.elementGreaterThan()', () {
      expect(
        IdrisDb.stringModels
            .where()
            .stringsElementGreaterThan('strings 3')
            .findAll(),
        [obj2, obj4, obj5],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementGreaterThan('nullable strings 3')
            .findAll(),
        [obj4, obj5, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementGreaterThan('strings nullable 3')
            .findAll(),
        [obj4, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementGreaterThan(
              'nullable strings nullable 3',
            )
            .findAll(),
        [obj6],
      );
    });

    IdrisDbTest('.elementLessThan()', () {
      expect(
        IdrisDb.stringModels.where().stringsElementLessThan('strings 3').findAll(),
        [obj1, obj2, obj4, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementLessThan('nullable strings 3')
            .findAll(),
        [obj1, obj2, obj5, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementLessThan('strings nullable 3')
            .findAll(),
        [obj1, obj5, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementLessThan(
              'nullable strings nullable 3',
            )
            .findAll(),
        [obj1, obj4, obj6],
      );
    });

    IdrisDbTest('.elementBetween()', () {
      expect(
        IdrisDb.stringModels
            .where()
            .stringsElementBetween('strings 2', 'strings 4')
            .findAll(),
        [obj1, obj2, obj5],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsElementBetween(
              'nullable strings 2',
              'nullable strings 4',
            )
            .findAll(),
        [obj1, obj2, obj4, obj5, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .stringsNullableElementBetween(
              'strings nullable 2',
              'strings nullable 4',
            )
            .findAll(),
        [obj4, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementBetween(
              'nullable strings nullable 2',
              'nullable strings nullable 4',
            )
            .findAll(),
        [obj6],
      );
    });

    IdrisDbTest('.elementIsEmpty()', () {
      expect(IdrisDb.stringModels.where().stringsElementIsEmpty().findAll(), [
        obj6,
      ]);

      expect(
        IdrisDb.stringModels.where().nullableStringsElementIsEmpty().findAll(),
        [obj6],
      );

      expect(
        IdrisDb.stringModels.where().stringsNullableElementIsEmpty().findAll(),
        [obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementIsEmpty()
            .findAll(),
        [obj6],
      );
    });

    IdrisDbTest('.elementIsNotEmpty()', () {
      expect(IdrisDb.stringModels.where().stringsElementIsNotEmpty().findAll(), [
        obj1,
        obj2,
        obj4,
        obj5,
      ]);

      expect(
        IdrisDb.stringModels.where().nullableStringsElementIsNotEmpty().findAll(),
        [obj1, obj2, obj4, obj5, obj6],
      );

      expect(
        IdrisDb.stringModels.where().stringsNullableElementIsNotEmpty().findAll(),
        [obj1, obj4, obj5, obj6],
      );

      expect(
        IdrisDb.stringModels
            .where()
            .nullableStringsNullableElementIsNotEmpty()
            .findAll(),
        [obj1, obj6],
      );
    });

    IdrisDbTest('.isEmpty()', () {
      expect(IdrisDb.stringModels.where().stringsIsEmpty().findAll(), [obj3]);

      expect(IdrisDb.stringModels.where().nullableStringsIsEmpty().findAll(), [
        obj3,
      ]);

      expect(IdrisDb.stringModels.where().stringsNullableIsEmpty().findAll(), [
        obj3,
      ]);

      expect(
        IdrisDb.stringModels.where().nullableStringsNullableIsEmpty().findAll(),
        [obj3],
      );
    });

    IdrisDbTest('.isNotEmpty()', () {
      expect(IdrisDb.stringModels.where().stringsIsNotEmpty().findAll(), [
        obj1,
        obj2,
        obj4,
        obj5,
        obj6,
      ]);

      expect(IdrisDb.stringModels.where().nullableStringsIsNotEmpty().findAll(), [
        obj1,
        obj2,
        obj4,
        obj5,
        obj6,
      ]);

      expect(IdrisDb.stringModels.where().stringsNullableIsNotEmpty().findAll(), [
        obj1,
        obj4,
        obj5,
        obj6,
      ]);

      expect(
        IdrisDb.stringModels.where().nullableStringsNullableIsNotEmpty().findAll(),
        [obj1, obj4, obj6],
      );
    });

    IdrisDbTest('.isNull()', () {
      expect(IdrisDb.stringModels.where().stringsNullableIsNull().findAll(), [
        obj2,
      ]);

      expect(
        IdrisDb.stringModels.where().nullableStringsNullableIsNull().findAll(),
        [obj2, obj5],
      );
    });

    IdrisDbTest('.isNotNull()', () {
      expect(IdrisDb.stringModels.where().stringsNullableIsNotNull().findAll(), [
        obj1,
        obj3,
        obj4,
        obj5,
        obj6,
      ]);

      expect(
        IdrisDb.stringModels.where().nullableStringsNullableIsNotNull().findAll(),
        [obj1, obj3, obj4, obj6],
      );
    });
  });
}
