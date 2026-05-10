part of '../idris_db_generator.dart';

String _generateDeserialize(ObjectInfo object) {
  final buffer = StringBuffer('''
  @IDRISDBProtected
  ${object.dartName} deserialize${object.dartName}(IDRISDBReader reader) {''');

  final propertiesByMode = {
    DeserializeMode.none: <PropertyInfo>[],
    DeserializeMode.assign: <PropertyInfo>[],
    DeserializeMode.positionalParam: <PropertyInfo>[],
    DeserializeMode.namedParam: <PropertyInfo>[],
  };
  for (final property in object.properties) {
    propertiesByMode[property.mode]!.add(property);
  }

  final positional = propertiesByMode[DeserializeMode.positionalParam]!
    ..sort(
      (p1, p2) => p1.constructorPosition!.compareTo(p2.constructorPosition!),
    );
  final named = propertiesByMode[DeserializeMode.namedParam]!;

  for (final p in [...positional, ...named]) {
    buffer
      ..write('final ${p.dartType} _${p.dartName};')
      ..write(
        _deserializeProperty(object, p, (value) {
          return '_${p.dartName} = $value;';
        }),
      );
  }

  buffer.write('final object = ${object.dartName}(');

  for (final p in positional) {
    buffer.write('_${p.dartName},');
  }

  for (final p in named) {
    buffer.write('${p.dartName}: _${p.dartName},');
  }

  buffer.write(');');

  final assign = propertiesByMode[DeserializeMode.assign]!;
  for (final p in assign) {
    buffer.write(
      _deserializeProperty(object, p, (value) {
        return 'object.${p.dartName} = $value;';
      }),
    );
  }

  return '''
    $buffer
    return object;
  }''';
}

String _generateDeserializeProp(ObjectInfo object) {
  final buffer = StringBuffer('''
    @IDRISDBProtected
    dynamic deserialize${object.dartName}Prop(IDRISDBReader reader, int property) {
      switch (property) {''');
  for (final p in object.properties) {
    final deser = _deserializeProperty(object, p, (value) {
      return 'return $value;';
    });
    buffer.write('case ${p.index}: $deser');
  }

  return '''
      $buffer
      default:
        throw ArgumentError('Unknown property: \$property');
      }
    }
    ''';
}

String _deserializeProperty(
  ObjectInfo object,
  PropertyInfo p,
  String Function(String value) result,
) {
  return _deserialize(
    index: p.index.toString(),
    isId: p.isId,
    typeClassName: p.typeClassName,
    type: p.type,
    elementDartType: p.scalarDartType,
    defaultValue: p.defaultValue,
    elementDefaultValue: p.elementDefaultValue,
    utc: p.utc,
    transform: (value) {
      if (p.isEnum && !p.type.isList && value != p.defaultValue) {
        return result('${p.enumMapName(object)}[$value] ?? ${p.defaultValue}');
      } else {
        return result(value);
      }
    },
    transformElement: (value) {
      if (p.isEnum && value != p.elementDefaultValue) {
        return '${p.enumMapName(object)}[$value] ?? ${p.elementDefaultValue}';
      } else {
        return value;
      }
    },
  );
}

