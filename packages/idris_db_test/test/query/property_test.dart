import 'dart:typed_data';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

import '../type_models.dart';

void main() {
  group('Query property', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([
        BoolModelSchema,
        ByteModelSchema,
        ShortModelSchema,
        IntModelSchema,
        FloatModelSchema,
        DoubleModelSchema,
        DateTimeModelSchema,
        StringModelSchema,
        EnumModelSchema,
        ObjectModelSchema,
      ]);
    });

    IdrisDbTest('id property', () {
      IdrisDb.write(
        (IdrisDb) =>
            IdrisDb.boolModels.putAll([BoolModel(0), BoolModel(1), BoolModel(2)]),
      );

      expect(IdrisDb.boolModels.where().idProperty().findAll(), [0, 1, 2]);
    });

    IdrisDbTest('bool property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.boolModels.putAll([
          BoolModel(0)
            ..value = true
            ..nValue = false,
          BoolModel(1)
            ..value = false
            ..nValue = true,
          BoolModel(2)..value = true,
        ]),
      );

      expect(IdrisDb.boolModels.where().valueProperty().findAll(), [
        true,
        false,
        true,
      ]);

      expect(IdrisDb.boolModels.where().nValueProperty().findAll(), [
        false,
        true,
        null,
      ]);
    });

    IdrisDbTest('byte property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.byteModels.putAll([
          ByteModel(0)..value = 5,
          ByteModel(1)..value = 123,
          ByteModel(2)..value = 0,
        ]),
      );

      expect(IdrisDb.byteModels.where().valueProperty().findAll(), [5, 123, 0]);
    });

    IdrisDbTest('short property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.shortModels.putAll([
          ShortModel(0)
            ..value = 1234
            ..nValue = 55,
          ShortModel(1)..value = 444,
          ShortModel(2)
            ..value = 321321
            ..nValue = 1,
        ]),
      );

      expect(IdrisDb.shortModels.where().valueProperty().findAll(), [
        1234,
        444,
        321321,
      ]);

      expect(IdrisDb.shortModels.where().nValueProperty().findAll(), [
        55,
        null,
        1,
      ]);
    });

    IdrisDbTest('int property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.intModels.putAll([
          IntModel(0)
            ..value = -5
            ..nValue = -99999,
          IntModel(1)
            ..value = -9999
            ..nValue = 0,
          IntModel(2)..value = 9999,
        ]),
      );

      expect(IdrisDb.intModels.where().valueProperty().findAll(), [
        -5,
        -9999,
        9999,
      ]);

      expect(IdrisDb.intModels.where().nValueProperty().findAll(), [
        -99999,
        0,
        null,
      ]);
    });

    IdrisDbTest('float property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.floatModels.putAll([
          FloatModel(0)
            ..value = -5.5
            ..nValue = double.infinity,
          FloatModel(1)..value = 70.7,
          FloatModel(2)
            ..value = double.nan
            ..nValue = double.negativeInfinity,
        ]),
      );

      expect(
        listEquals(IdrisDb.floatModels.where().valueProperty().findAll(), [
          -5.5,
          70.7,
          double.nan,
        ]),
        true,
      );

      expect(
        listEquals(IdrisDb.floatModels.where().nValueProperty().findAll(), [
          double.infinity,
          null,
          double.negativeInfinity,
        ]),
        true,
      );
    });

    IdrisDbTest('double property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.doubleModels.putAll([
          DoubleModel(0)
            ..value = -5.5
            ..nValue = double.infinity,
          DoubleModel(1)..value = 70.7,
          DoubleModel(2)
            ..value = double.nan
            ..nValue = double.negativeInfinity,
        ]),
      );

      expect(
        listEquals(IdrisDb.doubleModels.where().valueProperty().findAll(), [
          -5.5,
          70.7,
          double.nan,
        ]),
        true,
      );

      expect(IdrisDb.doubleModels.where().nValueProperty().findAll(), [
        double.infinity,
        null,
        double.negativeInfinity,
      ]);
    });

    IdrisDbTest('DateTime property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.dateTimeModels.putAll([
          DateTimeModel(0)..value = DateTime(2022),
          DateTimeModel(1)
            ..value = DateTime(2020)
            ..nValue = DateTime(2010),
          DateTimeModel(2)..value = DateTime(1999),
        ]),
      );

      expect(IdrisDb.dateTimeModels.where().valueProperty().findAll(), [
        DateTime(2022),
        DateTime(2020),
        DateTime(1999),
      ]);

      expect(IdrisDb.dateTimeModels.where().nValueProperty().findAll(), [
        null,
        DateTime(2010),
        null,
      ]);
    });

    IdrisDbTest('String property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.stringModels.putAll([
          StringModel(0)
            ..value = 'Just'
            ..nValue = 'A',
          StringModel(1)..value = 'a',
          StringModel(2)
            ..value = 'test'
            ..nValue = 'Z',
        ]),
      );

      expect(IdrisDb.stringModels.where().valueProperty().findAll(), [
        'Just',
        'a',
        'test',
      ]);

      expect(IdrisDb.stringModels.where().nValueProperty().findAll(), [
        'A',
        null,
        'Z',
      ]);
    });

    IdrisDbTest('Object property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.objectModels.putAll([
          ObjectModel(0)
            ..value = EmbeddedModel('E1')
            ..nValue = EmbeddedModel('XXX'),
          ObjectModel(1)
            ..value = EmbeddedModel('E2')
            ..nValue = EmbeddedModel('YYY'),
          ObjectModel(2)..value = EmbeddedModel('E3'),
        ]),
      );

      expect(IdrisDb.objectModels.where().valueProperty().findAll(), [
        EmbeddedModel('E1'),
        EmbeddedModel('E2'),
        EmbeddedModel('E3'),
      ]);

      expect(IdrisDb.objectModels.where().nValueProperty().findAll(), [
        EmbeddedModel('XXX'),
        EmbeddedModel('YYY'),
        null,
      ]);
    });

    IdrisDbTest('Enum property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.enumModels.putAll([
          EnumModel(0)..value = TestEnum.option2,
          EnumModel(1)
            ..value = TestEnum.option3
            ..nValue = TestEnum.option3,
          EnumModel(2)..value = TestEnum.option2,
        ]),
      );

      expect(IdrisDb.enumModels.where().valueProperty().findAll(), [
        TestEnum.option2,
        TestEnum.option3,
        TestEnum.option2,
      ]);

      expect(IdrisDb.enumModels.where().nValueProperty().findAll(), [
        null,
        TestEnum.option3,
        null,
      ]);
    });

    IdrisDbTest('bool list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.boolModels.putAll([
          BoolModel(0)
            ..list = [true, false, true]
            ..nList = [false],
          BoolModel(1)..list = [],
          BoolModel(2)
            ..list = [true]
            ..nList = [],
        ]),
      );

      expect(IdrisDb.boolModels.where().listProperty().findAll(), [
        [true, false, true],
        <bool>[],
        [true],
      ]);

      expect(IdrisDb.boolModels.where().nListProperty().findAll(), [
        [false],
        null,
        <bool>[],
      ]);
    });

    IdrisDbTest('byte list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.byteModels.putAll([
          ByteModel(0)..list = Uint8List.fromList([0, 10, 255]),
          ByteModel(1)
            ..list = []
            ..nList = [1, 2, 3, 4, 5],
          ByteModel(2)..list = [3],
        ]),
      );

      expect(IdrisDb.byteModels.where().listProperty().findAll(), [
        Uint8List.fromList([0, 10, 255]),
        Uint8List.fromList([]),
        Uint8List.fromList([3]),
      ]);

      expect(IdrisDb.byteModels.where().nListProperty().findAll(), [
        null,
        Uint8List.fromList([1, 2, 3, 4, 5]),
        null,
      ]);
    });

    IdrisDbTest('short list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.shortModels.putAll([
          ShortModel(0)
            ..list = [-5, 70, 999]
            ..nList = [],
          ShortModel(1)
            ..list = []
            ..nList = [1, 2, 3],
          ShortModel(2)..list = [0],
        ]),
      );

      expect(IdrisDb.shortModels.where().listProperty().findAll(), [
        [-5, 70, 999],
        <int>[],
        [0],
      ]);

      expect(IdrisDb.shortModels.where().nListProperty().findAll(), [
        <int>[],
        [1, 2, 3],
        null,
      ]);
    });

    IdrisDbTest('int list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.intModels.putAll([
          IntModel(0)
            ..list = [-5, 70, 999]
            ..nList = [],
          IntModel(1)
            ..list = []
            ..nList = [1, 2, 3],
          IntModel(2)..list = [0],
        ]),
      );

      expect(IdrisDb.intModels.where().listProperty().findAll(), [
        [-5, 70, 999],
        <int>[],
        [0],
      ]);

      expect(IdrisDb.intModels.where().nListProperty().findAll(), [
        <int>[],
        [1, 2, 3],
        null,
      ]);
    });

    IdrisDbTest('float list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.floatModels.putAll([
          FloatModel(0)
            ..list = [-5.5, 70.7, 999.999]
            ..nList = [1919191],
          FloatModel(1)..list = [],
          FloatModel(2)
            ..list = [0.0]
            ..nList = [-1919191],
        ]),
      );

      expect(
        listEquals(IdrisDb.floatModels.where().listProperty().findAll(), [
          [-5.5, 70.7, 999.999],
          <double>[],
          [0.0],
        ]),
        true,
      );

      expect(
        listEquals(IdrisDb.floatModels.where().nListProperty().findAll(), [
          [1919191],
          null,
          [-1919191],
        ]),
        true,
      );
    });

    IdrisDbTest('double list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.doubleModels.putAll([
          DoubleModel(0)
            ..list = [-5.5, 70.7, 999.999]
            ..nList = [1919191.1919191],
          DoubleModel(1)..list = [],
          DoubleModel(2)
            ..list = [0.0]
            ..nList = [double.maxFinite],
        ]),
      );

      expect(IdrisDb.doubleModels.where().listProperty().findAll(), [
        [-5.5, 70.7, 999.999],
        <double>[],
        [0.0],
      ]);

      expect(IdrisDb.doubleModels.where().nListProperty().findAll(), [
        [1919191.1919191],
        null,
        [double.maxFinite],
      ]);
    });

    IdrisDbTest('DateTime list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.dateTimeModels.putAll([
          DateTimeModel(0)
            ..list = [DateTime(2019), DateTime(2020)]
            ..nList = [DateTime(2000), DateTime(2001)],
          DateTimeModel(1)
            ..list = [DateTime(2020)]
            ..nList = [DateTime(2000)],
          DateTimeModel(2)..list = [],
        ]),
      );

      expect(IdrisDb.dateTimeModels.where().listProperty().findAll(), [
        [DateTime(2019), DateTime(2020)],
        [DateTime(2020)],
        <DateTime>[],
      ]);

      expect(IdrisDb.dateTimeModels.where().nListProperty().findAll(), [
        [DateTime(2000), DateTime(2001)],
        [DateTime(2000)],
        null,
      ]);
    });

    IdrisDbTest('String list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.stringModels.putAll([
          StringModel(0)..list = ['Just', 'a', 'test'],
          StringModel(1)..list = [],
          StringModel(2)
            ..list = ['']
            ..nList = ['HELLO'],
        ]),
      );

      expect(IdrisDb.stringModels.where().listProperty().findAll(), [
        ['Just', 'a', 'test'],
        <String>[],
        [''],
      ]);

      expect(IdrisDb.stringModels.where().nListProperty().findAll(), [
        null,
        null,
        ['HELLO'],
      ]);
    });

    IdrisDbTest('Object list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.objectModels.putAll([
          ObjectModel(0)
            ..list = []
            ..nList = [EmbeddedModel('abc'), EmbeddedModel('def')],
          ObjectModel(1)..list = [EmbeddedModel('abc'), EmbeddedModel('def')],
          ObjectModel(2)
            ..list = [EmbeddedModel()]
            ..nList = [EmbeddedModel()],
        ]),
      );

      expect(IdrisDb.objectModels.where().listProperty().findAll(), [
        <EmbeddedModel>[],
        [EmbeddedModel('abc'), EmbeddedModel('def')],
        [EmbeddedModel()],
      ]);

      expect(IdrisDb.objectModels.where().nListProperty().findAll(), [
        [EmbeddedModel('abc'), EmbeddedModel('def')],
        null,
        [EmbeddedModel()],
      ]);
    });

    IdrisDbTest('Enum list property', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.enumModels.putAll([
          EnumModel(0)
            ..list = [TestEnum.option2]
            ..nList = [TestEnum.option2, TestEnum.option3],
          EnumModel(1)..list = [TestEnum.option1],
          EnumModel(2)..list = [],
        ]),
      );

      expect(IdrisDb.enumModels.where().listProperty().findAll(), [
        [TestEnum.option2],
        [TestEnum.option1],
        <TestEnum>[],
      ]);

      expect(IdrisDb.enumModels.where().nListProperty().findAll(), [
        [TestEnum.option2, TestEnum.option3],
        null,
        null,
      ]);
    });

    IdrisDbTest('Query with 2 properties', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.intModels.putAll([
          IntModel(0)..value = 10,
          IntModel(1)..value = 20,
          IntModel(2)..value = 30,
        ]),
      );

      final results = IdrisDb.intModels
          .where()
          .idProperty()
          .valueProperty()
          .findAll();

      expect(results, [(0, 10), (1, 20), (2, 30)]);
    });
    IdrisDbTest('Query with 3 properties', () {
      IdrisDb.write(
        (IdrisDb) => IdrisDb.intModels.putAll([
          IntModel(0)
            ..value = 10
            ..nValue = 100,
          IntModel(1)
            ..value = 20
            ..nValue = 200,
          IntModel(2)
            ..value = 30
            ..nValue = null,
        ]),
      );

      final results = IdrisDb.intModels
          .where()
          .idProperty()
          .valueProperty()
          .nValueProperty()
          .findAll();

      expect(results, [(0, 10, 100), (1, 20, 200), (2, 30, null)]);
    });

    IdrisDbTest('Query with more than 3 properties throws', () {
      expect(
        // ignore: experimental_member_use
        () => IdrisDb.intModels.buildQuery<(int, int, int, int)>(
          properties: [0, 1, 2, 3],
        ),
        throwsArgumentError,
      );
    });
  });
}
