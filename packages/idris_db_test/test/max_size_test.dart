import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'max_size_test.g.dart';

@collection
class Model {
  Model(this.id);

  final int id;

  final String value = '123456789' * 1000;
}

void main() {
  group('Max Size', () {
    IdrisDbTest('default', () async {
      final IdrisDb = await openTempIDRISDB([ModelSchema]);
      IdrisDb.write((IdrisDb) {
        IdrisDb.models.putAll(List.generate(1000, Model.new));
      });
    });

    IdrisDbTest('10MB', sqlite: false, web: false, () async {
      final IdrisDb = await openTempIDRISDB([ModelSchema], maxSizeMiB: 10);

      expect(
        () => IdrisDb.write((IdrisDb) {
          IdrisDb.models.putAll(List.generate(1000, Model.new));
        }),
        throwsA(isA<DatabaseFullError>()),
      );

      IdrisDb.write((IdrisDb) {
        IdrisDb.models.putAll(List.generate(50, Model.new));
      });
    });
  });
}
