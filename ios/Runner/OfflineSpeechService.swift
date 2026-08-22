import AVFoundation
import CoreML
import Flutter
import Foundation
import Speech
import WhisperKit

// MARK: - WhisperModelSpec

enum WhisperModelSpec {
    static let selector = "base"                        // WhisperKit API selector
    static let expectedDirectory = "openai_whisper-base" // repository folder
    static let repository = "argmaxinc/whisperkit-coreml"
    static let canonicalRelativeDir = "NoteEchoes/Models/Whisper/openai_whisper-base"
    static let schemaVersion = 2
    static let sdkVersion = "1.1.0"
}

// MARK: - WhisperModelManager Actor

/// Comprehensive model lifecycle actor for Whisper Base Multilingual on iOS.
/// Handles download, canonical storage, one-time migration, strict verification,
/// loading, specialized decoding policies, and provenance recording.
actor WhisperModelManager {
    static let shared = WhisperModelManager()

    enum ModelState: String {
        case missing = "missing"
        case downloading = "downloading"
        case verifying = "verifying"
        case loading = "loading"
        case ready = "ready"
        case needsRepair = "needsRepair"
        case failed = "failed"
    }

    enum DiagnosticError: String {
        case networkUnavailable = "network_unavailable"
        case downloadInterrupted = "download_interrupted"
        case modelFolderNotFound = "model_folder_not_found"
        case missingModelComponent = "missing_model_component"
        case modelLoadFailed = "model_load_failed"
        case insufficientStorage = "insufficient_storage"
        case unsupportedDevice = "unsupported_device"
        case transcriptionFailed = "transcription_failed"
        case emptyTranscript = "empty_transcript"
        case teluguFallbackUnavailable = "telugu_fallback_unavailable"
        case audioTooShort = "audio_too_short"
        case audioUnreadable = "audio_unreadable"
        case audioFormatUnsupported = "audio_format_unsupported"
        case unknown = "unknown"
    }

    // MARK: - State
    private var currentState: ModelState = .missing
    private var lastErrorCode: DiagnosticError?
    private var lastErrorMessage: String?
    private var downloadProgress: Double = 0.0
    private var completedBytes: Int64 = 0
    private var totalBytes: Int64 = 0

    private var whisperKitInstance: WhisperKit?
    private var activeDownloadTask: Task<WhisperKit, Error>?
    private var hasMigrated: Bool = false

    private init() {}

    // MARK: - Status
    func status() -> [String: Any] {
        performOneTimeMigrationIfNeeded()

        let (verified, missing, folderURL) = verifyCanonicalComponents()
        let stateToReport: ModelState
        if activeDownloadTask != nil {
            stateToReport = currentState
        } else if verified {
            stateToReport = (whisperKitInstance != nil) ? .ready : .ready
        } else if !missing.isEmpty && missing.count < 4 {
            stateToReport = .needsRepair
        } else {
            stateToReport = (lastErrorCode != nil && currentState == .failed) ? .failed : .missing
        }

        let isInstalled = verified
        let isVerified = verified
        let isLoaded = whisperKitInstance != nil

        let sizeBytes: Int64 = verified ? computeDirectorySize(url: folderURL) : 0

        return [
            "state": stateToReport.rawValue,
            "installed": isInstalled,
            "verified": isVerified,
            "loaded": isLoaded,
            "modelSelector": WhisperModelSpec.selector,
            "repositoryFolder": WhisperModelSpec.expectedDirectory,
            "sdkVersion": WhisperModelSpec.sdkVersion,
            "sizeBytes": sizeBytes > 0 ? sizeBytes : (isInstalled ? 154000000 : 0),
            "path": WhisperModelSpec.canonicalRelativeDir,
            "missingComponents": missing,
            "error_code": lastErrorCode?.rawValue as Any,
            "error_message": lastErrorMessage as Any
        ]
    }

    // MARK: - Download & Verify
    func download(
        onProgress: @escaping @Sendable (Double, Int64, Int64, String) -> Void
    ) async throws -> WhisperKit {
        if let existing = whisperKitInstance {
            currentState = .ready
            return existing
        }

        if let inFlight = activeDownloadTask {
            return try await inFlight.value
        }

        let task = Task<WhisperKit, Error> {
            do {
                self.currentState = .downloading
                self.lastErrorCode = nil
                self.lastErrorMessage = nil
                self.downloadProgress = 0.0

                let canonicalFolder = try self.canonicalModelFolder()
                let stagingRoot = try self.stagingStorageRoot()

                // Check free disk space (require at least 350 MB)
                let freeBytes = try self.freeDiskSpaceBytes()
                if freeBytes < 350 * 1024 * 1024 {
                    self.lastErrorCode = .insufficientStorage
                    self.lastErrorMessage = "Insufficient storage on device for Whisper Base model."
                    self.currentState = .failed
                    throw NSError(domain: "WhisperModelManager", code: 1, userInfo: [NSLocalizedDescriptionKey: self.lastErrorMessage!])
                }

                onProgress(0.05, 0, 154000000, "Connecting to Hugging Face repository…")

                // Download using WhisperKit official API with selector "base"
                let downloadedURL = try await WhisperKit.download(
                    variant: WhisperModelSpec.selector,
                    downloadBase: stagingRoot,
                    useBackgroundSession: false,
                    from: WhisperModelSpec.repository,
                    progressCallback: { progress in
                        let fraction = progress.fractionCompleted
                        let completed = progress.completedUnitCount
                        let total = progress.totalUnitCount > 0 ? progress.totalUnitCount : 154000000
                        let percent = Int(fraction * 100)
                        let completedMB = Double(completed) / (1024 * 1024)
                        let totalMB = Double(total) / (1024 * 1024)

                        Task {
                            await self.updateProgress(fraction: fraction, completed: completed, total: total)
                        }

                        let statusText = totalMB > 0
                            ? String(format: "Downloading Whisper Base (%.1f / %.1f MB • %d%%)…", completedMB, totalMB, percent)
                            : "Downloading Whisper Base (\(percent)%)…"

                        onProgress(fraction, completed, total, statusText)
                    }
                )

                self.currentState = .verifying
                onProgress(0.92, 140000000, 154000000, "Verifying Core ML Neural Engine components…")

                // Locate the downloaded direct folder in staging
                guard let sourceFolder = self.findDirectModelFolder(in: downloadedURL) ?? self.findDirectModelFolder(in: stagingRoot) else {
                    self.lastErrorCode = .modelFolderNotFound
                    self.lastErrorMessage = "Downloaded files were missing expected Core ML components."
                    self.currentState = .needsRepair
                    throw NSError(domain: "WhisperModelManager", code: 2, userInfo: [NSLocalizedDescriptionKey: self.lastErrorMessage!])
                }

                // Promote from staging to canonical folder atomically
                try self.promoteStagingToCanonical(source: sourceFolder, destination: canonicalFolder)

                // Strict component verification on the canonical folder
                let (verified, missing, finalFolder) = self.verifyCanonicalComponents()
                guard verified, let verifiedFolder = finalFolder else {
                    self.lastErrorCode = .missingModelComponent
                    self.lastErrorMessage = "Missing required components: \(missing.joined(separator: ", "))"
                    self.currentState = .needsRepair
                    throw NSError(domain: "WhisperModelManager", code: 3, userInfo: [NSLocalizedDescriptionKey: self.lastErrorMessage!])
                }

                self.currentState = .loading
                onProgress(0.96, 148000000, 154000000, "Executing model verification smoke test…")

                // Load test: Initialize WhisperKit to guarantee it compiles and prewarms cleanly
                let kit = try await WhisperKit(
                    modelFolder: verifiedFolder.path,
                    computeOptions: ModelComputeOptions(
                        melCompute: .cpuAndNeuralEngine,
                        audioEncoderCompute: .cpuAndNeuralEngine,
                        textDecoderCompute: .cpuAndNeuralEngine
                    )
                )

                // Write metadata record on successful verification
                try self.writeMetadataRecord()

                self.whisperKitInstance = kit
                self.currentState = .ready
                self.downloadProgress = 1.0
                onProgress(1.0, 154000000, 154000000, "Whisper Base is ready!")

                return kit
            } catch {
                self.currentState = (self.currentState == .verifying || self.currentState == .loading) ? .needsRepair : .failed
                self.mapAndStoreError(error)
                throw error
            }
        }

        activeDownloadTask = task
        do {
            let kit = try await task.value
            activeDownloadTask = nil
            return kit
        } catch {
            activeDownloadTask = nil
            throw error
        }
    }

    private func updateProgress(fraction: Double, completed: Int64, total: Int64) {
        self.downloadProgress = fraction
        self.completedBytes = completed
        self.totalBytes = total
    }

    // MARK: - Model Loading (Offline / Fast)
    func loadModel() async throws -> WhisperKit {
        if let existing = whisperKitInstance { return existing }

        performOneTimeMigrationIfNeeded()

        let (verified, missing, folderURL) = verifyCanonicalComponents()
        guard verified, let folderURL else {
            currentState = (missing.isEmpty) ? .missing : .needsRepair
            lastErrorCode = .missingModelComponent
            lastErrorMessage = "Whisper Base components missing: \(missing.joined(separator: ", "))"
            throw NSError(domain: "WhisperModelManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Model not verified on disk."])
        }

        currentState = .loading
        do {
            let kit = try await WhisperKit(
                modelFolder: folderURL.path,
                computeOptions: ModelComputeOptions(
                    melCompute: .cpuAndNeuralEngine,
                    audioEncoderCompute: .cpuAndNeuralEngine,
                    textDecoderCompute: .cpuAndNeuralEngine
                )
            )
            self.whisperKitInstance = kit
            self.currentState = .ready
            return kit
        } catch {
            self.currentState = .needsRepair
            self.lastErrorCode = .modelLoadFailed
            self.lastErrorMessage = "Failed to load model pipeline: \(error.localizedDescription)"
            throw error
        }
    }

    // MARK: - Repair
    func repair(
        onProgress: @escaping @Sendable (Double, Int64, Int64, String) -> Void
    ) async throws -> WhisperKit {
        whisperKitInstance = nil
        try? deleteIncompleteModelFiles()
        return try await download(onProgress: onProgress)
    }

    // MARK: - Deletion
    func deleteModel() throws {
        whisperKitInstance = nil
        activeDownloadTask?.cancel()
        activeDownloadTask = nil

        let canonical = try canonicalModelFolder()
        let staging = try stagingStorageRoot()
        let fm = FileManager.default

        if fm.fileExists(atPath: canonical.path) {
            try fm.removeItem(at: canonical)
        }
        if fm.fileExists(atPath: staging.path) {
            try fm.removeItem(at: staging)
        }

        currentState = .missing
        downloadProgress = 0.0
        completedBytes = 0
        totalBytes = 0
        lastErrorCode = nil
        lastErrorMessage = nil
    }

    func cancelDownload() {
        activeDownloadTask?.cancel()
        activeDownloadTask = nil
        currentState = .missing
        downloadProgress = 0.0
        lastErrorCode = .downloadInterrupted
        lastErrorMessage = "Download was cancelled."
    }

    // MARK: - Storage Path Management
    func canonicalModelFolder() throws -> URL {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let root = appSupport.appendingPathComponent(WhisperModelSpec.canonicalRelativeDir, isDirectory: true)
        if !FileManager.default.fileExists(atPath: root.path) {
            try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        }

        // Exclude model files from iCloud/iTunes backup
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableRoot = root
        try? mutableRoot.setResourceValues(values)

        return root
    }

    private func stagingStorageRoot() throws -> URL {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let staging = appSupport.appendingPathComponent("NoteEchoes/Staging/Whisper", isDirectory: true)
        if !FileManager.default.fileExists(atPath: staging.path) {
            try FileManager.default.createDirectory(at: staging, withIntermediateDirectories: true)
        }
        return staging
    }

    // MARK: - Component Verification
    func verifyCanonicalComponents() -> (verified: Bool, missing: [String], folderURL: URL?) {
        guard let folder = try? canonicalModelFolder() else {
            return (false, ["all"], nil)
        }

        let requiredFiles = [
            "AudioEncoder.mlmodelc",
            "MelSpectrogram.mlmodelc",
            "TextDecoder.mlmodelc",
            "config.json"
        ]

        var missing: [String] = []
        let fm = FileManager.default

        for file in requiredFiles {
            let path = folder.appendingPathComponent(file).path
            var isDir: ObjCBool = false
            if !fm.fileExists(atPath: path, isDirectory: &isDir) {
                missing.append(file)
            } else if isDir.boolValue {
                // For .mlmodelc directory, verify it has contents
                let contents = (try? fm.contentsOfDirectory(atPath: path)) ?? []
                if contents.isEmpty {
                    missing.append(file)
                }
            } else {
                // For file, verify non-zero size
                let attr = (try? fm.attributesOfItem(atPath: path)) ?? [:]
                let size = (attr[.size] as? NSNumber)?.int64Value ?? 0
                if size == 0 {
                    missing.append(file)
                }
            }
        }

        let isComplete = missing.isEmpty
        return (isComplete, missing, isComplete ? folder : nil)
    }

    private func findDirectModelFolder(in searchURL: URL) -> URL? {
        let fm = FileManager.default
        let directConfig = searchURL.appendingPathComponent("config.json").path
        let directEncoder = searchURL.appendingPathComponent("AudioEncoder.mlmodelc").path
        if fm.fileExists(atPath: directConfig) && fm.fileExists(atPath: directEncoder) {
            return searchURL
        }

        let repoCandidate = searchURL.appendingPathComponent(WhisperModelSpec.expectedDirectory, isDirectory: true)
        let repoConfig = repoCandidate.appendingPathComponent("config.json").path
        if fm.fileExists(atPath: repoConfig) {
            return repoCandidate
        }

        guard let enumerator = fm.enumerator(at: searchURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles]) else {
            return nil
        }

        var isDir: ObjCBool = false
        for case let url as URL in enumerator {
            if fm.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                let conf = url.appendingPathComponent("config.json").path
                let enc = url.appendingPathComponent("AudioEncoder.mlmodelc").path
                if fm.fileExists(atPath: conf) && fm.fileExists(atPath: enc) {
                    return url
                }
            }
        }

        return nil
    }

    private func promoteStagingToCanonical(source: URL, destination: URL) throws {
        let fm = FileManager.default
        let items = try fm.contentsOfDirectory(at: source, includingPropertiesForKeys: nil)
        for item in items {
            let destItem = destination.appendingPathComponent(item.lastPathComponent)
            if fm.fileExists(atPath: destItem.path) {
                try fm.removeItem(at: destItem)
            }
            try fm.moveItem(at: item, to: destItem)
        }
        try? fm.removeItem(at: source)
    }

    private func performOneTimeMigrationIfNeeded() {
        if hasMigrated { return }
        hasMigrated = true

        guard let canonical = try? canonicalModelFolder() else { return }
        let (verified, _, _) = verifyCanonicalComponents()
        if verified { return }

        let fm = FileManager.default
        guard let appSupport = try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return
        }

        let legacyCandidates = [
            appSupport.appendingPathComponent("WhisperKitModels/openai_whisper-base"),
            appSupport.appendingPathComponent("WhisperKitModels"),
            appSupport.appendingPathComponent("openai_whisper-base")
        ]

        for candidate in legacyCandidates {
            if let direct = findDirectModelFolder(in: candidate) {
                NSLog("[WhisperModelManager] Migrating legacy Whisper model from \(direct.path) to canonical location.")
                try? promoteStagingToCanonical(source: direct, destination: canonical)
                try? writeMetadataRecord()
                break
            }
        }
    }

    private func writeMetadataRecord() throws {
        let canonical = try canonicalModelFolder()
        let metadataURL = canonical.appendingPathComponent("whisper_metadata.json")
        let record: [String: Any] = [
            "schemaVersion": WhisperModelSpec.schemaVersion,
            "modelSelector": WhisperModelSpec.selector,
            "repositoryFolder": WhisperModelSpec.expectedDirectory,
            "relativePath": WhisperModelSpec.canonicalRelativeDir,
            "verifiedAt": ISO8601DateFormatter().string(from: Date()),
            "sdkVersion": WhisperModelSpec.sdkVersion
        ]
        let data = try JSONSerialization.data(withJSONObject: record, options: [.prettyPrinted])
        try data.write(to: metadataURL)
    }

    private func deleteIncompleteModelFiles() throws {
        let canonical = try canonicalModelFolder()
        let staging = try stagingStorageRoot()
        let fm = FileManager.default
        if fm.fileExists(atPath: canonical.path) {
            try fm.removeItem(at: canonical)
            try fm.createDirectory(at: canonical, withIntermediateDirectories: true)
        }
        if fm.fileExists(atPath: staging.path) {
            try fm.removeItem(at: staging)
            try fm.createDirectory(at: staging, withIntermediateDirectories: true)
        }
    }

    private func computeDirectorySize(url: URL?) -> Int64 {
        guard let url = url else { return 0 }
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey], options: []) else {
            return 0
        }
        var total: Int64 = 0
        for case let fileURL as URL in enumerator {
            let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey])
            total += Int64(values?.fileSize ?? 0)
        }
        return total
    }

    private func freeDiskSpaceBytes() throws -> Int64 {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        let values = try appSupport.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        return values.volumeAvailableCapacityForImportantUsage ?? 0
    }

    private func mapAndStoreError(_ error: Error) {
        let nsError = error as NSError
        let msg = nsError.localizedDescription.lowercased()

        if msg.contains("space") || msg.contains("storage") || msg.contains("quota") {
            lastErrorCode = .insufficientStorage
            lastErrorMessage = "Insufficient disk storage for Whisper Base."
        } else if msg.contains("network") || msg.contains("internet") || msg.contains("offline") || msg.contains("timed out") {
            lastErrorCode = .networkUnavailable
            lastErrorMessage = "Network connection is required to download Whisper Base."
        } else if msg.contains("cancel") {
            lastErrorCode = .downloadInterrupted
            lastErrorMessage = "Download was cancelled."
        } else if msg.contains("missing") || msg.contains("component") {
            lastErrorCode = .missingModelComponent
            lastErrorMessage = "Required Core ML components were missing."
        } else if msg.contains("load") || msg.contains("pipeline") {
            lastErrorCode = .modelLoadFailed
            lastErrorMessage = "Model loading verification failed."
        } else {
            lastErrorCode = .unknown
            lastErrorMessage = nsError.localizedDescription
        }
    }
}

