part of 'package:idris_db/idris_db.dart';

/// Annotation to nest objects of this type in collections.
const embedded = Embedded();

/// Annotation to nest objects of this type in collections.
@Target({TargetKind.classType})
class Embedded {
  /// Annotation to nest objects of this type in collections.
  const Embedded({this.inheritance = true, this.ignore = const {}});

  /// Should properties and accessors of parent classes and mixins be included?
  final bool inheritance;

  /// A list of properties or getter names that IdrisDb should ignore.
  final Set<String> ignore;
}
