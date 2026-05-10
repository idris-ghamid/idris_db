// ids cannot be indexed

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Index(composite: ['id'])
  int? str;
}
