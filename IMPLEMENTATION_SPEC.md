# 🚀 Idris DB - Complete Implementation Specification

**Version:** 1.0.0  
**Author:** Idris Ghamid / IDRISIUM Corp  
**Date:** 9 مايو 2026  
**Status:** Ready for Implementation

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Testing Results](#testing-results)
3. [Feature 1: Better Error Messages](#feature-1-better-error-messages)
4. [Feature 2: Smart Logging System](#feature-2-smart-logging-system)
5. [Feature 3: Query Performance Analyzer](#feature-3-query-performance-analyzer)
6. [Feature 4: Built-in Data Validation](#feature-4-built-in-data-validation)
7. [Feature 5: Backup & Restore](#feature-5-backup--restore)
8. [Feature 6: Smart Caching Layer](#feature-6-smart-caching-layer)
9. [Feature 7: Real-time Database Stats](#feature-7-real-time-database-stats)
10. [Feature 8: Export/Import Tools](#feature-8-exportimport-tools)
11. [Feature 9: Arabic Language Support](#feature-9-arabic-language-support)
12. [Feature 10: Visual Database Inspector](#feature-10-visual-database-inspector)
13. [Implementation Timeline](#implementation-timeline)
14. [Testing Strategy](#testing-strategy)

---

## Overview

### 🎯 **Project Goal**

تحويل **idris_db** من fork بسيط لـ idris_db إلى **أقوى مكتبة NoSQL لـ Flutter** مع 10 exclusive features غير موجودة في أي مكتبة تانية.

### ✅ **Current Status**

- ✅ Fork من idris_db مكتمل
- ✅ Branding متحدث (README, LICENSE, NOTICE)
- ✅ Dependencies شغالة
- ⚠️ Generator فيه compatibility issue مع analyzer 9.0 (محتاج fix)
- ❌ الـ 10 Exclusive Features لسه مش متنفذة

### 🎯 **Success Criteria**

1. كل الـ 10 features شغالة 100%
2. Test coverage >= 80%
3. Documentation كاملة (English + Arabic)
4. Examples لكل feature
5. Performance benchmarks
6. Ready for pub.dev publishing

---

## Testing Results

### 📊 **Current Test Status**

```bash
dart test
```

**Result:** ❌ Failed

**Error:** Compatibility issue with analyzer 9.0.0
- `TypeChecker.fromRuntime` method not found
- `ConstructorElement.parameters` getter not found
- `ConstructorElement.enclosingElement3` getter not found

**Root Cause:** analyzer API changed from version 6.x to 9.x

**Fix Required:** Update generator code to use new analyzer API

**Priority:** 🔴 High (blocks all features)

---

## Feature 1: Better Error Messages

### 🎯 **Goal**

Replace vague `IdrisDbError` messages with **clear, actionable errors** that include:
- ❌ Error message
- 💡 Hint (what might be wrong)
- ✅ Solution (how to fix it)
- 📚 Documentation link
- 🔢 Error code (for programmatic handling)

### 📊 **Current State**

```dart
// ❌ Vague error
throw IdrisDbError('Operation failed');
throw IdrisDbError('Invalid schema');
throw IdrisDbError('Collection not found');
```

**Problems:**
- No context
- No solution
- Hard to debug
- No error codes

### ✨ **New Implementation**

#### **1.1 Base Error Class**

**File:** `lib/src/errors/idris_db_error.dart`

```dart
/// Enhanced error class with detailed information
class IdrisDbError implements Exception {
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
  
  const IdrisDbError(
    this.message, {
    this.hint,
    this.solution,
    required this.code,
    this.stackTrace,
    this.docsUrl,
  });
  
  @override
  String toString() {
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
}
```

#### **1.2 Specific Error Types**

**File:** `lib/src/errors/collection_not_found_error.dart`

```dart
/// Collection not found error
class CollectionNotFoundError extends IdrisDbError {
  CollectionNotFoundError(String collectionName)
      : super(
          'Collection "$collectionName" not found in database',
          hint: 'Make sure the collection schema is registered',
          solution: 'Add ${collectionName}Schema to IdrisDb.open(schemas: [...])',
          code: 'COLLECTION_NOT_FOUND',
          docsUrl: 'https://github.com/idris-ghamid/idris_db#collection-not-found',
        );
}
```

**File:** `lib/src/errors/schema_validation_error.dart`

```dart
/// Schema validation error
class SchemaValidationError extends IdrisDbError {
  SchemaValidationError(String field, String reason)
      : super(
          'Schema validation failed for field "$field": $reason',
          hint: 'Check your @Collection() annotation',
          solution: 'Ensure all required fields are properly annotated',
          code: 'SCHEMA_VALIDATION_ERROR',
          docsUrl: 'https://github.com/idris-ghamid/idris_db#schema-validation',
        );
}
```

**File:** `lib/src/errors/query_execution_error.dart`

```dart
/// Query execution error
class QueryExecutionError extends IdrisDbError {
  QueryExecutionError(String query, String reason)
      : super(
          'Query execution failed: $reason',
          hint: 'Query: $query',
          solution: 'Check your query syntax and field names',
          code: 'QUERY_EXECUTION_ERROR',
          docsUrl: 'https://github.com/idris-ghamid/idris_db#query-execution',
        );
}
```

**File:** `lib/src/errors/data_validation_error.dart`

```dart
/// Data validation error
class DataValidationError extends IdrisDbError {
  DataValidationError(String field, dynamic value, String constraint)
      : super(
          'Validation failed for field "$field" with value "$value"',
          hint: 'Constraint: $constraint',
          solution: 'Ensure the value meets the validation rules',
          code: 'DATA_VALIDATION_ERROR',
          docsUrl: 'https://github.com/idris-ghamid/idris_db#data-validation',
        );
}
```

**File:** `lib/src/errors/transaction_error.dart`

```dart
/// Transaction error
class TransactionError extends IdrisDbError {
  TransactionError(String reason)
      : super(
          'Transaction failed: $reason',
          hint: 'Check if the database is open and not corrupted',
          solution: 'Try closing and reopening the database',
          code: 'TRANSACTION_ERROR',
          docsUrl: 'https://github.com/idris-ghamid/idris_db#transaction-error',
        );
}
```

#### **1.3 Migration Strategy**

**Step 1:** Create all error classes  
**Step 2:** Update `lib/idris_db.dart` to export them  
**Step 3:** Find and replace all `throw IdrisDbError(...)` with specific errors  
**Step 4:** Update tests  
**Step 5:** Update documentation

**Files to Modify:**
- `lib/src/IDRISDB_error.dart` - Keep for backward compatibility
- `lib/src/impl/IDRISDB_impl.dart` - Replace errors
- `lib/src/impl/IDRISDB_collection_impl.dart` - Replace errors
- `lib/src/impl/IDRISDB_query_impl.dart` - Replace errors

#### **1.4 Usage Example**

```dart
// Before
try {
  await IdrisDb.collection<User>().findAll();
} catch (e) {
  print(e); // IdrisDbError: Operation failed
}

// After
try {
  await IdrisDb.collection<User>().findAll();
} catch (e) {
  if (e is CollectionNotFoundError) {
    print(e);
    // Output:
    // ❌ Idris DB Error [COLLECTION_NOT_FOUND]
    //    Collection "User" not found in database
    //
    // 💡 Hint: Make sure the collection schema is registered
    //
    // ✅ Solution: Add UserSchema to IdrisDb.open(schemas: [...])
    //
    // 📚 Docs: https://github.com/idris-ghamid/idris_db#collection-not-found
  }
}
```

#### **1.5 Testing**

**File:** `test/errors/better_error_messages_test.dart`

```dart
import 'package:idris_db/idris_db.dart';
import 'package:test/test.dart';

void main() {
  group('Better Error Messages', () {
    test('CollectionNotFoundError has all fields', () {
      final error = CollectionNotFoundError('User');
      
      expect(error.message, contains('User'));
      expect(error.hint, isNotNull);
      expect(error.solution, isNotNull);
      expect(error.code, equals('COLLECTION_NOT_FOUND'));
      expect(error.docsUrl, isNotNull);
    });
    
    test('Error toString() is formatted correctly', () {
      final error = CollectionNotFoundError('User');
      final output = error.toString();
      
      expect(output, contains('❌ Idris DB Error'));
      expect(output, contains('[COLLECTION_NOT_FOUND]'));
      expect(output, contains('💡 Hint:'));
      expect(output, contains('✅ Solution:'));
      expect(output, contains('📚 Docs:'));
    });
  });
}
```

#### **1.6 Documentation**

**File:** `docs/errors.md`

```markdown
# Error Handling

## Error Codes

| Code | Error Class | Description |
|------|-------------|-------------|
| `COLLECTION_NOT_FOUND` | `CollectionNotFoundError` | Collection schema not registered |
| `SCHEMA_VALIDATION_ERROR` | `SchemaValidationError` | Invalid schema definition |
| `QUERY_EXECUTION_ERROR` | `QueryExecutionError` | Query failed to execute |
| `DATA_VALIDATION_ERROR` | `DataValidationError` | Data validation failed |
| `TRANSACTION_ERROR` | `TransactionError` | Transaction failed |

## Examples

[... examples for each error ...]
```

### ✅ **Acceptance Criteria**

- [ ] All 5 error classes created
- [ ] All errors have: message, hint, solution, code, docsUrl
- [ ] All `IdrisDbError` replaced with specific errors
- [ ] Tests written and passing
- [ ] Documentation complete
- [ ] Examples added to README

### ⏱️ **Estimated Time:** 4 hours

---

## Feature 2: Smart Logging System

### 🎯 **Goal**

Provide **comprehensive logging** for debugging and monitoring with:
- 📊 Multiple log levels (none, error, warning, info, debug, trace)
- ⏱️ Performance tracking (query duration, transaction duration)
- 📝 Log history (last 1000 entries)
- 🔍 Automatic query logging
- 💾 Automatic transaction logging

### 📊 **Current State**

**No logging system exists.** Developers have to manually add print statements.

### ✨ **New Implementation**

#### **2.1 Logger Class**

**File:** `lib/src/logging/idris_db_logger.dart`

```dart
/// Log levels
enum LogLevel {
  none,    // No logging
  error,   // Errors only
  warning, // Warnings and errors
  info,    // Info, warnings, and errors
  debug,   // Everything including debug info
  trace,   // Very detailed logging
}

/// Smart logger for Idris DB
class IdrisDbLogger {
  static LogLevel _level = LogLevel.warning;
  static final List<LogEntry> _history = [];
  static const int _maxHistorySize = 1000;
  
  /// Set the log level
  static void setLevel(LogLevel level) {
    _level = level;
  }
  
  /// Get current log level
  static LogLevel get level => _level;
  
  /// Get log history
  static List<LogEntry> get history => List.unmodifiable(_history);
  
  /// Clear log history
  static void clearHistory() {
    _history.clear();
  }
  
  /// Log an error
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_level.index >= LogLevel.error.index) {
      _log(LogLevel.error, message, error, stackTrace);
    }
  }
  
  /// Log a warning
  static void warning(String message) {
    if (_level.index >= LogLevel.warning.index) {
      _log(LogLevel.warning, message);
    }
  }
  
  /// Log info
  static void info(String message) {
    if (_level.index >= LogLevel.info.index) {
      _log(LogLevel.info, message);
    }
  }
  
  /// Log debug info
  static void debug(String message) {
    if (_level.index >= LogLevel.debug.index) {
      _log(LogLevel.debug, message);
    }
  }
  
  /// Log trace info
  static void trace(String message) {
    if (_level.index >= LogLevel.trace.index) {
      _log(LogLevel.trace, message);
    }
  }
  
  /// Log a query
  static void query(String query, Duration duration, int resultCount) {
    if (_level.index >= LogLevel.debug.index) {
      final message = '🔍 Query: $query\n'
          '   ⏱️  Duration: ${duration.inMilliseconds}ms\n'
          '   📊 Results: $resultCount';
      _log(LogLevel.debug, message);
    }
  }
  
  /// Log a transaction
  static void transaction(String operation, Duration duration) {
    if (_level.index >= LogLevel.debug.index) {
      final message = '💾 Transaction: $operation\n'
          '   ⏱️  Duration: ${duration.inMilliseconds}ms';
      _log(LogLevel.debug, message);
    }
  }
  
  static void _log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final entry = LogEntry(
      level: level,
      message: message,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
    
    // Add to history
    _history.add(entry);
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
    
    // Print to console
    print(entry.formatted);
  }
}
```

#### **2.2 Log Entry Class**

**File:** `lib/src/logging/log_entry.dart`

```dart
/// Log entry
class LogEntry {
  final LogLevel level;
  final String message;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
  
  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });
  
  String get formatted {
    final icon = _getIcon(level);
    final time = timestamp.toString().substring(11, 19);
    final buffer = StringBuffer();
    
    buffer.write('[$time] $icon [Idris DB] $message');
    
    if (error != null) {
      buffer.write('\n   Error: $error');
    }
    
    if (stackTrace != null && level == LogLevel.error) {
      buffer.write('\n   Stack trace:\n$stackTrace');
    }
    
    return buffer.toString();
  }
  
  String _getIcon(LogLevel level) {
    switch (level) {
      case LogLevel.error:
        return '❌';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.debug:
        return '🔧';
      case LogLevel.trace:
        return '🔍';
      default:
        return '📝';
    }
  }
}
```

#### **2.3 Integration Points**

**Files to Modify:**

1. **`lib/src/impl/IDRISDB_impl.dart`**
   - Add logging to `open()` method
   - Add logging to `close()` method
   - Add logging to `writeTxn()` method

2. **`lib/src/impl/IDRISDB_query_impl.dart`**
   - Add logging to `findAll()` method
   - Add logging to `findFirst()` method
   - Add logging to all query methods

3. **`lib/src/impl/IDRISDB_collection_impl.dart`**
   - Add logging to `put()` method
   - Add logging to `delete()` method
   - Add logging to `clear()` method

#### **2.4 Usage Example**

```dart
// Enable debug logging
IdrisDbLogger.setLevel(LogLevel.debug);

// Open database (auto-logged)
final IdrisDb = await IdrisDb.open([UserSchema]);
// Output: [12:34:56] ℹ️ [Idris DB] Opening database at /path/to/db

// Query (auto-logged)
final users = await IdrisDb.users.findAll();
// Output: [12:34:57] 🔍 [Idris DB] Query: users.findAll()
//            ⏱️  Duration: 2ms
//            📊 Results: 42

// Manual logging
IdrisDbLogger.info('Custom operation started');
IdrisDbLogger.warning('Cache is getting full');
IdrisDbLogger.error('Failed to sync', exception, stackTrace);

// View log history
for (final entry in IdrisDbLogger.history) {
  print(entry.formatted);
}

// Clear history
IdrisDbLogger.clearHistory();
```

#### **2.5 Testing**

**File:** `test/logging/smart_logging_test.dart`

```dart
import 'package:idris_db/idris_db.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    IdrisDbLogger.clearHistory();
  });
  
  group('Smart Logging', () {
    test('Log level filtering works', () {
      IdrisDbLogger.setLevel(LogLevel.warning);
      
      IdrisDbLogger.debug('Debug message');
      IdrisDbLogger.warning('Warning message');
      IdrisDbLogger.error('Error message');
      
      expect(IdrisDbLogger.history.length, equals(2)); // warning + error
    });
    
    test('Log history is limited to 1000 entries', () {
      IdrisDbLogger.setLevel(LogLevel.debug);
      
      for (int i = 0; i < 1500; i++) {
        IdrisDbLogger.debug('Message $i');
      }
      
      expect(IdrisDbLogger.history.length, equals(1000));
    });
    
    test('Query logging includes duration and count', () {
      IdrisDbLogger.setLevel(LogLevel.debug);
      
      IdrisDbLogger.query('users.findAll()', Duration(milliseconds: 5), 42);
      
      final entry = IdrisDbLogger.history.last;
      expect(entry.message, contains('users.findAll()'));
      expect(entry.message, contains('5ms'));
      expect(entry.message, contains('42'));
    });
  });
}
```

### ✅ **Acceptance Criteria**

- [ ] Logger class created with all log levels
- [ ] Log history implemented (max 1000 entries)
- [ ] Automatic query logging added
- [ ] Automatic transaction logging added
- [ ] Manual logging methods work
- [ ] Tests written and passing
- [ ] Documentation complete

### ⏱️ **Estimated Time:** 6 hours

---

## Feature 3: Query Performance Analyzer

### 🎯 **Goal**

Analyze queries and provide **actionable suggestions** for optimization:
- ⏱️ Measure query duration
- 📊 Count results
- ⚠️ Detect slow queries (>100ms)
- 💡 Suggest indexes
- 📈 Suggest pagination for large result sets

### 📊 **Current State**

**No performance analysis exists.** Developers have to manually profile queries.

### ✨ **New Implementation**

#### **3.1 Query Analyzer Class**

**File:** `lib/src/performance/query_analyzer.dart`

```dart
/// Query performance analyzer
class QueryAnalyzer {
  final IdrisDb IdrisDb;
  
  QueryAnalyzer(this.IdrisDb);
  
  /// Analyze a query and provide suggestions
  Future<QueryAnalysis> analyze<T>(
    Future<List<T>> Function() query,
  ) async {
    final stopwatch = Stopwatch()..start();
    final results = await query();
    stopwatch.stop();
    
    final duration = stopwatch.elapsed;
    final resultCount = results.length;
    
    // Analyze query performance
    final suggestions = <String>[];
    final warnings = <String>[];
    
    // Check if query is slow
    if (duration.inMilliseconds > 100) {
      warnings.add('Query took ${duration.inMilliseconds}ms (slow)');
      suggestions.add('Consider adding an index on the filtered fields');
    }
    
    // Check if result set is large
    if (resultCount > 1000) {
      warnings.add('Large result set: $resultCount documents');
      suggestions.add('Consider using pagination with .limit() and .offset()');
    }
    
    // Check if result set is empty
    if (resultCount == 0) {
      warnings.add('Query returned no results');
      suggestions.add('Check your filter conditions');
    }
    
    return QueryAnalysis(
      duration: duration,
      resultCount: resultCount,
      suggestions: suggestions,
      warnings: warnings,
    );
  }
  
  /// Get index suggestions for a collection
  Future<List<IndexSuggestion>> suggestIndexes<T>() async {
    // TODO: Analyze query patterns and suggest indexes
    // This requires tracking query history and analyzing filter patterns
    final suggestions = <IndexSuggestion>[];
    
    return suggestions;
  }
}
```

#### **3.2 Query Analysis Class**

**File:** `lib/src/performance/query_analysis.dart`

```dart
/// Query analysis result
class QueryAnalysis {
  final Duration duration;
  final int resultCount;
  final List<String> suggestions;
  final List<String> warnings;
  
  const QueryAnalysis({
    required this.duration,
    required this.resultCount,
    required this.suggestions,
    required this.warnings,
  });
  
  bool get isSlow => duration.inMilliseconds > 100;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Query Analysis:');
    buffer.writeln('   ⏱️  Duration: ${duration.inMilliseconds}ms');
    buffer.writeln('   📈 Results: $resultCount');
    
    if (warnings.isNotEmpty) {
      buffer.writeln('\n⚠️  Warnings:');
      for (final warning in warnings) {
        buffer.writeln('   - $warning');
      }
    }
    
    if (suggestions.isNotEmpty) {
      buffer.writeln('\n💡 Suggestions:');
      for (final suggestion in suggestions) {
        buffer.writeln('   - $suggestion');
      }
    }
    
    return buffer.toString();
  }
}

/// Index suggestion
class IndexSuggestion {
  final String collectionName;
  final String fieldName;
  final String reason;
  final double estimatedSpeedup;
  
  const IndexSuggestion({
    required this.collectionName,
    required this.fieldName,
    required this.reason,
    required this.estimatedSpeedup,
  });
}
```

#### **3.3 Usage Example**

```dart
// Analyze a query
final analyzer = QueryAnalyzer(IdrisDb);

final analysis = await analyzer.analyze(() {
  return IdrisDb.users
      .filter()
      .ageGreaterThan(18)
      .findAll();
});

print(analysis);
// Output:
// 📊 Query Analysis:
//    ⏱️  Duration: 234ms
//    📈 Results: 5000
//
// ⚠️  Warnings:
//    - Query took 234ms (slow)
//    - Large result set: 5000 documents
//
// 💡 Suggestions:
//    - Consider adding an index on the 'age' field
//    - Consider using pagination with .limit() and .offset()

// Get index suggestions
final suggestions = await analyzer.suggestIndexes<User>();
for (final suggestion in suggestions) {
  print('Add index on ${suggestion.fieldName}: ${suggestion.reason}');
  print('Estimated speedup: ${suggestion.estimatedSpeedup}x');
}
```

#### **3.4 Testing**

**File:** `test/performance/query_analyzer_test.dart`

```dart
import 'package:idris_db/idris_db.dart';
import 'package:test/test.dart';

void main() {
  group('Query Performance Analyzer', () {
    test('Detects slow queries', () async {
      final analyzer = QueryAnalyzer(IdrisDb);
      
      final analysis = await analyzer.analyze(() async {
        await Future.delayed(Duration(milliseconds: 150));
        return <User>[];
      });
      
      expect(analysis.isSlow, isTrue);
      expect(analysis.warnings, contains(contains('slow')));
    });
    
    test('Detects large result sets', () async {
      final analyzer = QueryAnalyzer(IdrisDb);
      
      final analysis = await analyzer.analyze(() async {
        return List.generate(2000, (i) => User());
      });
      
      expect(analysis.warnings, contains(contains('Large result set')));
      expect(analysis.suggestions, contains(contains('pagination')));
    });
  });
}
```

### ✅ **Acceptance Criteria**

- [ ] QueryAnalyzer class created
- [ ] Query duration measurement works
- [ ] Slow query detection works (>100ms)
- [ ] Large result set detection works (>1000)
- [ ] Suggestions are actionable
- [ ] Tests written and passing
- [ ] Documentation complete

### ⏱️ **Estimated Time:** 8 hours

---

## Implementation Timeline

### 📅 **Phase-by-Phase Schedule**

| Phase | Features | Duration | Priority | Status |
|-------|----------|----------|----------|--------|
| **Phase 0** | Fix analyzer compatibility | 4 hours | 🔴 Critical | ⏳ Pending |
| **Phase 1** | Features 1-2 | 10 hours | 🔴 High | ⏳ Pending |
| **Phase 2** | Features 3-5 | 20 hours | 🟡 Medium | ⏳ Pending |
| **Phase 3** | Features 7-9 | 12 hours | 🟢 Low | ⏳ Pending |
| **Phase 4** | Features 6, 10 | 16 hours | 🟢 Advanced | ⏳ Pending |
| **Testing** | All features | 8 hours | 🔴 High | ⏳ Pending |
| **Documentation** | All features | 6 hours | 🟡 Medium | ⏳ Pending |
| **Total** | **10 Features** | **76 hours** | | |

### 🎯 **Milestones**

1. **M1:** Analyzer compatibility fixed ✅
2. **M2:** Features 1-2 complete and tested ✅
3. **M3:** Features 3-5 complete and tested ✅
4. **M4:** Features 7-9 complete and tested ✅
5. **M5:** Features 6, 10 complete and tested ✅
6. **M6:** All tests passing (>80% coverage) ✅
7. **M7:** Documentation complete ✅
8. **M8:** Ready for pub.dev ✅

---

## Testing Strategy

### 🧪 **Test Coverage Goals**

- **Unit Tests:** >= 80% coverage
- **Integration Tests:** All features tested end-to-end
- **Performance Tests:** Benchmarks for all features
- **Example Tests:** All examples run without errors

### 📋 **Test Categories**

1. **Error Messages Tests**
   - All error classes have required fields
   - Error formatting is correct
   - Error codes are unique

2. **Logging Tests**
   - Log level filtering works
   - Log history is limited
   - Automatic logging works

3. **Performance Tests**
   - Query analyzer detects slow queries
   - Suggestions are generated correctly
   - Benchmarks meet targets

4. **Validation Tests**
   - All validation rules work
   - Error messages are clear
   - Custom validators work

5. **Backup/Restore Tests**
   - Backup creates valid files
   - Restore works correctly
   - Compression works

---

## 🎉 **Next Steps**

1. ✅ **Review this spec** - Make sure everything is clear
2. 🔧 **Fix analyzer compatibility** - Critical blocker
3. 🚀 **Start Phase 1** - Features 1-2 (Better Errors + Logging)
4. 🧪 **Write tests** - As we implement each feature
5. 📚 **Update docs** - Keep documentation in sync
6. 🎯 **Publish to pub.dev** - When all features are complete

---

**Built by IDRISIUM Corp | Idris Ghamid**  
**Date:** 9 مايو 2026


## Feature 4: Built-in Data Validation

### 🎯 **Goal**

Validate data **before** inserting/updating to prevent invalid data from entering the database.

### 📊 **Current State**

**No validation exists.** Developers have to manually validate data before operations.

### ✨ **New Implementation**

#### **4.1 Validation Annotations**

**File:** `lib/src/validation/validate_annotation.dart`

```dart
/// Validation annotation for fields
class Validate {
  /// Minimum value (for numbers)
  final num? min;
  
  /// Maximum value (for numbers)
  final num? max;
  
  /// Minimum length (for strings/lists)
  final int? minLength;
  
  /// Maximum length (for strings/lists)
  final int? maxLength;
  
  /// Regex pattern (for strings)
  final String? pattern;
  
  /// Email validation
  final bool email;
  
  /// URL validation
  final bool url;
  
  /// Phone number validation
  final bool phone;
  
  /// Custom validator function name
  final String? customValidator;
  
  const Validate({
    this.min,
    this.max,
    this.minLength,
    this.maxLength,
    this.pattern,
    this.email = false,
    this.url = false,
    this.phone = false,
    this.customValidator,
  });
}

/// Required field annotation
class Required {
  const Required();
}
```

#### **4.2 Data Validator Class**

**File:** `lib/src/validation/data_validator.dart`

```dart
/// Data validator
class DataValidator {
  /// Validate an object
  static ValidationResult validate<T>(T object) {
    final errors = <ValidationError>[];
    
    // Use reflection or code generation to validate fields
    // This will be implemented in the generator
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
  
  /// Validate a single field
  static ValidationError? validateField(
    String fieldName,
    dynamic value,
    Validate? validation,
    bool isRequired,
  ) {
    // Check required
    if (isRequired && value == null) {
      return ValidationError(
        field: fieldName,
        message: 'Field is required',
        value: value,
      );
    }
    
    if (value == null || validation == null) {
      return null;
    }
    
    // Validate numbers
    if (value is num) {
      if (validation.min != null && value < validation.min!) {
        return ValidationError(
          field: fieldName,
          message: 'Value must be >= ${validation.min}',
          value: value,
        );
      }
      if (validation.max != null && value > validation.max!) {
        return ValidationError(
          field: fieldName,
          message: 'Value must be <= ${validation.max}',
          value: value,
        );
      }
    }
    
    // Validate strings
    if (value is String) {
      if (validation.minLength != null && value.length < validation.minLength!) {
        return ValidationError(
          field: fieldName,
          message: 'Length must be >= ${validation.minLength}',
          value: value,
        );
      }
      if (validation.maxLength != null && value.length > validation.maxLength!) {
        return ValidationError(
          field: fieldName,
          message: 'Length must be <= ${validation.maxLength}',
          value: value,
        );
      }
      
      // Email validation
      if (validation.email) {
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!emailRegex.hasMatch(value)) {
          return ValidationError(
            field: fieldName,
            message: 'Invalid email format',
            value: value,
          );
        }
      }
      
      // URL validation
      if (validation.url) {
        final urlRegex = RegExp(r'^https?://[\w\-]+(\.[\w\-]+)+[/#?]?.*$');
        if (!urlRegex.hasMatch(value)) {
          return ValidationError(
            field: fieldName,
            message: 'Invalid URL format',
            value: value,
          );
        }
      }
      
      // Phone validation
      if (validation.phone) {
        final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
        if (!phoneRegex.hasMatch(value)) {
          return ValidationError(
            field: fieldName,
            message: 'Invalid phone number format',
            value: value,
          );
        }
      }
      
      // Pattern validation
      if (validation.pattern != null) {
        final regex = RegExp(validation.pattern!);
        if (!regex.hasMatch(value)) {
          return ValidationError(
            field: fieldName,
            message: 'Value does not match pattern: ${validation.pattern}',
            value: value,
          );
        }
      }
    }
    
    // Validate lists
    if (value is List) {
      if (validation.minLength != null && value.length < validation.minLength!) {
        return ValidationError(
          field: fieldName,
          message: 'List length must be >= ${validation.minLength}',
          value: value,
        );
      }
      if (validation.maxLength != null && value.length > validation.maxLength!) {
        return ValidationError(
          field: fieldName,
          message: 'List length must be <= ${validation.maxLength}',
          value: value,
        );
      }
    }
    
    return null;
  }
}

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  
  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
  
  @override
  String toString() {
    if (isValid) {
      return '✅ Validation passed';
    }
    
    final buffer = StringBuffer();
    buffer.writeln('❌ Validation failed:');
    for (final error in errors) {
      buffer.writeln('   - ${error.field}: ${error.message}');
    }
    return buffer.toString();
  }
}

/// Validation error
class ValidationError {
  final String field;
  final String message;
  final dynamic value;
  
  const ValidationError({
    required this.field,
    required this.message,
    required this.value,
  });
}
```

#### **4.3 Usage in Models**

```dart
@collection
class User {
  Id? id;
  
  @Required()
  @Validate(minLength: 2, maxLength: 50)
  late String name;
  
  @Required()
  @Validate(min: 0, max: 150)
  late int age;
  
  @Required()
  @Validate(email: true)
  late String email;
  
  @Validate(url: true)
  String? website;
  
  @Validate(phone: true)
  String? phoneNumber;
  
  @Validate(pattern: r'^[a-zA-Z0-9_]+$')
  String? username;
}
```

#### **4.4 Integration with put() Method**

**File:** `lib/src/impl/IDRISDB_collection_impl.dart` (modify)

```dart
Future<Id> put(T object) async {
  // Validate before inserting
  final validationResult = DataValidator.validate(object);
  if (!validationResult.isValid) {
    throw DataValidationError(
      validationResult.errors.first.field,
      validationResult.errors.first.value,
      validationResult.errors.first.message,
    );
  }
  
  // Continue with normal put operation
  // ...
}
```

#### **4.5 Testing**

**File:** `test/validation/data_validation_test.dart`

```dart
import 'package:idris_db/idris_db.dart';
import 'package:test/test.dart';

void main() {
  group('Data Validation', () {
    test('Required field validation', () {
      final error = DataValidator.validateField(
        'name',
        null,
        null,
        true,
      );
      
      expect(error, isNotNull);
      expect(error!.message, contains('required'));
    });
    
    test('Min/Max number validation', () {
      final validation = Validate(min: 0, max: 150);
      
      final error1 = DataValidator.validateField('age', -1, validation, false);
      expect(error1, isNotNull);
      expect(error1!.message, contains('>='));
      
      final error2 = DataValidator.validateField('age', 200, validation, false);
      expect(error2, isNotNull);
      expect(error2!.message, contains('<='));
      
      final error3 = DataValidator.validateField('age', 25, validation, false);
      expect(error3, isNull);
    });
    
    test('Email validation', () {
      final validation = Validate(email: true);
      
      final error1 = DataValidator.validateField('email', 'invalid', validation, false);
      expect(error1, isNotNull);
      
      final error2 = DataValidator.validateField('email', 'test@example.com', validation, false);
      expect(error2, isNull);
    });
  });
}
```

### ✅ **Acceptance Criteria**

- [ ] Validation annotations created
- [ ] DataValidator class implemented
- [ ] All validation rules work (min, max, minLength, maxLength, email, url, phone, pattern)
- [ ] Integration with put() method
- [ ] Generator updated to support validation
- [ ] Tests written and passing
- [ ] Documentation complete

### ⏱️ **Estimated Time:** 10 hours

---

## Feature 5: Backup & Restore

### 🎯 **Goal**

Provide **one-line backup and restore** functionality with optional compression.

### 📊 **Current State**

**No backup/restore exists.** Developers have to manually copy database files.

### ✨ **New Implementation**

#### **5.1 Backup Extension**

**File:** `lib/src/backup/backup_extension.dart`

```dart
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

extension IdrisDbBackup on IdrisDb {
  /// Backup database to a file
  Future<void> backup({
    required String path,
    bool compress = true,
  }) async {
    IdrisDbLogger.info('Creating backup at $path');
    
    try {
      // Close all active transactions
      // (Implementation depends on IdrisDb internals)
      
      // Get database directory
      final dbDir = Directory(this.path);
      if (!await dbDir.exists()) {
        throw BackupError('Database directory not found: ${this.path}');
      }
      
      // Get all database files
      final files = await dbDir.list().where((e) => e is File).toList();
      
      if (compress) {
        // Create archive
        final archive = Archive();
        
        for (final file in files) {
          if (file is File) {
            final bytes = await file.readAsBytes();
            final archiveFile = ArchiveFile(
              path.basename(file.path),
              bytes.length,
              bytes,
            );
            archive.addFile(archiveFile);
          }
        }
        
        // Encode to zip
        final zipData = ZipEncoder().encode(archive);
        if (zipData == null) {
          throw BackupError('Failed to compress backup');
        }
        
        // Write to file
        final backupFile = File(path);
        await backupFile.writeAsBytes(zipData);
      } else {
        // Copy files without compression
        final backupDir = Directory(path);
        await backupDir.create(recursive: true);
        
        for (final file in files) {
          if (file is File) {
            final targetPath = path.join(backupDir.path, path.basename(file.path));
            await file.copy(targetPath);
          }
        }
      }
      
      IdrisDbLogger.info('Backup completed successfully');
    } catch (e, stackTrace) {
      IdrisDbLogger.error('Backup failed', e, stackTrace);
      throw BackupError('Backup failed: $e');
    }
  }
  
  /// Restore database from a backup file
  static Future<IdrisDb> restore({
    required String backupPath,
    required String targetPath,
    required List<CollectionSchema> schemas,
    bool compressed = true,
  }) async {
    IdrisDbLogger.info('Restoring backup from $backupPath');
    
    try {
      final targetDir = Directory(targetPath);
      await targetDir.create(recursive: true);
      
      if (compressed) {
        // Read zip file
        final backupFile = File(backupPath);
        final bytes = await backupFile.readAsBytes();
        
        // Decode archive
        final archive = ZipDecoder().decodeBytes(bytes);
        
        // Extract files
        for (final file in archive) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            final targetFile = File(path.join(targetPath, filename));
            await targetFile.writeAsBytes(data);
          }
        }
      } else {
        // Copy files from backup directory
        final backupDir = Directory(backupPath);
        final files = await backupDir.list().where((e) => e is File).toList();
        
        for (final file in files) {
          if (file is File) {
            final targetFile = path.join(targetPath, path.basename(file.path));
            await file.copy(targetFile);
          }
        }
      }
      
      IdrisDbLogger.info('Restore completed successfully');
      
      // Open restored database
      return await IdrisDb.open(
        schemas,
        directory: targetPath,
      );
    } catch (e, stackTrace) {
      IdrisDbLogger.error('Restore failed', e, stackTrace);
      throw RestoreError('Restore failed: $e');
    }
  }
}

/// Backup error
class BackupError extends IdrisDbError {
  BackupError(String message)
      : super(
          message,
          hint: 'Check if the database is open and the path is writable',
          solution: 'Ensure the database is not corrupted and you have write permissions',
          code: 'BACKUP_ERROR',
          docsUrl: 'https://github.com/idris-ghamid/idris_db#backup-error',
        );
}

/// Restore error
class RestoreError extends IdrisDbError {
  RestoreError(String message)
      : super(
          message,
          hint: 'Check if the backup file exists and is valid',
          solution: 'Ensure the backup file is not corrupted',
          code: 'RESTORE_ERROR',
          docsUrl: 'https://github.com/idris-ghamid/idris_db#restore-error',
        );
}
```

#### **5.2 Usage Example**

```dart
// Backup with compression
await IdrisDb.backup(
  path: '/backups/my_backup.idb.zip',
  compress: true,
);

// Backup without compression
await IdrisDb.backup(
  path: '/backups/my_backup_dir',
  compress: false,
);

// Restore from backup
final restoredIDRISDB = await IdrisDb.restore(
  backupPath: '/backups/my_backup.idb.zip',
  targetPath: '/data/restored_db',
  schemas: [UserSchema, PostSchema],
  compressed: true,
);
```

#### **5.3 Testing**

**File:** `test/backup/backup_restore_test.dart`

```dart
import 'dart:io';
import 'package:idris_db/idris_db.dart';
import 'package:test/test.dart';

void main() {
  group('Backup & Restore', () {
    late IdrisDb IdrisDb;
    late Directory tempDir;
    
    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('idris_db_test');
      IdrisDb = await IdrisDb.open([UserSchema], directory: tempDir.path);
    });
    
    tearDown(() async {
      await IdrisDb.close();
      await tempDir.delete(recursive: true);
    });
    
    test('Backup creates file', () async {
      final backupPath = '${tempDir.path}/backup.zip';
      
      await IdrisDb.backup(path: backupPath, compress: true);
      
      expect(File(backupPath).existsSync(), isTrue);
    });
    
    test('Restore works correctly', () async {
      // Add some data
      await IdrisDb.writeTxn(() async {
        await IdrisDb.users.put(User()..name = 'Test' ..age = 25);
      });
      
      // Backup
      final backupPath = '${tempDir.path}/backup.zip';
      await IdrisDb.backup(path: backupPath, compress: true);
      
      // Close original
      await IdrisDb.close();
      
      // Restore
      final restored = await IdrisDb.restore(
        backupPath: backupPath,
        targetPath: '${tempDir.path}/restored',
        schemas: [UserSchema],
        compressed: true,
      );
      
      // Verify data
      final users = await restored.users.where().findAll();
      expect(users.length, equals(1));
      expect(users.first.name, equals('Test'));
      
      await restored.close();
    });
  });
}
```

### ✅ **Acceptance Criteria**

- [ ] Backup extension created
- [ ] Compression works (using archive package)
- [ ] Restore works correctly
- [ ] Data integrity maintained
- [ ] Error handling implemented
- [ ] Tests written and passing
- [ ] Documentation complete

### ⏱️ **Estimated Time:** 8 hours

---

## Summary

تم كتابة spec تفصيلي لـ **5 features من أصل 10**:

✅ **Feature 1:** Better Error Messages (4 hours)  
✅ **Feature 2:** Smart Logging System (6 hours)  
✅ **Feature 3:** Query Performance Analyzer (8 hours)  
✅ **Feature 4:** Built-in Data Validation (10 hours)  
✅ **Feature 5:** Backup & Restore (8 hours)

**Total:** 36 hours

الـ 5 features المتبقية (6-10) هكتبهم في ملف منفصل عشان الملف مش يكبر أوي.

---

**هل تريد أن:**
1. أكمل الـ 5 features المتبقية (6-10)؟
2. أبدأ في تنفيذ الـ features اللي اتكتبت؟
3. أصلح مشكلة الـ analyzer compatibility الأول؟

**إيه اللي تحب نعمله؟** 🎯
