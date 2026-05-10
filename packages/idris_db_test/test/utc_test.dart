import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:test/test.dart';

part 'utc_test.g.dart';

@collection
class DateModel {
  DateModel(this.id, this.date, this.dateUtc);

  int id;

  DateTime date;

  @utc
  DateTime dateUtc;
}

void main() {
  group('UTC', () {
    late IdrisDb IdrisDb;
    late IdrisDbCollection<int, DateModel> col;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([DateModelSchema]);
      col = IdrisDb.dateModels;
    });

    IdrisDbTest('get', () {
      final date = DateTime.now();

      IdrisDb.write((IdrisDb) {
        col.put(DateModel(1, date, date));
        col.put(DateModel(2, date.toUtc(), date.toUtc()));
      });

      expect(col.get(1)!.date, date);
      expect(col.get(1)!.dateUtc, date.toUtc());
      expect(col.get(2)!.date, date);
      expect(col.get(2)!.dateUtc, date.toUtc());
    });

    IdrisDbTest('get property', () {
      final date = DateTime.now();

      IdrisDb.write((IdrisDb) {
        col.put(DateModel(1, date, date));
        col.put(DateModel(2, date.toUtc(), date.toUtc()));
      });

      expect(col.where().dateProperty().findAll(), [date, date]);
      expect(col.where().dateUtcProperty().findAll(), [
        date.toUtc(),
        date.toUtc(),
      ]);
    });
  });
}
