import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../infrastructure/ai_database.dart';

class ModelIntegrityService {
  static final ModelIntegrityService _instance = ModelIntegrityService._internal();

  factory ModelIntegrityService() {
    return _instance;
  }

  ModelIntegrityService._internal();

  static ModelIntegrityService get instance => _instance;

  Future<bool> verifyIntegrity(String modelId, String filePath, AiDatabase database) async {
    try {
      // Assuming a method like getExpectedSha256 exists in AiDatabase.
      // Depending on actual drift implementation, this might be a direct query.
      final expectedSha = await database.getExpectedSha256(modelId);
      if (expectedSha == null || expectedSha.isEmpty) {
        debugPrint('ModelIntegrityService: No expected SHA-256 found for $modelId');
        return false;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('ModelIntegrityService: File does not exist at $filePath');
        return false;
      }

      final stream = file.openRead();
      final hash = await sha256.bind(stream).first;
      final actualSha = hash.toString();

      if (actualSha == expectedSha) {
        return true;
      } else {
        debugPrint('ModelIntegrityService: SHA-256 mismatch. Expected: $expectedSha, Actual: $actualSha');
        return false;
      }
    } catch (e) {
      debugPrint('ModelIntegrityService: Error verifying integrity: $e');
      return false;
    }
  }
}
