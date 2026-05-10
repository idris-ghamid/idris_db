// unsupported enum property type

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  late MyEnum prop;
}

enum MyEnum {
  optionA;

  @enumValue
  final List<String> value = [];
}
