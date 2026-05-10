// only classes

import 'package:idris_db/idris_db.dart';

// Test case: collection annotation should only be used on classes, not enums
// ignore: invalid_annotation_target
@collection
enum Test { a, b, c }
