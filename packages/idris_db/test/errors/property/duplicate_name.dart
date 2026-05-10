// same name

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  String? prop1;

  @Name('prop1')
  String? prop2;
}
