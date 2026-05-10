// must not be abstract

import 'package:idris_db/idris_db.dart';

@collection
abstract class Model {
  late int id;
}
