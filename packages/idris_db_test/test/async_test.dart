@TestOn('vm')
library;

import 'dart:io';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'async_test.g.dart';

@collection
class Model {
  Model(this.id, this.value);

  final int id;

  final String value;

  @override
  bool operator ==(other) =>
      other is Model && id == other.id && value == other.value;
}

void main() async {
  group('Async', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema]);
    });

    IdrisDbTest('Open', () async {
      final idrisDbName = IdrisDb.name;
      final IDRISDBDir = IdrisDb.directory;

      IdrisDb.write((IdrisDb) {
        IdrisDb.models.put(Model(1, 'abc'));
      });
      expect(IdrisDb.close(), true);

      final IDRISDB2 = await IdrisDb.openAsync(
        schemas: [ModelSchema],
        name: idrisDbName,
        directory: IDRISDBDir,
        engine: isSQLite ? IdrisDbEngine.sqlite : IdrisDbEngine.IdrisDb,
        inspector: false,
      );

      expect(IDRISDB2.models.get(1), Model(1, 'abc'));
      expect(IDRISDB2.close(), true);
    });

    IdrisDbTest('Bulk insert', () async {
      final futures = List.generate(100, (index) {
        return IdrisDb.writeAsyncWith(index, (IdrisDb, index) {
          IdrisDb.models.putAll([
            Model(index * 100 + 1, 'value1'),
            Model(index * 100 + 2, 'value2'),
            Model(index * 100 + 3, 'value3'),
          ]);
        });
      });

      await Future.wait(futures);
    }, timeout: const Timeout(Duration(minutes: 2)));

    IdrisDbTest(
      'openAsync with encryption on IdrisDb engine throws exception',
      sqlite: false,
      () async {
        final tempDir = Directory.systemTemp.createTempSync('idris_db_async_test_');
        addTearDown(() {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });
        await expectLater(
          IdrisDb.openAsync(
            schemas: [ModelSchema],
            name: 'async_error_test_${DateTime.now().millisecondsSinceEpoch}',
            directory: tempDir.path,
            encryptionKey: 'test_encryption_key_1234567890',
            inspector: false,
          ),
          throwsException,
        );
      },
    );

    IdrisDbTest(
      'openAsync with compactOnLaunch on SQLite throws exception',
      IdrisDb: false,
      () async {
        final tempDir = Directory.systemTemp.createTempSync(
          'idris_db_compact_test_',
        );
        addTearDown(() {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        });
        await expectLater(
          IdrisDb.openAsync(
            schemas: [ModelSchema],
            name: 'async_compact_test_${DateTime.now().millisecondsSinceEpoch}',
            directory: tempDir.path,
            engine: IdrisDbEngine.sqlite,
            compactOnLaunch: const CompactCondition(minRatio: 2),
            inspector: false,
          ),
          throwsException,
        );
      },
    );
  });
}
