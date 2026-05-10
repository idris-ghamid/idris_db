import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'watcher_test.g.dart';

@collection
class Value {
  Value(this.id, this.value);

  int id;

  @Index(unique: true)
  String? value;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) =>
      other is Value && id == other.id && value == other.value;
}

void main() {
  group('Watcher', () {
    late IdrisDb IdrisDb;

    late Value obj1;
    late Value obj2;
    late Value obj3;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([ValueSchema]);

      obj1 = Value(1, 'Hello');
      obj2 = Value(2, 'Hi');
      obj3 = Value(3, 'Test');
    });

    group('Collection', () {
      IdrisDbTest('.put()', web: false, () async {
        final listener = Listener<void>(IdrisDb.values.watchLazy());

        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj1));
        await listener.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj1));
        await listener.next;

        await listener.done();
      });

      IdrisDbTest('.putAll()', web: false, () async {
        final listener = Listener<void>(IdrisDb.values.watchLazy());

        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2]));
        await listener.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1]));
        await listener.next;

        await listener.done();
      });

      IdrisDbTest('.delete()', web: false, () async {
        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2]));

        final listener = Listener<void>(IdrisDb.values.watchLazy());

        IdrisDb.write((IdrisDb) => IdrisDb.values.delete(1));
        await listener.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.delete(2));
        await listener.next;

        await listener.done();
      });

      IdrisDbTest('.deleteAll()', web: false, () async {
        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2]));

        final listener = Listener<void>(IdrisDb.values.watchLazy());

        IdrisDb.write((IdrisDb) => IdrisDb.values.deleteAll([1, 3]));
        await listener.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.deleteAll([2]));
        await listener.next;

        await listener.done();
      });

      IdrisDbTest('fireImmediately', web: false, () async {
        final listener = Listener<void>(
          IdrisDb.values.watchLazy(fireImmediately: true),
        );

        await listener.next;
        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj1));
        await listener.next;

        await listener.done();
      });
    });

    group('Object', () {
      IdrisDbTest('.put()', web: false, () async {
        final listenerLazy = Listener<void>(IdrisDb.values.watchObjectLazy(1));
        final listener = Listener<Value?>(IdrisDb.values.watchObject(2));

        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj1));
        await listenerLazy.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj2));
        expect(await listener.next, obj2);

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('.putAll()', web: false, () async {
        final listenerLazy = Listener<void>(IdrisDb.values.watchObjectLazy(1));
        final listener = Listener<Value?>(IdrisDb.values.watchObject(2));

        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj3]));
        await listenerLazy.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2]));
        await listenerLazy.next;
        expect(await listener.next, obj2);

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('.delete()', web: false, () async {
        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2, obj3]));

        final listenerLazy = Listener<void>(IdrisDb.values.watchObjectLazy(1));
        final listener = Listener<Value?>(IdrisDb.values.watchObject(2));

        IdrisDb.write((IdrisDb) => IdrisDb.values.delete(1));
        await listenerLazy.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.delete(2));
        expect(await listener.next, null);

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('.deleteAll()', web: false, () async {
        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2, obj3]));

        final listenerLazy = Listener<void>(IdrisDb.values.watchObjectLazy(1));
        final listener = Listener<Value?>(IdrisDb.values.watchObject(2));

        IdrisDb.write((IdrisDb) => IdrisDb.values.deleteAll([4, 1]));
        await listenerLazy.next;

        IdrisDb.write((IdrisDb) => IdrisDb.values.deleteAll([2, 3]));
        expect(await listener.next, null);

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('fireImmediately', web: false, () async {
        final listenerLazy = Listener<void>(
          IdrisDb.values.watchObjectLazy(1, fireImmediately: true),
        );
        final listener = Listener<Value?>(
          IdrisDb.values.watchObject(1, fireImmediately: true),
        );

        await listenerLazy.next;
        expect(await listener.next, null);
        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj1));
        await listenerLazy.next;
        expect(await listener.next, obj1);

        await listenerLazy.done();
        await listener.done();
      });
    });

    group('Query', () {
      IdrisDbTest('.put()', web: false, () async {
        final listenerLazy = Listener(
          IdrisDb.values.where().valueEqualTo('Hello').watchLazy(),
        );
        final listener = Listener(
          IdrisDb.values.where().valueEqualTo('Hi').watch(),
        );

        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj1));
        await listenerLazy.next;
        if (isSQLite) {
          expect(await listener.next, isEmpty);
        }

        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj2));
        expect(await listener.next, [obj2]);
        if (isSQLite) {
          await listenerLazy.next;
        }

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('.putAll()', web: false, () async {
        final listenerLazy = Listener(
          IdrisDb.values.where().valueContains('H').watchLazy(),
        );
        final listener = Listener(
          IdrisDb.values.where().valueContains('H').watch(),
        );

        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2]));
        await listenerLazy.next;
        expect(await listener.next, [obj1, obj2]);

        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj3]));
        if (isSQLite) {
          await listenerLazy.next;
          expect(await listener.next, [obj1, obj2]);
        }

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('.delete()', web: false, () async {
        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2, obj3]));

        final listenerLazy = Listener(
          IdrisDb.values.where().valueEqualTo('Hello').watchLazy(),
        );
        final listener = Listener(
          IdrisDb.values.where().valueEqualTo('Hi').watch(),
        );

        IdrisDb.write((IdrisDb) => IdrisDb.values.delete(1));
        await listenerLazy.next;
        if (isSQLite) {
          expect(await listener.next, [obj2]);
        }

        IdrisDb.write((IdrisDb) => IdrisDb.values.delete(2));
        if (isSQLite) {
          await listenerLazy.next;
        }
        expect(await listener.next, <dynamic>[]);

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('.deleteAll()', web: false, () async {
        IdrisDb.write((IdrisDb) => IdrisDb.values.putAll([obj1, obj2, obj3]));

        final listenerLazy = Listener(
          IdrisDb.values.where().valueContains('H').watchLazy(),
        );
        final listener = Listener(
          IdrisDb.values.where().valueContains('H').watch(),
        );

        IdrisDb.write((IdrisDb) => IdrisDb.values.deleteAll([1, 2]));
        await listenerLazy.next;
        expect(await listener.next, <dynamic>[]);

        IdrisDb.write((IdrisDb) => IdrisDb.values.deleteAll([3]));
        if (isSQLite) {
          await listenerLazy.next;
          expect(await listener.next, <dynamic>[]);
        }

        await listenerLazy.done();
        await listener.done();
      });

      IdrisDbTest('fireImmediately', web: false, () async {
        final listenerLazy = Listener(
          IdrisDb.values
              .where()
              .valueEqualTo('Hello')
              .watchLazy(fireImmediately: true),
        );
        final listener = Listener(
          IdrisDb.values
              .where()
              .valueEqualTo('Hello')
              .watch(fireImmediately: true),
        );

        await listenerLazy.next;
        expect(await listener.next, isEmpty);
        IdrisDb.write((IdrisDb) => IdrisDb.values.put(obj1));
        await listenerLazy.next;
        expect(await listener.next, [obj1]);

        await listenerLazy.done();
        await listener.done();
      });
    });
  });
}
