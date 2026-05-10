import 'package:idris_db/idris_db.dart';
import 'package:test/test.dart';

void main() {
  group('Smart Logging System', () {
    setUp(() {
      IdrisDbLogger.clearHistory();
      IdrisDbLogger.setLevel(LogLevel.debug);
    });

    tearDown(() {
      IdrisDbLogger.clearHistory();
      IdrisDbLogger.setLevel(LogLevel.warning);
    });

    group('LogLevel', () {
      test('has correct order', () {
        expect(LogLevel.none.index, lessThan(LogLevel.error.index));
        expect(LogLevel.error.index, lessThan(LogLevel.warning.index));
        expect(LogLevel.warning.index, lessThan(LogLevel.info.index));
        expect(LogLevel.info.index, lessThan(LogLevel.debug.index));
        expect(LogLevel.debug.index, lessThan(LogLevel.trace.index));
      });
    });

    group('IdrisDbLogger', () {
      test('setLevel changes the log level', () {
        IdrisDbLogger.setLevel(LogLevel.error);
        expect(IdrisDbLogger.level, equals(LogLevel.error));

        IdrisDbLogger.setLevel(LogLevel.trace);
        expect(IdrisDbLogger.level, equals(LogLevel.trace));
      });

      test('clearHistory removes all entries', () {
        IdrisDbLogger.info('Test 1');
        IdrisDbLogger.info('Test 2');
        expect(IdrisDbLogger.history.length, equals(2));

        IdrisDbLogger.clearHistory();
        expect(IdrisDbLogger.history.isEmpty, isTrue);
      });

      test('history is immutable', () {
        IdrisDbLogger.info('Test');
        final history = IdrisDbLogger.history;

        expect(
          () => history.add(LogEntry(
            level: LogLevel.info,
            message: 'Should fail',
            timestamp: DateTime.now(),
          )),
          throwsUnsupportedError,
        );
      });
    });

    group('Log Level Filtering', () {
      test('none level logs nothing', () {
        IdrisDbLogger.setLevel(LogLevel.none);

        IdrisDbLogger.error('Error');
        IdrisDbLogger.warning('Warning');
        IdrisDbLogger.info('Info');
        IdrisDbLogger.debug('Debug');
        IdrisDbLogger.trace('Trace');

        expect(IdrisDbLogger.history.isEmpty, isTrue);
      });

      test('error level logs only errors', () {
        IdrisDbLogger.setLevel(LogLevel.error);

        IdrisDbLogger.error('Error');
        IdrisDbLogger.warning('Warning');
        IdrisDbLogger.info('Info');

        expect(IdrisDbLogger.history.length, equals(1));
        expect(IdrisDbLogger.history.first.level, equals(LogLevel.error));
      });

      test('warning level logs warnings and errors', () {
        IdrisDbLogger.setLevel(LogLevel.warning);

        IdrisDbLogger.error('Error');
        IdrisDbLogger.warning('Warning');
        IdrisDbLogger.info('Info');
        IdrisDbLogger.debug('Debug');

        expect(IdrisDbLogger.history.length, equals(2));
        expect(IdrisDbLogger.history[0].level, equals(LogLevel.error));
        expect(IdrisDbLogger.history[1].level, equals(LogLevel.warning));
      });

      test('info level logs info, warnings, and errors', () {
        IdrisDbLogger.setLevel(LogLevel.info);

        IdrisDbLogger.error('Error');
        IdrisDbLogger.warning('Warning');
        IdrisDbLogger.info('Info');
        IdrisDbLogger.debug('Debug');

        expect(IdrisDbLogger.history.length, equals(3));
      });

      test('debug level logs everything except trace', () {
        IdrisDbLogger.setLevel(LogLevel.debug);

        IdrisDbLogger.error('Error');
        IdrisDbLogger.warning('Warning');
        IdrisDbLogger.info('Info');
        IdrisDbLogger.debug('Debug');
        IdrisDbLogger.trace('Trace');

        expect(IdrisDbLogger.history.length, equals(4));
      });

      test('trace level logs everything', () {
        IdrisDbLogger.setLevel(LogLevel.trace);

        IdrisDbLogger.error('Error');
        IdrisDbLogger.warning('Warning');
        IdrisDbLogger.info('Info');
        IdrisDbLogger.debug('Debug');
        IdrisDbLogger.trace('Trace');

        expect(IdrisDbLogger.history.length, equals(5));
      });
    });

    group('Log History Management', () {
      test('history is limited to 1000 entries', () {
        IdrisDbLogger.setLevel(LogLevel.debug);

        for (int i = 0; i < 1500; i++) {
          IdrisDbLogger.debug('Message $i');
        }

        expect(IdrisDbLogger.history.length, equals(1000));
      });

      test('oldest entries are removed when limit is reached', () {
        IdrisDbLogger.setLevel(LogLevel.debug);

        for (int i = 0; i < 1100; i++) {
          IdrisDbLogger.debug('Message $i');
        }

        // First 100 messages should be removed
        expect(IdrisDbLogger.history.first.message, equals('Message 100'));
        expect(IdrisDbLogger.history.last.message, equals('Message 1099'));
      });
    });

    group('Query Logging', () {
      test('query logs include duration and result count', () {
        IdrisDbLogger.setLevel(LogLevel.debug);

        IdrisDbLogger.query('users.findAll()', Duration(milliseconds: 5), 42);

        expect(IdrisDbLogger.history.length, equals(1));
        final entry = IdrisDbLogger.history.first;
        expect(entry.level, equals(LogLevel.debug));
        expect(entry.message, contains('users.findAll()'));
        expect(entry.message, contains('5ms'));
        expect(entry.message, contains('42'));
      });

      test('query logs are not created when level is too low', () {
        IdrisDbLogger.setLevel(LogLevel.info);

        IdrisDbLogger.query('users.findAll()', Duration(milliseconds: 5), 42);

        expect(IdrisDbLogger.history.isEmpty, isTrue);
      });
    });

    group('Transaction Logging', () {
      test('transaction logs include duration', () {
        IdrisDbLogger.setLevel(LogLevel.debug);

        IdrisDbLogger.transaction('put', Duration(milliseconds: 10));

        expect(IdrisDbLogger.history.length, equals(1));
        final entry = IdrisDbLogger.history.first;
        expect(entry.level, equals(LogLevel.debug));
        expect(entry.message, contains('put'));
        expect(entry.message, contains('10ms'));
      });

      test('transaction logs are not created when level is too low', () {
        IdrisDbLogger.setLevel(LogLevel.info);

        IdrisDbLogger.transaction('put', Duration(milliseconds: 10));

        expect(IdrisDbLogger.history.isEmpty, isTrue);
      });
    });

    group('Error Logging', () {
      test('error logs can include error object', () {
        final exception = Exception('Test exception');

        IdrisDbLogger.error('Operation failed', exception);

        expect(IdrisDbLogger.history.length, equals(1));
        final entry = IdrisDbLogger.history.first;
        expect(entry.error, equals(exception));
      });

      test('error logs can include stack trace', () {
        final stackTrace = StackTrace.current;

        IdrisDbLogger.error('Operation failed', null, stackTrace);

        expect(IdrisDbLogger.history.length, equals(1));
        final entry = IdrisDbLogger.history.first;
        expect(entry.stackTrace, equals(stackTrace));
      });
    });

    group('LogEntry', () {
      test('formatted output includes timestamp', () {
        final entry = LogEntry(
          level: LogLevel.info,
          message: 'Test message',
          timestamp: DateTime(2026, 5, 9, 12, 34, 56),
        );

        final formatted = entry.formatted;
        expect(formatted, contains('[12:34:56]'));
      });

      test('formatted output includes correct icon for each level', () {
        final levels = {
          LogLevel.error: '❌',
          LogLevel.warning: '⚠️',
          LogLevel.info: 'ℹ️',
          LogLevel.debug: '🔧',
          LogLevel.trace: '🔍',
        };

        for (final entry in levels.entries) {
          final logEntry = LogEntry(
            level: entry.key,
            message: 'Test',
            timestamp: DateTime.now(),
          );

          expect(logEntry.formatted, contains(entry.value));
        }
      });

      test('formatted output includes message', () {
        final entry = LogEntry(
          level: LogLevel.info,
          message: 'Test message',
          timestamp: DateTime.now(),
        );

        expect(entry.formatted, contains('Test message'));
        expect(entry.formatted, contains('[Idris DB]'));
      });

      test('formatted output includes error when present', () {
        final exception = Exception('Test error');
        final entry = LogEntry(
          level: LogLevel.error,
          message: 'Operation failed',
          timestamp: DateTime.now(),
          error: exception,
        );

        expect(entry.formatted, contains('Error: Exception: Test error'));
      });

      test('formatted output includes stack trace for errors', () {
        final stackTrace = StackTrace.current;
        final entry = LogEntry(
          level: LogLevel.error,
          message: 'Operation failed',
          timestamp: DateTime.now(),
          stackTrace: stackTrace,
        );

        expect(entry.formatted, contains('Stack trace:'));
      });

      test('formatted output does not include stack trace for non-errors', () {
        final stackTrace = StackTrace.current;
        final entry = LogEntry(
          level: LogLevel.info,
          message: 'Info message',
          timestamp: DateTime.now(),
          stackTrace: stackTrace,
        );

        expect(entry.formatted, isNot(contains('Stack trace:')));
      });
    });
  });
}
