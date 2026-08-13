import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../infrastructure/ai_database.dart';
import 'model_integrity_service.dart';

enum DownloadErrorCode { wifiRequired, networkError, sha256Mismatch, diskFull, cancelled, unknown }

class DownloadException implements Exception {
  final DownloadErrorCode code;
  final String message;
  DownloadException(this.code, [this.message = '']);
  @override
  String toString() => 'DownloadException: $code - $message';
}

class DownloadProgress {
  final double fraction;
  final int bytesDownloaded;
  final int totalBytes;
  DownloadProgress(this.fraction, this.bytesDownloaded, this.totalBytes);
}

class ModelDownloadService {
  static final ModelDownloadService _instance = ModelDownloadService._internal();

  factory ModelDownloadService() {
    return _instance;
  }

  ModelDownloadService._internal();

  static ModelDownloadService get instance => _instance;

  final Map<String, bool> _cancellations = {};
  final MethodChannel _channel = const MethodChannel('notechoes/file_attributes');

  void cancel(String modelId) {
    _cancellations[modelId] = true;
  }

  Future<void> downloadModel({
    required String modelId,
    required String url,
    required String finalPath,
    required AiDatabase database,
    bool requiresWifi = true,
    void Function(DownloadProgress)? onProgress,
  }) async {
    _cancellations[modelId] = false;
    final tempPath = '$finalPath.part';
    final tempFile = File(tempPath);
    
    if (requiresWifi) {
      // TODO: Implement actual WiFi connectivity check using connectivity_plus or native channels.
      // For now, assume this is handled or throws if strict requirement is missed.
      // throw DownloadException(DownloadErrorCode.wifiRequired);
    }

    try {
      await _updateInstallationStatus(database, modelId, 'downloading');

      int downloadedBytes = 0;
      if (await tempFile.exists()) {
        downloadedBytes = await tempFile.length();
      }

      final request = http.Request('GET', Uri.parse(url));
      if (downloadedBytes > 0) {
        request.headers['Range'] = 'bytes=$downloadedBytes-';
      }

      final response = await http.Client().send(request);

      if (response.statusCode >= 400 && response.statusCode != 416) {
        throw DownloadException(DownloadErrorCode.networkError, 'HTTP ${response.statusCode}');
      }

      final totalBytes = (response.contentLength ?? 0) + downloadedBytes;
      final sink = tempFile.openWrite(mode: downloadedBytes > 0 ? FileMode.append : FileMode.write);

      await for (final chunk in response.stream) {
        if (_cancellations[modelId] == true) {
          await sink.close();
          throw DownloadException(DownloadErrorCode.cancelled);
        }
        sink.add(chunk);
        downloadedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(DownloadProgress(downloadedBytes / totalBytes, downloadedBytes, totalBytes));
        }
      }
      await sink.close();

      if (_cancellations[modelId] == true) {
        throw DownloadException(DownloadErrorCode.cancelled);
      }

      final isValid = await ModelIntegrityService.instance.verifyIntegrity(modelId, tempPath, database);
      if (!isValid) {
        throw DownloadException(DownloadErrorCode.sha256Mismatch);
      }

      await tempFile.rename(finalPath);

      try {
        await _channel.invokeMethod('excludeFromBackup', {'path': finalPath});
      } catch (e) {
        debugPrint('Failed to exclude from backup: $e');
      }

      await _updateInstallationStatus(database, modelId, 'completed');
    } catch (e) {
      await _updateInstallationStatus(database, modelId, 'failed');
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      if (e is DownloadException) rethrow;
      throw DownloadException(DownloadErrorCode.unknown, e.toString());
    } finally {
      _cancellations.remove(modelId);
    }
  }

  Future<void> _updateInstallationStatus(AiDatabase database, String modelId, String status) async {
    try {
      await database.updateModelInstallationStatus(modelId, status);
    } catch (e) {
      debugPrint('Error updating installation status: $e');
    }
  }
}
