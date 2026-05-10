// same name

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Index(name: 'myindex')
  String? prop1;

  @Index(name: 'myindex')
  String? prop2;
}
