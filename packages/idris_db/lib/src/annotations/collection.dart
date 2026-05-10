part of 'package:idris_db/idris_db.dart';

/// Annotation to create an IdrisDb collection.
const collection = Collection();

/// Annotation to create an IdrisDb collection.
@Target({TargetKind.classType})
class Collection {
  /// Annotation to create an IdrisDb collection.
  const Collection({
    this.inheritance = true,
    this.accessor,
    this.ignore = const {'copyWith'},
  });

  /// Should properties and accessors of parent classes and mixins be included?
  final bool inheritance;

  /// Allows you to override the default collection accessor.
  ///
  /// Example:
  /// ```dart
  /// @Collection(accessor: 'col')
  /// class MyCol {
  ///   Id? id;
  /// }
  ///
  /// // access collection:
  /// IdrisDb.col.where().findAll();
  /// ```
  final String? accessor;

  /// A list of properties or getter names that IdrisDb should ignore.
  final Set<String> ignore;
}
