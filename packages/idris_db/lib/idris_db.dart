/// Fast, easy to use, and fully async NoSQL database for Flutter and Dart.
///
/// IdrisDb is a high-performance embedded database that offers rich
/// features like transactions, queries, watchers, and synchronous/asynchronous
/// operations out of the box.
///
/// **Enhanced by IDRISIUM Corp | Idris Ghamid**
/// Fork of idris_db with exclusive features and better compatibility.
library;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:idris_db/src/idris_db_connect_api.dart';
import 'package:idris_db/src/native/native.dart'
    if (dart.library.js_interop) 'src/web/web.dart';
import 'package:logger/web.dart';
import 'package:meta/meta.dart';
import 'package:meta/meta_meta.dart';

part 'src/annotations/collection.dart';
part 'src/annotations/embedded.dart';
part 'src/annotations/enum_value.dart';
part 'src/annotations/id.dart';
part 'src/annotations/ignore.dart';
part 'src/annotations/index.dart';
part 'src/annotations/name.dart';
part 'src/annotations/type.dart';
part 'src/annotations/utc.dart';
part 'src/compact_condition.dart';
part 'src/errors/collection_not_found_error.dart';
part 'src/errors/data_validation_error.dart';
part 'src/errors/idris_db_error.dart';
part 'src/errors/query_execution_error.dart';
part 'src/errors/schema_validation_error.dart';
part 'src/errors/transaction_error.dart';
part 'src/impl/filter_builder.dart';
part 'src/impl/idris_db_collection_impl.dart';
part 'src/impl/idris_db_impl.dart';
part 'src/impl/idris_db_query_impl.dart';
part 'src/impl/native_error.dart';
part 'src/idris_db.dart';
part 'src/idris_db_collection.dart';
part 'src/idris_db_connect.dart';
part 'src/idris_db_core.dart';
part 'src/idris_db_error.dart';
part 'src/idris_db_generated_schema.dart';
part 'src/idris_db_query.dart';
part 'src/idris_db_schema.dart';
part 'src/logging/idris_db_logger.dart';
part 'src/logging/log_entry.dart';
part 'src/logging/log_level.dart';
part 'src/logging/logging_mixin.dart';
part 'src/performance/query_analyzer.dart';
part 'src/query_builder.dart';
part 'src/query_components.dart';
part 'src/query_extensions.dart';
part 'src/watcher_details.dart';

/// @nodoc
@protected
/// ignored to avoid "unused import" warnings
// ignore: specify_nonobvious_property_types
const idrisDbProtected = protected;

/// @nodoc
@protected
const String Function(
  Object? object, {
  Object? Function(Object? nonEncodable)? toEncodable,
})
idrisDbJsonEncode = jsonEncode;

/// @nodoc
@protected
const Object? Function(
  String source, {
  Object? Function(Object? key, Object? value)? reviver,
})
idrisDbJsonDecode = jsonDecode;
