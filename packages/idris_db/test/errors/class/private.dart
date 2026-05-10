// must be public

import 'package:idris_db/idris_db.dart';

@collection
// Test case: private class for testing collection annotation errors
// ignore: unused_element
class _Model {
  late int id;
}
