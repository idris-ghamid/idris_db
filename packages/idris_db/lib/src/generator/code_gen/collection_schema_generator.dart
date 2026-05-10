part of '../idris_db_generator.dart';

String _generateSchema(ObjectInfo object) {
  String generatePropertySchema(PropertyInfo p) {
    return '''
    IdrisDbPropertySchema(
      name: '${p.idrisDbName}',
      type: IdrisDbType.${p.type.name},
      ${p.targetidrisDbName != null ? "target: '${p.targetidrisDbName}'," : ''}
      ${p.enumMap != null ? 'enumMap: ${jsonEncode(p.enumMap)},' : ''}
    ),''';
  }

  String generateIndexSchema(IndexInfo index) {
    return '''
    IdrisDbIndexSchema(
      name: '${index.name}',
      properties: [${index.properties.map((e) => '"$e",').join()}],
      unique: ${index.unique},
      hash: ${index.hash},
    ),''';
  }

  final embeddedSchemas = object.embeddedDartNames
      .map((e) => '${e.capitalize()}Schema')
      .join(',');
  final properties = object.properties
      .where((e) => !e.isId || e.type != IdrisDbType.long)
      .map(generatePropertySchema)
      .join();
  final indexes = object.indexes.map(generateIndexSchema).join();
  return '''
    final ${object.dartName.capitalize()}Schema = IdrisDbGeneratedSchema(
      schema: IdrisDbSchema(
        name: '${object.idrisDbName}',
        ${object.idProperty != null ? "idName: '${object.idProperty!.idrisDbName}'," : ''}
        embedded: ${object.isEmbedded},
        properties: [$properties],
        indexes: [$indexes],
      ),
      converter: IDRISDBObjectConverter<${object.idProperty?.dartType ?? 'void'}, ${object.dartName}>(
        serialize: serialize${object.dartName},
        deserialize: deserialize${object.dartName},
        ${!object.isEmbedded ? 'deserializeProperty: deserialize${object.dartName}Prop,' : ''}
      ),
      ${object.isEmbedded ? '' : 'getEmbeddedSchemas: () => [$embeddedSchemas],'}
    );''';
}
