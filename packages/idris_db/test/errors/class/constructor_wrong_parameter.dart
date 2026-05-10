// constructor parameter type does not match property type

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  /// ignored to avoid "unused constructor parameters" warning
  // ignore: avoid_unused_constructor_parameters
  Model(int prop1);

  late int id;

  String prop1 = '5';
}
