// ignore_for_file: avoid_print

import 'package:idris_db/idris_db.dart';

// ═══════════════════════════════════════════════════════════════════════════
// QUERY ANALYZER EXAMPLE
// Demonstrates the enhanced Query Performance Analyzer features
// ═══════════════════════════════════════════════════════════════════════════

/// Simulated database for demonstration
class MockDb {
  final List<Map<String, dynamic>> users = [];
  
  MockDb() {
    // Create sample data
    for (var i = 0; i < 100; i++) {
      users.add({
        'id': i,
        'name': 'User $i',
        'email': 'user$i@example.com',
        'age': 18 + (i % 50),
        'city': ['Cairo', 'Alexandria', 'Giza'][i % 3],
      });
    }
  }
  
  Future<List<Map<String, dynamic>>> queryByAge(int minAge) async {
    await Future.delayed(Duration(milliseconds: 50 + minAge % 100));
    return users.where((u) => u['age'] >= minAge).toList();
  }
  
  Future<List<Map<String, dynamic>>> queryByCity(String city) async {
    await Future.delayed(Duration(milliseconds: 30));
    return users.where((u) => u['city'] == city).toList();
  }
  
  Future<List<Map<String, dynamic>>> queryAll() async {
    await Future.delayed(Duration(milliseconds: 150));
    return users;
  }
}

