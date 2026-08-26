import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/note_model.dart';

/// Durable SQLite storage for notes. Existing SharedPreferences notes are
/// imported once in a transaction so upgrades do not lose user content.
class NoteStorageService {
  static const _legacyStorageKey = 'notechoes_saved_notes_v1';
  static const _migrationKey = 'notechoes_notes_sqlite_migration_v1';
  static const _backupFileName = 'notechoes_notes_backup_v1.json';
  static const _backupChannel = MethodChannel('notechoes/note_backup');
  static final NoteStorageService _instance = NoteStorageService._internal();

  factory NoteStorageService() => _instance;
  NoteStorageService._internal();

  Database? _databaseInstance;
  Future<Database>? _opening;
  bool _usingTestDatabase = false;

  Future<Database> _database() => _opening ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    final databaseFile = File(p.join(directory.path, 'notechoes.sqlite'));
    final databaseWasMissing = !await databaseFile.exists();
    final database = sqlite3.open(databaseFile.path);
    _configure(database);
    await _migrateLegacyNotes(database);
    if (databaseWasMissing || _noteCount(database) == 0) {
      await _recoverFromBackup(database);
    }
    if (_noteCount(database) > 0) {
      await _writeRecoveryBackup(database);
    }
    _databaseInstance = database;
    return database;
  }

  int _noteCount(Database database) =>
      database.select('SELECT COUNT(*) AS count FROM notes;').first['count']
          as int;

  void _configure(Database database) {
    database.execute('PRAGMA journal_mode = WAL;');
    database.execute('PRAGMA synchronous = NORMAL;');
    database.execute('''
      CREATE TABLE IF NOT EXISTS notes (
        note_id TEXT PRIMARY KEY NOT NULL,
        payload_json TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');
    database.execute(
      'CREATE INDEX IF NOT EXISTS notes_created_at_idx ON notes(created_at DESC);',
    );
  }

  Future<void> _migrateLegacyNotes(Database database) async {
    final preferences = await SharedPreferences.getInstance();
    final legacyJson = preferences.getString(_legacyStorageKey);
    if (preferences.getBool(_migrationKey) == true &&
        (_noteCount(database) > 0 || legacyJson == null)) {
      return;
    }
    if (legacyJson != null && legacyJson.isNotEmpty) {
      final decoded = jsonDecode(legacyJson) as List<dynamic>;
      database.execute('BEGIN IMMEDIATE;');
      try {
        for (final value in decoded) {
          final note = NoteModel.fromJson(
            Map<String, dynamic>.from(value as Map),
          );
          _upsert(database, note);
        }
        database.execute('COMMIT;');
      } catch (_) {
        database.execute('ROLLBACK;');
        rethrow;
      }
    }
    await preferences.setBool(_migrationKey, true);
  }

  Future<File> _backupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    await directory.create(recursive: true);
    return File(p.join(directory.path, _backupFileName));
  }

  Future<int> _recoverFromBackup(Database database) async {
    final candidates = <String>[];
    try {
      final file = await _backupFile();
      if (await file.exists()) candidates.add(await file.readAsString());
    } catch (error) {
      debugPrint('Local note-backup read failed: $error');
    }
    try {
      final shared = await _backupChannel
          .invokeMethod<String>('readBackup')
          .timeout(const Duration(seconds: 2));
      if (shared != null && shared.isNotEmpty) candidates.add(shared);
    } catch (error) {
      debugPrint('Shared note-backup read failed: $error');
    }

    final existingIds = database
        .select('SELECT note_id FROM notes;')
        .map((row) => row['note_id'] as String)
        .toSet();

    var totalRecovered = 0;
    for (final payload in candidates) {
      try {
        final decoded = jsonDecode(payload) as List<dynamic>;
        if (decoded.isEmpty) continue;
        database.execute('BEGIN IMMEDIATE;');
        try {
          for (final value in decoded) {
            final note = NoteModel.fromJson(
              Map<String, dynamic>.from(value as Map),
            );
            if (existingIds.add(note.noteId)) {
              _upsert(database, note);
              totalRecovered++;
            }
          }
          database.execute('COMMIT;');
        } catch (_) {
          database.execute('ROLLBACK;');
          rethrow;
        }
      } catch (error) {
        debugPrint('Ignored an unreadable note backup: $error');
      }
    }
    if (totalRecovered > 0) {
      debugPrint('Recovered $totalRecovered new notes from safety backup.');
    }
    return totalRecovered;
  }

  Future<void> _writeRecoveryBackup(Database database) async {
    if (_usingTestDatabase) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_legacyStorageKey);
      return;
    }
    final rows = database.select(
      'SELECT payload_json FROM notes ORDER BY created_at DESC;',
    );
    final payload = jsonEncode(
      rows.map((row) => jsonDecode(row['payload_json'] as String)).toList(),
    );

    var durableCopyWritten = false;
    try {
      final file = await _backupFile();
      final temporary = File('${file.path}.new');
      await temporary.writeAsString(payload, flush: true);
      await temporary.rename(file.path);
      durableCopyWritten = true;
    } catch (error) {
      debugPrint('Local note-backup write failed: $error');
    }
    try {
      await _backupChannel
          .invokeMethod<void>('writeBackup', payload)
          .timeout(const Duration(seconds: 2));
      durableCopyWritten = true;
    } catch (error) {
      debugPrint('Shared note-backup write failed: $error');
    }

    if (durableCopyWritten) {
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.remove(_legacyStorageKey);
      } catch (error) {
        debugPrint('Could not retire legacy note storage: $error');
      }
    }
  }

  Future<List<NoteModel>> loadNotes() async {
    try {
      final database = await _database();
      final rows = database.select(
        'SELECT payload_json FROM notes ORDER BY created_at DESC;',
      );
      return rows
          .map(
            (row) => NoteModel.fromJson(
              Map<String, dynamic>.from(
                jsonDecode(row['payload_json'] as String) as Map,
              ),
            ),
          )
          .toList();
    } catch (error) {
      debugPrint('Error loading notes from SQLite: $error');
      return [];
    }
  }

  /// Re-syncs the recovery copies after Flutter's native channels are live.
  /// Startup storage opens before the first frame, which can be too early for
  /// the App Group bridge on a UIScene-based iOS launch.
  Future<bool> syncRecoveryBackup() async {
    final database = await _database();
    final recovered = await _recoverFromBackup(database);
    if (_noteCount(database) > 0) {
      await _writeRecoveryBackup(database);
    }
    return recovered > 0;
  }

  Future<void> upsertNote(NoteModel note) async {
    final database = await _database();
    _upsert(database, note);
    // SQLite is already durable at this point. Recovery mirrors can finish in
    // the background instead of holding the Save interaction for up to four
    // seconds across the local and App Group copies.
    unawaited(_writeRecoveryBackup(database));
  }

  void _upsert(Database database, NoteModel note) {
    database.execute(
      '''
      INSERT INTO notes (note_id, payload_json, created_at, updated_at)
      VALUES (?, ?, ?, ?)
      ON CONFLICT(note_id) DO UPDATE SET
        payload_json = excluded.payload_json,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;
      ''',
      [
        note.noteId,
        jsonEncode(note.toJson()),
        note.createdAt.millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
      ],
    );
  }

  Future<void> deleteNote(String noteId) async {
    final database = await _database();
    database.execute('DELETE FROM notes WHERE note_id = ?;', [noteId]);
    await _writeRecoveryBackup(database);
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    final database = await _database();
    database.execute('BEGIN IMMEDIATE;');
    try {
      database.execute('DELETE FROM notes;');
      for (final note in notes) {
        _upsert(database, note);
      }
      database.execute('COMMIT;');
      await _writeRecoveryBackup(database);
    } catch (_) {
      database.execute('ROLLBACK;');
      rethrow;
    }
  }

  Future<List<String>> readAndClearPendingFileNotes() async {
    final pendingNotes = <String>[];
    try {
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File(
        p.join(documentDirectory.path, 'notechoes_pending_notes.txt'),
      );
      if (await file.exists()) {
        for (final line in await file.readAsLines()) {
          if (line.trim().isNotEmpty) pendingNotes.add(line.trim());
        }
        await file.delete();
      }
    } catch (error) {
      debugPrint('Error reading pending file notes: $error');
    }
    return pendingNotes;
  }

  Future<void> clearAll() async {
    final database = await _database();
    database.execute('DELETE FROM notes;');
    await _writeRecoveryBackup(database);
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_legacyStorageKey);
  }

  @visibleForTesting
  Future<void> useInMemoryDatabaseForTesting({
    List<NoteModel> seedNotes = const [],
  }) async {
    _databaseInstance?.close();
    _usingTestDatabase = true;
    final database = sqlite3.openInMemory();
    _configure(database);
    for (final note in seedNotes) {
      _upsert(database, note);
    }
    _databaseInstance = database;
    _opening = Future.value(database);
  }

  @visibleForTesting
  void closeDatabaseForTesting() {
    _databaseInstance?.close();
    _databaseInstance = null;
    _opening = null;
    _usingTestDatabase = false;
  }

  @visibleForTesting
  Future<void> migrateLegacyNotesForTesting() async {
    final database = await _database();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_migrationKey, false);
    await _migrateLegacyNotes(database);
    await _writeRecoveryBackup(database);
  }
}
