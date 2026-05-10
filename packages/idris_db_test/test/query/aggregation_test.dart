import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

import '../type_models.dart';

void main() {
  group('Aggregation', () {
    group('id', () {
      late IdrisDbCollection<int, IntModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([IntModelSchema]);
        col = IdrisDb.intModels;

        IdrisDb.write(
          (IdrisDb) => col.putAll([IntModel(-5), IntModel(0), IntModel(10)]),
        );
      });

      IdrisDbTest('min', () {
        expect(col.where().idProperty().min(), -5);
        expect(col.where().idEqualTo(10).idProperty().min(), 10);
        expect(col.where().idEqualTo(99).idProperty().min(), null);
      });

      IdrisDbTest('max', () {
        expect(col.where().idProperty().max(), 10);
        expect(col.where().idEqualTo(10).idProperty().max(), 10);
        expect(col.where().idEqualTo(99).idProperty().max(), null);
      });

      IdrisDbTest('sum', () {
        expect(col.where().idProperty().sum(), 5);
        expect(col.where().idEqualTo(10).idProperty().sum(), 10);
        expect(col.where().idEqualTo(99).idProperty().sum(), 0);
      });

      IdrisDbTest('average', () {
        expect(col.where().idProperty().average(), 5.0 / 3);
        expect(col.where().idEqualTo(10).idProperty().average(), 10);
        expect(col.where().idEqualTo(99).idProperty().average(), isNaN);
      });
    });

    group('byte', () {
      late IdrisDbCollection<int, ByteModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([ByteModelSchema]);
        col = IdrisDb.byteModels;

        IdrisDb.write(
          (IdrisDb) => col.putAll([
            ByteModel(0)..value = 1,
            ByteModel(1)..value = 5,
            ByteModel(2)..value = 2,
          ]),
        );
      });

      IdrisDbTest('min', () {
        expect(col.where().valueProperty().min(), 1);
        expect(col.where().valueEqualTo(5).valueProperty().min(), 5);
        expect(col.where().valueEqualTo(25).valueProperty().min(), null);
      });

      IdrisDbTest('max', () {
        expect(col.where().valueProperty().max(), 5);
        expect(col.where().valueEqualTo(2).valueProperty().max(), 2);
        expect(col.where().valueEqualTo(25).valueProperty().max(), null);
      });

      IdrisDbTest('sum', () {
        expect(col.where().valueProperty().sum(), 8);
        expect(col.where().valueEqualTo(2).valueProperty().sum(), 2);
        expect(col.where().valueEqualTo(25).valueProperty().sum(), 0);
      });

      IdrisDbTest('average', () {
        expect(col.where().valueProperty().average(), 8.0 / 3);
        expect(col.where().valueEqualTo(2).valueProperty().average(), 2);
        expect(col.where().valueEqualTo(25).valueProperty().average(), isNaN);
      });
    });

    group('short', () {
      late IdrisDbCollection<int, ShortModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([ShortModelSchema]);
        col = IdrisDb.shortModels;

        IdrisDb.write(
          (IdrisDb) => col.putAll([
            ShortModel(0)
              ..value = 3
              ..nValue = -5,
            ShortModel(1)..nValue = 0,
            ShortModel(2)
              ..value = -2
              ..nValue = 10,
            ShortModel(3)..nValue = null,
          ]),
        );
      });

      IdrisDbTest('min', () {
        expect(col.where().nValueProperty().min(), -5);
        expect(col.where().valueProperty().min(), -2);
        expect(col.where().nValueEqualTo(10).nValueProperty().min(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().min(), null);
      });

      IdrisDbTest('max', () {
        expect(col.where().nValueProperty().max(), 10);
        expect(col.where().valueProperty().max(), 3);
        expect(col.where().nValueEqualTo(10).nValueProperty().max(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().max(), null);
      });

      IdrisDbTest('sum', () {
        expect(col.where().nValueProperty().sum(), 5);
        expect(col.where().valueProperty().sum(), 1);
        expect(col.where().nValueEqualTo(10).nValueProperty().sum(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().sum(), 0);
      });

      IdrisDbTest('average', () {
        expect(col.where().nValueProperty().average(), 5.0 / 3);
        expect(col.where().valueProperty().average(), 1 / 4);
        expect(col.where().nValueEqualTo(10).nValueProperty().average(), 10);
        expect(
          col.where().nValueEqualTo(null).nValueProperty().average(),
          isNaN,
        );
      });
    });

    group('int', () {
      late IdrisDbCollection<int, IntModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([IntModelSchema]);
        col = IdrisDb.intModels;

        IdrisDb.write(
          (IdrisDb) => col.putAll([
            IntModel(0)
              ..value = 3
              ..nValue = -5,
            IntModel(1)..nValue = 0,
            IntModel(2)
              ..value = -2
              ..nValue = 10,
            IntModel(3)..nValue = null,
          ]),
        );
      });

      IdrisDbTest('min', () {
        expect(col.where().nValueProperty().min(), -5);
        expect(col.where().valueProperty().min(), -2);
        expect(col.where().nValueEqualTo(10).nValueProperty().min(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().min(), null);
      });

      IdrisDbTest('max', () {
        expect(col.where().nValueProperty().max(), 10);
        expect(col.where().valueProperty().max(), 3);
        expect(col.where().nValueEqualTo(10).nValueProperty().max(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().max(), null);
      });

      IdrisDbTest('sum', () {
        expect(col.where().nValueProperty().sum(), 5);
        expect(col.where().valueProperty().sum(), 1);
        expect(col.where().nValueEqualTo(10).nValueProperty().sum(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().sum(), 0);
      });

      IdrisDbTest('average', () {
        expect(col.where().nValueProperty().average(), 5.0 / 3);
        expect(col.where().valueProperty().average(), 1 / 4);
        expect(col.where().nValueEqualTo(10).nValueProperty().average(), 10);
        expect(
          col.where().nValueEqualTo(null).nValueProperty().average(),
          isNaN,
        );
      });
    });

    group('float', () {
      late IdrisDbCollection<int, FloatModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([FloatModelSchema]);
        col = IdrisDb.floatModels;

        IdrisDb.write(
          (IdrisDb) => col.putAll([
            FloatModel(0)
              ..value = 3
              ..nValue = -5,
            FloatModel(1)..nValue = 0,
            FloatModel(2)
              ..value = -2
              ..nValue = 10,
            FloatModel(3)..nValue = null,
          ]),
        );
      });

      IdrisDbTest('min', () {
        expect(col.where().nValueProperty().min(), -5);
        expect(col.where().valueProperty().min(), -2);
        expect(col.where().nValueEqualTo(10).nValueProperty().min(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().min(), null);
      });

      IdrisDbTest('max', () {
        expect(col.where().nValueProperty().max(), 10);
        expect(col.where().valueProperty().max(), 3);
        expect(col.where().nValueEqualTo(10).nValueProperty().max(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().max(), null);
      });

      IdrisDbTest('sum', () {
        expect(col.where().nValueProperty().sum(), 5);
        expect(col.where().valueProperty().sum(), 1);
        expect(col.where().nValueEqualTo(10).nValueProperty().sum(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().sum(), 0);
      });

      IdrisDbTest('average', () {
        expect(col.where().nValueProperty().average(), 5.0 / 3);
        expect(col.where().valueProperty().average(), 1 / 4);
        expect(col.where().nValueEqualTo(10).nValueProperty().average(), 10);
        expect(
          col.where().nValueEqualTo(null).nValueProperty().average(),
          isNaN,
        );
      });
    });

    group('double', () {
      late IdrisDbCollection<int, DoubleModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([DoubleModelSchema]);
        col = IdrisDb.doubleModels;

        IdrisDb.write(
          (IdrisDb) => col.putAll([
            DoubleModel(0)
              ..value = 3
              ..nValue = -5,
            DoubleModel(1)..nValue = 0,
            DoubleModel(2)
              ..value = -2
              ..nValue = 10,
            DoubleModel(3)..nValue = null,
          ]),
        );
      });

      IdrisDbTest('min', () {
        expect(col.where().nValueProperty().min(), -5);
        expect(col.where().valueProperty().min(), -2);
        expect(col.where().nValueEqualTo(10).nValueProperty().min(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().min(), null);
      });

      IdrisDbTest('max', () {
        expect(col.where().nValueProperty().max(), 10);
        expect(col.where().valueProperty().max(), 3);
        expect(col.where().nValueEqualTo(10).nValueProperty().max(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().max(), null);
      });

      IdrisDbTest('sum', () {
        expect(col.where().nValueProperty().sum(), 5);
        expect(col.where().valueProperty().sum(), 1);
        expect(col.where().nValueEqualTo(10).nValueProperty().sum(), 10);
        expect(col.where().nValueEqualTo(null).nValueProperty().sum(), 0);
      });

      IdrisDbTest('average', () {
        expect(col.where().nValueProperty().average(), 5.0 / 3);
        expect(col.where().valueProperty().average(), 1 / 4);
        expect(col.where().nValueEqualTo(10).nValueProperty().average(), 10);
        expect(
          col.where().nValueEqualTo(null).nValueProperty().average(),
          isNaN,
        );
      });
    });

    group('dateTime', () {
      late IdrisDbCollection<int, DateTimeModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([DateTimeModelSchema]);
        col = IdrisDb.dateTimeModels;

        final now = DateTime.now();
        IdrisDb.write(
          (IdrisDb) => col.putAll([
            DateTimeModel(0)..value = now.subtract(const Duration(days: 10)),
            DateTimeModel(1)..value = now.subtract(const Duration(days: 5)),
            DateTimeModel(2)..value = now,
          ]),
        );
      });

      IdrisDbTest('min', () {
        final min = col.where().valueProperty().min();
        expect(min, isNotNull);
        expect(min, isA<DateTime>());
      });

      IdrisDbTest('max', () {
        final max = col.where().valueProperty().max();
        expect(max, isNotNull);
        expect(max, isA<DateTime>());
      });

      IdrisDbTest('nullable min returns null when all null', () {
        expect(col.where().nValueProperty().min(), null);
      });

      IdrisDbTest('nullable max returns null when all null', () {
        expect(col.where().nValueProperty().max(), null);
      });
    });

    group('string', () {
      late IdrisDbCollection<int, StringModel> col;

      setUp(() async {
        final IdrisDb = await openTempIDRISDB([StringModelSchema]);
        col = IdrisDb.stringModels;

        IdrisDb.write(
          (IdrisDb) => col.putAll([
            StringModel(0)..value = 'apple',
            StringModel(1)..value = 'banana',
            StringModel(2)..value = 'cherry',
          ]),
        );
      });

      IdrisDbTest('min', () {
        expect(col.where().valueProperty().min(), 'apple');
      });

      IdrisDbTest('max', () {
        expect(col.where().valueProperty().max(), 'cherry');
      });

      IdrisDbTest('nullable min returns null when all null', () {
        expect(col.where().nValueProperty().min(), null);
      });

      IdrisDbTest('nullable max returns null when all null', () {
        expect(col.where().nValueProperty().max(), null);
      });
    });
  });
}
