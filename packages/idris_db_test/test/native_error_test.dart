import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'native_error_test.g.dart';

@collection
class SimpleModel {
  SimpleModel(this.id);

  final int id;

  String value = '';

  @override
  bool operator ==(Object other) =>
      other is SimpleModel && id == other.id && value == other.value;

  @override
  int get hashCode => Object.hash(id, value);
}

void main() {
  group('Native Errors', () {
    IdrisDbTest('PathError - invalid directory', web: false, () async {
      await prepareTest();
      expect(
        () => IdrisDb.open(
          schemas: [SimpleModelSchema],
          name: 'test_path_error',
          directory: '/nonexistent_root_path/subdir/another',
          inspector: false,
        ),
        throwsA(isA<PathError>()),
      );
    });

    IdrisDbTest(
      'DatabaseError - generic database error with message',
      sqlite: false,
      web: false,
      () async {
        await prepareTest();
        expect(
          () => IdrisDb.open(
            schemas: [SimpleModelSchema],
            name: 'test_db_error',
            directory: testTempPath ?? '.',
            maxSizeMiB: -1,
            inspector: false,
          ),
          throwsA(isA<DatabaseError>()),
        );
      },
    );
  });
}
