// ids cannot be indexed

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late String id;

  @Index(composite: ['id'])
  int? value;
}
