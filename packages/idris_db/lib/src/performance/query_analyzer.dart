part of '../../idris_db.dart';

/// Query performance analyzer
/// 
/// Analyzes queries and provides actionable suggestions for optimization:
/// - Measures query duration
/// - Counts results
/// - Detects slow queries (>100ms)
/// - Suggests indexes based on query patterns
/// - Suggests pagination for large result sets
/// - Tracks query history for pattern analysis
/// - Provides detailed performance insights
class QueryAnalyzer {
  final IdrisDb? idrisDb;
  
  /// Query history for pattern analysis
  final List<QueryAnalysis> _queryHistory = [];
  
  /// Maximum number of queries to keep in history
  final int maxHistorySize;
  
  /// Threshold for slow queries (in milliseconds)
  final int slowQueryThreshold;
  
  QueryAnalyzer(
    this.idrisDb, {
    this.maxHistorySize = 1000,
    this.slowQueryThreshold = 100,
  });
  
  /// Analyze a query and provide suggestions
  Future<QueryAnalysis> analyze<T>(
    Future<List<T>> Function() query, {
    String? queryDescription,
    String? collectionName,
    List<String>? filterFields,
  }) async {
    final stopwatch = Stopwatch()..start();
    final results = await query();
    stopwatch.stop();
    
    final duration = stopwatch.elapsed;
    final resultCount = results.length;
    
    // Analyze query performance
    final suggestions = <String>[];
    final warnings = <String>[];
    
    // Check if query is slow
    if (duration.inMilliseconds > slowQueryThreshold) {
      warnings.add('Query took ${duration.inMilliseconds}ms (slow)');
      suggestions.add('Consider adding an index on the filtered fields');
      
      // More specific suggestions based on filter fields
      if (filterFields != null && filterFields.isNotEmpty) {
        if (filterFields.length == 1) {
          suggestions.add('Add single-field index: @Index() on ${filterFields.first}');
        } else {
          suggestions.add('Consider composite index on: ${filterFields.join(", ")}');
        }
      }
    }
    
    // Check if result set is large
    if (resultCount > 1000) {
      warnings.add('Large result set: $resultCount documents');
      suggestions.add('Consider using pagination with .limit() and .offset()');
      suggestions.add('Example: .limit(100).offset(0) for first page');
    }
    
    // Check if result set is empty
    if (resultCount == 0) {
      warnings.add('Query returned no results');
      suggestions.add('Check your filter conditions');
      suggestions.add('Use .count() if you only need to check existence');
    }
    
    // Check if query is very fast but returns many results
    if (duration.inMilliseconds < 10 && resultCount > 100) {
      suggestions.add('Query is well-optimized! Consider caching if accessed frequently');
    }
    
    // Create analysis result
    final analysis = QueryAnalysis(
      duration: duration,
      resultCount: resultCount,
      suggestions: suggestions,
      warnings: warnings,
      queryDescription: queryDescription,
      collectionName: collectionName,
      filterFields: filterFields,
      timestamp: DateTime.now(),
    );
    
    // Add to history
    _addToHistory(analysis);
    
    return analysis;
  }
  
  /// Add analysis to history (with size limit)
  void _addToHistory(QueryAnalysis analysis) {
    _queryHistory.add(analysis);
    
    // Keep only the most recent queries
    if (_queryHistory.length > maxHistorySize) {
      _queryHistory.removeAt(0);
    }
  }
  
  /// Get query history
  List<QueryAnalysis> get queryHistory => List.unmodifiable(_queryHistory);
  
  /// Get slow queries from history
  List<QueryAnalysis> getSlowQueries({int? limit}) {
    final slow = _queryHistory
        .where((q) => q.isSlow)
        .toList()
      ..sort((a, b) => b.duration.compareTo(a.duration));
    
    if (limit != null && slow.length > limit) {
      return slow.sublist(0, limit);
    }
    return slow;
  }
  
