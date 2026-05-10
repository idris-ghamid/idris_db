part of 'package:idris_db/idris_db.dart';

/// Annotate IdrisDb collections or properties to change their name.
///
/// Can be used to change the name in Dart independently of IdrisDb.
@Target({TargetKind.classType, TargetKind.field, TargetKind.getter})
class Name {
  /// Annotate IdrisDb collections or properties to change their name.
  const Name(this.name);

  /// The name this entity should have in the database.
  final String name;
}
