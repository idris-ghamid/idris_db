library;

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:idris_db/idris_db.dart';
import 'package:source_gen/source_gen.dart';

part 'code_gen/collection_schema_generator.dart';
part 'code_gen/deserialize_generator.dart';
part 'code_gen/enum_maps_generator.dart';
part 'code_gen/query_distinct_by_generator.dart';
part 'code_gen/query_filter_generator.dart';
part 'code_gen/query_object_generator.dart';
part 'code_gen/query_property_generator.dart';
part 'code_gen/query_sort_by_generator.dart';
part 'code_gen/serialize_generator.dart';
part 'code_gen/update_generator.dart';
part 'collection_generator.dart';
part 'helper.dart';
part 'idris_db_analyzer.dart';
part 'idris_db_type.dart';
part 'object_info.dart';

const _nullInt = -2147483648;
const _nullLong = -9223372036854775808;

/// Generates the IdrisDb code for the annotated classes.
Builder getIDRISDBGenerator(BuilderOptions options) => SharedPartBuilder([
  _IDRISDBCollectionGenerator(),
  _IDRISDBEmbeddedGenerator(),
], 'IDRISDB_generator');
