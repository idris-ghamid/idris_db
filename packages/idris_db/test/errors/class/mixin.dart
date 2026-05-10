// only classes

import 'package:idris_db/idris_db.dart';

// Test case: collection annotation should only be used on classes, not mixins
// ignore: invalid_annotation_target
@collection
mixin Test {}
