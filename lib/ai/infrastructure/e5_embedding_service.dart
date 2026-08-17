import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:dart_sentencepiece_tokenizer/dart_sentencepiece_tokenizer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model_availability_service.dart';

class E5EmbeddingService extends ChangeNotifier {
  E5EmbeddingService._();
  static final instance = E5EmbeddingService._();

  static const modelVersion = 'multilingual-e5-small-qint8-v1';
  static const dimensions = 384;
  static const _modelBytes = 118346824;
  static const _tokenizerBytes = 5069051;
  static const _modelSha =
      'dd476dd0c2514e9b9be83aeb3853fac0763e0bdf4a71645407587d77c48a2d88';
  static const _tokenizerSha =
      'cfc8146abe2a0488e9e2a0c56de7952f7c11ab059eca145a0a727afce0db2865';
  static const _modelUrl =
      'https://huggingface.co/intfloat/multilingual-e5-small/resolve/main/onnx/model_qint8_avx512_vnni.onnx?download=true';
  static const _tokenizerUrl =
      'https://huggingface.co/intfloat/multilingual-e5-small/resolve/main/onnx/sentencepiece.bpe.model?download=true';

  final OnnxRuntime _runtime = OnnxRuntime();
  OrtSession? _session;
  SentencePieceTokenizer? _tokenizer;
  bool isDownloading = false;
  double downloadProgress = 0;

