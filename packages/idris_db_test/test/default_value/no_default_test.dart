import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

import 'common.dart';

part 'no_default_test.g.dart';

@Name('Col')
@collection
class NoDefaultModel {
  NoDefaultModel(
    this.id,
    this.boolValue,
    this.byteValue,
    this.shortValue,
    this.intValue,
    this.floatValue,
    this.doubleValue,
    this.dateTimeValue,
    this.stringValue,
    this.jsonValue,
    this.enumValue,
    this.embeddedValue,
  );

  final int id;

  final bool boolValue;

  final byte byteValue;

  final short shortValue;

  final int intValue;

  final float floatValue;

  final double doubleValue;

  final DateTime dateTimeValue;

  final String stringValue;

  final MyEnum enumValue;

  final MyEmbedded embeddedValue;

  final dynamic jsonValue;
}

@Name('Col')
@collection
class NoDefaultListModel {
  NoDefaultListModel(
    this.id,
    this.boolValue,
    this.byteValue,
    this.shortValue,
    this.intValue,
    this.floatValue,
    this.doubleValue,
    this.dateTimeValue,
    this.stringValue,
    this.enumValue,
    this.embeddedValue,
    this.jsonValue,
    this.jsonObjectValue,
  );

  final int id;

  final List<bool?> boolValue;

  final List<byte> byteValue;

  final List<short?> shortValue;

  final List<int?> intValue;

  final List<float?> floatValue;

  final List<double?> doubleValue;

  final List<DateTime?> dateTimeValue;

  final List<String?> stringValue;

  final List<MyEnum?> enumValue;

  final List<MyEmbedded?> embeddedValue;

  final List<dynamic> jsonValue;

  final Map<String, dynamic> jsonObjectValue;
}

void main() {
  group('No default value', () {
    IdrisDbTest('scalar', web: false, () async {
      final emptyObj = EmptyModel(0);
      final IDRISDB1 = await openTempIDRISDB([EmptyModelSchema]);
      IDRISDB1.write((IdrisDb) => IdrisDb.emptyModels.put(emptyObj));
      final idrisDbName = IDRISDB1.name;
      IDRISDB1.close();

      final IDRISDB2 = await openTempIDRISDB([NoDefaultModelSchema], name: idrisDbName);
      final obj = IDRISDB2.noDefaultModels.get(0)!;
      expect(obj.boolValue, false);
      expect(obj.byteValue, 0);
      expect(obj.shortValue, -2147483648);
      expect(obj.intValue, -9223372036854775808);
      expect(obj.floatValue, isNaN);
      expect(obj.doubleValue, isNaN);
      expect(obj.dateTimeValue, DateTime.fromMillisecondsSinceEpoch(0));
      expect(obj.stringValue, '');
      expect(obj.enumValue, MyEnum.value1);
      expect(obj.embeddedValue, const MyEmbedded());
      expect(obj.jsonValue, null);
    });

    IdrisDbTest('scalar property', web: false, () async {
      final emptyObj = EmptyModel(0);
      final IDRISDB1 = await openTempIDRISDB([EmptyModelSchema]);
      IDRISDB1.write((IdrisDb) => IdrisDb.emptyModels.put(emptyObj));
      final idrisDbName = IDRISDB1.name;
      IDRISDB1.close();

      final IDRISDB2 = await openTempIDRISDB([NoDefaultModelSchema], name: idrisDbName);
      final col = IDRISDB2.noDefaultModels;
      expect(col.where().boolValueProperty().findFirst(), false);
      expect(col.where().byteValueProperty().findFirst(), 0);
      expect(col.where().shortValueProperty().findFirst(), -2147483648);
      expect(col.where().intValueProperty().findFirst(), -9223372036854775808);
      expect(col.where().floatValueProperty().findFirst(), isNaN);
      expect(col.where().doubleValueProperty().findFirst(), isNaN);
      expect(
        col.where().dateTimeValueProperty().findFirst(),
        DateTime.fromMillisecondsSinceEpoch(0),
      );
      expect(col.where().stringValueProperty().findFirst(), '');
      expect(col.where().enumValueProperty().findFirst(), MyEnum.value1);
      expect(
        col.where().embeddedValueProperty().findFirst(),
        const MyEmbedded(),
      );
      expect(col.where().jsonValueProperty().findFirst(), null);
    });

    IdrisDbTest('list', web: false, () async {
      final emptyObj = EmptyModel(0);
      final IDRISDB1 = await openTempIDRISDB([EmptyModelSchema]);
      IDRISDB1.write((IdrisDb) => IdrisDb.emptyModels.put(emptyObj));
      final idrisDbName = IDRISDB1.name;
      IDRISDB1.close();

      final IDRISDB2 = await openTempIDRISDB([
        NoDefaultListModelSchema,
      ], name: idrisDbName);
      final obj = IDRISDB2.noDefaultListModels.get(0)!;
      expect(obj.boolValue, isEmpty);
      expect(obj.byteValue, isEmpty);
      expect(obj.shortValue, isEmpty);
      expect(obj.intValue, isEmpty);
      expect(obj.floatValue, isEmpty);
      expect(obj.doubleValue, isEmpty);
      expect(obj.dateTimeValue, isEmpty);
      expect(obj.stringValue, isEmpty);
      expect(obj.enumValue, isEmpty);
      expect(obj.embeddedValue, isEmpty);
      expect(obj.jsonValue, isEmpty);
      expect(obj.jsonObjectValue, isEmpty);
    });

    IdrisDbTest('list property', web: false, () async {
      final emptyObj = EmptyModel(0);
      final IDRISDB1 = await openTempIDRISDB([EmptyModelSchema]);
      IDRISDB1.write((IdrisDb) => IdrisDb.emptyModels.put(emptyObj));
      final idrisDbName = IDRISDB1.name;
      IDRISDB1.close();

      final IDRISDB2 = await openTempIDRISDB([
        NoDefaultListModelSchema,
      ], name: idrisDbName);
      final col = IDRISDB2.noDefaultListModels;
      expect(col.where().boolValueProperty().findFirst(), isEmpty);
      expect(col.where().byteValueProperty().findFirst(), isEmpty);
      expect(col.where().shortValueProperty().findFirst(), isEmpty);
      expect(col.where().intValueProperty().findFirst(), isEmpty);
      expect(col.where().floatValueProperty().findFirst(), isEmpty);
      expect(col.where().doubleValueProperty().findFirst(), isEmpty);
      expect(col.where().dateTimeValueProperty().findFirst(), isEmpty);
      expect(col.where().stringValueProperty().findFirst(), isEmpty);
      expect(col.where().enumValueProperty().findFirst(), isEmpty);
      expect(col.where().embeddedValueProperty().findFirst(), isEmpty);
      expect(col.where().jsonValueProperty().findFirst(), isEmpty);
      expect(col.where().jsonObjectValueProperty().findFirst(), isEmpty);
    });
  });
}
