part of '../idris_db_generator.dart';

String _generateSerialize(ObjectInfo object) {
  final buffer = StringBuffer(
    '''
  @IDRISDBProtected
  int serialize${object.dartName}(IDRISDBWriter writer, ${object.dartName} object) {''',
  );

  for (final property in object.properties) {
    if (property.isId && property.type == IdrisDbType.long) {
      continue;
    }

    buffer.write(
      _writeProperty(
        index: property.index.toString(),
        type: property.type,
        nullable: property.nullable,
        elementNullable: property.elementNullable,
        typeClassName: property.typeClassName,
        value: 'object.${property.dartName}',
        enumProperty: property.enumProperty,
      ),
    );
  }

  final idProp = object.idProperty;
  if (idProp != null) {
    if (idProp.type == IdrisDbType.long) {
      buffer.write('return object.${idProp.dartName};');
    } else {
      buffer.write('return IdrisDb.fastHash(object.${idProp.dartName});');
    }
  } else {
    buffer.write('return 0;');
  }

  return '$buffer}';
}

String _writeProperty({
  required String index,
  required IdrisDbType type,
  required bool nullable,
  required String typeClassName,
  required String value,
  required String? enumProperty,
  String writer = 'writer',
  bool? elementNullable,
}) {
  final enumGetter = enumProperty != null
      ? nullable
            ? '?.$enumProperty'
            : '.$enumProperty'
      : '';
  switch (type) {
    case IdrisDbType.bool:
      if (nullable) {
        return '''
        {
          final value = $value$enumGetter;
          if (value == null) {
            IdrisDbCore.writeNull($writer, $index);
          } else {
            IdrisDbCore.writeBool($writer, $index,value: value);
          }
        }''';
      } else {
        return 'IdrisDbCore.writeBool($writer, $index,value:$value$enumGetter);';
      }
    case IdrisDbType.byte:
      return 'IdrisDbCore.writeByte($writer, $index, $value$enumGetter);';
    case IdrisDbType.int:
      final orNull = nullable ? '?? $_nullInt' : '';
      return 'IdrisDbCore.writeInt($writer, $index, $value$enumGetter $orNull);';
    case IdrisDbType.float:
      final orNull = nullable ? '?? double.nan' : '';
      return 'IdrisDbCore.writeFloat($writer, $index, $value$enumGetter $orNull);';
    case IdrisDbType.long:
      final orNull = nullable ? '?? $_nullLong' : '';
      return 'IdrisDbCore.writeLong($writer, $index, $value$enumGetter $orNull);';
    case IdrisDbType.dateTime:
      final converted = nullable
          ? '$value$enumGetter?.toUtc().microsecondsSinceEpoch '
                '?? $_nullLong'
          : '$value$enumGetter.toUtc().microsecondsSinceEpoch';
      return 'IdrisDbCore.writeLong($writer, $index, $converted);';
    case IdrisDbType.double:
      final orNull = nullable ? '?? double.nan' : '';
      return 'IdrisDbCore.writeDouble($writer, $index, $value$enumGetter$orNull);';
    case IdrisDbType.string:
      if (nullable) {
        return '''
        {
          final value = $value$enumGetter;
          if (value == null) {
            IdrisDbCore.writeNull($writer, $index);
          } else {
            IdrisDbCore.writeString($writer, $index, value);
          }
        }''';
      } else {
        return '''
        IdrisDbCore.writeString($writer, $index, $value$enumGetter);''';
      }
    case IdrisDbType.object:
      var code = '''
      {
        final value = $value;''';
      if (nullable) {
        code +=
            '''
        if (value == null) {
          IdrisDbCore.writeNull($writer, $index);
        } else {''';
      }
      code +=
          '''
      final objectWriter = IdrisDbCore.beginObject($writer, $index);
      serialize$typeClassName(objectWriter, value);
      IdrisDbCore.endObject($writer, objectWriter);''';
      if (nullable) {
        code += '}';
      }
      return '$code}';
    case IdrisDbType.json:
      return 'IdrisDbCore.writeString($writer, $index, IDRISDBJsonEncode($value));';
    case IdrisDbType.boolList:
    case IdrisDbType.byteList:
    case IdrisDbType.intList:
    case IdrisDbType.floatList:
    case IdrisDbType.longList:
    case IdrisDbType.dateTimeList:
    case IdrisDbType.doubleList:
    case IdrisDbType.stringList:
    case IdrisDbType.objectList:
      var code = '''
      {
        final list = $value;''';
      if (nullable) {
        code +=
            '''
        if (list == null) {
          IdrisDbCore.writeNull($writer, $index);
        } else {''';
      }
      code +=
          '''
      final listWriter = IdrisDbCore.beginList(writer, $index, list.length);
      for (var i = 0; i < list.length; i++) {
        ${_writeProperty(writer: 'listWriter', index: 'i', type: type.scalarType, nullable: elementNullable!, typeClassName: typeClassName, value: 'list[i]', enumProperty: enumProperty)}
      }
      IdrisDbCore.endList(writer, listWriter);
      ''';
      if (nullable) {
        code += '}';
      }
      return '$code}';
  }
}