  /// Get most frequent queries
  Map<String, int> getFrequentQueries() {
    final frequency = <String, int>{};
    
    for (final query in _queryHistory) {
      final key = query.queryDescription ?? 'unknown';
      frequency[key] = (frequency[key] ?? 0) + 1;
    }
    
    return Map.fromEntries(
      frequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }
  
  /// Get average query duration
  Duration get averageQueryDuration {
    if (_queryHistory.isEmpty) return Duration.zero;
    
    final total = _queryHistory.fold<int>(
      0,
      (sum, q) => sum + q.duration.inMicroseconds,
    );
    
    return Duration(microseconds: total ~/ _queryHistory.length);
  }
  
  /// Get total queries analyzed
  int get totalQueries => _queryHistory.length;
  
  /// Get percentage of slow queries
  double get slowQueryPercentage {
    if (_queryHistory.isEmpty) return 0.0;
    
    final slowCount = _queryHistory.where((q) => q.isSlow).length;
    return (slowCount / _queryHistory.length) * 100;
  }
  
  /// Clear query history
  void clearHistory() {
    _queryHistory.clear();
  }
  
  /// Get index suggestions for a collection based on query patterns
  Future<List<IndexSuggestion>> suggestIndexes<T>({
    String? collectionName,
    int minQueryCount = 5,
    double minImpactScore = 0.5,
  }) async {
    final suggestions = <IndexSuggestion>[];
    
    // Analyze query patterns from history
    final fieldUsage = <String, _FieldUsageStats>{};
    
    for (final query in _queryHistory) {
      // Skip if collection doesn't match
      if (collectionName != null && query.collectionName != collectionName) {
        continue;
      }
      
      // Skip if no filter fields
      if (query.filterFields == null || query.filterFields!.isEmpty) {
        continue;
      }
      
      // Track field usage
      for (final field in query.filterFields!) {
        final key = '${query.collectionName ?? "unknown"}.$field';
        
        if (!fieldUsage.containsKey(key)) {
          fieldUsage[key] = _FieldUsageStats(
            collectionName: query.collectionName ?? 'unknown',
            fieldName: field,
          );
        }
        
        fieldUsage[key]!.queryCount++;
        fieldUsage[key]!.totalDuration += query.duration.inMilliseconds;
        
        if (query.isSlow) {
          fieldUsage[key]!.slowQueryCount++;
        }
      }
    }
    
    // Generate suggestions based on usage patterns
    for (final stats in fieldUsage.values) {
      // Skip if not enough queries
      if (stats.queryCount < minQueryCount) continue;
      
      // Calculate impact score
      final impactScore = _calculateImpactScore(stats);
      
      // Skip if impact is too low
      if (impactScore < minImpactScore) continue;
      
      // Estimate speedup
      final estimatedSpeedup = _estimateSpeedup(stats);
      
      // Generate reason
      final reason = _generateIndexReason(stats);
      
      suggestions.add(IndexSuggestion(
        collectionName: stats.collectionName,
        fieldName: stats.fieldName,
        reason: reason,
        estimatedSpeedup: estimatedSpeedup,
        queryCount: stats.queryCount,
        slowQueryCount: stats.slowQueryCount,
        impactScore: impactScore,
      ));
    }
    
    // Sort by impact score (highest first)
    suggestions.sort((a, b) => b.impactScore.compareTo(a.impactScore));
    
    return suggestions;
  }
  
  /// Calculate impact score for a field (0.0 to 1.0)
  double _calculateImpactScore(_FieldUsageStats stats) {
    // Factors:
    // 1. Query frequency (more queries = higher impact)
    // 2. Slow query ratio (more slow queries = higher impact)
    // 3. Average duration (slower queries = higher impact)
    
    final frequencyScore = (stats.queryCount / maxHistorySize).clamp(0.0, 1.0);
    final slowRatio = stats.queryCount > 0 
        ? stats.slowQueryCount / stats.queryCount 
        : 0.0;
    final avgDuration = stats.queryCount > 0
        ? stats.totalDuration / stats.queryCount
        : 0.0;
    final durationScore = (avgDuration / 1000).clamp(0.0, 1.0); // Normalize to 1 second
    
    // Weighted average
    return (frequencyScore * 0.3) + (slowRatio * 0.4) + (durationScore * 0.3);
  }
  
  /// Estimate speedup from adding an index
  double _estimateSpeedup(_FieldUsageStats stats) {
    // Rough estimation based on slow query ratio and average duration
    final slowRatio = stats.queryCount > 0
        ? stats.slowQueryCount / stats.queryCount
        : 0.0;
    
    final avgDuration = stats.queryCount > 0
        ? stats.totalDuration / stats.queryCount
        : 0.0;
    
    // More slow queries and longer duration = higher speedup potential
    if (slowRatio > 0.7 && avgDuration > 200) {
      return 10.0; // 10x speedup
    } else if (slowRatio > 0.5 && avgDuration > 100) {
      return 5.0; // 5x speedup
    } else if (slowRatio > 0.3 || avgDuration > 50) {
      return 3.0; // 3x speedup
    } else {
      return 2.0; // 2x speedup
    }
  }
  
  /// Generate human-readable reason for index suggestion
  String _generateIndexReason(_FieldUsageStats stats) {
    final parts = <String>[];
    
    parts.add('Used in ${stats.queryCount} queries');
    
    if (stats.slowQueryCount > 0) {
      parts.add('${stats.slowQueryCount} slow queries');
    }
    
    final avgDuration = stats.queryCount > 0
        ? (stats.totalDuration / stats.queryCount).round()
        : 0;
    
    if (avgDuration > 0) {
      parts.add('avg ${avgDuration}ms');
    }
    
    return parts.join(', ');
  }
  
  /// Get performance summary
  PerformanceSummary getPerformanceSummary() {
    return PerformanceSummary(
      totalQueries: totalQueries,
      averageDuration: averageQueryDuration,
      slowQueryCount: getSlowQueries().length,
      slowQueryPercentage: slowQueryPercentage,
      mostFrequentQueries: getFrequentQueries(),
      indexSuggestions: suggestIndexes<dynamic>(),
    );
  }
}

/// Query analysis result
class QueryAnalysis {
  final Duration duration;
  final int resultCount;
  final List<String> suggestions;
  final List<String> warnings;
  final String? queryDescription;
  final String? collectionName;
  final List<String>? filterFields;
  final DateTime timestamp;
  
