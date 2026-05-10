// last property of a non-hashed composite index can be a string

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Index(composite: ['str2'])
  String? str1;

  String? str2;
}