  Future<Directory> get _directory async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'models', modelVersion));
  }

  Future<LocalModelStatus> status({bool verifyHashes = false}) async {
    final directory = await _directory;
    final model = File(p.join(directory.path, 'model.onnx'));
    final tokenizer = File(p.join(directory.path, 'sentencepiece.bpe.model'));
    final verification = File(p.join(directory.path, 'verified.sha256'));
    if (!await model.exists() && !await tokenizer.exists()) {
      return LocalModelStatus(
        id: modelVersion,
        health: ModelHealth.missing,
        localPath: directory.path,
        reason: 'Semantic model is not downloaded.',
      );
    }
    final modelSize = await model.exists() ? await model.length() : 0;
    final tokenizerSize = await tokenizer.exists()
        ? await tokenizer.length()
        : 0;
    final correctSizes =
        modelSize == _modelBytes && tokenizerSize == _tokenizerBytes;
    final verificationText = await verification.exists()
        ? await verification.readAsString()
        : '';
    var verified =
        correctSizes && verificationText.trim() == '$_modelSha\n$_tokenizerSha';
    if (correctSizes && verifyHashes) {
      verified =
          await _sha(model) == _modelSha &&
          await _sha(tokenizer) == _tokenizerSha;
    }
    return LocalModelStatus(
      id: modelVersion,
      health: verified ? ModelHealth.ready : ModelHealth.needsRepair,
      sizeBytes: modelSize + tokenizerSize,
      localPath: directory.path,
      reason: verified ? '' : 'Semantic model files are incomplete or damaged.',
    );
  }

  Future<void> download() async {
    if (isDownloading) return;
    isDownloading = true;
    downloadProgress = 0;
    notifyListeners();
    try {
      final directory = await _directory;
      await directory.create(recursive: true);
      await _downloadFile(
        Uri.parse(_modelUrl),
        File(p.join(directory.path, 'model.onnx')),
        _modelBytes,
        (value) {
          downloadProgress = value * 0.96;
          notifyListeners();
        },
      );
      await _downloadFile(
        Uri.parse(_tokenizerUrl),
        File(p.join(directory.path, 'sentencepiece.bpe.model')),
        _tokenizerBytes,
        (value) {
          downloadProgress = 0.96 + value * 0.04;
          notifyListeners();
        },
      );
      final checked = await status(verifyHashes: true);
      if (!checked.isReady) throw StateError(checked.reason);
      final marker = File(p.join(directory.path, 'verified.sha256'));
      final partialMarker = File('${marker.path}.partial');
      await partialMarker.writeAsString('$_modelSha\n$_tokenizerSha');
      if (await marker.exists()) await marker.delete();
      await partialMarker.rename(marker.path);
      downloadProgress = 1;
    } finally {
      isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> remove() async {
    await unload();
    final directory = await _directory;
    if (await directory.exists()) await directory.delete(recursive: true);
    downloadProgress = 0;
    notifyListeners();
  }

  Future<List<double>> embedDocument(String text) => _embed('passage: $text');
  Future<List<double>> embedQuery(String text) => _embed('query: $text');

  Future<List<double>> _embed(String text) async {
    await _load();
    final raw = _tokenizer!.encode(text, addSpecialTokens: false).ids;
    final usable = raw.take(510).map((id) => id == 0 ? 3 : id + 1).toList();
    final ids = Int64List.fromList([0, ...usable, 2]);
    final mask = Int64List.fromList(List<int>.filled(ids.length, 1));
    final types = Int64List(ids.length);
    final inputIds = await OrtValue.fromList(ids, [1, ids.length]);
    final attention = await OrtValue.fromList(mask, [1, ids.length]);
    final tokenTypes = await OrtValue.fromList(types, [1, ids.length]);
    Map<String, OrtValue> outputs = const {};
    try {
      outputs = await _session!.run({
        'input_ids': inputIds,
        'attention_mask': attention,
        'token_type_ids': tokenTypes,
      });
      final output = outputs['last_hidden_state'] ?? outputs.values.first;
      final flat = await output.asFlattenedList();
      final pooled = List<double>.filled(dimensions, 0);
      for (var token = 0; token < ids.length; token++) {
        for (var d = 0; d < dimensions; d++) {
          pooled[d] += (flat[token * dimensions + d] as num).toDouble();
        }
      }
      var magnitude = 0.0;
      for (var d = 0; d < dimensions; d++) {
        pooled[d] /= ids.length;
        magnitude += pooled[d] * pooled[d];
      }
      magnitude = math.sqrt(magnitude).clamp(1e-12, double.infinity);
      return pooled.map((value) => value / magnitude).toList(growable: false);
    } finally {
      await inputIds.dispose();
      await attention.dispose();
      await tokenTypes.dispose();
      for (final value in outputs.values) {
        await value.dispose();
      }
    }
  }

  Future<void> _load() async {
    if (_session != null && _tokenizer != null) return;
    final checked = await status();
    if (!checked.isReady) throw StateError(checked.reason);
    final directory = await _directory;
    _tokenizer = await SentencePieceTokenizer.fromModelFile(
      p.join(directory.path, 'sentencepiece.bpe.model'),
    );
    _session = await _runtime.createSession(
      p.join(directory.path, 'model.onnx'),
      options: OrtSessionOptions(intraOpNumThreads: 2, interOpNumThreads: 1),
    );
  }

  Future<void> unload() async {
    await _session?.close();
    _session = null;
    _tokenizer = null;
  }

  Future<void> _downloadFile(
    Uri uri,
    File destination,
    int expectedBytes,
    ValueChanged<double> onProgress,
  ) async {
    final partial = File('${destination.path}.partial');
    var existing = await partial.exists() ? await partial.length() : 0;
    if (existing > expectedBytes) {
      await partial.delete();
      existing = 0;
    }
    if (await destination.exists() &&
        await destination.length() == expectedBytes) {
      onProgress(1);
      return;
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 30);
    try {
      final request = await client.getUrl(uri);
      if (existing > 0) {
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=$existing-');
      }
      final response = await request.close();
      final canResume = response.statusCode == HttpStatus.partialContent;
      if (existing > 0 && !canResume) {
        existing = 0;
        if (await partial.exists()) await partial.delete();
      }
      if (response.statusCode != HttpStatus.ok && !canResume) {
        throw HttpException('Model download failed (${response.statusCode}).');
      }
      final sink = partial.openWrite(
        mode: existing > 0 ? FileMode.append : FileMode.write,
      );
      var received = existing;
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        onProgress((received / expectedBytes).clamp(0, 1));
      }
      await sink.flush();
      await sink.close();
      if (await partial.length() != expectedBytes) {
        throw const FileSystemException(
          'Downloaded model has an unexpected size.',
        );
      }
      if (await destination.exists()) await destination.delete();
      await partial.rename(destination.path);
    } finally {
      client.close(force: true);
    }
  }

  Future<String> _sha(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();
}
