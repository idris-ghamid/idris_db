part of '../../idris_db.dart';

/// Mixin to add logging capabilities to database operations
/// 
/// This mixin provides helper methods to automatically log
/// queries, transactions, and other database operations.
mixin LoggingMixin {
  /// Log a query execution with performance metrics
  T logQuery<T>(
    String queryDescription,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      // Determine result count
      int resultCount = 0;
      if (result is List) {
        resultCount = result.length;
      } else if (result is int) {
        resultCount = result;
      } else if (result != null) {
        resultCount = 1;
      }
      
      // Log the query
      IdrisDbLogger.query(
        queryDescription,
        stopwatch.elapsed,
        resultCount,
      );
      
      return result;
    } catch (e) {
      stopwatch.stop();
      IdrisDbLogger.error(
        'Query failed: $queryDescription',
        e,
        StackTrace.current,
      );
      rethrow;
    }
  }
  
  /// Log a transaction execution with performance metrics
  T logTransaction<T>(
    String transactionDescription,
    T Function() operation,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      // Log the transaction
      IdrisDbLogger.transaction(
        transactionDescription,
        stopwatch.elapsed,
      );
      
      return result;
    } catch (e) {
      stopwatch.stop();
      IdrisDbLogger.error(
        'Transaction failed: $transactionDescription',
        e,
        StackTrace.current,
      );
      rethrow;
    }
  }
  
  /// Log a database operation
  T logOperation<T>(
    String operationDescription,
    T Function() operation,
  ) {
    IdrisDbLogger.debug('Starting: $operationDescription');
    
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = operation();
      stopwatch.stop();
      
      IdrisDbLogger.debug(
        'Completed: $operationDescription (${stopwatch.elapsedMilliseconds}ms)',
      );
      
      return result;
    } catch (e) {
      stopwatch.stop();
      IdrisDbLogger.error(
        'Failed: $operationDescription (${stopwatch.elapsedMilliseconds}ms)',
        e,
        StackTrace.current,
      );
      rethrow;
    }
  }
}

