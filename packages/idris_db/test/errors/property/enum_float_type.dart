// unsupported enum property type

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  late MyEnum field;
}

enum MyEnum {
  optionA;

  @enumValue
  final float value = 5.5;
}
