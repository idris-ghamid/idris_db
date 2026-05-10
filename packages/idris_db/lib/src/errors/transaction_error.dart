part of '../../idris_db.dart';

/// Transaction error
/// 
/// Thrown when a database transaction fails to complete successfully.
class TransactionError extends IdrisDbEnhancedError {
  TransactionError(String reason)
      : super(
          IdrisDbEnhancedError.language == 'ar'
              ? 'فشلت المعاملة: $reason'
              : 'Transaction failed: $reason',
          code: 'TRANSACTION_ERROR',
          hint: IdrisDbEnhancedError.language == 'ar'
              ? 'قد تكون المعاملة قد أُلغيت بسبب تعارض أو خطأ'
              : 'The transaction might have been aborted due to a conflict or error',
          solution: IdrisDbEnhancedError.language == 'ar'
              ? 'جرب ما يلي:\n'
                  '  - أعد محاولة المعاملة\n'
                  '  - تحقق من التعديلات المتزامنة\n'
                  '  - تأكد من صحة جميع العمليات داخل المعاملة\n'
                  '  - تحقق من أن قاعدة البيانات ليست مغلقة'
              : 'Try the following:\n'
                  '  - Retry the transaction\n'
                  '  - Check for concurrent modifications\n'
                  '  - Ensure all operations within the transaction are valid\n'
                  '  - Verify database is not closed',
          docsUrl: 'https://github.com/IDRISIUMCorp/idris_db#transactions',
        );
}
