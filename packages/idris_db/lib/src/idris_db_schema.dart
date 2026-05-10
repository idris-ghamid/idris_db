part of 'package:idris_db/idris_db.dart';

/// The schema of a collection in IdrisDb.
///
/// This class represents the structure of a collection. This includes the
/// collection name, the properties and indexes.
class IdrisDbSchema {
  /// @nodoc
  const IdrisDbSchema({
    required this.name,
    required this.embedded,
    required this.properties,
    required this.indexes,
    this.idName,
  });

  /// @nodoc
  factory IdrisDbSchema.fromJson(Map<String, dynamic> json) {
    return IdrisDbSchema(
      name: json['name'] as String,
      idName: json['idName'] as String?,
      embedded: json['embedded'] as bool,
      properties: (json['properties'] as List<dynamic>)
          .map((e) => IdrisDbPropertySchema.fromJson(e as Map<String, dynamic>))
          .toList(),
      indexes: (json['indexes'] as List<dynamic>)
          .map((e) => IdrisDbIndexSchema.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The name of the collection.
  final String name;

  /// The name of the id property. Only String id properties are defined
  /// in [properties].
  final String? idName;

  /// Whether this collection is embedded in another object.
  final bool embedded;

  /// The properties of this collection.
  final List<IdrisDbPropertySchema> properties;

  /// The indexes of this collection.
  final List<IdrisDbIndexSchema> indexes;

  /// @nodoc
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'idName': idName,
      'embedded': embedded,
      'properties': properties.map((e) => e.toJson()).toList(),
      'indexes': indexes.map((e) => e.toJson()).toList(),
    };
  }

  /// Get the index of a property in this schema.
  int getPropertyIndex(String property) {
    for (var i = 0; i < properties.length; i++) {
      if (properties[i].name == property) {
        return i + 1;
      }
    }
    if (idName == property) {
      return 0;
    }
    throw ArgumentError('Property $property not found in schema $name');
  }

  /// Get the property schema by its index.
  IdrisDbPropertySchema getPropertyByIndex(int index) {
    if (index == 0) {
      return IdrisDbPropertySchema(name: idName!, type: IdrisDbType.long);
    } else {
      return properties[index - 1];
    }
  }
}

/// The schema of a property in IdrisDb.
class IdrisDbPropertySchema {
  /// @nodoc
  const IdrisDbPropertySchema({
    required this.name,
    required this.type,
    this.target,
    this.enumMap,
  });

  /// @nodoc
  factory IdrisDbPropertySchema.fromJson(Map<String, dynamic> json) {
    return IdrisDbPropertySchema(
      name: json['name'] as String,
      type: IdrisDbType.values.firstWhere(
        (e) => e.coreName == json['type'] as String,
      ),
      target: json['target'] as String?,
      enumMap: json['enumMap'] as Map<String, dynamic>?,
    );
  }

  /// The name of the property.
  final String name;

  /// The type of the property.
  final IdrisDbType type;

  /// If this property contains object(s), this is the name of the embedded
  /// collection.
  final String? target;

  /// If this property is an enum, this map contains the enum values.
  final Map<String, dynamic>? enumMap;

  /// @nodoc
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.coreName,
      if (target != null) 'target': target,
      if (enumMap != null) 'enumMap': enumMap,
    };
  }
}

/// The schema of an index in IdrisDb.
class IdrisDbIndexSchema {
  /// @nodoc
  const IdrisDbIndexSchema({
    required this.name,
    required this.properties,
    required this.unique,
    required this.hash,
  });

  /// @nodoc
  factory IdrisDbIndexSchema.fromJson(Map<String, dynamic> json) {
    return IdrisDbIndexSchema(
      name: json['name'] as String,
      properties: (json['properties'] as List).cast(),
      unique: json['unique'] as bool,
      hash: json['hash'] as bool,
    );
  }

  /// The name of the index.
  final String name;

  /// The properties of the index.
  final List<String> properties;

  /// Whether this index is unique.
  final bool unique;

  /// Whether this index should be hashed.
  final bool hash;

  /// @nodoc
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'properties': properties,
      'unique': unique,
      'hash': hash,
    };
  }
}

/// Supported IdrisDb property types.
enum IdrisDbType {
  /// boolean (1 byte)
  bool('Bool'),

  /// unsigned 8 bit integer (1 byte)
  byte('Byte'),

