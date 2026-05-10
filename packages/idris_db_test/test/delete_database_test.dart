@TestOn('vm')
library;

import 'dart:io';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

part 'delete_database_test.g.dart';

@collection
class Model {
  Model(this.id);

  final int id;
}

void main() {
  group('Delete database', () {
    IdrisDbTest('should delete the database file', () async {
      final IdrisDb = await openTempIDRISDB([ModelSchema]);
      final name = IdrisDb.name;
      final directory = IdrisDb.directory;

      final dbFile = File(
        path.join(directory, isSQLite ? '$name.sqlite' : '$name.IdrisDb'),
      );
      final lockFile = File(path.join(directory, '$name.lock'));

      expect(dbFile.existsSync(), true);
      expect(IdrisDb.close(), true);
      IdrisDb.deleteDatabase(
        name: name,
        directory: directory,
        engine: isSQLite ? IdrisDbEngine.sqlite : IdrisDbEngine.IdrisDb,
      );

      expect(dbFile.existsSync(), false);
      expect(lockFile.existsSync(), false);
    });

    IdrisDbTest('should throw if database is open', () async {
      final IdrisDb = await openTempIDRISDB([ModelSchema]);
      final name = IdrisDb.name;
      final directory = IdrisDb.directory;
      try {
        IdrisDb.deleteDatabase(
          name: name,
          directory: directory,
          engine: isSQLite ? IdrisDbEngine.sqlite : IdrisDbEngine.IdrisDb,
        );
      } on Object catch (e) {
        expect(e, isA<IdrisDbError>());
        IdrisDb.close();
        return;
      }
      IdrisDb.close();
    });

    IdrisDbTest('Accessing closed IdrisDb throws IdrisDbNotReadyError', () async {
      final IdrisDb = await openTempIDRISDB([ModelSchema], closeAutomatically: false);
      IdrisDb.close();

      expect(() => IdrisDb.models.count(), throwsA(isA<IdrisDbNotReadyError>()));
    });

    IdrisDbTest(
      'IdrisDb.get throws when instance not opened',
      sqlite: false,
      () async {
        expect(
          () => IdrisDb.get(
            schemas: [ModelSchema],
            name: 'nonexistent_${DateTime.now().millisecondsSinceEpoch}',
          ),
          throwsA(isA<IdrisDbNotReadyError>()),
        );
      },
    );

    IdrisDbTest(
      'IdrisDb.get throws when instance not opened (SQLite)',
      IdrisDb: false,
      () async {
        expect(
          () => IdrisDb.get(
            schemas: [ModelSchema],
            name: 'nonexistent_sqlite_${DateTime.now().millisecondsSinceEpoch}',
          ),
          throwsA(isA<IdrisDbNotReadyError>()),
        );
      },
    );

    IdrisDbTest('Query on closed IdrisDb throws IdrisDbNotReadyError', () async {
      final IdrisDb = await openTempIDRISDB([ModelSchema], closeAutomatically: false);
      IdrisDb.write((IdrisDb) {
        IdrisDb.models.put(Model(1));
      });

      // Get a query reference while IdrisDb is still open
      final query = IdrisDb.models.where().build();

      // Close the IdrisDb instance
      IdrisDb.close();

      // Using the query after closing should throw IdrisDbNotReadyError
      expect(query.findAll, throwsA(isA<IdrisDbNotReadyError>()));
    });
  });
}
