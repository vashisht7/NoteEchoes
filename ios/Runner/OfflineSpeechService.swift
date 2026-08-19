import AVFoundation
import Flutter
import Speech
import WhisperKit

/// One durable transcription path for in-app recordings and App Shortcuts.
/// Whisper Base is downloaded on demand; Apple Speech remains the zero-download
/// fallback for English and for users who have not installed the offline pack.
final class OfflineSpeechService {
    static let shared = OfflineSpeechService()

    private let modelName = "base"
    private let installedKey = "whisper_base_multilingual_installed"
    private let modelPathKey = "whisper_base_multilingual_model_path"
    private var whisperKit: WhisperKit?
    private var loadingTask: Task<WhisperKit, Error>?

    private init() {}

    var isWhisperInstalled: Bool {
        installedModelFolder() != nil
    }

    func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "noteechoes/offline_speech",
            binaryMessenger: controller.binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { return result(FlutterError(code: "unavailable", message: nil, details: nil)) }
            switch call.method {
            case "whisperStatus":
                result(self.whisperStatus())
            case "isWhisperInstalled":
                result(self.isWhisperInstalled)
            case "downloadWhisperBase":
                Task {
                    do {
                        _ = try await self.loadWhisper(download: true)
                        UserDefaults.standard.set(true, forKey: self.installedKey)
                        await MainActor.run { result(true) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "whisper_download_failed",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    }
                }
            case "disableWhisper":
                self.whisperKit = nil
                UserDefaults.standard.set(false, forKey: self.installedKey)
                result(true)
            case "deleteWhisperBase":
                do {
                    try self.deleteWhisperModel()
                    result(self.whisperStatus())
                } catch {
                    result(FlutterError(
                        code: "whisper_delete_failed",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            case "recordingPermissionStatus":
                result(self.recordingPermissionStatus())
            case "transcribeAudioFile":
                guard
                    let arguments = call.arguments as? [String: Any],
                    let path = arguments["path"] as? String
                else {
                    return result(FlutterError(code: "bad_arguments", message: "Audio path is required.", details: nil))
                }
                let language = arguments["language"] as? String ?? "en"
                Task {
                    do {
                        let text = try await self.transcribeAudio(
                            at: URL(fileURLWithPath: path),
                            language: language
                        )
                        await MainActor.run { result(text) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "transcription_failed",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    }
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func transcribeAudio(at url: URL, language: String) async throws -> String {
        if isWhisperInstalled {
            let pipe = try await loadWhisper(download: false)
            let isAutomatic = language == "auto"
            let options = DecodingOptions(
                task: .transcribe,
                language: isAutomatic ? nil : language,
                usePrefillPrompt: !isAutomatic,
                detectLanguage: isAutomatic,
                chunkingStrategy: .vad
            )
            let results = try await pipe.transcribe(
                audioPath: url.path,
                decodeOptions: options
            )
            return results.map(\.text)
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return try await transcribeWithAppleSpeech(at: url, language: language)
    }

    private func loadWhisper(download: Bool) async throws -> WhisperKit {
        if let whisperKit { return whisperKit }
        if let loadingTask { return try await loadingTask.value }

        let existingFolder = installedModelFolder()
        if !download && existingFolder == nil {
            throw SpeechError.modelUnavailable
        }

        let task = Task<WhisperKit, Error> {
            let loaded = try await WhisperKit(WhisperKitConfig(
                model: "openai_whisper-base",
                modelRepo: "argmaxinc/whisperkit-coreml",
                modelFolder: existingFolder?.path,
                verbose: true,
                prewarm: false,
                load: true,
                download: download && existingFolder == nil,
                useBackgroundDownloadSession: false
            ))
            if let folder = loaded.modelFolder {
                UserDefaults.standard.set(folder.path, forKey: self.modelPathKey)
            }
            return loaded
        }
        loadingTask = task
        do {
            let loaded = try await task.value
            whisperKit = loaded
            loadingTask = nil
            return loaded
        } catch {
            loadingTask = nil
            throw error
        }
    }

    private func whisperStatus() -> [String: Any] {
        let folder = installedModelFolder()
        let bytes = folder.map(directorySize) ?? 0
        let installed = folder != nil
        UserDefaults.standard.set(installed, forKey: installedKey)
        return [
            "installed": installed,
            "verified": installed,
            "enabled": installed,
            "path": folder?.path ?? "",
            "sizeBytes": bytes,
            "reason": installed ? "" : "Model files are not downloaded."
        ]
    }

    private func installedModelFolder() -> URL? {
        let manager = FileManager.default
        var roots: [URL] = []
        if let storedPath = UserDefaults.standard.string(forKey: modelPathKey) {
            roots.append(URL(fileURLWithPath: storedPath))
        }
        if let documents = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            roots.append(documents)
            roots.append(documents.appendingPathComponent("huggingface"))
            roots.append(documents.appendingPathComponent("models"))
            roots.append(documents.appendingPathComponent("whisper"))
        }
        if let appSupport = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            roots.append(appSupport)
            roots.append(appSupport.appendingPathComponent("huggingface"))
            roots.append(appSupport.appendingPathComponent("models"))
            roots.append(appSupport.appendingPathComponent("whisper"))
        }
        if let caches = manager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            roots.append(caches)
            roots.append(caches.appendingPathComponent("huggingface"))
            roots.append(caches.appendingPathComponent("models"))
            roots.append(caches.appendingPathComponent("whisper"))
        }
        if let shared = SharedDefaults.sharedContainerURL {
            roots.append(shared)
            roots.append(shared.appendingPathComponent("huggingface"))
            roots.append(shared.appendingPathComponent("models"))
        }

        for root in roots {
            if isCompleteWhisperFolder(root) { return root }
            guard let enumerator = manager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            ) else { continue }
            for case let candidate as URL in enumerator {
                if isCompleteWhisperFolder(candidate) {
                    UserDefaults.standard.set(candidate.path, forKey: modelPathKey)
                    return candidate
                }
            }
        }
        return nil
    }

    private func isCompleteWhisperFolder(_ folder: URL) -> Bool {
        let manager = FileManager.default
        guard manager.fileExists(atPath: folder.path) else { return false }
        let required = ["MelSpectrogram", "AudioEncoder", "TextDecoder"]
        guard let enumerator = manager.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return false }
        var found = Set<String>()
        for case let url as URL in enumerator {
            let ext = url.pathExtension.lowercased()
            if ext == "mlmodelc" || ext == "mlpackage" {
                found.insert(url.deletingPathExtension().lastPathComponent)
            }
        }
        return required.allSatisfy(found.contains)
    }

    private func directorySize(_ directory: URL) -> Int64 {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return 0 }
        var total: Int64 = 0
        for case let url as URL in enumerator {
            if let values = try? url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey]),
               values.isRegularFile == true {
                total += Int64(values.fileSize ?? 0)
            }
        }
        return total
    }

