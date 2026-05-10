part of 'package:idris_db/idris_db.dart';

/// Annotate a property or accessor in an IdrisDb collection to ignore it.
const ignore = Ignore();

/// @nodoc
@Target({TargetKind.field, TargetKind.getter})
class Ignore {
  /// @nodoc
  const Ignore();
}
