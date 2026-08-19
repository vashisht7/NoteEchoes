import AVFoundation
import Flutter
import Speech
import WhisperKit

/// One durable transcription path for in-app recordings and App Shortcuts.
/// Whisper Base is downloaded on demand using the official WhisperKit.download() API;
/// Apple Speech remains the zero-download fallback for English and for users who
/// have not installed the offline pack.
final class OfflineSpeechService {
    static let shared = OfflineSpeechService()

    private let whisperVariant  = "base"
    private let whisperRepo     = "argmaxinc/whisperkit-coreml"
    private let modelPathKey    = "whisper_base_multilingual_model_path"
    private let installedKey    = "whisper_base_multilingual_installed"

    private var whisperKit: WhisperKit?
    private var loadingTask: Task<WhisperKit, Error>?
    private weak var methodChannel: FlutterMethodChannel?

    private init() {}

    // MARK: – Public status

    var isWhisperInstalled: Bool {
        resolveInstalledFolder() != nil
    }

    // MARK: – Flutter channel

    func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(
            name: "noteechoes/offline_speech",
            binaryMessenger: controller.binaryMessenger
        )
        self.methodChannel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                return result(FlutterError(code: "unavailable", message: nil, details: nil))
            }
            switch call.method {

            case "whisperStatus":
                result(self.whisperStatus())

            case "isWhisperInstalled":
                result(self.isWhisperInstalled)

            case "downloadWhisperBase":
                Task {
                    do {
                        _ = try await self.downloadAndLoad()
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
                    return result(FlutterError(
                        code: "bad_arguments",
                        message: "Audio path is required.",
                        details: nil
                    ))
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

    // MARK: – Transcription

    func transcribeAudio(at url: URL, language: String) async throws -> String {
        if isWhisperInstalled {
            do {
                let pipe = try await getLoadedWhisperKit()
                // Map Flutter language code → Whisper language token
                // "auto" or empty → nil language + detectLanguage: true for mixed Telugu-English
                let isAuto = language == "auto" || language.isEmpty
                let whisperLang: String? = isAuto ? nil : (switch language {
                case "te": "te"
                case "hi": "hi"
                case "en": "en"
                default: nil
                })

                let options = DecodingOptions(
                    verbose: false,
                    task: .transcribe,
                    language: whisperLang,
                    temperature: 0.0,
                    temperatureIncrementOnFallback: 0.2,
                    temperatureFallbackCount: 3,
                    usePrefillPrompt: whisperLang != nil,
                    detectLanguage: whisperLang == nil,
                    skipSpecialTokens: true,
                    withoutTimestamps: true,
                    suppressBlank: true,
                    chunkingStrategy: .vad
                )
                let results = try await pipe.transcribe(
                    audioPath: url.path,
                    decodeOptions: options
                )
                let text = results.map(\.text)
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty {
                    return text
                }
            } catch {
                // If Whisper encountered an issue on a specific audio clip, fall back to Apple Speech
                NSLog("[OfflineSpeechService] Whisper transcription error: \(error), falling back to Apple Speech")
            }
        }
        return try await transcribeWithAppleSpeech(at: url, language: language)
    }

    // MARK: – Download + Load (two-step, reliable with live progress)

    /// Step 1: Download the model files using WhisperKit's own HuggingFace downloader with live progress streaming.
    /// Step 2: Load WhisperKit from the downloaded folder.
    private func downloadAndLoad() async throws -> WhisperKit {
        // Reuse a cached instance if already downloaded + loaded
        if let whisperKit { return whisperKit }
        if let loadingTask { return try await loadingTask.value }

        let task = Task<WhisperKit, Error> {
            // --- Step 1: Download ---
            let folderURL: URL
            if let existing = self.resolveInstalledFolder() {
                folderURL = existing
            } else {
                // Download to the app's Application Support directory so it
                // persists across reboots and isn't cleaned by iOS cache eviction.
                let downloadBase = try Self.whisperDownloadBase()
                folderURL = try await WhisperKit.download(
                    variant: self.whisperVariant,
                    downloadBase: downloadBase,
                    useBackgroundSession: false,
                    from: self.whisperRepo,
                    progressCallback: { [weak self] progress in
                        let fraction = progress.fractionCompleted
                        let completedBytes = progress.completedUnitCount
                        let totalBytes = progress.totalUnitCount
                        let percent = Int(fraction * 100)
                        let completedMB = Double(completedBytes) / (1024 * 1024)
                        let totalMB = Double(totalBytes) / (1024 * 1024)

                        let statusText = totalMB > 0
                            ? String(format: "Downloading Whisper Base (%.1f / %.1f MB • %d%%)…", completedMB, totalMB, percent)
                            : "Downloading Whisper Base (\(percent)%)…"

                        DispatchQueue.main.async {
                            self?.methodChannel?.invokeMethod("onWhisperDownloadProgress", arguments: [
                                "progress": fraction,
                                "percent": percent,
                                "completedBytes": completedBytes,
                                "totalBytes": totalBytes,
                                "statusText": statusText
                            ])
                        }
                    }
                )
            }

            // Persist the resolved path immediately so whisperStatus() sees it.
            UserDefaults.standard.set(folderURL.path, forKey: self.modelPathKey)
            UserDefaults.standard.set(true, forKey: self.installedKey)

            DispatchQueue.main.async { [weak self] in
                self?.methodChannel?.invokeMethod("onWhisperDownloadProgress", arguments: [
                    "progress": 0.95,
                    "percent": 95,
                    "statusText": "Preparing Core ML Neural Engine model…"
                ])
            }

            // --- Step 2: Load ---
            let kit = try await WhisperKit(
                modelFolder: folderURL.path,
                computeOptions: ModelComputeOptions(
                    melCompute: .cpuAndNeuralEngine,
                    audioEncoderCompute: .cpuAndNeuralEngine,
                    textDecoderCompute: .cpuAndNeuralEngine
                )
            )

            DispatchQueue.main.async { [weak self] in
                self?.methodChannel?.invokeMethod("onWhisperDownloadProgress", arguments: [
                    "progress": 1.0,
                    "percent": 100,
                    "statusText": "Whisper Base is ready!"
                ])
            }

            return kit
        }

        loadingTask = task
        do {
            let kit = try await task.value
            whisperKit   = kit
            loadingTask  = nil
            return kit
        } catch {
            loadingTask = nil
            throw error
        }
    }

    /// Returns the already-loaded WhisperKit instance for transcription,
    /// loading it from the persisted folder path without re-downloading.
    private func getLoadedWhisperKit() async throws -> WhisperKit {
        if let whisperKit { return whisperKit }

        guard let folder = resolveInstalledFolder() else {
            throw SpeechError.modelUnavailable
        }

        let kit = try await WhisperKit(modelFolder: folder.path)
        whisperKit = kit
        return kit
    }

    // MARK: – Folder resolution

    /// Returns the Application Support sub-directory where models are downloaded.
    private static func whisperDownloadBase() throws -> URL {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw SpeechError.modelUnavailable
        }
        let base = appSupport.appendingPathComponent("WhisperKitModels", isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    /// Scans known locations for an already-downloaded model and returns the
    /// first directory that contains the required Core ML model files.
    private func resolveInstalledFolder() -> URL? {
        let manager = FileManager.default

        // 1. Stored path (fastest check — set after a successful download)
        if let stored = UserDefaults.standard.string(forKey: modelPathKey) {
            let url = URL(fileURLWithPath: stored)
            if isCompleteWhisperFolder(url) { return url }
        }

        // 2. Known roots to scan
        var roots: [URL] = []

        if let appSupport = manager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first {
            // Our custom download base
            roots.append(appSupport.appendingPathComponent("WhisperKitModels"))
            // WhisperKit default HuggingFace cache
            roots.append(appSupport.appendingPathComponent("huggingface/models/\(whisperRepo)/openai_whisper-\(whisperVariant)"))
            roots.append(appSupport.appendingPathComponent("huggingface/models/\(whisperRepo)"))
            roots.append(appSupport)
        }

        if let caches = manager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            roots.append(caches.appendingPathComponent("WhisperKitModels"))
            roots.append(caches.appendingPathComponent("huggingface/models/\(whisperRepo)"))
            roots.append(caches)
        }

        if let documents = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            roots.append(documents)
        }

        for root in roots {
            // Check the root itself
            if isCompleteWhisperFolder(root) {
                UserDefaults.standard.set(root.path, forKey: modelPathKey)
                return root
            }
            // Enumerate one level of subdirectories
            guard let enumerator = manager.enumerator(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
            ) else { continue }
            for case let candidate as URL in enumerator {
                if isCompleteWhisperFolder(candidate) {
                    UserDefaults.standard.set(candidate.path, forKey: modelPathKey)
                    return candidate
                }
                // Also check one level deeper (variant folder inside repo folder)
                guard let sub = manager.enumerator(
                    at: candidate,
                    includingPropertiesForKeys: [.isDirectoryKey],
                    options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
                ) else { continue }
                for case let deep as URL in sub {
                    if isCompleteWhisperFolder(deep) {
                        UserDefaults.standard.set(deep.path, forKey: modelPathKey)
                        return deep
                    }
                }
            }
        }
        return nil
    }

    /// Returns true if `folder` contains the three Core ML model components
    /// that WhisperKit requires to run transcription.
    private func isCompleteWhisperFolder(_ folder: URL) -> Bool {
        let manager = FileManager.default
        var isDir: ObjCBool = false
        guard manager.fileExists(atPath: folder.path, isDirectory: &isDir), isDir.boolValue else {
            return false
        }

        // Look for the required model component names (any depth within the folder)
        let required = Set(["MelSpectrogram", "AudioEncoder", "TextDecoder"])
        guard let enumerator = manager.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return false }

        var found = Set<String>()
        for case let url as URL in enumerator {
            let ext = url.pathExtension.lowercased()
            if ext == "mlmodelc" || ext == "mlpackage" || ext == "mlmodel" {
                let name = url.deletingPathExtension().lastPathComponent
                // Match partial names (e.g. "AudioEncoderContextAll" contains "AudioEncoder")
                for req in required {
                    if name.contains(req) { found.insert(req) }
                }
            }
            if found == required { return true }
        }
        return found == required
    }

    // MARK: – Status

    private func whisperStatus() -> [String: Any] {
        let folder = resolveInstalledFolder()
        let installed = folder != nil
        UserDefaults.standard.set(installed, forKey: installedKey)
        let bytes = folder.map(directorySize) ?? 0
        return [
            "installed": installed,
            "verified": installed,
            "enabled": installed,
            "path": folder?.path ?? "",
            "sizeBytes": bytes,
            "reason": installed ? "" : "Model files are not downloaded."
        ]
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

    // MARK: – Delete

    private func deleteWhisperModel() throws {
        whisperKit = nil
        loadingTask?.cancel()
        loadingTask = nil

        // Remove both the custom download base and any found folder
        if let folder = resolveInstalledFolder() {
            try? FileManager.default.removeItem(at: folder)
        }
        if let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first {
            let customBase = appSupport.appendingPathComponent("WhisperKitModels")
            try? FileManager.default.removeItem(at: customBase)
        }

        UserDefaults.standard.removeObject(forKey: modelPathKey)
        UserDefaults.standard.set(false, forKey: installedKey)
    }

    // MARK: – Recording permission

    private func recordingPermissionStatus() -> String {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:      "granted"
        case .denied:       "denied"
        case .undetermined: "undetermined"
        @unknown default:   "unknown"
        }
    }

    // MARK: – Apple Speech fallback

    private func transcribeWithAppleSpeech(at url: URL, language: String) async throws -> String {
        let authorization = await requestSpeechAuthorization()
        guard authorization == .authorized else {
            throw SpeechError.permissionDenied
        }

        let localeIdentifier = switch language {
        case "te":   "te-IN"
        case "hi":   "hi-IN"
        case "en":   "en-US"
        case "auto": Locale.current.identifier
        default:     "en-US"
        }

        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)),
              recognizer.isAvailable else {
            // Fall back to English if te-IN / hi-IN recognizer unavailable
            guard let fallback = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) else {
                throw SpeechError.recognizerUnavailable
            }
            return try await recognizeFile(at: url, recognizer: fallback)
        }
        return try await recognizeFile(at: url, recognizer: recognizer)
    }

    private func recognizeFile(at url: URL, recognizer: SFSpeechRecognizer) async throws -> String {
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
        exporter.outputURL  = outputURL
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

// MARK: – Helpers

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
        case .modelUnavailable:    "The offline speech model is not installed."
        case .permissionDenied:    "Speech recognition permission was denied."
        case .recognizerUnavailable: "Speech recognition is unavailable for the selected language."
        case .emptyResult:         "No speech was recognized in the recording."
        }
    }
}
