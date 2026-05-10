// names must not be blank or start with "_"

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Name('_prop')
  String? prop;
}
