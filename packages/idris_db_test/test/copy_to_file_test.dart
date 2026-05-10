@TestOn('vm')
library;

import 'dart:io';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

part 'copy_to_file_test.g.dart';

@collection
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
}

void main() {
  group('Copy to file', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      // disable WAL for SQLite
      IdrisDb = await openTempIDRISDB([ModelSchema], maxSizeMiB: isSQLite ? 0 : 20);

      IdrisDb.write((IdrisDb) => IdrisDb.models.putAll(List.generate(100, Model.new)));
    });

    IdrisDbTest('.copyToFile() should create a new file', () async {
      final copiedDbFile = File(path.join(IdrisDb.directory, getRandomName()));
      expect(copiedDbFile.existsSync(), false);

      IdrisDb.copyToFile(copiedDbFile.path);

      expect(copiedDbFile.existsSync(), true);
      expect(copiedDbFile.lengthSync(), greaterThan(0));
      await copiedDbFile.delete();
    });

    IdrisDbTest('.copyToFile() should keep the same content', () async {
      final name = getRandomName();
      final copiedDbFile = File(
        path.join(IdrisDb.directory, isSQLite ? '$name.sqlite' : '$name.IdrisDb'),
      );

      IdrisDb.copyToFile(copiedDbFile.path);

      final copiedIDRISDB = await openTempIDRISDB(
        [ModelSchema],
        directory: IdrisDb.directory,
        name: name,
        maxSizeMiB: 20,
      );

      expect(
        copiedIDRISDB.models.where().findAll(),
        IdrisDb.models.where().findAll(),
      );
    });

    IdrisDbTest('.copyToFile() should compact copied file', () async {
      final dbFile = File(
        path.join(
          IdrisDb.directory,
          isSQLite ? '${IdrisDb.name}.sqlite' : '${IdrisDb.name}.IdrisDb',
        ),
      );
      IdrisDb.write((IdrisDb) => IdrisDb.models.where().deleteAll(limit: 50));

      final name1 = getRandomName();
      final copiedDbFile1 = File(
        path.join(IdrisDb.directory, isSQLite ? '$name1.sqlite' : '$name1.IdrisDb'),
      );

      IdrisDb.copyToFile(copiedDbFile1.path);

      final IDRISDBCopy1 = await openTempIDRISDB(
        [ModelSchema],
        directory: IdrisDb.directory,
        name: name1,
        maxSizeMiB: 20,
      );

      expect(copiedDbFile1.lengthSync(), greaterThan(0));
      expect(copiedDbFile1.lengthSync(), lessThan(dbFile.lengthSync()));

      IDRISDBCopy1.write((IdrisDb) => IDRISDBCopy1.models.where().deleteAll(limit: 25));

      final name2 = getRandomName();
      final copiedDbFile2 = File(
        path.join(IdrisDb.directory, isSQLite ? '$name2.sqlite' : '$name2.IdrisDb'),
      );
      IDRISDBCopy1.copyToFile(copiedDbFile2.path);

      expect(copiedDbFile2.lengthSync(), greaterThan(0));
      expect(copiedDbFile2.lengthSync(), lessThan(copiedDbFile1.lengthSync()));
      copiedDbFile2.deleteSync();
    });

    IdrisDbTest('Copies should be the same size', () async {
      final name1 = getRandomName();
      final copiedDbFile1 = File(
        path.join(IdrisDb.directory, isSQLite ? '$name1.sqlite' : '$name1.IdrisDb'),
      );

      final name2 = getRandomName();
      final copiedDbFile2 = File(
        path.join(IdrisDb.directory, isSQLite ? '$name2.sqlite' : '$name2.IdrisDb'),
      );

      IdrisDb.copyToFile(copiedDbFile1.path);
      IdrisDb.copyToFile(copiedDbFile2.path);

      expect(copiedDbFile1.lengthSync(), copiedDbFile2.lengthSync());
      copiedDbFile2.deleteSync();

      final IDRISDBCopy = await openTempIDRISDB(
        [ModelSchema],
        directory: IdrisDb.directory,
        name: name1,
        maxSizeMiB: 20,
      );

      final name3 = getRandomName();
      final copiedDbFile3 = File(
        path.join(IdrisDb.directory, isSQLite ? '$name3.sqlite' : '$name3.IdrisDb'),
      );

      IDRISDBCopy.copyToFile(copiedDbFile3.path);

      expect(copiedDbFile3.lengthSync(), copiedDbFile1.lengthSync());
      copiedDbFile3.deleteSync();
    });
  });
}
