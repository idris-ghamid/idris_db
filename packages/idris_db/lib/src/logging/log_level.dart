part of '../../idris_db.dart';

/// Log level enumeration
/// 
/// Defines the severity levels for logging in Idris DB.
/// Levels are ordered from most verbose to least verbose.
enum LogLevel {
  /// Trace level - most verbose, for detailed debugging
  trace,
  
  /// Debug level - for debugging information
  debug,
  
  /// Info level - for general information
  info,
  
  /// Warning level - for warnings that don't stop execution
  warning,
  
  /// Error level - for errors that need attention
  error,
  
  /// No logging
  none,
}
