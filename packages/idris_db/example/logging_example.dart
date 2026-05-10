// ignore_for_file: avoid_print

import 'package:idris_db/idris_db.dart';

/// Example demonstrating the Smart Logging System
/// 
/// This example shows how to use IdrisDbLogger to track
/// database operations with different log levels.
void main() async {
  print('=== Idris DB - Smart Logging Example ===\n');
  
  // ============================================
  // 1. Configure Logging Level
  // ============================================
  print('1. Configuring log level...');
  
  // Set to debug to see all operations
  IdrisDbLogger.setLevel(LogLevel.debug);
  print('   Log level set to: ${IdrisDbLogger.level}\n');
  
  // ============================================
  // 2. Manual Logging
  // ============================================
  print('2. Manual logging examples:');
  
  IdrisDbLogger.trace('This is a trace message (very detailed)');
  IdrisDbLogger.debug('This is a debug message (detailed)');
  IdrisDbLogger.info('This is an info message (general)');
  IdrisDbLogger.warning('This is a warning message (caution)');
  IdrisDbLogger.error('This is an error message (problem)');
  print('');
  
  // ============================================
  // 3. Query Logging
  // ============================================
  print('3. Query logging:');
  
  // Simulate a query
  IdrisDbLogger.query(
    'users.filter().ageGreaterThan(18).findAll()',
    Duration(milliseconds: 23),
    1234,
  );
  print('');
  
  // ============================================
  // 4. Transaction Logging
  // ============================================
  print('4. Transaction logging:');
  
  // Simulate a transaction
  IdrisDbLogger.transaction(
    'Insert 5 users',
    Duration(milliseconds: 45),
  );
  print('');
  
  // ============================================
  // 5. Error Logging with Stack Trace
  // ============================================
  print('5. Error logging with details:');
  
  try {
    throw Exception('Simulated database error');
  } catch (e, stackTrace) {
    IdrisDbLogger.error(
      'Failed to execute query',
      e,
      stackTrace,
    );
  }
  print('');
  
  // ============================================
  // 6. Log History
  // ============================================
  print('6. Viewing log history:');
  
  final history = IdrisDbLogger.history;
  print('   Total log entries: ${history.length}');
  print('   Last 3 entries:');
  
  for (final entry in history.take(3)) {
    print('   - [${entry.level.name.toUpperCase()}] ${entry.message}');
  }
  print('');
  
  // ============================================
  // 7. Log Level Filtering
  // ============================================
  print('7. Log level filtering:');
  
  // Clear history
  IdrisDbLogger.clearHistory();
  
  // Set to warning level (only warnings and errors)
  IdrisDbLogger.setLevel(LogLevel.warning);
  print('   Log level set to: WARNING');
  
  // These won't be logged
  IdrisDbLogger.debug('This debug message will be ignored');
  IdrisDbLogger.info('This info message will be ignored');
  
  // These will be logged
  IdrisDbLogger.warning('This warning will be logged');
  IdrisDbLogger.error('This error will be logged');
  
  print('   Logged entries: ${IdrisDbLogger.history.length}');
  print('');
  
  // ============================================
  // 8. Production vs Development
  // ============================================
  print('8. Production vs Development logging:');
  
  // In production: minimal logging
  IdrisDbLogger.setLevel(LogLevel.error);
  print('   Production mode: Only errors logged');
  
  // In development: detailed logging
  IdrisDbLogger.setLevel(LogLevel.debug);
  print('   Development mode: All operations logged');
  print('');
  
  // ============================================
  // 9. Performance Tracking
  // ============================================
  print('9. Performance tracking example:');
  
  IdrisDbLogger.clearHistory();
  
  // Simulate multiple queries
  for (var i = 0; i < 5; i++) {
    IdrisDbLogger.query(
      'Query #$i',
      Duration(milliseconds: 10 + i * 5),
      100 + i * 50,
    );
  }
  
  // Analyze performance
  final queryLogs = IdrisDbLogger.history
      .where((e) => e.message.contains('Query'))
      .toList();
  
  print('   Total queries: ${queryLogs.length}');
  print('   Query log entries captured');
  print('');
  
  // ============================================
  // 10. Best Practices
  // ============================================
  print('10. Best Practices:');
  print('   ✓ Use LogLevel.debug in development');
  print('   ✓ Use LogLevel.warning in production');
  print('   ✓ Use LogLevel.error for critical apps');
  print('   ✓ Clear history periodically to save memory');
  print('   ✓ Export logs for debugging issues');
  print('');
  
  print('=== Example Complete ===');
}

