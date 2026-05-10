// ignore_for_file: non_nullable_equals_parameter

import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

part 'constructor_test.g.dart';

@collection
class EmptyConstructorModel {
  EmptyConstructorModel();

  @id
  late String name;

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) {
    return other is EmptyConstructorModel && other.name == name;
  }
}

@collection
@immutable
class NamedConstructorModel {
  const NamedConstructorModel({required this.name});

  @id
  final String name;

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) {
    return other is NamedConstructorModel && other.name == name;
  }
}

@collection
class PositionalConstructorModel {
  PositionalConstructorModel(this.name);

  @id
  final String name;

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) {
    return other is PositionalConstructorModel && other.name == name;
  }
}

@collection
class OptionalConstructorModel {
  OptionalConstructorModel([this.name = 'default']);

  @id
  final String name;

  int? value2;

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) {
    return other is OptionalConstructorModel &&
        other.name == name &&
        other.value2 == value2;
  }
}

@collection
class PositionalNamedConstructorModel {
  PositionalNamedConstructorModel(this.name, {required this.value2});

  @id
  final String name;

  final String value2;

  @override
  // ignore: hash_and_equals
  bool operator ==(dynamic other) {
    return other is PositionalNamedConstructorModel &&
        other.name == name &&
        other.value2 == value2;
  }
}

void main() {
  group('Constructor', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([
        EmptyConstructorModelSchema,
        NamedConstructorModelSchema,
        PositionalConstructorModelSchema,
        OptionalConstructorModelSchema,
        PositionalNamedConstructorModelSchema,
      ]);
    });

    IdrisDbTest('EmptyConstructorModel', () {
      final obj1 = EmptyConstructorModel()..name = 'obj1';
      final obj2 = EmptyConstructorModel()..name = 'obj2';
      IdrisDb.write((IdrisDb) {
        IdrisDb.emptyConstructorModels.putAll([obj1, obj2]);
      });

      expect(IdrisDb.emptyConstructorModels.where().findAll().toSet(), {
        obj1,
        obj2,
      });
    });

    IdrisDbTest('NamedConstructorModel', () {
      const obj1 = NamedConstructorModel(name: 'obj1');
      const obj2 = NamedConstructorModel(name: 'obj2');
      IdrisDb.write((IdrisDb) {
        IdrisDb.namedConstructorModels.putAll([obj1, obj2]);
      });

      expect(IdrisDb.namedConstructorModels.where().findAll().toSet(), {
        obj1,
        obj2,
      });
    });

    IdrisDbTest('PositionalConstructorModel', () {
      final obj1 = PositionalConstructorModel('obj1');
      final obj2 = PositionalConstructorModel('obj2');
      final obj3 = PositionalConstructorModel('obj3');
      IdrisDb.write((IdrisDb) {
        IdrisDb.positionalConstructorModels.putAll([obj1, obj2, obj3]);
      });

      expect(IdrisDb.positionalConstructorModels.where().findAll().toSet(), {
        obj1,
        obj2,
        obj3,
      });
    });

    IdrisDbTest('OptionalConstructorModel', () {
      final obj1 = OptionalConstructorModel()..value2 = 1;
      final obj2 = OptionalConstructorModel('obj2')..value2 = 2;
      final obj3 = OptionalConstructorModel()..value2 = 3;
      final obj4 = OptionalConstructorModel('obj4')..value2 = 4;
      IdrisDb.write((IdrisDb) {
        IdrisDb.optionalConstructorModels.putAll([obj1, obj2, obj3, obj4]);
      });

      expect(IdrisDb.optionalConstructorModels.where().findAll().toSet(), {
        obj2,
        obj3,
        obj4,
      });
    });

    IdrisDbTest('PositionalNamedConstructorModel', () {
      final obj1 = PositionalNamedConstructorModel('obj1', value2: 'value2');
      final obj2 = PositionalNamedConstructorModel('obj2', value2: 'value2_2');
      IdrisDb.write((IdrisDb) {
        IdrisDb.positionalNamedConstructorModels.putAll([obj1, obj2]);
      });

      expect(IdrisDb.positionalNamedConstructorModels.where().findAll().toSet(), {
        obj1,
        obj2,
      });
    });
  });
}
