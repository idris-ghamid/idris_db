part of '../../idris_db.dart';

/// Schema validation error
/// 
/// Thrown when a schema definition is invalid or doesn't meet
/// the requirements for Idris DB collections.
class SchemaValidationError extends IdrisDbEnhancedError {
  SchemaValidationError(String field, String reason)
      : super(
          IdrisDbEnhancedError.language == 'ar'
              ? 'فشل التحقق من schema للحقل "$field": $reason'
              : 'Schema validation failed for field "$field": $reason',
          code: 'SCHEMA_VALIDATION_ERROR',
          hint: IdrisDbEnhancedError.language == 'ar'
              ? 'قد يكون تعريف schema يفتقد إلى annotations مطلوبة أو يحتوي على أنواع حقول غير صالحة'
              : 'The schema definition might be missing required annotations or have invalid field types',
          solution: IdrisDbEnhancedError.language == 'ar'
              ? 'تحقق من تعريف schema:\n'
                  '  - تأكد من أن الـ class يحتوي على @collection annotation\n'
                  '  - تحقق من أن جميع الحقول لها أنواع صحيحة\n'
                  '  - تأكد من تعريف حقل Id بشكل صحيح\n'
                  '  - شغل code generation: flutter pub run build_runner build'
              : 'Check your schema definition:\n'
                  '  - Ensure the class has @collection annotation\n'
                  '  - Verify all fields have proper types\n'
                  '  - Check that Id field is properly defined\n'
                  '  - Run code generation: flutter pub run build_runner build',
          docsUrl: 'https://github.com/IDRISIUMCorp/idris_db#schema',
        );
}
