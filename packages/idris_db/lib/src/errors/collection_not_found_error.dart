part of '../../idris_db.dart';

/// Collection not found error
/// 
/// Thrown when trying to access a collection that hasn't been registered
/// in the database schema.
class CollectionNotFoundError extends IdrisDbEnhancedError {
  CollectionNotFoundError(String collectionName)
      : super(
          IdrisDbEnhancedError.language == 'ar'
              ? 'المجموعة "$collectionName" غير موجودة في قاعدة البيانات'
              : 'Collection "$collectionName" not found in database',
          code: 'COLLECTION_NOT_FOUND',
          hint: IdrisDbEnhancedError.language == 'ar'
              ? 'قد يكون schema المجموعة غير مسجل عند فتح قاعدة البيانات'
              : 'The collection schema might not be registered when opening the database',
          solution: IdrisDbEnhancedError.language == 'ar'
              ? 'أضف ${collectionName}Schema إلى قائمة schemas عند استدعاء IdrisDb.open():\n'
                  '  final db = await IdrisDb.open(\n'
                  '    schemas: [${collectionName}Schema],\n'
                  '  );'
              : 'Add ${collectionName}Schema to the schemas list when calling IdrisDb.open():\n'
                  '  final db = await IdrisDb.open(\n'
                  '    schemas: [${collectionName}Schema],\n'
                  '  );',
          docsUrl: 'https://github.com/IDRISIUMCorp/idris_db#collections',
        );
}
