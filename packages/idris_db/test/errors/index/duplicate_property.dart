// composite index contains duplicate properties

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Index(composite: ['str2', 'str1'])
  String? str1;

  String? str2;
}
