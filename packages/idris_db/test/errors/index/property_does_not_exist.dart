// property does not exist

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Index(composite: ['myProp'])
  int? value;
}