  QueryAnalysis({
    required this.duration,
    required this.resultCount,
    required this.suggestions,
    required this.warnings,
    this.queryDescription,
    this.collectionName,
    this.filterFields,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  bool get isSlow => duration.inMilliseconds > 100;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasSuggestions => suggestions.isNotEmpty;
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Query Analysis:');
    
    if (queryDescription != null) {
      buffer.writeln('   🔍 Query: $queryDescription');
    }
    
    if (collectionName != null) {
      buffer.writeln('   📦 Collection: $collectionName');
    }
    
    buffer.writeln('   ⏱️  Duration: ${duration.inMilliseconds}ms');
    buffer.writeln('   📈 Results: $resultCount');
    
    if (filterFields != null && filterFields!.isNotEmpty) {
      buffer.writeln('   🔎 Filtered by: ${filterFields!.join(", ")}');
    }
    
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
  final int queryCount;
  final int slowQueryCount;
  final double impactScore;
  
  const IndexSuggestion({
    required this.collectionName,
    required this.fieldName,
    required this.reason,
    required this.estimatedSpeedup,
    required this.queryCount,
    required this.slowQueryCount,
    required this.impactScore,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('💡 Index Suggestion:');
    buffer.writeln('   Collection: $collectionName');
    buffer.writeln('   Field: $fieldName');
    buffer.writeln('   Reason: $reason');
    buffer.writeln('   Estimated Speedup: ${estimatedSpeedup}x');
    buffer.writeln('   Impact Score: ${(impactScore * 100).toStringAsFixed(1)}%');
    buffer.writeln('   Code: @Index() late YourType $fieldName;');
    return buffer.toString();
  }
}

/// Field usage statistics (internal)
class _FieldUsageStats {
  final String collectionName;
  final String fieldName;
  int queryCount = 0;
  int slowQueryCount = 0;
  int totalDuration = 0;
  
  _FieldUsageStats({
    required this.collectionName,
    required this.fieldName,
  });
}

/// Performance summary
class PerformanceSummary {
  final int totalQueries;
  final Duration averageDuration;
  final int slowQueryCount;
  final double slowQueryPercentage;
  final Map<String, int> mostFrequentQueries;
  final Future<List<IndexSuggestion>> indexSuggestions;
  
  const PerformanceSummary({
    required this.totalQueries,
    required this.averageDuration,
    required this.slowQueryCount,
    required this.slowQueryPercentage,
    required this.mostFrequentQueries,
    required this.indexSuggestions,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('📊 Performance Summary:');
    buffer.writeln('   Total Queries: $totalQueries');
    buffer.writeln('   Average Duration: ${averageDuration.inMilliseconds}ms');
    buffer.writeln('   Slow Queries: $slowQueryCount (${slowQueryPercentage.toStringAsFixed(1)}%)');
    
    if (mostFrequentQueries.isNotEmpty) {
      buffer.writeln('\n🔥 Most Frequent Queries:');
      var count = 0;
      for (final entry in mostFrequentQueries.entries) {
        if (count >= 5) break; // Top 5
        buffer.writeln('   ${entry.value}x - ${entry.key}');
        count++;
      }
    }
    
    return buffer.toString();
  }
}
