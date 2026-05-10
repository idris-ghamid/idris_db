// list properties cannot be indexed

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @index
  List<int>? val1;

  String? val2;
}