  /// signed 32 bit integer (4 bytes)
  int('Int'),

  /// 32 bit floating point (4 bytes)
  float('Float'),

  /// signed 64 bit integer (8 bytes)
  long('Long'),

  /// 64 bit floating point (8 bytes)
  double('Double'),

  /// date and time stored in UTC (8 bytes)
  dateTime('DateTime'),

  /// string (6 + length bytes)
  string('String'),

  /// embedded object (6 + size bytes)
  object('Object'),

  /// json (6 + length bytes)
  json('Json'),

  /// list of booleans (6 + length bytes)
  boolList('BoolList'),

  /// list of unsigned 8 bit integers (6 + length bytes)
  byteList('ByteList'),

  /// list of signed 32 bit integers (6 + length * 4 bytes)
  intList('IntList'),

  /// list of 32 bit floating points (6 + length * 4 bytes)
  floatList('FloatList'),

  /// list of signed 64 bit integers (6 + length * 8 bytes)
  longList('LongList'),

  /// list of 64 bit floating points (6 + length * 8 bytes)
  doubleList('DoubleList'),

  /// list of dates and times stored in UTC (6 + length * 8 bytes)
  dateTimeList('DateTimeList'),

  /// list of strings (6 + length * (6 + length) bytes)
  stringList('StringList'),

  /// list of embedded objects (6 + length * (6 + size) bytes)
  objectList('ObjectList');

  const IdrisDbType(this.coreName);

  /// @nodoc
  final String coreName;
}

/// @nodoc
extension IDRISDBTypeX on IdrisDbType {
  /// @nodoc
  bool get isBool => this == IdrisDbType.bool || this == IdrisDbType.boolList;

  /// @nodoc
  bool get isFloat =>
      this == IdrisDbType.float ||
      this == IdrisDbType.floatList ||
      this == IdrisDbType.double ||
      this == IdrisDbType.doubleList;

  /// @nodoc
  bool get isInt =>
      this == IdrisDbType.int ||
      this == IdrisDbType.int ||
      this == IdrisDbType.long ||
      this == IdrisDbType.longList;

  /// @nodoc
  bool get isNum => isFloat || isInt;

  /// @nodoc
  bool get isDate => this == IdrisDbType.dateTime || this == IdrisDbType.dateTimeList;

  /// @nodoc
  bool get isString => this == IdrisDbType.string || this == IdrisDbType.stringList;

  /// @nodoc
  bool get isObject => this == IdrisDbType.object || this == IdrisDbType.objectList;

  /// @nodoc
  bool get isList => scalarType != this;

  /// @nodoc
  IdrisDbType get scalarType {
    switch (this) {
      case IdrisDbType.boolList:
        return IdrisDbType.bool;
      case IdrisDbType.byteList:
        return IdrisDbType.byte;
      case IdrisDbType.intList:
        return IdrisDbType.int;
      case IdrisDbType.floatList:
        return IdrisDbType.float;
      case IdrisDbType.longList:
        return IdrisDbType.long;
      case IdrisDbType.doubleList:
        return IdrisDbType.double;
      case IdrisDbType.dateTimeList:
        return IdrisDbType.dateTime;
      case IdrisDbType.stringList:
        return IdrisDbType.string;
      case IdrisDbType.objectList:
        return IdrisDbType.object;
      // Default case needed for exhaustiveness even though all cases
      // are covered
      // ignore: no_default_cases
      default:
        return this;
    }
  }

  /// @nodoc
  IdrisDbType get listType {
    switch (this) {
      case IdrisDbType.bool:
        return IdrisDbType.boolList;
      case IdrisDbType.byte:
        return IdrisDbType.byteList;
      case IdrisDbType.int:
        return IdrisDbType.intList;
      case IdrisDbType.float:
        return IdrisDbType.floatList;
      case IdrisDbType.long:
        return IdrisDbType.longList;
      case IdrisDbType.double:
        return IdrisDbType.doubleList;
      case IdrisDbType.dateTime:
        return IdrisDbType.dateTimeList;
      case IdrisDbType.string:
        return IdrisDbType.stringList;
      case IdrisDbType.object:
        return IdrisDbType.objectList;
      // Default case needed for exhaustiveness even though all cases
      // are covered
      // ignore: no_default_cases
      default:
        return this;
    }
  }
}
