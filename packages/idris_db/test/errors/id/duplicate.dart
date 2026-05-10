// two or more properties are annotated with @id

import 'package:idris_db/idris_db.dart';

@collection
class Test {
  @id
  late int id1;

  @id
  late int id2;
}
