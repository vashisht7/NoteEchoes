import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Keeps attachment references valid when iOS changes the app-container UUID
/// during an update or a development install.
class AttachmentPathService {
  static const attachmentsFolder = 'attachments';

  static Future<String?> resolve(
    String storedReference, {
    String? documentsPath,
  }) async {
    if (storedReference.trim().isEmpty) return null;

    final directFile = File(storedReference);
    if (directFile.isAbsolute && directFile.existsSync()) {
      return directFile.path;
    }

    final normalizedReference = p.normalize(storedReference);
    final isRecoverableLegacyPath =
        p.isAbsolute(normalizedReference) &&
        normalizedReference.contains(
          '${p.separator}Documents${p.separator}$attachmentsFolder${p.separator}',
        );
    if (p.isAbsolute(normalizedReference) && !isRecoverableLegacyPath) {
      return null;
    }

    try {
      final documents =
          documentsPath ?? (await getApplicationDocumentsDirectory()).path;
      final candidates = <String>[
        if (!p.isAbsolute(normalizedReference))
          p.join(documents, normalizedReference),
        p.join(documents, attachmentsFolder, p.basename(normalizedReference)),
      ];

      for (final candidate in candidates.toSet()) {
        if (await File(candidate).exists()) return candidate;
      }
    } catch (_) {
      // Path-provider is unavailable in some widget tests. The caller will
      // show its normal missing-attachment state.
    }
    return null;
  }

  static Future<String> toStoredReference(String absolutePath) async {
    try {
      final documents = await getApplicationDocumentsDirectory();
      if (p.isWithin(documents.path, absolutePath)) {
        return p.relative(absolutePath, from: documents.path);
      }
    } catch (_) {
      // Retain the original path if the platform directory is unavailable.
    }
    return absolutePath;
  }
}
