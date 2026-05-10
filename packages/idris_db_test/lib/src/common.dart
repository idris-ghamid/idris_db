import 'dart:async';
import 'dart:math';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/src/init_native.dart'
    if (dart.library.js_interop) 'package:idris_db_test/src/init_web.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
// ignore: implementation_imports, depend_on_referenced_packages
import 'package:test_api/src/backend/invoker.dart';

export 'package:idris_db_test/src/init_native.dart'
    if (dart.library.js_interop) 'package:idris_db_test/src/init_web.dart';

final testErrors = <String>[];
int testCount = 0;

String getRandomName() {
  final random = Random().nextInt(pow(2, 32) as int).toString();
  return '${random}_tmp';
}

String? testTempPath;
Future<IdrisDb> openTempIDRISDB(
  List<IdrisDbGeneratedSchema> schemas, {
  String? name,
  String? directory,
  int maxSizeMiB = IdrisDb.defaultMaxSizeMiB,
  String? encryptionKey,
  CompactCondition? compactOnLaunch,
  bool closeAutomatically = true,
}) async {
  await prepareTest();

  final IdrisDb = IdrisDb.open(
    schemas: schemas,
    name: name ?? getRandomName(),
    directory: directory ?? testTempPath ?? IdrisDb.sqliteInMemory,
    engine: isSQLite ? IdrisDbEngine.sqlite : IdrisDbEngine.IdrisDb,
    maxSizeMiB: maxSizeMiB,
    encryptionKey: encryptionKey,
    compactOnLaunch: compactOnLaunch,
    inspector: false,
  );

  if (closeAutomatically) {
    addTearDown(() async {
      if (IdrisDb.isOpen) {
        IdrisDb.close(deleteFromDisk: true);
      }
    });
  }

  return IdrisDb;
}

String get _testName => Invoker.current!.liveTest.test.name;

bool get isSQLite => _testName.endsWith('(sqlite)');

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

typedef TestRunner =
    void Function(
      String description,
      dynamic Function() body, {
      String? testOn,
      Timeout? timeout,
      dynamic skip,
      dynamic tags,
      Map<String, dynamic>? onPlatform,
      int? retry,
    });

TestRunner IDRISDBTestRunner = test;

@isTestGroup
void IdrisDbTest(
  String name,
  FutureOr<void> Function() body, {
  Timeout? timeout,
  bool skip = false,
  bool IdrisDb = true,
  bool sqlite = true,
  bool web = true,
}) {
  testCount++;
  group(name, () {
    if (IdrisDb && !kIsWeb) {
      IDRISDBTestRunner(
        '(IdrisDb)',
        () async {
          try {
            await body();
          } catch (e, s) {
            testErrors.add('$name (IdrisDb): $e\n$s');
            rethrow;
          }
        },
        timeout: timeout,
        skip: skip,
      );
    }

    if ((!kIsWeb && sqlite) || (kIsWeb && web)) {
      IDRISDBTestRunner(
        '(sqlite)',
        () async {
          try {
            await body();
          } catch (e, s) {
            testErrors.add('$name (sqlite): $e\n$s');
            rethrow;
          }
        },
        timeout: timeout,
        skip: skip,
      );
    }
  });
}

extension IDRISDBCollectionX<ID, OBJ> on IdrisDbCollection<ID, OBJ> {
  void verify(List<OBJ> objects) {
    // ignore: invalid_use_of_visible_for_testing_member
    IdrisDb.verify();
    expect(where().findAll(), objects);
  }
}
