import 'package:idris_db/idris_db.dart';

// 1. Define your model
@collection
class User {
  Id? id;

  @Index()
  late String name;

  late int age;
}

void main() async {
  // 2. Open the database
  final idrisDb = await IdrisDb.open([UserSchema]);

  // 3. Create a new user
  final newUser = User()
    ..name = 'Idris Ghamid'
    ..age = 25;

  // 4. Write data
  await idrisDb.writeTxn(() async {
    await idrisDb.users.put(newUser);
  });

  // 5. Query data
  final users = await idrisDb.users.where().nameEqualTo('Idris Ghamid').findAll();
  
  print('Found ${users.length} users');
  
  // 6. Use the NEW Query Analyzer (Exclusive to idris DB)
  final analyzer = QueryAnalyzer(idrisDb);
  final analysis = await analyzer.analyze(() {
    return idrisDb.users.filter().ageGreaterThan(18).findAll();
  });
  
  print(analysis);
}
