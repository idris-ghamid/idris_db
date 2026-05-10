part of '../../idris_db.dart';

/// Log entry
/// 
/// Represents a single log entry with timestamp, level, message,
/// and optional error information.
class LogEntry {
  /// Log level
  final LogLevel level;
  
  /// Log message
  final String message;
  
  /// Timestamp when the log was created
  final DateTime timestamp;
  
  /// Optional error object
  final Object? error;
  
  /// Optional stack trace
  final StackTrace? stackTrace;
  
  const LogEntry({
    required this.level,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });
  
  /// Get formatted log entry string
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