    private func deleteWhisperModel() throws {
        whisperKit = nil
        if let folder = installedModelFolder(),
           FileManager.default.fileExists(atPath: folder.path) {
            try FileManager.default.removeItem(at: folder)
        }
        UserDefaults.standard.removeObject(forKey: modelPathKey)
        UserDefaults.standard.set(false, forKey: installedKey)
    }

    private func recordingPermissionStatus() -> String {
        switch AVAudioApplication.shared.recordPermission {
        case .granted: "granted"
        case .denied: "denied"
        case .undetermined: "undetermined"
        @unknown default: "unknown"
        }
    }

    private func transcribeWithAppleSpeech(at url: URL, language: String) async throws -> String {
        let authorization = await requestSpeechAuthorization()
        guard authorization == .authorized else {
            throw SpeechError.permissionDenied
        }

        let localeIdentifier = switch language {
        case "te": "te-IN"
        case "hi": "hi-IN"
        case "auto": Locale.current.identifier
        default: "en-US"
        }
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)) else {
            throw SpeechError.recognizerUnavailable
        }

        let asset = AVURLAsset(url: url)
        let duration = (try? await asset.load(.duration).seconds) ?? 0
        if duration <= 52 {
            return try await recognizeChunk(at: url, recognizer: recognizer, timeout: max(60, duration * 2.5))
        }

        var paragraphs: [String] = []
        var start = 0.0
        while start < duration {
            let length = min(50.0, duration - start)
            let chunkURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("noteechoes_chunk_\(UUID().uuidString).m4a")
            defer { try? FileManager.default.removeItem(at: chunkURL) }
            if await exportChunk(from: asset, start: start, duration: length, to: chunkURL),
               let text = try? await recognizeChunk(at: chunkURL, recognizer: recognizer, timeout: 90),
               !text.isEmpty {
                paragraphs.append(text)
            }
            start += length
        }
        let complete = paragraphs.joined(separator: "\n\n")
        if complete.isEmpty { throw SpeechError.emptyResult }
        return complete
    }

    private func requestSpeechAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        let current = SFSpeechRecognizer.authorizationStatus()
        if current != .notDetermined { return current }
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { continuation.resume(returning: $0) }
        }
    }

    private func exportChunk(
        from asset: AVAsset,
        start: Double,
        duration: Double,
        to outputURL: URL
    ) async -> Bool {
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            return false
        }
        exporter.outputURL = outputURL
        exporter.outputFileType = .m4a
        exporter.timeRange = CMTimeRange(
            start: CMTime(seconds: start, preferredTimescale: 600),
            duration: CMTime(seconds: duration, preferredTimescale: 600)
        )
        await exporter.export()
        return exporter.status == .completed
    }

    private func recognizeChunk(
        at url: URL,
        recognizer: SFSpeechRecognizer,
        timeout: Double
    ) async throws -> String {
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.taskHint = .dictation
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        request.requiresOnDeviceRecognition = false

        return try await withCheckedThrowingContinuation { continuation in
            let state = RecognitionState()
            let task = recognizer.recognitionTask(with: request) { result, error in
                if let result {
                    let text = result.bestTranscription.formattedString
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty { state.bestText = text }
                    if result.isFinal { state.finish(continuation: continuation) }
                } else if let error {
                    state.finish(continuation: continuation, error: error)
                }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                task.cancel()
                state.finish(continuation: continuation)
            }
        }
    }
}

private final class RecognitionState: @unchecked Sendable {
    private let lock = NSLock()
    private var finished = false
    var bestText = ""

    func finish(
        continuation: CheckedContinuation<String, Error>,
        error: Error? = nil
    ) {
        lock.lock()
        defer { lock.unlock() }
        guard !finished else { return }
        finished = true
        if !bestText.isEmpty {
            continuation.resume(returning: bestText)
        } else if let error {
            continuation.resume(throwing: error)
        } else {
            continuation.resume(throwing: SpeechError.emptyResult)
        }
    }
}

private enum SpeechError: LocalizedError {
    case modelUnavailable
    case permissionDenied
    case recognizerUnavailable
    case emptyResult

    var errorDescription: String? {
        switch self {
        case .modelUnavailable: "The offline speech model is not installed."
        case .permissionDenied: "Speech recognition permission was denied."
        case .recognizerUnavailable: "Speech recognition is unavailable for the selected language."
        case .emptyResult: "No speech was recognized in the recording."
        }
    }
}
