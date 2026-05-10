import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'watcher_detailed_test.g.dart';

@collection
class WatcherModel implements DocumentSerializable {
  WatcherModel(this.id, this.name);

  factory WatcherModel.fromJson(Map<String, dynamic> json) {
    return WatcherModel(json['id'] as int, json['name'] as String);
  }

  final int id;
  final String name;

  @override
  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatcherModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'WatcherModel(id: $id, name: $name)';
}

void main() {
  group('Watcher Detailed', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([WatcherModelSchema]);
    });

    IdrisDbTest('Receive insert event', web: false, () async {
      final listener = Listener<ChangeDetail<WatcherModel>>(
        IdrisDb.watcherModels.watchDetailed(documentParser: WatcherModel.fromJson),
      );

      final model = WatcherModel(1, 'Test');
      IdrisDb.write((IdrisDb) => IdrisDb.watcherModels.put(model));

      final event = await listener.next;
      expect(event.changeType, ChangeType.insert);
      expect(event.objectId, 1);
      expect(event.fullDocument, model);
      expect(event.fieldChanges, isNotEmpty);

      await listener.done();
    });

    IdrisDbTest('Receive update event', web: false, () async {
      final model = WatcherModel(1, 'Old');
      IdrisDb.write((IdrisDb) => IdrisDb.watcherModels.put(model));

      final listener = Listener<ChangeDetail<WatcherModel>>(
        IdrisDb.watcherModels.watchDetailed(documentParser: WatcherModel.fromJson),
      );

      final updated = WatcherModel(1, 'New');
      IdrisDb.write((IdrisDb) => IdrisDb.watcherModels.put(updated));

      final event = await listener.next;
      expect(event.changeType, ChangeType.update);
      expect(event.objectId, 1);
      expect(event.fullDocument, updated);
      expect(event.wasFieldModified('name'), isTrue);
      expect(event.getFieldChange('name')?.oldValue, 'Old');
      expect(event.getFieldChange('name')?.newValue, 'New');

      await listener.done();
    });

    IdrisDbTest('Receive delete event', web: false, () async {
      final model = WatcherModel(1, 'Test');
      IdrisDb.write((IdrisDb) => IdrisDb.watcherModels.put(model));

      final listener = Listener<ChangeDetail<WatcherModel>>(
        IdrisDb.watcherModels.watchDetailed(documentParser: WatcherModel.fromJson),
      );

      IdrisDb.write((IdrisDb) => IdrisDb.watcherModels.delete(1));

      final event = await listener.next;
      expect(event.changeType, ChangeType.delete);
      expect(event.objectId, 1);

      await listener.done();
    });
  });
}
