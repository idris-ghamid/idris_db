part of '../../idris_db.dart';

/// Smart logger for Idris DB
/// 
/// Provides comprehensive logging with:
/// - Multiple log levels
/// - Log history (last 1000 entries)
/// - Automatic query logging
/// - Automatic transaction logging
/// - Performance tracking
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
    if (_level.index <= LogLevel.error.index) {
      _log(LogLevel.error, message, error, stackTrace);
    }
  }
  
  /// Log a warning
  static void warning(String message) {
    if (_level.index <= LogLevel.warning.index) {
      _log(LogLevel.warning, message);
    }
  }
  
  /// Log info
  static void info(String message) {
    if (_level.index <= LogLevel.info.index) {
      _log(LogLevel.info, message);
    }
  }
  
  /// Log debug info
  static void debug(String message) {
    if (_level.index <= LogLevel.debug.index) {
      _log(LogLevel.debug, message);
    }
  }
  
  /// Log trace info
  static void trace(String message) {
    if (_level.index <= LogLevel.trace.index) {
      _log(LogLevel.trace, message);
    }
  }
  
  /// Log a query with performance metrics
  static void query(String query, Duration duration, int resultCount) {
    if (_level.index <= LogLevel.debug.index) {
      final message = '🔍 Query: $query\n'
          '   ⏱️  Duration: ${duration.inMilliseconds}ms\n'
          '   📊 Results: $resultCount';
      _log(LogLevel.debug, message);
    }
  }
  
  /// Log a transaction with performance metrics
  static void transaction(String operation, Duration duration) {
    if (_level.index <= LogLevel.debug.index) {
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
