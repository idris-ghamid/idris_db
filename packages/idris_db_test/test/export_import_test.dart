@TestOn('vm')
library;

import 'dart:io';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

part 'export_import_test.g.dart';

@collection
class User {
  User({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email;
}

void main() {
  group('Database Export/Import', () {
    late IdrisDb IdrisDb;
    late List<User> testUsers;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([UserSchema], maxSizeMiB: isSQLite ? 0 : 20);

      testUsers = [
        User(id: 1, name: 'Alice', email: 'alice@example.com'),
        User(id: 2, name: 'Bob', email: 'bob@example.com'),
        User(id: 3, name: 'Charlie', email: 'charlie@example.com'),
        User(id: 4, name: 'Diana', email: 'diana@example.com'),
        User(id: 5, name: 'Eve', email: 'eve@example.com'),
      ];

      IdrisDb.write((IdrisDb) => IdrisDb.users.putAll(testUsers));
    });

    IdrisDbTest('Export: .copyToFile() should create backup file', () async {
      final backupPath = path.join(IdrisDb.directory, 'backup_test.IdrisDb');
      final backupFile = File(backupPath);

      if (backupFile.existsSync()) {
        backupFile.deleteSync();
      }

      expect(backupFile.existsSync(), false);

      IdrisDb.copyToFile(backupPath);

      expect(backupFile.existsSync(), true);
      expect(backupFile.lengthSync(), greaterThan(0));

      await backupFile.delete();
    });

    IdrisDbTest('Export: .copyToFile() should preserve all data', () async {
      final backupName = getRandomName();
      final backupPath = path.join(
        IdrisDb.directory,
        isSQLite ? '$backupName.sqlite' : '$backupName.IdrisDb',
      );

      IdrisDb.copyToFile(backupPath);

      final exportedIDRISDB = await openTempIDRISDB(
        [UserSchema],
        directory: IdrisDb.directory,
        name: backupName,
        maxSizeMiB: 20,
      );

      final exportedUsers = exportedIDRISDB.users.where().findAll();
      expect(exportedUsers.length, testUsers.length);

      for (var i = 0; i < testUsers.length; i++) {
        expect(exportedUsers[i], testUsers[i]);
      }

      exportedIDRISDB.close();
    });

    IdrisDbTest('Import: Restore database from backup file', () async {
      final backupName = getRandomName();
      final backupPath = path.join(
        IdrisDb.directory,
        isSQLite ? '$backupName.sqlite' : '$backupName.IdrisDb',
      );

      IdrisDb.copyToFile(backupPath);

      IdrisDb.write((IdrisDb) {
        IdrisDb.users.where().deleteAll();
        IdrisDb.users.put(User(id: 999, name: 'Test', email: 'test@example.com'));
      });

      expect(IdrisDb.users.count(), 1);
      expect(IdrisDb.users.get(999)?.name, 'Test');

      final originalName = IdrisDb.name;
      final originalDir = IdrisDb.directory;
      IdrisDb.close();

      final backupFile = File(backupPath);
      final originalPath = path.join(
        originalDir,
        isSQLite ? '$originalName.sqlite' : '$originalName.IdrisDb',
      );
      await backupFile.copy(originalPath);

      final restoredIDRISDB = await openTempIDRISDB(
        [UserSchema],
        directory: originalDir,
        name: originalName,
        maxSizeMiB: 20,
      );

      final restoredUsers = restoredIDRISDB.users.where().findAll();
      expect(restoredUsers.length, testUsers.length);

      for (var i = 0; i < testUsers.length; i++) {
        expect(restoredUsers[i], testUsers[i]);
      }

      expect(restoredIDRISDB.users.get(999), null);

      restoredIDRISDB.close();
      await backupFile.delete();
    });

    IdrisDbTest(
      'Export: .copyToFile() creates valid backup after fragmentation',
      () async {
        IdrisDb.write((IdrisDb) {
          final largeUsers = List.generate(
            100,
            (i) => User(
              id: i + 100,
              name: 'User $i' * 100,
              email: 'user$i@example.com' * 100,
            ),
          );
          IdrisDb.users.putAll(largeUsers);
        });

        IdrisDb.write(
          (IdrisDb) => IdrisDb.users.where().idBetween(100, 149).deleteAll(),
        );

        final backupName = getRandomName();
        final backupPath = path.join(
          IdrisDb.directory,
          isSQLite ? '$backupName.sqlite' : '$backupName.IdrisDb',
        );

        IdrisDb.copyToFile(backupPath);

        final backupFile = File(backupPath);

        expect(backupFile.existsSync(), true);
        expect(backupFile.lengthSync(), greaterThan(0));

        final backupIDRISDB = await openTempIDRISDB(
          [UserSchema],
          directory: IdrisDb.directory,
          name: backupName,
          maxSizeMiB: 20,
        );

        expect(backupIDRISDB.users.count(), 55);

        for (var i = 0; i < testUsers.length; i++) {
          final user = backupIDRISDB.users.get(testUsers[i].id);
          expect(user, isNotNull);
          expect(user, testUsers[i]);
        }

        for (var i = 100; i < 150; i++) {
          expect(backupIDRISDB.users.get(i), null);
        }

        for (var i = 150; i < 200; i++) {
          final user = backupIDRISDB.users.get(i);
          expect(user, isNotNull);
          expect(user!.id, i);
        }

        backupIDRISDB.close();
        await backupFile.delete();
      },
    );

    IdrisDbTest('Export/Import: Multiple backup and restore cycles', () async {
      final backup1Name = getRandomName();
      final backup1Path = path.join(
        IdrisDb.directory,
        isSQLite ? '$backup1Name.sqlite' : '$backup1Name.IdrisDb',
      );

      IdrisDb.copyToFile(backup1Path);

      IdrisDb.write((IdrisDb) {
        IdrisDb.users.put(User(id: 10, name: 'Frank', email: 'frank@example.com'));
      });

      final backup2Name = getRandomName();
      final backup2Path = path.join(
        IdrisDb.directory,
        isSQLite ? '$backup2Name.sqlite' : '$backup2Name.IdrisDb',
      );

      IdrisDb.copyToFile(backup2Path);

      final backup1IDRISDB = await openTempIDRISDB(
        [UserSchema],
        directory: IdrisDb.directory,
        name: backup1Name,
        maxSizeMiB: 20,
      );
      expect(backup1IDRISDB.users.count(), 5);
      backup1IDRISDB.close();

      final backup2IDRISDB = await openTempIDRISDB(
        [UserSchema],
        directory: IdrisDb.directory,
        name: backup2Name,
        maxSizeMiB: 20,
      );
      expect(backup2IDRISDB.users.count(), 6);
      expect(backup2IDRISDB.users.get(10)?.name, 'Frank');
      backup2IDRISDB.close();

      await File(backup1Path).delete();
      await File(backup2Path).delete();
    });

    IdrisDbTest('Export: .copyToFile() with empty database', () async {
      final emptyIDRISDB = await openTempIDRISDB([
        UserSchema,
      ], maxSizeMiB: isSQLite ? 0 : 20);

      final backupName = getRandomName();
      final backupPath = path.join(
        emptyIDRISDB.directory,
        isSQLite ? '$backupName.sqlite' : '$backupName.IdrisDb',
      );

      emptyIDRISDB.copyToFile(backupPath);

      final backupFile = File(backupPath);
      expect(backupFile.existsSync(), true);
      expect(backupFile.lengthSync(), greaterThan(0));

      final backupIDRISDB = await openTempIDRISDB(
        [UserSchema],
        directory: emptyIDRISDB.directory,
        name: backupName,
        maxSizeMiB: 20,
      );

      expect(backupIDRISDB.users.count(), 0);

      backupIDRISDB.close();
      emptyIDRISDB.close();
      await backupFile.delete();
    });

    IdrisDbTest('Export: Consecutive exports should have same size', () async {
      final backup1Name = getRandomName();
      final backup1Path = path.join(
        IdrisDb.directory,
        isSQLite ? '$backup1Name.sqlite' : '$backup1Name.IdrisDb',
      );

      final backup2Name = getRandomName();
      final backup2Path = path.join(
        IdrisDb.directory,
        isSQLite ? '$backup2Name.sqlite' : '$backup2Name.IdrisDb',
      );

      IdrisDb.copyToFile(backup1Path);
      IdrisDb.copyToFile(backup2Path);

      final backup1Size = File(backup1Path).lengthSync();
      final backup2Size = File(backup2Path).lengthSync();

      expect(backup1Size, backup2Size);

      await File(backup1Path).delete();
      await File(backup2Path).delete();
    });
  });
}
