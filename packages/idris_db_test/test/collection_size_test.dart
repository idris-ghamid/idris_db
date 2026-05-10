import 'dart:math';

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'collection_size_test.g.dart';

@collection
class ModelA {
  ModelA({required this.name});

  int id = Random().nextInt(99999);

  @Index()
  String name;

  // We store a big buffer in order to better detect collection size changes,
  // since reported collection size is based on block size (eg. 4096, 8192, ...)
  final List<int> randomBuffer = List.filled(64000, 42);
}

@collection
class ModelB {
  int id = Random().nextInt(99999);

  final List<int> randomBuffer = List.filled(64000, 42);
}

void main() {
  group('Collection size', () {
    late IdrisDb IdrisDb;

    late ModelA objA0;
    late ModelA objA1;
    late ModelA objA2;
    late ModelA objA3;
    late ModelA objA4;
    late ModelA objA5;

    late ModelB objB0;
    late ModelB objB1;
    late ModelB objB2;
    late ModelB objB3;
    late ModelB objB4;
    late ModelB objB5;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelASchema, ModelBSchema]);

      objA0 = ModelA(name: 'Obj A0');
      objA1 = ModelA(name: 'Obj A1');
      objA2 = ModelA(name: 'Obj A2');
      objA3 = ModelA(name: 'Obj A3');
      objA4 = ModelA(name: 'Obj A4');
      objA5 = ModelA(name: 'Obj A5');

      objB0 = ModelB();
      objB1 = ModelB();
      objB2 = ModelB();
      objB3 = ModelB();
      objB4 = ModelB();
      objB5 = ModelB();
    });

    IdrisDbTest('Size should start at 0', sqlite: false, web: false, () {
      expect(IdrisDb.modelAs.getSize(), 0);
      expect(IdrisDb.modelAs.getSize(), 0);

      expect(IdrisDb.modelAs.getSize(includeIndexes: true), 0);
      expect(IdrisDb.modelAs.getSize(includeIndexes: true), 0);
    });

    IdrisDbTest(
      'Size should increase with more entries',
      sqlite: false,
      web: false,
      () {
        IdrisDb.write((IdrisDb) => IdrisDb.modelAs.put(objA0));
        final sizeA0 = IdrisDb.modelAs.getSize();
        expect(sizeA0, greaterThan(0));

        IdrisDb.write((IdrisDb) => IdrisDb.modelAs.putAll([objA1, objA2, objA3]));
        final sizeA1 = IdrisDb.modelAs.getSize();
        expect(sizeA1, greaterThan(sizeA0));

        IdrisDb.write((IdrisDb) => IdrisDb.modelAs.putAll([objA4, objA5]));
        final sizeA2 = IdrisDb.modelAs.getSize();
        expect(sizeA2, greaterThan(sizeA1));

        expect(IdrisDb.modelBs.getSize(), 0);

        IdrisDb.write((IdrisDb) => IdrisDb.modelBs.put(objB0));
        final sizeB0 = IdrisDb.modelBs.getSize();
        expect(sizeB0, greaterThan(0));

        IdrisDb.write((IdrisDb) => IdrisDb.modelBs.putAll([objB1, objB2, objB3]));
        final sizeB1 = IdrisDb.modelBs.getSize();
        expect(sizeB1, greaterThanOrEqualTo(sizeB0));

        IdrisDb.write((IdrisDb) => IdrisDb.modelBs.putAll([objB4, objB5]));
        final sizeB2 = IdrisDb.modelBs.getSize();
        expect(sizeB2, greaterThanOrEqualTo(sizeB1));
      },
    );

    // TODO(ahmtydn): enable when indexes are implemented
    /*IdrisDbTest('includeIndexes should change size', () {
      IdrisDb.write((IdrisDb) => IdrisDb.modelAs.putAll([objA0, objA1, objA3]));

      final sizeAWithoutIndexes = IdrisDb.modelAs.getSize();
      final sizeAWithIndexes = IdrisDb.modelAs.getSize(includeIndexes: true);
      expect(sizeAWithIndexes, greaterThan(sizeAWithoutIndexes));

      IdrisDb.write((IdrisDb) => IdrisDb.modelBs.putAll([objB0, objB3, objB4]));

      final sizeBWithoutIndexes = IdrisDb.modelBs.getSize();
      final sizeBWithIndexes = IdrisDb.modelBs.getSize(includeIndexes: true);
      // ModelB has no indexes, so should stay the same
      expect(sizeBWithIndexes, sizeBWithoutIndexes);
    });*/

    IdrisDbTest('Delete should decrease size', sqlite: false, web: false, () {
      IdrisDb.write((IdrisDb) {
        IdrisDb.modelAs.putAll([objA0, objA1, objA2, objA3]);
        IdrisDb.modelBs.putAll([objB0, objB1, objB2, objB3, objB4]);
      });

      final sizeA1 = IdrisDb.modelAs.getSize();

      IdrisDb.write((IdrisDb) => IdrisDb.modelAs.delete(objA0.id));
      final sizeA2 = IdrisDb.modelAs.getSize();

      expect(sizeA2, lessThan(sizeA1));

      IdrisDb.write((IdrisDb) => IdrisDb.modelAs.clear());
      final sizeA3 = IdrisDb.modelAs.getSize();
      expect(sizeA3, 0);

      final sizeB1 = IdrisDb.modelBs.getSize();

      IdrisDb.write((IdrisDb) => IdrisDb.modelBs.deleteAll([objB0.id, objB1.id]));
      final sizeB2 = IdrisDb.modelBs.getSize();

      expect(sizeB2, lessThan(sizeB1));

      IdrisDb.write((IdrisDb) => IdrisDb.modelBs.deleteAll([objB2.id, objB3.id]));
      final sizeB3 = IdrisDb.modelBs.getSize();

      expect(sizeB3, lessThan(sizeB2));
      expect(sizeB3, greaterThan(0));
    });

    IdrisDbTest('Update should change size', sqlite: false, web: false, () {
      IdrisDb.write((IdrisDb) {
        IdrisDb.modelAs.putAll([objA0, objA1, objA2, objA3]);
        IdrisDb.modelBs.putAll([objB0, objB1, objB2, objB3, objB4]);
      });

      final sizeA1 = IdrisDb.modelAs.getSize();
      final sizeB1 = IdrisDb.modelBs.getSize();

      objA0.name += String.fromCharCodes(List.filled(64000, 42));

      IdrisDb.write((IdrisDb) => IdrisDb.modelAs.put(objA0));
      final sizeA2 = IdrisDb.modelAs.getSize();
      final sizeB2 = IdrisDb.modelBs.getSize();

      expect(sizeA2, greaterThan(sizeA1));
      expect(sizeB2, sizeB1);

      objA0.name += String.fromCharCodes(List.filled(64000, 42));
      objA1.name += String.fromCharCodes(List.filled(64000, 42));

      IdrisDb.write((IdrisDb) => IdrisDb.modelAs.putAll([objA0, objA1]));
      final sizeA3 = IdrisDb.modelAs.getSize();
      final sizeB3 = IdrisDb.modelBs.getSize();

      expect(sizeA3, greaterThan(sizeA2));
      expect(sizeB3, sizeB2);
    });
    IdrisDbTest(
      'IdrisDb getSize returns total size of all collections',
      sqlite: false,
      web: false,
      () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.modelAs.putAll([objA0, objA1, objA2]);
          IdrisDb.modelBs.putAll([objB0, objB1]);
        });

        final totalSize = IdrisDb.getSize();
        final sizeA = IdrisDb.modelAs.getSize();
        final sizeB = IdrisDb.modelBs.getSize();

        expect(totalSize, sizeA + sizeB);

        final totalSizeWithIndexes = IdrisDb.getSize(includeIndexes: true);
        expect(totalSizeWithIndexes, greaterThanOrEqualTo(totalSize));
      },
    );

    IdrisDbTest(
      'IdrisDb clear removes all data from all collections',
      sqlite: false,
      web: false,
      () {
        IdrisDb.write((IdrisDb) {
          IdrisDb.modelAs.putAll([objA0, objA1, objA2]);
          IdrisDb.modelBs.putAll([objB0, objB1]);
        });

        expect(IdrisDb.modelAs.count(), 3);
        expect(IdrisDb.modelBs.count(), 2);

        IdrisDb.write((IdrisDb) => IdrisDb.clear());

        expect(IdrisDb.modelAs.count(), 0);
        expect(IdrisDb.modelBs.count(), 0);
      },
    );
  });
}
