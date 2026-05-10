@TestOn('vm')
library;

import 'dart:io';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'compact_on_launch_test.g.dart';

@Collection()
class Model {
  Model(this.id);

  final int id;

  List<int> buffer = List.filled(16000, 42);

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Model &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listEquals(buffer, other.buffer);

  @override
  String toString() {
    return 'Model{id: $id}';
  }
}

void main() {
  group('Compact on launch', () {
    late IdrisDb IdrisDb;
    late final idrisDbName = getRandomName();
    late File file;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema], name: idrisDbName);
      if (isSQLite) {
        file = File('${IdrisDb.directory}/$idrisDbName.sqlite');
      } else {
        file = File('${IdrisDb.directory}/$idrisDbName.IdrisDb');
      }

      IdrisDb.write((IdrisDb) => IdrisDb.models.putAll(List.generate(100, Model.new)));
    });

    IdrisDbTest('No compact on launch', () async {
      IdrisDb.close();
      final size1 = file.lengthSync();

      IdrisDb = await openTempIDRISDB([ModelSchema], name: idrisDbName);
      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 50));
      IdrisDb.close();

      final size2 = file.lengthSync();

      IdrisDb = await openTempIDRISDB([ModelSchema], name: idrisDbName);

      expect(size1, size2);
    });

    IdrisDbTest('minFileSize', sqlite: false, () async {
      IdrisDb.close();
      final size1 = file.lengthSync();

      IdrisDb = await openTempIDRISDB([ModelSchema], name: idrisDbName);
      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 50));
      IdrisDb.close();

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: CompactCondition(minFileSize: size1 * 2),
      );
      IdrisDb.close();
      final size2 = file.lengthSync();
      expect(size1, size2);

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: CompactCondition(minFileSize: size1 ~/ 2),
      );
      final size3 = file.lengthSync();
      expect(size3, lessThan(size2));
    });

    IdrisDbTest('minBytes', sqlite: false, () async {
      IdrisDb.close();
      final size1 = file.lengthSync();

      IdrisDb = await openTempIDRISDB([ModelSchema], name: idrisDbName);
      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 10));
      IdrisDb.close();

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: CompactCondition(minBytes: size1 ~/ 2),
      );
      IdrisDb.close();
      final size2 = file.lengthSync();
      expect(size1, size2);

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: CompactCondition(minBytes: size1 ~/ 2),
      );
      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 90));
      IdrisDb.close();
      final size3 = file.lengthSync();
      expect(size3, size2);

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: CompactCondition(minBytes: size1 ~/ 2),
      );
      final size4 = file.lengthSync();
      expect(size4, lessThan(size3));
    });

    IdrisDbTest('minRatio', sqlite: false, () async {
      IdrisDb.close();
      final size1 = file.lengthSync();

      IdrisDb = await openTempIDRISDB([ModelSchema], name: idrisDbName);
      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 10));
      IdrisDb.close();

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: const CompactCondition(minRatio: 2),
      );
      IdrisDb.close();
      final size2 = file.lengthSync();
      expect(size1, size2);

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: const CompactCondition(minRatio: 2),
      );
      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 80));
      IdrisDb.close();
      final size3 = file.lengthSync();
      expect(size3, size2);

      IdrisDb = await openTempIDRISDB(
        [ModelSchema],
        name: idrisDbName,
        compactOnLaunch: const CompactCondition(minRatio: 2),
      );
      final size4 = file.lengthSync();
      expect(size4, lessThan(size3));
    });

    test('SQLite engine does not support compaction', () async {
      await prepareTest();
      expect(
        () => IdrisDb.open(
          schemas: [ModelSchema],
          name: 'test_compact_${DateTime.now().millisecondsSinceEpoch}',
          directory: IdrisDb.sqliteInMemory,
          engine: IdrisDbEngine.sqlite,
          compactOnLaunch: const CompactCondition(minFileSize: 1024),
        ),
        throwsArgumentError,
      );
    });
  });
}
