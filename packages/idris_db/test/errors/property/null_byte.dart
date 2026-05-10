// bytes must not be nullable

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  late byte? prop;
}
