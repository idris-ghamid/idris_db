part of 'idris_db_generator.dart';

const _ignoreLints = [
  'duplicate_ignore',
  'invalid_use_of_protected_member',
  'lines_longer_than_80_chars',
  'constant_identifier_names',
  'avoid_js_rounded_ints',
  'no_leading_underscores_for_local_identifiers',
  'require_trailing_commas',
  'unnecessary_parenthesis',
  'unnecessary_raw_strings',
  'unnecessary_null_in_if_null_operators',
  'library_private_types_in_public_api',
  'prefer_const_constructors',
];

class _IDRISDBCollectionGenerator extends GeneratorForAnnotation<Collection> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final object = _IdrisDbAnalyzer().analyzeCollection(element);
    final idType = object.idProperty!.type == IdrisDbType.string
        ? 'String'
        : 'int';
    return '''
      // coverage:ignore-file
      // ignore_for_file: ${_ignoreLints.join(', ')}
      // ignore_for_file: type=lint

      extension Get${object.dartName}Collection on IdrisDb {
        IdrisDbCollection<$idType, ${object.dartName}> get ${object.accessor} => this.collection();
      }

      ${_generateSchema(object)}

      ${_generateSerialize(object)}

      ${_generateDeserialize(object)}

      ${_generateDeserializeProp(object)}

      ${_generateUpdate(object)}

      ${_generateEnumMaps(object)}

      ${_FilterGenerator(object).generate()}

      ${_generateQueryObjects(object)}

      ${_generateSortBy(object)}

      ${_generateDistinctBy(object)}
      
      ${_generatePropertyQuery(object)}
    ''';
  }
}

class _IDRISDBEmbeddedGenerator extends GeneratorForAnnotation<Embedded> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final object = _IdrisDbAnalyzer().analyzeEmbedded(element);
    return '''
      // coverage:ignore-file
      // ignore_for_file: ${_ignoreLints.join(', ')}
      // ignore_for_file: type=lint

      ${_generateSchema(object)}

      ${_generateSerialize(object)}

      ${_generateDeserialize(object)}

      ${_generateEnumMaps(object)}

      ${_FilterGenerator(object).generate()}

      ${_generateQueryObjects(object)}
    ''';
  }
}
