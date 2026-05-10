part of '../../idris_db.dart';

/// Query execution error
/// 
/// Thrown when a query fails to execute due to syntax errors,
/// invalid field names, or other query-related issues.
class QueryExecutionError extends IdrisDbEnhancedError {
  QueryExecutionError(String query, String reason)
      : super(
          IdrisDbEnhancedError.language == 'ar'
              ? 'فشل تنفيذ الاستعلام: $reason'
              : 'Query execution failed: $reason',
          code: 'QUERY_EXECUTION_ERROR',
          hint: IdrisDbEnhancedError.language == 'ar'
              ? 'قد يستخدم الاستعلام أسماء حقول غير صالحة أو صيغة غير صحيحة'
              : 'The query might be using invalid field names or incorrect syntax',
          solution: IdrisDbEnhancedError.language == 'ar'
              ? 'تحقق من الاستعلام:\n'
                  '  - تأكد من وجود جميع أسماء الحقول في المجموعة\n'
                  '  - تأكد من صحة شروط الفلترة\n'
                  '  - تحقق من الأخطاء الإملائية في أسماء الحقول\n'
                  '\nالاستعلام: $query'
              : 'Check your query:\n'
                  '  - Verify all field names exist in the collection\n'
                  '  - Ensure filter conditions are valid\n'
                  '  - Check for typos in field names\n'
                  '\nQuery: $query',
          docsUrl: 'https://github.com/IDRISIUMCorp/idris_db#queries',
        );
}
