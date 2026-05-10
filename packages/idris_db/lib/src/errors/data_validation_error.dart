part of '../../idris_db.dart';

/// Data validation error
/// 
/// Thrown when data validation fails before inserting or updating
/// a document in the database.
class DataValidationError extends IdrisDbEnhancedError {
  DataValidationError(String field, dynamic value, String constraint)
      : super(
          IdrisDbEnhancedError.language == 'ar'
              ? 'فشل التحقق من الحقل "$field" بالقيمة "$value": $constraint'
              : 'Validation failed for field "$field" with value "$value": $constraint',
          code: 'DATA_VALIDATION_ERROR',
          hint: IdrisDbEnhancedError.language == 'ar'
              ? 'القيمة المقدمة لا تتوافق مع قيود التحقق'
              : 'The value provided does not meet the validation constraints',
          solution: IdrisDbEnhancedError.language == 'ar'
              ? 'تحقق من قواعد التحقق لهذا الحقل:\n'
                  '  - تأكد من أن القيمة تطابق الصيغة المتوقعة\n'
                  '  - تحقق من قيود min/max\n'
                  '  - تأكد من أن الحقول المطلوبة ليست null'
              : 'Check the validation rules for this field:\n'
                  '  - Ensure the value matches the expected format\n'
                  '  - Check min/max constraints\n'
                  '  - Verify required fields are not null',
          docsUrl: 'https://github.com/IDRISIUMCorp/idris_db#validation',
        );
}
