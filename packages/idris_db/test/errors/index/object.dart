// embedded object properties cannot be indexed

import 'package:idris_db/idris_db.dart';

@collection
class Model {
  late int id;

  @Index()
  EmbeddedModel? obj;
}

@embedded
class EmbeddedModel {}
