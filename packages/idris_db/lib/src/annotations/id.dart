part of 'package:idris_db/idris_db.dart';

/// Annotate the property or accessor in an IdrisDb collection that should be used
/// as the primary key.
const id = Id();

/// @nodoc
@Target({TargetKind.field, TargetKind.getter})
class Id {
  /// @nodoc
  const Id();
}
