import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/voice_feedback.dart';

typedef FeedbackDirectoryProvider = Future<Directory> Function();

/// Local-only, append-only feedback storage for later user-approved RL export.
class VoiceFeedbackStore {
  static final VoiceFeedbackStore instance = VoiceFeedbackStore();

  final FeedbackDirectoryProvider _directoryProvider;
  Future<void> _writeTail = Future<void>.value();

  VoiceFeedbackStore({FeedbackDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  Future<File> _feedbackFile() async {
    final root = await _directoryProvider();
    final directory = Directory('${root.path}/noteechoes_rl_feedback');
    await directory.create(recursive: true);
    return File('${directory.path}/feedback.jsonl');
  }

  Future<void> append(VoiceFeedbackRecord record) {
    final operation = _writeTail.then((_) async {
      final file = await _feedbackFile();
      await file.writeAsString(
        '${record.toJsonLine()}\n',
        mode: FileMode.append,
        flush: true,
      );
    });
    _writeTail = operation.catchError((_) {});
    return operation;
  }

  Future<List<VoiceFeedbackRecord>> readAll() async {
    await _writeTail;
    final file = await _feedbackFile();
    if (!await file.exists()) return const [];
    final records = <VoiceFeedbackRecord>[];
    for (final line in await file.readAsLines()) {
      if (line.trim().isEmpty) continue;
      records.add(
        VoiceFeedbackRecord.fromJson(
          Map<String, dynamic>.from(jsonDecode(line) as Map),
        ),
      );
    }
    return records;
  }
}
