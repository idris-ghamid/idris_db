import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:idris_db/idris_db.dart';
import 'package:path_provider/path_provider.dart';

part 'main.g.dart';

/// Metadata for a counter step, stored as an embedded object.
@embedded
class StepMetadata {
  const StepMetadata({required this.recordedAt, this.note = ''});

  final DateTime recordedAt;
  final String note;
}

/// Represents a single counter increment with metadata.
@collection
class Count {
  Count({required this.id, required this.step, required this.metadata});

  final int id;
  final int step;
  final StepMetadata metadata;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await IdrisDb.initialize();
  }

  runApp(const CounterApp());
}

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IdrisDb Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        useMaterial3: true,
      ),
      home: const CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  IdrisDb? _IDRISDB;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      final directory = kIsWeb
          ? null
          : await getApplicationDocumentsDirectory();
      final IdrisDb = IdrisDb.open(
        schemas: [CountSchema],
        directory: directory?.path ?? 'IDRISDB_data',
        engine: kIsWeb ? IdrisDbEngine.sqlite : IdrisDbEngine.IdrisDb,
      );

      if (mounted) {
        setState(() {
          _IDRISDB = IdrisDb;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize database: $e';
        });
      }
    }
  }

  int _getCurrentCount() {
    final IdrisDb = _IDRISDB;
    if (IdrisDb == null) return 0;
    return IdrisDb.counts.where().stepProperty().sum();
  }

  Count? _getLatestCount() {
    final IdrisDb = _IDRISDB;
    if (IdrisDb == null) return null;
    return IdrisDb.counts.where().sortByIdDesc().findFirst();
  }

  Future<void> _incrementCounter() async {
    final IdrisDb = _IDRISDB;
    if (IdrisDb == null) return;

    try {
      IdrisDb.write((IDRISDBInstance) {
        final nextId = IDRISDBInstance.counts.where().idProperty().max() ?? 0;
        IDRISDBInstance.counts.put(
          Count(
            id: nextId + 1,
            step: 1,
            metadata: StepMetadata(
              recordedAt: DateTime.now(),
              note: 'Manual increment',
            ),
          ),
        );
      });

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving count: $e')));
      }
    }
  }

  @override
  void dispose() {
    _IDRISDB?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('IdrisDb Counter')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_IDRISDB == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('IdrisDb Counter')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final count = _getCurrentCount();
    final latest = _getLatestCount();

    return Scaffold(
      appBar: AppBar(
        title: const Text('IdrisDb Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You have pushed the button this many times:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '$count',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (latest != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Last Recorded',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDateTime(latest.metadata.recordedAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}:'
        '${dateTime.second.toString().padLeft(2, '0')}';
  }
}
