import 'package:idris_db/idris_db.dart';

extension CollectionInfoX on IdrisDbSchema {
  List<IdrisDbPropertySchema> get idAndProperties {
    final props = [
      if (!this.embedded && !properties.any((e) => e.name == idName))
        IdrisDbPropertySchema(name: idName!, type: IdrisDbType.long),
      ...properties,
    ];
    props.sort((a, b) {
      if (a.name == idName) {
        return -1;
      } else if (b.name == idName) {
        return 1;
      } else {
        return a.name.compareTo(b.name);
      }
    });
    return props;
  }
}

extension TypeName on IdrisDbType {
  String get typeName {
    switch (this) {
      case IdrisDbType.bool:
        return 'bool';
      case IdrisDbType.byte:
        return 'byte';
      case IdrisDbType.int:
        return 'short';
      case IdrisDbType.long:
        return 'int';
      case IdrisDbType.float:
        return 'float';
      case IdrisDbType.double:
        return 'double';
      case IdrisDbType.dateTime:
        return 'DateTime';
      case IdrisDbType.string:
        return 'String';
      case IdrisDbType.object:
        return 'Object';
      case IdrisDbType.json:
        return 'Json';
      case IdrisDbType.boolList:
        return 'List<bool>';
      case IdrisDbType.byteList:
        return 'List<byte>';
      case IdrisDbType.intList:
        return 'List<short>';
      case IdrisDbType.longList:
        return 'List<int>';
      case IdrisDbType.floatList:
        return 'List<float>';
      case IdrisDbType.doubleList:
        return 'List<double>';
      case IdrisDbType.dateTimeList:
        return 'List<DateTime>';
      case IdrisDbType.stringList:
        return 'List<String>';
      case IdrisDbType.objectList:
        return 'List<Object>';
    }
  }
}
