import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'enum_test.g.dart';

// ignore_for_file: unreachable_from_main

enum IndexEnum { option1, option2, option3 }

enum ByteEnum {
  option1(1),
  option2(2),
  option3(3);

  const ByteEnum(this.value);

  @enumValue
  final byte value;
}

enum ByteEnum2 {
  option1(2),
  option2(4),
  option3(6),
  option4(8);

  const ByteEnum2(this.value);

  @enumValue
  final byte value;
}

enum ShortEnum {
  option1(5),
  option2(6),
  option3(77);

  const ShortEnum(this.value);

  @enumValue
  final short value;
}

enum IntEnum {
  option1(-1),
  option2(0),
  option3(1);

  const IntEnum(this.value);

  @enumValue
  final int value;
}

enum StringEnum {
  option1('a'),
  option2('b'),
  option3('c');

  const StringEnum(this.value);

  @enumValue
  final String value;
}

@collection
class EnumModel {
  EnumModel(
    this.id,
    this.ordinalEnum,
    this.byteEnum,
    this.shortEnum,
    this.intEnum,
    this.stringEnum,
  );

  final int id;

  final IndexEnum ordinalEnum;

  final ByteEnum byteEnum;

  final ShortEnum shortEnum;

  final IntEnum intEnum;

  final StringEnum stringEnum;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is EnumModel &&
      other.ordinalEnum == ordinalEnum &&
      other.byteEnum == byteEnum &&
      other.shortEnum == shortEnum &&
      other.intEnum == intEnum &&
      other.stringEnum == stringEnum;
}

void main() {
  // TODO(ahmtydn): implement enum tests
  group('Enum', () {
    IdrisDbTest('Verify property types', () {});

    IdrisDbTest('.get() / .put()', () async {});

    IdrisDbTest('DateTime Enum', () {});

    IdrisDbTest('Added value', () {});

    IdrisDbTest('Removed value', () {});

    IdrisDbTest('.exportJson()', () {});

    IdrisDbTest('.importJson()', () {});
  });
}
