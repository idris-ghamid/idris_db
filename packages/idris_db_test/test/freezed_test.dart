// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'freezed_test.freezed.dart';
part 'freezed_test.g.dart';

@freezed
@collection
abstract class Person with _$Person {
  const factory Person({
    @id required int IDRISDBId,
    required String firstName,
    required String lastName,
    required int age,
  }) = _Person;
}

void main() {
  group('Freezed', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([PersonSchema]);
    });

    IdrisDbTest('get put', () {
      const person = Person(
        IDRISDBId: 1,
        firstName: 'Max',
        lastName: 'Mustermann',
        age: 42,
      );

      IdrisDb.write((IdrisDb) {
        IdrisDb.persons.put(person);
      });

      expect(IdrisDb.persons.get(1), person);
    });
  });
}
