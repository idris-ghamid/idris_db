part of '../../idris_db.dart';

/// Enhanced error class with detailed information
/// 
/// Provides clear, actionable error messages with:
/// - Error message
/// - Hint (what might be wrong)
/// - Solution (how to fix it)
/// - Error code (for programmatic handling)
/// - Documentation link
class IdrisDbEnhancedError implements Exception {
  /// The error message
  final String message;
  
  /// Hint for fixing the error
  final String? hint;
  
  /// Suggested solution
  final String? solution;
  
  /// Error code for programmatic handling
  final String code;
  
  /// Stack trace context
  final StackTrace? stackTrace;
  
  /// Related documentation URL
  final String? docsUrl;
  
  /// Language for error messages ('en' or 'ar')
  static String language = 'en';
  
  const IdrisDbEnhancedError(
    this.message, {
    this.hint,
    this.solution,
    required this.code,
    this.stackTrace,
    this.docsUrl,
  });
  
  @override
  String toString() {
    if (language == 'ar') {
      return _toStringArabic();
    }
    return _toStringEnglish();
  }
  
  String _toStringEnglish() {
    final buffer = StringBuffer();
    buffer.writeln('❌ Idris DB Error [$code]');
    buffer.writeln('   $message');
    
    if (hint != null) {
      buffer.writeln('\n💡 Hint: $hint');
    }
    
    if (solution != null) {
      buffer.writeln('\n✅ Solution: $solution');
    }
    
    if (docsUrl != null) {
      buffer.writeln('\n📚 Docs: $docsUrl');
    }
    
    return buffer.toString();
  }
  
  String _toStringArabic() {
    final buffer = StringBuffer();
    buffer.writeln('❌ خطأ Idris DB [$code]');
    buffer.writeln('   $message');
    
    if (hint != null) {
      buffer.writeln('\n💡 تلميح: $hint');
    }
    
    if (solution != null) {
      buffer.writeln('\n✅ الحل: $solution');
    }
    
    if (docsUrl != null) {
      buffer.writeln('\n📚 التوثيق: $docsUrl');
    }
    
    return buffer.toString();
  }
}
