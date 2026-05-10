part of 'idris_db_generator.dart';

/// Represents information about an IdrisDb object for code generation.
class ObjectInfo {
  /// Creates an [ObjectInfo] instance.
  const ObjectInfo({
    /// The Dart name of the object.
    required this.dartName,

    /// The IdrisDb name of the object.
    required this.idrisDbName,

    /// The list of properties in the object.
    required this.properties,

    /// The list of indexes on the object.
    this.indexes = const [],

    /// The accessor for embedded objects.
    this.accessor,

    /// The set of embedded Dart names.
    this.embeddedDartNames = const {},
  });

  /// The Dart name of the object.
  final String dartName;

  /// The IdrisDb name of the object.
  final String idrisDbName;

  /// The accessor for embedded objects.
  final String? accessor;

  /// The list of properties in the object.
  final List<PropertyInfo> properties;

  /// The list of indexes on the object.
  final List<IndexInfo> indexes;

  /// The set of embedded Dart names.
  final Set<String> embeddedDartNames;

  /// Whether this object is embedded.
  bool get isEmbedded => accessor == null;

  /// The ID property of the object, if any.
  PropertyInfo? get idProperty => properties.where((it) => it.isId).firstOrNull;
}

/// @nodoc
enum DeserializeMode {
  /// @nodoc
  none,

  /// @nodoc
  assign,

  /// Positional parameter.
  positionalParam,

  /// @nodoc
  namedParam,
}

/// Represents information about a property in an
/// IdrisDb object for code generation.
class PropertyInfo {
  /// @nodoc
  PropertyInfo({
    /// The index of the property.
    required this.index,

    /// The Dart name of the property.
    required this.dartName,

    /// The IdrisDb name of the property.
    required this.idrisDbName,

    /// The class name of the property type.
    required this.typeClassName,

    /// The target IdrisDb name for links.
    required this.targetidrisDbName,

    /// The IdrisDb type of the property.
    required this.type,

    /// Whether this property is the ID.
    required this.isId,

    /// The enum map for enum properties.
    required this.enumMap,

    /// The enum property name.
    required this.enumProperty,

    /// Whether the property is nullable.
    required this.nullable,

    /// Whether elements in a list are nullable.
    required this.elementNullable,

    /// The default value of the property.
    required this.defaultValue,

    /// The default value for list elements.
    required this.elementDefaultValue,

    /// Whether to use UTC for DateTime.
    required this.utc,

    /// The deserialization mode.
    required this.mode,

    /// Whether the property is assignable.
    required this.assignable,

    /// The constructor position.
    required this.constructorPosition,
  });

  /// The index of the property.
  final int index;

  /// The Dart name of the property.
  final String dartName;

  /// The IdrisDb name of the property.
  final String idrisDbName;

  /// The class name of the property type.
  final String typeClassName;

  /// The target IdrisDb name for links.
  final String? targetidrisDbName;

  /// The IdrisDb type of the property.
  final IdrisDbType type;

  /// Whether this property is the ID.
  final bool isId;

  /// The enum map for enum properties.
  final Map<String, dynamic>? enumMap;

  /// The enum property name.
  final String? enumProperty;

  /// Whether the property is nullable.
  final bool nullable;

  /// Whether elements in a list are nullable.
  final bool? elementNullable;

  /// The default value of the property.
  final String defaultValue;

  /// The default value for list elements.
  final String? elementDefaultValue;

  /// Whether to use UTC for DateTime.
  final bool utc;

  /// The deserialization mode.
  final DeserializeMode mode;

  /// Whether the property is assignable.
  final bool assignable;

  /// The constructor position.
  final int? constructorPosition;

  /// Whether this property is an enum.
  bool get isEnum => enumMap != null;

  /// The scalar Dart type without nullability.
  String get scalarDartTypeNotNull {
    if (isEnum) {
      return typeClassName;
    }

    switch (type) {
      case IdrisDbType.bool:
      case IdrisDbType.boolList:
        return 'bool';
      case IdrisDbType.byte:
      case IdrisDbType.byteList:
      case IdrisDbType.int:
      case IdrisDbType.intList:
      case IdrisDbType.long:
      case IdrisDbType.longList:
        return 'int';
      case IdrisDbType.float:
      case IdrisDbType.floatList:
      case IdrisDbType.double:
      case IdrisDbType.doubleList:
        return 'double';
      case IdrisDbType.dateTime:
      case IdrisDbType.dateTimeList:
        return 'DateTime';
      case IdrisDbType.object:
      case IdrisDbType.objectList:
        return typeClassName;
      case IdrisDbType.string:
      case IdrisDbType.stringList:
        return 'String';
      case IdrisDbType.json:
        if (typeClassName == 'List') {
          return 'List<dynamic>';
        } else if (typeClassName == 'Map') {
          return 'Map<String, dynamic>';
        } else {
          return 'dynamic';
        }
    }
  }

  /// The scalar Dart type with nullability.
  String get scalarDartType {
    final sNN = scalarDartTypeNotNull;
    return type.isList
        ? '$sNN${elementNullable! && typeClassName != 'dynamic' ? '?' : ''}'
        : '$sNN${nullable && typeClassName != 'dynamic' ? '?' : ''}';
  }

  /// The full Dart type of the property.
  String get dartType => type.isList
      ? 'List<$scalarDartType>${nullable ? '?' : ''}'
      : scalarDartType;

  /// Generates the enum map name for this property.
  String enumMapName(ObjectInfo object) =>
      '_${object.dartName.decapitalize()}${dartName.capitalize()}';
}

/// Represents information about an index in an IdrisDb object for code generation.
class IndexInfo {
  /// @nodoc
  IndexInfo({
    /// The name of the index.
    required this.name,

    /// The properties included in the index.
    required this.properties,

    /// Whether the index is unique.
    required this.unique,

    /// Whether the index uses hashing.
    required this.hash,
  });

  /// The name of the index.
  final String name;

  /// The properties included in the index.
  final List<String> properties;

  /// Whether the index is unique.
  final bool unique;

  /// Whether the index uses hashing.
  final bool hash;
}
