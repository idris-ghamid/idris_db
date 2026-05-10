// only int and string properties can be used as id

import 'package:idris_db/idris_db.dart';

@collection
class Test {
  late TestEnum id;
}

enum TestEnum { a, b, c }
