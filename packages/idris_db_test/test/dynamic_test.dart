import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'dynamic_test.g.dart';

@collection
class Model {
  Model({
    required this.id,
    required this.value,
    required this.list,
    required this.map,
  });

  final int id;

  final dynamic value;

  final List<dynamic> list;

  final Map<String, dynamic> map;

  @override
  bool operator ==(other) =>
      other is Model &&
      id == other.id &&
      listEquals([value], [other.value]) &&
      listEquals(list, other.list) &&
      listEquals(map.keys.toList(), other.map.keys.toList()) &&
      listEquals(map.values.toList(), other.map.values.toList());
}

void main() {
  group('Dynamic', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema]);
    });

    IdrisDbTest('String', () {
      final obj1 = Model(
        id: 1,
        value: 'a',
        list: ['a', null, 'value'],
        map: {'a': 'hello'},
      );

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(obj1));
      expect(IdrisDb.models.get(1), obj1);
    });

    IdrisDbTest('int', () {
      final obj1 = Model(id: 1, value: 1, list: [1, null, 2], map: {'a': 1});

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(obj1));
      expect(IdrisDb.models.get(1), obj1);
    });

    IdrisDbTest('double', () {
      final obj1 = Model(
        id: 1,
        value: 1.1,
        list: [1.1, null, 2.2],
        map: {'a': 1.1},
      );

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(obj1));
      expect(IdrisDb.models.get(1), obj1);
    });

    IdrisDbTest('bool', () {
      final obj1 = Model(
        id: 1,
        value: true,
        list: [true, null, false],
        map: {'a': true},
      );

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(obj1));
      expect(IdrisDb.models.get(1), obj1);
    });

    IdrisDbTest('null', () {
      final obj1 = Model(
        id: 1,
        value: null,
        list: [null, null, null],
        map: {'a': null},
      );

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(obj1));
      expect(IdrisDb.models.get(1), obj1);
    });

    IdrisDbTest('List', () {
      final obj1 = Model(
        id: 1,
        value: [8, 'aaa', false, null],
        list: [
          [1, 'a', true, null],
          null,
          [2, 'b', true, null],
        ],
        map: {
          'a': [1, 'a', true, null],
        },
      );

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(obj1));
      expect(IdrisDb.models.get(1), obj1);
    });

    IdrisDbTest('Map', () {
      final obj1 = Model(
        id: 1,
        value: {'a': 1, 'b': '2', 'c': true, 'd': null},
        list: [
          {'a': 1, 'b': '2', 'c': true, 'd': null},
          null,
          {'a': 2, 'b': '3', 'c': true, 'd': null},
        ],
        map: {
          'a': {'a': 1, 'b': '2', 'c': true, 'd': null},
        },
      );

      IdrisDb.write((IdrisDb) => IdrisDb.models.put(obj1));
      expect(IdrisDb.models.get(1), obj1);
    });
  });
}