// MARK: - OfflineSpeechService (Method Channel & Transcription)

@MainActor
final class OfflineSpeechService: NSObject {
    static let shared = OfflineSpeechService()
    private var methodChannel: FlutterMethodChannel?

    private override init() {
        super.init()
    }

    func register(with controller: FlutterViewController) {
        register(with: controller.binaryMessenger)
    }

    func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "noteechoes/offline_speech",
            binaryMessenger: messenger
        )
        self.methodChannel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                return result(FlutterError(code: "unavailable", message: nil, details: nil))
            }
            switch call.method {

            case "whisperStatus":
                Task {
                    let status = await WhisperModelManager.shared.status()
                    await MainActor.run { result(status) }
                }

            case "isWhisperInstalled":
                Task {
                    let status = await WhisperModelManager.shared.status()
                    let installed = status["installed"] as? Bool ?? false
                    await MainActor.run { result(installed) }
                }

            case "downloadWhisperBase":
                Task {
                    do {
                        _ = try await WhisperModelManager.shared.download { [weak self] fraction, completed, total, statusText in
                            DispatchQueue.main.async {
                                self?.methodChannel?.invokeMethod("onWhisperDownloadProgress", arguments: [
                                    "progress": fraction,
                                    "percent": Int(fraction * 100),
                                    "completedBytes": completed,
                                    "totalBytes": total,
                                    "statusText": statusText
                                ])
                            }
                        }
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

            case "repairWhisperBase":
                Task {
                    do {
                        _ = try await WhisperModelManager.shared.repair { [weak self] fraction, completed, total, statusText in
                            DispatchQueue.main.async {
                                self?.methodChannel?.invokeMethod("onWhisperDownloadProgress", arguments: [
                                    "progress": fraction,
                                    "percent": Int(fraction * 100),
                                    "completedBytes": completed,
                                    "totalBytes": total,
                                    "statusText": statusText
                                ])
                            }
                        }
                        await MainActor.run { result(true) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "whisper_repair_failed",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    }
                }

            case "cancelWhisperDownload":
                Task {
                    await WhisperModelManager.shared.cancelDownload()
                    await MainActor.run { result(true) }
                }

            case "deleteWhisperBase":
                Task {
                    do {
                        try await WhisperModelManager.shared.deleteModel()
                        let status = await WhisperModelManager.shared.status()
                        await MainActor.run { result(status) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "whisper_delete_failed",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    }
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
                let language = arguments["language"] as? String ?? "auto"
                Task {
                    do {
                        let provenance = try await self.transcribeAudioWithProvenance(
                            at: URL(fileURLWithPath: path),
                            requestedLanguage: language
                        )
                        await MainActor.run { result(provenance) }
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

    // MARK: – Audio Pre-Validation

    private func validateAudioFile(at url: URL) throws {
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else {
            throw NSError(domain: "OfflineSpeechService", code: 404, userInfo: [NSLocalizedDescriptionKey: "audio_unreadable"])
        }

        let attr = try fm.attributesOfItem(atPath: url.path)
        let size = (attr[.size] as? NSNumber)?.int64Value ?? 0
        guard size > 256 else {
            throw NSError(domain: "OfflineSpeechService", code: 400, userInfo: [NSLocalizedDescriptionKey: "audio_too_short"])
        }

        let asset = AVURLAsset(url: url)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        if durationSeconds.isFinite && durationSeconds < 0.25 {
            throw NSError(domain: "OfflineSpeechService", code: 400, userInfo: [NSLocalizedDescriptionKey: "audio_too_short"])
        }
    }

    // MARK: – Multilingual Transcription & Quality Scored Decoding

    struct TranscriptionCandidate {
        let text: String
        let detectedLanguage: String
        let avgLogprob: Float
        let noSpeechProb: Float
        let compressionRatio: Float
        let passName: String

        var isValid: Bool {
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty || trimmed.count < 2 { return false }
            if compressionRatio > 2.4 { return false } // Repetition loop
            if noSpeechProb > 0.75 { return false }
            return true
        }
    }

    func transcribeAudioWithProvenance(at url: URL, requestedLanguage: String) async throws -> [String: Any] {
        try validateAudioFile(at: url)

        let isMixedMode = requestedLanguage == "te-en-mixed" || requestedLanguage == "mixed"
        let isTeluguMode = requestedLanguage == "te" || requestedLanguage == "telugu"
        let isHindiMode = requestedLanguage == "hi" || requestedLanguage == "hindi"
        let isEnglishMode = requestedLanguage == "en" || requestedLanguage == "english"

        // Attempt WhisperKit transcription first
        do {
            let pipe = try await WhisperModelManager.shared.loadModel()

            if isMixedMode {
                // Pass 1: Forced Telugu transcription
                let pass1Candidate = try await executeWhisperPass(
                    pipe: pipe,
                    audioURL: url,
                    language: "te",
                    detectLanguage: false,
                    passName: "forced_telugu"
                )

                if pass1Candidate.isValid {
                    return formatProvenance(
                        candidate: pass1Candidate,
                        requestedMode: requestedLanguage,
                        fallbackUsed: false,
                        fallbackReason: nil
                    )
                }

                // Pass 2: Fallback to auto-detect if Pass 1 quality check failed
                let pass2Candidate = try await executeWhisperPass(
                    pipe: pipe,
                    audioURL: url,
                    language: nil,
                    detectLanguage: true,
                    passName: "auto_detect_fallback"
                )

                let chosen = pass2Candidate.isValid ? pass2Candidate : pass1Candidate
                if !chosen.text.isEmpty {
                    return formatProvenance(
                        candidate: chosen,
                        requestedMode: requestedLanguage,
                        fallbackUsed: false,
                        fallbackReason: nil
                    )
                }
            } else {
                let targetLang: String? = isTeluguMode ? "te" : (isHindiMode ? "hi" : (isEnglishMode ? "en" : nil))
                let candidate = try await executeWhisperPass(
                    pipe: pipe,
                    audioURL: url,
                    language: targetLang,
                    detectLanguage: targetLang == nil,
                    passName: "standard"
                )

                if candidate.isValid {
                    return formatProvenance(
                        candidate: candidate,
                        requestedMode: requestedLanguage,
                        fallbackUsed: false,
                        fallbackReason: nil
                    )
                }
            }
        } catch {
            NSLog("[OfflineSpeechService] Whisper offline decode error: \(error)")
        }

        // Apple Speech Fallback Policy: NEVER silently fall back to en-US for Telugu or Mixed mode!
        return try await transcribeWithAppleSpeechGuarded(at: url, requestedLanguage: requestedLanguage)
    }

    func transcribeAudio(at url: URL, language: String = "auto") async throws -> String {
        let provenance = try await transcribeAudioWithProvenance(at: url, requestedLanguage: language)
        return provenance["text"] as? String ?? ""
    }

    private func executeWhisperPass(
        pipe: WhisperKit,
        audioURL: URL,
        language: String?,
        detectLanguage: Bool,
        passName: String
    ) async throws -> TranscriptionCandidate {
        let options = DecodingOptions(
            verbose: false,
            task: .transcribe,
            language: language,
            temperature: 0.0,
            temperatureIncrementOnFallback: 0.2,
            temperatureFallbackCount: 3,
            usePrefillPrompt: language != nil,
            detectLanguage: detectLanguage,
            skipSpecialTokens: true,
            withoutTimestamps: true,
            suppressBlank: true,
            chunkingStrategy: .vad
        )

        let results = try await pipe.transcribe(
            audioPath: audioURL.path,
            decodeOptions: options
        )

        let text = results.compactMap { $0.text }
            .joined(separator: " ")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        let firstSegment = results.first?.segments.first
        let avgLogprob = firstSegment?.avgLogprob ?? -0.3
        let noSpeechProb = firstSegment?.noSpeechProb ?? 0.01
        let compressionRatio = firstSegment?.compressionRatio ?? 1.0
        let detectedLang = language ?? (results.first?.language ?? "auto")

        return TranscriptionCandidate(
            text: text,
            detectedLanguage: detectedLang,
            avgLogprob: avgLogprob,
            noSpeechProb: noSpeechProb,
            compressionRatio: compressionRatio,
            passName: passName
        )
    }

    private func formatProvenance(
        candidate: TranscriptionCandidate,
        requestedMode: String,
        fallbackUsed: Bool,
        fallbackReason: String?
    ) -> [String: Any] {
        return [
            "text": candidate.text,
            "requestedMode": requestedMode,
            "detectedLanguage": candidate.detectedLanguage,
            "engine": fallbackUsed ? "apple_speech" : "whisperkit",
            "model": fallbackUsed ? "sfspeech" : WhisperModelSpec.selector,
            "fallbackUsed": fallbackUsed,
            "fallbackReason": fallbackReason as Any,
            "quality": [
                "avgLogprob": candidate.avgLogprob,
                "noSpeechProb": candidate.noSpeechProb,
                "compressionRatio": candidate.compressionRatio,
                "pass": candidate.passName
            ]
        ]
    }

    // MARK: – Guarded Apple Speech Fallback

    private func transcribeWithAppleSpeechGuarded(at url: URL, requestedLanguage: String) async throws -> [String: Any] {
        let isTelugu = requestedLanguage == "te" || requestedLanguage == "te-en-mixed" || requestedLanguage == "mixed"
        let isHindi = requestedLanguage == "hi"

        let targetLocaleIdentifier: String
        if isTelugu {
            targetLocaleIdentifier = "te-IN"
        } else if isHindi {
            targetLocaleIdentifier = "hi-IN"
        } else {
            targetLocaleIdentifier = "en-US"
        }

        let locale = Locale(identifier: targetLocaleIdentifier)
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            if isTelugu || isHindi {
                // Never silently return en-US for Telugu or Hindi! Throw explicit typed failure.
                throw NSError(
                    domain: "OfflineSpeechService",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Telugu offline recognizer unavailable and on-device Whisper model is not ready. Please download Whisper Base in Settings."]
                )
            }
            throw NSError(domain: "OfflineSpeechService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Apple speech recognizer unavailable."])
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = false
        request.shouldReportPartialResults = false

        let recognizedText: String = try await withCheckedThrowingContinuation { continuation in
            recognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                if let result = result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }

        return [
            "text": recognizedText,
            "requestedMode": requestedLanguage,
            "detectedLanguage": targetLocaleIdentifier.components(separatedBy: "-").first ?? "auto",
            "engine": "apple_speech",
            "model": "sfspeech",
            "fallbackUsed": true,
            "fallbackReason": "Whisper unavailable or failed candidate evaluation",
            "quality": [
                "pass": "apple_speech_fallback"
            ]
        ]
    }

    private func recordingPermissionStatus() -> String {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted: return "granted"
        case .denied:  return "denied"
        case .undetermined: return "undetermined"
        @unknown default: return "undetermined"
        }
    }
}
