// json properties cannot be indexed

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @index
  dynamic val1;

  String? val2;
}