void main() async {
  print('🚀 Idris DB - Query Analyzer Example\n');

  // Create mock database
  final mockDb = MockDb();
  
  // Create analyzer (note: we pass null for IdrisDb since this is a demo)
  // In real usage, you would pass your actual IdrisDb instance
  final analyzer = QueryAnalyzer(
    null, // Mock - in real usage: pass your IdrisDb instance
    maxHistorySize: 100,
    slowQueryThreshold: 50, // 50ms threshold for this demo
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 1: Basic Query Analysis
  // ═══════════════════════════════════════════════════════════════════════════

  print('═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 1: Basic Query Analysis');
  print('═══════════════════════════════════════════════════════════════\n');

  final analysis1 = await analyzer.analyze(
    () => mockDb.queryByAge(25),
    queryDescription: 'Find users older than 25',
    collectionName: 'users',
    filterFields: ['age'],
  );

  print(analysis1);

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 2: Slow Query Detection
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 2: Slow Query Detection');
  print('═══════════════════════════════════════════════════════════════\n');

  // Simulate a slow query by loading all users
  final analysis2 = await analyzer.analyze(
    () => mockDb.queryAll(),
    queryDescription: 'Load all users (no filter)',
    collectionName: 'users',
  );

  print(analysis2);

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 3: Multiple Queries for Pattern Analysis
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 3: Running Multiple Queries for Pattern Analysis');
  print('═══════════════════════════════════════════════════════════════\n');

  // Run multiple queries to build history
  print('Running 20 queries to build pattern history...\n');

  for (var i = 0; i < 20; i++) {
    // Query by age (frequently)
    await analyzer.analyze(
      () => mockDb.queryByAge(20 + (i % 5)),
      queryDescription: 'Find users by age',
      collectionName: 'users',
      filterFields: ['age'],
    );

    // Query by city (frequently)
    await analyzer.analyze(
      () => mockDb.queryByCity(i % 2 == 0 ? 'Cairo' : 'Alexandria'),
      queryDescription: 'Find users by city',
      collectionName: 'users',
      filterFields: ['city'],
    );

    // Query by email (occasionally)
    if (i % 5 == 0) {
      await analyzer.analyze(
        () => mockDb.queryByAge(30),
        queryDescription: 'Find users by email',
        collectionName: 'users',
        filterFields: ['email'],
      );
    }
  }

  print('✅ Completed ${analyzer.totalQueries} queries\n');

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 4: Query History Analysis
  // ═══════════════════════════════════════════════════════════════════════════

  print('═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 4: Query History Analysis');
  print('═══════════════════════════════════════════════════════════════\n');

  print('📊 Total Queries: ${analyzer.totalQueries}');
  print('⏱️  Average Duration: ${analyzer.averageQueryDuration.inMilliseconds}ms');
  print('🐌 Slow Query Percentage: ${analyzer.slowQueryPercentage.toStringAsFixed(1)}%\n');

  // Get slow queries
  final slowQueries = analyzer.getSlowQueries(limit: 5);
  if (slowQueries.isNotEmpty) {
    print('🐌 Top ${slowQueries.length} Slow Queries:');
    for (var i = 0; i < slowQueries.length; i++) {
      final query = slowQueries[i];
      print('   ${i + 1}. ${query.queryDescription ?? "Unknown"} - ${query.duration.inMilliseconds}ms');
    }
    print('');
  }

  // Get frequent queries
  final frequentQueries = analyzer.getFrequentQueries();
  if (frequentQueries.isNotEmpty) {
    print('🔥 Most Frequent Queries:');
    var count = 0;
    for (final entry in frequentQueries.entries) {
      if (count >= 5) break;
      print('   ${entry.value}x - ${entry.key}');
      count++;
    }
    print('');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 5: Index Suggestions
  // ═══════════════════════════════════════════════════════════════════════════

  print('═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 5: Smart Index Suggestions');
  print('═══════════════════════════════════════════════════════════════\n');

  final indexSuggestions = await analyzer.suggestIndexes(
    collectionName: 'users',
    minQueryCount: 3,
    minImpactScore: 0.1,
  );

  if (indexSuggestions.isEmpty) {
    print('✅ No index suggestions (all queries are well-optimized)\n');
  } else {
    print('💡 Found ${indexSuggestions.length} Index Suggestions:\n');
    for (var i = 0; i < indexSuggestions.length; i++) {
      final suggestion = indexSuggestions[i];
      print('${i + 1}. ${suggestion.fieldName}');
      print('   Reason: ${suggestion.reason}');
      print('   Estimated Speedup: ${suggestion.estimatedSpeedup}x');
      print('   Impact Score: ${(suggestion.impactScore * 100).toStringAsFixed(1)}%');
      print('   Code: @Index() late YourType ${suggestion.fieldName};\n');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 6: Performance Summary
  // ═══════════════════════════════════════════════════════════════════════════

  print('═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 6: Complete Performance Summary');
  print('═══════════════════════════════════════════════════════════════\n');

  final summary = analyzer.getPerformanceSummary();
  print(summary);

  // Show index suggestions from summary
  final summaryIndexes = await summary.indexSuggestions;
  if (summaryIndexes.isNotEmpty) {
    print('\n💡 Recommended Indexes:');
    for (final suggestion in summaryIndexes) {
      print('   - ${suggestion.collectionName}.${suggestion.fieldName} '
          '(${suggestion.estimatedSpeedup}x speedup)');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 7: Empty Result Detection
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 7: Empty Result Detection');
  print('═══════════════════════════════════════════════════════════════\n');

  final analysis3 = await analyzer.analyze(
    () => mockDb.queryByAge(1000),
    queryDescription: 'Find users older than 1000 (impossible)',
    collectionName: 'users',
    filterFields: ['age'],
  );

  print(analysis3);

  // ═══════════════════════════════════════════════════════════════════════════
  // EXAMPLE 8: Large Result Set Warning
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('EXAMPLE 8: Large Result Set Warning');
  print('═══════════════════════════════════════════════════════════════\n');

  // Add more users to trigger large result set warning
  print('Adding 1500 more users...\n');
  for (var i = 0; i < 1500; i++) {
    mockDb.users.add({
      'id': 100 + i,
      'name': 'User ${100 + i}',
      'email': 'user${100 + i}@example.com',
      'age': 20 + (i % 50),
      'city': 'Cairo',
    });
  }

  final analysis4 = await analyzer.analyze(
    () => mockDb.queryAll(),
    queryDescription: 'Load all users (large dataset)',
    collectionName: 'users',
  );

  print(analysis4);

  // ═══════════════════════════════════════════════════════════════════════════
  // CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  print('\n═══════════════════════════════════════════════════════════════');
  print('🧹 Cleanup');
  print('═══════════════════════════════════════════════════════════════\n');

  print('Clearing query history...');
  analyzer.clearHistory();
  print('✅ History cleared (${analyzer.totalQueries} queries remaining)\n');

  print('═══════════════════════════════════════════════════════════════');
  print('✨ Query Analyzer Example Complete!');
  print('═══════════════════════════════════════════════════════════════');
  print('\n📚 Key Features Demonstrated:');
  print('   ✓ Basic query analysis with duration and result count');
  print('   ✓ Slow query detection (>50ms threshold)');
  print('   ✓ Query history tracking');
  print('   ✓ Pattern analysis across multiple queries');
  print('   ✓ Smart index suggestions based on usage patterns');
  print('   ✓ Impact score calculation for optimization priorities');
  print('   ✓ Performance summary with metrics');
  print('   ✓ Empty result detection');
  print('   ✓ Large result set warnings');
  print('\n💡 In Real Usage:');
  print('   - Pass your actual IdrisDb instance to QueryAnalyzer');
  print('   - Wrap your real queries with analyzer.analyze()');
  print('   - Review suggestions periodically to optimize performance');
  print('   - Add recommended indexes to your schema');
}
