// composite indexes cannot have more than 3 properties

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Index(composite: ['int2', 'int3', 'int4'])
  int? int1;

  int? int2;

  int? int3;

  int? int4;
}
