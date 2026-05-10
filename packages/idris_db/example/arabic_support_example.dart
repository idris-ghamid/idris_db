// ignore_for_file: avoid_print

import 'package:idris_db/idris_db.dart';

/// Example demonstrating Arabic Support
/// 
/// This example shows how to use Arabic error messages
/// by switching the language setting.
void main() async {
  print('🌍 Idris DB - Arabic Support Example\n');
  print('═══════════════════════════════════════════════════════════════\n');

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 1: English Error Messages (Default)
  // ═══════════════════════════════════════════════════════════════════════════

  print('EXAMPLE 1: English Error Messages (Default)');
  print('═══════════════════════════════════════════════════════════════\n');

  // Default language is English
  print('Current language: ${IdrisDbEnhancedError.language}\n');

  // Demonstrate all error types in English
  print('1. CollectionNotFoundError:');
  print(CollectionNotFoundError('User'));
  print('');

  print('2. DataValidationError:');
  print(DataValidationError('email', 'invalid-email', 'Must be a valid email'));
  print('');

  print('3. QueryExecutionError:');
  print(QueryExecutionError('users.filter().invalidField()', 'Field does not exist'));
  print('');

  print('4. SchemaValidationError:');
  print(SchemaValidationError('name', 'Missing @collection annotation'));
  print('');

  print('5. TransactionError:');
  print(TransactionError('Concurrent modification detected'));
  print('');

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 2: Arabic Error Messages
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 2: Arabic Error Messages');
  print('═══════════════════════════════════════════════════════════════\n');

  // Switch to Arabic
  IdrisDbEnhancedError.language = 'ar';
  print('تم تغيير اللغة إلى: ${IdrisDbEnhancedError.language}\n');

  // Demonstrate all error types in Arabic
  print('1. CollectionNotFoundError (خطأ المجموعة غير موجودة):');
  print(CollectionNotFoundError('User'));
  print('');

  print('2. DataValidationError (خطأ التحقق من البيانات):');
  print(DataValidationError('email', 'invalid-email', 'يجب أن يكون بريد إلكتروني صالح'));
  print('');

  print('3. QueryExecutionError (خطأ تنفيذ الاستعلام):');
  print(QueryExecutionError('users.filter().invalidField()', 'الحقل غير موجود'));
  print('');

  print('4. SchemaValidationError (خطأ التحقق من Schema):');
  print(SchemaValidationError('name', 'يفتقد @collection annotation'));
  print('');

  print('5. TransactionError (خطأ المعاملة):');
  print(TransactionError('تم اكتشاف تعديل متزامن'));
  print('');

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 3: Switching Languages Dynamically
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 3: Switching Languages Dynamically');
  print('═══════════════════════════════════════════════════════════════\n');

  final error = CollectionNotFoundError('Product');

  print('English:');
  IdrisDbEnhancedError.language = 'en';
  print(error);
  print('');

  print('العربية:');
  IdrisDbEnhancedError.language = 'ar';
  print(error);
  print('');

  print('English again:');
  IdrisDbEnhancedError.language = 'en';
  print(error);
  print('');

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 4: Language Detection Based on Locale
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 4: Language Detection Based on Locale');
  print('═══════════════════════════════════════════════════════════════\n');

  // Simulate setting language based on device locale
  void setLanguageFromLocale(String locale) {
    if (locale.startsWith('ar')) {
      IdrisDbEnhancedError.language = 'ar';
      print('تم اكتشاف اللغة العربية من الـ locale: $locale');
    } else {
      IdrisDbEnhancedError.language = 'en';
      print('Detected English from locale: $locale');
    }
  }

  // Test with different locales
  setLanguageFromLocale('ar_EG'); // Arabic (Egypt)
  print(CollectionNotFoundError('Order'));
  print('');

  setLanguageFromLocale('en_US'); // English (US)
  print(CollectionNotFoundError('Order'));
  print('');

  setLanguageFromLocale('ar_SA'); // Arabic (Saudi Arabia)
  print(CollectionNotFoundError('Order'));
  print('');

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 5: Best Practices
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 5: Best Practices');
  print('═══════════════════════════════════════════════════════════════\n');

  print('✅ Best Practices for Arabic Support:\n');
  print('1. Set language at app startup based on user preference:');
  print('   IdrisDbEnhancedError.language = userPreferredLanguage;\n');
  
  print('2. Detect from device locale:');
  print('   final locale = Platform.localeName;');
  print('   IdrisDbEnhancedError.language = locale.startsWith("ar") ? "ar" : "en";\n');
  
  print('3. Allow users to switch language in settings:');
  print('   // In settings screen');
  print('   onLanguageChanged(String lang) {');
  print('     IdrisDbEnhancedError.language = lang;');
  print('   }\n');
  
  print('4. Supported languages:');
  print('   - "en" - English (default)');
  print('   - "ar" - العربية (Arabic)\n');

  // Reset to English
  IdrisDbEnhancedError.language = 'en';

  print('═══════════════════════════════════════════════════════════════');
  print('✨ Arabic Support Example Complete!');
  print('═══════════════════════════════════════════════════════════════');
  print('\n📚 Key Features Demonstrated:');
  print('   ✓ English error messages (default)');
  print('   ✓ Arabic error messages (العربية)');
  print('   ✓ Dynamic language switching');
  print('   ✓ Locale-based language detection');
  print('   ✓ All 5 error types support both languages');
  print('\n💡 In Real Usage:');
  print('   - Set language once at app startup');
  print('   - Use device locale for automatic detection');
  print('   - Allow users to override in settings');
  print('   - All error messages will automatically use selected language');
}
