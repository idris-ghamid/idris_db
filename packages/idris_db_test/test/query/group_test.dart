import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'group_test.g.dart';

@collection
class Model {
  Model(this.id, this.name, this.age);

  final int id;

  String? name;

  int? age = 0;

  @override
  String toString() {
    return '{name: $name, age: $age, }';
  }

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is Model && name == other.name && age == other.age;
  }
}

void main() {
  group('Filter Groups', () {
    late IdrisDb IdrisDb;
    late IdrisDbCollection<int, Model> users;

    late Model david;
    late Model emma;
    late Model tina;
    late Model simon;
    late Model bjorn;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ModelSchema]);
      users = IdrisDb.models;

      david = Model(0, 'David', 20);
      emma = Model(1, 'Emma', 30);
      tina = Model(2, 'Tina', 40);
      simon = Model(3, 'Simon', 30);
      bjorn = Model(4, 'Bjorn', 40);

      IdrisDb.write((IdrisDb) {
        IdrisDb.models.putAll([david, emma, tina, simon, bjorn]);
      });
    });

    IdrisDbTest('Simple or', () {
      expect(users.where().ageEqualTo(20).or().ageEqualTo(30).findAll(), [
        david,
        emma,
        simon,
      ]);
    });

    IdrisDbTest('Simple and', () {
      expect(users.where().ageEqualTo(40).and().idEqualTo(4).findAll(), [
        bjorn,
      ]);
    });

    IdrisDbTest('Or followed by and', () {
      expect(
        users
            .where()
            .ageEqualTo(20)
            .or()
            .ageEqualTo(30)
            .and()
            .nameEqualTo('Emma')
            .findAll(),
        [david, emma],
      );
    });

    IdrisDbTest('And followed by or', () {
      expect(
        users
            .where()
            .ageEqualTo(30)
            .and()
            .nameEqualTo('Simon')
            .or()
            .ageEqualTo(20)
            .findAll(),
        [david, simon],
      );
    });

    IdrisDbTest('Or followed by group', () {
      expect(
        users
            .where()
            .ageEqualTo(20)
            .or()
            .group((q) => q.ageEqualTo(30).and().nameEqualTo('Emma'))
            .findAll(),
        [david, emma],
      );
    });

    IdrisDbTest('And followed by group', () {
      expect(
        users
            .where()
            .ageEqualTo(30)
            .and()
            .group((q) => q.nameEqualTo('Simon').or().ageEqualTo(20))
            .findAll(),
        [simon],
      );
    });

    IdrisDbTest('Nested groups', () {
      expect(
        users
            .where()
            .group(
              (q) => q
                  .nameEqualTo('Simon')
                  .or()
                  .group((q) => q.ageEqualTo(30).or().ageEqualTo(20)),
            )
            .findAll(),
        [david, emma, simon],
      );
    });
    IdrisDbTest('AndGroup with single filter', () {
      expect(users.where().group((q) => q.ageEqualTo(20)).findAll(), [david]);
    });

    IdrisDbTest('OrGroup with single filter in nested group', () {
      expect(
        users
            .where()
            .ageEqualTo(20)
            .or()
            .group((q) => q.ageEqualTo(40))
            .findAll(),
        [david, tina, bjorn],
      );
    });

    IdrisDbTest('AndGroup with exactly one filter via buildQuery', () {
      // ignore: experimental_member_use
      final query = users.buildQuery<Model>(
        filter: AndGroup([const EqualCondition(property: 2, value: 20)]),
      );
      expect(query.findAll(), [david]);
      query.close();
    });

    IdrisDbTest('OrGroup with exactly one filter via buildQuery', () {
      // ignore: experimental_member_use
      final query = users.buildQuery<Model>(
        filter: OrGroup([const EqualCondition(property: 2, value: 40)]),
      );
      expect(query.findAll(), [tina, bjorn]);
      query.close();
    });

    IdrisDbTest('Unsupported filter value type throws ArgumentError', () {
      expect(
        // ignore: experimental_member_use
        () => users.buildQuery<Model>(
          filter: const EqualCondition(property: 2, value: [1, 2, 3]),
        ),
        throwsArgumentError,
      );
    });
  });
}