String _deserialize({
  required String index,
  required bool isId,
  required String typeClassName,
  required IdrisDbType type,
  required String defaultValue,
  required bool utc,
  required String Function(String value) transform,
  String? elementDartType,
  String? elementDefaultValue,
  String Function(String value)? transformElement,
}) {
  switch (type) {
    case IdrisDbType.bool:
      if (defaultValue == 'false') {
        return transform('IdrisDbCore.readBool(reader, $index)');
      } else {
        return '''
        {
          if (IdrisDbCore.readNull(reader, $index)) {
            ${transform(defaultValue)}
          } else {
            ${transform('IdrisDbCore.readBool(reader, $index)')}
          }
        }''';
      }
    case IdrisDbType.byte:
      if (defaultValue == '0') {
        return transform('IdrisDbCore.readByte(reader, $index)');
      } else {
        return '''
        {
          if (IdrisDbCore.readNull(reader, $index)) {
            ${transform(defaultValue)}
          } else {
            ${transform('IdrisDbCore.readByte(reader, $index)')}
          }
        }''';
      }
    case IdrisDbType.int:
      if (defaultValue == '$_nullInt') {
        return transform('IdrisDbCore.readInt(reader, $index)');
      } else {
        return '''
        {
          final value = IdrisDbCore.readInt(reader, $index);
          if (value == $_nullInt) {
            ${transform(defaultValue)}
          } else {
            ${transform('value')}
          }
        }''';
      }
    case IdrisDbType.float:
      if (defaultValue == 'double.nan') {
        return transform('IdrisDbCore.readFloat(reader, $index)');
      } else {
        return '''
        {
          final value = IdrisDbCore.readFloat(reader, $index);
          if (value.isNaN) {
            ${transform(defaultValue)}
          } else {
            ${transform('value')}
          }
        }''';
      }
    case IdrisDbType.long:
      if (isId) {
        return transform('IdrisDbCore.readId(reader)');
      } else if (defaultValue == '$_nullLong') {
        return transform('IdrisDbCore.readLong(reader, $index)');
      } else {
        return '''
        {
          final value = IdrisDbCore.readLong(reader, $index);
          if (value == $_nullLong) {
            ${transform(defaultValue)}
          } else {
            ${transform('value')}
          }
        }''';
      }
    case IdrisDbType.dateTime:
      final toLocal = utc ? '' : '.toLocal()';
      return '''
        {
          final value = IdrisDbCore.readLong(reader, $index);
          if (value == $_nullLong) {
            ${transform(defaultValue)}
          } else {
            ${transform('DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true)$toLocal')}
          }
        }''';

    case IdrisDbType.double:
      if (defaultValue == 'double.nan') {
        return transform('IdrisDbCore.readDouble(reader, $index)');
      } else {
        return '''
        {
          final value = IdrisDbCore.readDouble(reader, $index);
          if (value.isNaN) {
            ${transform(defaultValue)}
          } else {
            ${transform('value')}
          }
        }''';
      }
    case IdrisDbType.string:
      if (defaultValue == 'null') {
        return transform('IdrisDbCore.readString(reader, $index)');
      } else {
        return transform(
          'IdrisDbCore.readString(reader, $index) ?? $defaultValue',
        );
      }

    case IdrisDbType.object:
      return '''
      {
        final objectReader = IdrisDbCore.readObject(reader, $index);
        if (objectReader.isNull) {
          ${transform(defaultValue)}
        } else {
          final embedded = deserialize$typeClassName(objectReader);
          IdrisDbCore.freeReader(objectReader);
          ${transform('embedded')}
        }
      }''';
    case IdrisDbType.boolList:
    case IdrisDbType.byteList:
    case IdrisDbType.intList:
    case IdrisDbType.floatList:
    case IdrisDbType.longList:
    case IdrisDbType.dateTimeList:
    case IdrisDbType.doubleList:
    case IdrisDbType.stringList:
    case IdrisDbType.objectList:
      final deser = _deserialize(
        index: 'i',
        isId: false,
        typeClassName: typeClassName,
        type: type.scalarType,
        defaultValue: elementDefaultValue!,
        utc: utc,
        transform: (value) => 'list[i] = ${transformElement!(value)};',
      );
      return '''
      {
        final length = IdrisDbCore.readList(reader, $index, IdrisDbCore.readerPtrPtr);
        {
          final reader = IdrisDbCore.readerPtr;
          if (reader.isNull) {
            ${transform(defaultValue)}
          } else {
            final list = List<$elementDartType>.filled(length, $elementDefaultValue, growable: true);
            for (var i = 0; i < length; i++) {
              $deser
            }
            IdrisDbCore.freeReader(reader);
            ${transform('list')}
          }
        }
      }''';
    case IdrisDbType.json:
      if (typeClassName == 'dynamic') {
        return transform(
          'IDRISDBJsonDecode(IdrisDbCore.readString(reader, $index) '
          "?? 'null') ?? $defaultValue",
        );
      } else {
        return '''
        {
          final json = IDRISDBJsonDecode(IdrisDbCore.readString(reader, $index) ?? 'null');
          if (json is ${typeClassName == 'List' ? 'List' : 'Map<String, dynamic>'}) {
            ${typeClassName == 'List' || typeClassName == 'Map' ? transform('json') : transform('$typeClassName.fromJson(json)')}
          } else {
            ${transform(defaultValue)}
          }
        }''';
      }
  }
}
