import Foundation
import CryptoKit
import Hub
#if os(macOS)
import FlutterMacOS
#else
import Flutter
#endif
import MLX
import MLXLLM
import MLXLMCommon

/// One shared MLX container keeps Metal memory predictable across note and PDF
/// requests. Model files are downloaded by the Hugging Face integration into
/// Application Support / Caches on first load, so they do not inflate the App Store IPA.
actor MLXTextGenerationService {
    static let shared = MLXTextGenerationService()

    static let productModelName = "noteechoes-english-voice-intent-action-qwen3-0.6b-mlx-8bit"
    static let primaryModelID = "Vashisht7/noteechoes-english-voice-intent-action-qwen3-0.6b-mlx-8bit"
    static let productModelRevision = "b829d1d480c0bc0226326e36f009ae825af60f18"
    static let requiredFreeSpaceBytes: Int64 = 2_000_000_000
    static let expectedRuntimeBytes: Int64 = 649_376_484
    static let verificationMarkerName = ".noteechoes-english-action-mlx8-verified.json"
    static let requiredFiles: [(name: String, size: Int64, sha256: String)] = [
        ("added_tokens.json", 707, "c0284b582e14987fbd3d5a2cb2bd139084371ed9acbae488829a1c900833c680"),
        ("chat_template.jinja", 4_168, "a55ee1b1660128b7098723e0abcd92caa0788061051c62d51cbe87d9cf1974d8"),
        ("config.json", 1_737, "ab345d334484b3809b0f671cda5201d4f69102aa68b0f339e4cbe53fff02e6e9"),
        ("generation_config.json", 214, "64d86df2173901c58389974bde21f7d2ab9eb7d79f35a337753329d39cf265c0"),
        ("merges.txt", 1_671_853, "8831e4f1a044471340f7c0a83d7bd71306a5b867e95fd870f74d0c5308a904d5"),
        ("model.safetensors", 633_442_531, "4f7acb40c1bcf6c4bf8a3b6f0350e595ef6ae8130469bcfc85cceec7eb4114ea"),
        ("model.safetensors.index.json", 49_770, "9e9d09d5f0eb73a33663314f68b24dd91d33e245ca3af15daed8e69b5adff982"),
        ("special_tokens_map.json", 613, "76862e765266b85aa9459767e33cbaf13970f327a0e88d1c65846c2ddd3a1ecd"),
        ("tokenizer.json", 11_422_654, "aeb13307a71acd8fe81861d94ad54ab689df773318809eed3cbe794b4492dae4"),
        ("tokenizer_config.json", 5_404, "443bfa629eb16387a12edbf92a76f6a6f10b2af3b53d87ba1550adfcf45f7fa0"),
        ("vocab.json", 2_776_833, "ca10d7e9fb3ed18575dd1e277a2579c16d108e32f27439684afa0e10b1440910")
    ]

    private var container: ModelContainer?
    private var activeLoadTask: Task<Void, Error>?

    var isLoaded: Bool {
        return container != nil
    }

    nonisolated static func installationStatus() -> [String: Any] {
        if let local = localProductModelDirectory() {
            let localStatus = inspectCache(at: local)
            if localStatus["verified"] as? Bool == true {
                return localStatus
            }
        }
        return inspectCache(at: productHubDirectory())
    }

    func load(onProgress: (@Sendable (Double, String) -> Void)? = nil) async throws {
        if container != nil { return }
        if let activeLoadTask {
            try await activeLoadTask.value
            return
        }

        let task = Task { [weak self] in
            guard let self else { throw MLXTextGenerationError.modelUnavailable }
            try await self.performLoad(onProgress: onProgress)
        }
        activeLoadTask = task
        defer { activeLoadTask = nil }
        try await task.value
    }

    private func performLoad(
        onProgress: (@Sendable (Double, String) -> Void)?
    ) async throws {
        Memory.cacheLimit = 20 * 1024 * 1024

        let manager = FileManager.default
        var modelDirectory: URL?

        if let legacyDirectory = Self.localProductModelDirectory(),
           manager.fileExists(atPath: legacyDirectory.path) {
            do {
                try Self.verifyAndMark(directory: legacyDirectory)
                modelDirectory = legacyDirectory
            } catch {
                try? manager.removeItem(at: legacyDirectory)
            }
        }

        if modelDirectory == nil {
            let hubDirectory = Self.productHubDirectory()
            if Self.hasCompleteRuntimeFiles(at: hubDirectory) {
                do {
                    try Self.verifyAndMark(directory: hubDirectory)
                    modelDirectory = hubDirectory
                } catch {
                    try? manager.removeItem(at: hubDirectory)
                }
            }
            if modelDirectory == nil {
                try Self.ensureDownloadCapacity()
                onProgress?(0, "Preparing the NoteEchoes English Action model download…")
                modelDirectory = try await Self.productHub.snapshot(
                    from: Self.primaryModelID,
                    revision: Self.productModelRevision,
                    matching: Self.requiredFiles.map { $0.name }
                ) { progress in
                    let fraction = progress.fractionCompleted
                    let percent = Int(fraction * 100)
                    onProgress?(fraction, "Downloading NoteEchoes English Action model (\(percent)%)…")
                }
                guard let modelDirectory else {
                    throw MLXTextGenerationError.modelUnavailable
                }
                onProgress?(0.99, "Verifying model integrity…")
                try Self.verifyAndMark(directory: modelDirectory)
            }
        }

        guard let modelDirectory else { throw MLXTextGenerationError.modelUnavailable }
        try Self.excludeFromBackup(modelDirectory)
        let loaded = try await LLMModelFactory.shared.loadContainer(
            configuration: ModelConfiguration(directory: modelDirectory)
        )
        container = loaded
        onProgress?(1, "NoteEchoes English Action model is ready.")
    }

    func generate(
        prompt: String,
        systemPrompt: String?,
        maxTokens: Int = 600,
        temperature: Float = 0
    ) async throws -> String {
        try await load()
        guard let container else {
            throw MLXTextGenerationError.modelUnavailable
        }

        let session = ChatSession(
            container,
            instructions: systemPrompt,
            generateParameters: GenerateParameters(
                maxTokens: min(max(maxTokens, 1), 1_024),
                temperature: min(max(temperature, 0), 1)
            )
        )
        return try await session.respond(to: prompt)
    }

    func unload() {
        container = nil
        Memory.clearCache()
    }

    func cancelDownload() {
        activeLoadTask?.cancel()
        activeLoadTask = nil
    }

    func deleteCachedModel() throws -> [String: Any] {
        unload()
        cancelDownload()
        var directories = [Self.productHubDirectory()]
        if let local = Self.localProductModelDirectory() {
            directories.append(local)
        }
        for directory in directories where FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.removeItem(at: directory)
        }
        return Self.installationStatus()
    }

    nonisolated private static func inspectCache(at directory: URL) -> [String: Any] {
        let manager = FileManager.default
        guard manager.fileExists(atPath: directory.path) else {
            return [
                "installed": false, "verified": false,
                "path": directory.path, "sizeBytes": Int64(0),
                "reason": "Model files are not downloaded."
            ]
        }

        var sizeBytes: Int64 = 0
        let keys: Set<URLResourceKey> = [.isRegularFileKey, .fileSizeKey]
        if let enumerator = manager.enumerator(
            at: directory,
            includingPropertiesForKeys: Array(keys),
            options: [.skipsHiddenFiles]
        ) {
            for case let url as URL in enumerator {
                guard let values = try? url.resourceValues(forKeys: keys),
                      values.isRegularFile == true else { continue }
                sizeBytes += Int64(values.fileSize ?? 0)
            }
        }
        let missing = requiredFiles.compactMap { expected -> String? in
            let file = directory.appendingPathComponent(expected.name)
            guard manager.fileExists(atPath: file.path),
                  let values = try? file.resourceValues(forKeys: [.fileSizeKey]),
                  Int64(values.fileSize ?? -1) == expected.size else {
                return expected.name
            }
            return nil
        }
        let markerValid = validVerificationMarker(at: directory)
        let verified = missing.isEmpty && markerValid
        return [
            "installed": sizeBytes > 0,
            "verified": verified,
            "path": directory.path,
            "sizeBytes": sizeBytes,
            "expectedSizeBytes": expectedRuntimeBytes,
            "revision": productModelRevision,
            "missingComponents": missing,
            "reason": verified ? "" : (missing.isEmpty
                ? "Model files require integrity verification."
                : (sizeBytes > 0 ? "Model download is incomplete or damaged." : "Model files are not downloaded."))
        ]
    }

    nonisolated private static func hasCompleteRuntimeFiles(at directory: URL) -> Bool {
        let manager = FileManager.default
        return requiredFiles.allSatisfy { expected in
            let file = directory.appendingPathComponent(expected.name)
            guard manager.fileExists(atPath: file.path),
                  let values = try? file.resourceValues(forKeys: [.fileSizeKey]) else {
                return false
            }
            return Int64(values.fileSize ?? -1) == expected.size
        }
    }

    nonisolated private static func verifyAndMark(directory: URL) throws {
        for expected in requiredFiles {
            let file = directory.appendingPathComponent(expected.name)
            guard FileManager.default.fileExists(atPath: file.path) else {
                throw MLXTextGenerationError.integrityFailure("Missing \(expected.name).")
            }
            let values = try file.resourceValues(forKeys: [.fileSizeKey])
            guard Int64(values.fileSize ?? -1) == expected.size else {
                throw MLXTextGenerationError.integrityFailure("Unexpected size for \(expected.name).")
            }
            guard try sha256(of: file) == expected.sha256 else {
                throw MLXTextGenerationError.integrityFailure("SHA-256 mismatch for \(expected.name).")
            }
        }

        let marker: [String: Any] = [
            "model": productModelName,
            "revision": productModelRevision,
            "weightsSHA256": requiredFiles.first(where: { $0.name == "model.safetensors" })?.sha256 ?? "",
            "runtimeFilesTotalBytes": expectedRuntimeBytes
        ]
        let data = try JSONSerialization.data(withJSONObject: marker, options: [.sortedKeys])
        try data.write(
            to: directory.appendingPathComponent(verificationMarkerName),
            options: [.atomic]
        )
    }

    nonisolated private static func validVerificationMarker(at directory: URL) -> Bool {
        let marker = directory.appendingPathComponent(verificationMarkerName)
        guard let data = try? Data(contentsOf: marker),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return false
        }
        let expectedWeightsHash = requiredFiles.first(where: { $0.name == "model.safetensors" })?.sha256
        return json["model"] as? String == productModelName
            && json["revision"] as? String == productModelRevision
            && json["weightsSHA256"] as? String == expectedWeightsHash
    }

    nonisolated private static func sha256(of file: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: file)
        defer { try? handle.close() }
        var hasher = SHA256()
        while true {
            let data = try handle.read(upToCount: 4 * 1_024 * 1_024) ?? Data()
            if data.isEmpty { break }
            hasher.update(data: data)
        }
        return hasher.finalize().map { String(format: "%02x", $0) }.joined()
    }

    nonisolated private static func ensureDownloadCapacity() throws {
        let base = productDownloadBase()
        try FileManager.default.createDirectory(
            at: base,
            withIntermediateDirectories: true
        )
        try excludeFromBackup(base)
        let values = try base.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
        if let available = values.volumeAvailableCapacityForImportantUsage,
           available < requiredFreeSpaceBytes {
            throw MLXTextGenerationError.insufficientStorage(
                required: requiredFreeSpaceBytes,
                available: available
            )
        }
    }

    nonisolated private static func excludeFromBackup(_ directory: URL) throws {
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        var mutableDirectory = directory
        try mutableDirectory.setResourceValues(values)
    }

    nonisolated private static func productDownloadBase() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("NoteEchoes", isDirectory: true)
            .appendingPathComponent("HuggingFace", isDirectory: true)
    }

    nonisolated private static let productHub = HubApi(
        downloadBase: productDownloadBase(),
        cache: nil,
        // swift-transformers 1.2.0 currently drives downloads through completion
        // handlers, which iOS forbids on a background URLSession. Keep the
        // transfer in the foreground until the package provides a delegate-based
        // background implementation; integrity and immutable-revision checks are
        // unchanged.
        useBackgroundSession: false
    )

    nonisolated private static func productHubDirectory() -> URL {
        ModelConfiguration(
            id: primaryModelID,
            revision: productModelRevision
        ).modelDirectory(hub: productHub)
    }

    nonisolated private static func localProductModelDirectory() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("NoteEchoes", isDirectory: true)
            .appendingPathComponent("Models", isDirectory: true)
            .appendingPathComponent(productModelName, isDirectory: true)
    }
}

enum MLXTextGenerationError: LocalizedError {
    case modelUnavailable
    case integrityFailure(String)
    case insufficientStorage(required: Int64, available: Int64)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "The NoteEchoes English Action model could not be loaded."
        case .integrityFailure(let detail):
            "The downloaded NoteEchoes model failed verification. \(detail) Use Repair Model and try again."
        case .insufficientStorage(let required, let available):
            "At least \(required / 1_000_000_000) GB of free storage is required. This device currently has about \(available / 1_000_000) MB available."
        }
    }
}

// MARK: - MLXTextGenerationChannelService

@MainActor
final class MLXTextGenerationChannelService: NSObject {
    static let shared = MLXTextGenerationChannelService()
    private var methodChannel: FlutterMethodChannel?

    private override init() {
        super.init()
    }

    func register(with controller: FlutterViewController) {
#if os(macOS)
        register(with: controller.engine.binaryMessenger)
#else
        register(with: controller.binaryMessenger)
#endif
    }

    func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "noteechoes/mlx_text_generation",
            binaryMessenger: messenger
        )
        self.methodChannel = channel
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                return result(FlutterError(code: "unavailable", message: nil, details: nil))
            }
            switch call.method {
            case "status":
                result(MLXTextGenerationService.installationStatus())
            case "load":
                Task {
                    do {
                        try await MLXTextGenerationService.shared.load { [weak self] fraction, statusText in
                            DispatchQueue.main.async {
                                self?.methodChannel?.invokeMethod("onMLXDownloadProgress", arguments: [
                                    "progress": fraction,
                                    "statusText": statusText
                                ])
                            }
                        }
                        await MainActor.run { result(true) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "MLX_LOAD_FAILED",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    }
                }
            case "generate":
                guard let arguments = call.arguments as? [String: Any],
                      let prompt = arguments["prompt"] as? String else {
                    result(FlutterError(
                        code: "INVALID_PROMPT",
                        message: "A prompt is required.",
                        details: nil
                    ))
                    return
                }
                let systemPrompt = arguments["systemPrompt"] as? String
                let maxTokens = arguments["maxTokens"] as? Int ?? 600
                let temperature = Float(
                    (arguments["temperature"] as? NSNumber)?.doubleValue ?? 0
                )
                Task {
                    do {
                        let text = try await MLXTextGenerationService.shared.generate(
                            prompt: prompt,
                            systemPrompt: systemPrompt,
                            maxTokens: maxTokens,
                            temperature: temperature
                        )
                        await MainActor.run { result(text) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "MLX_GENERATION_FAILED",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    }
                }
            case "unload":
                Task {
                    await MLXTextGenerationService.shared.unload()
                    await MainActor.run { result(nil) }
                }
            case "cancelDownload":
                Task {
                    await MLXTextGenerationService.shared.cancelDownload()
                    await MainActor.run { result(true) }
                }
            case "deleteCachedModel":
                Task {
                    do {
                        let status = try await MLXTextGenerationService.shared.deleteCachedModel()
                        await MainActor.run { result(status) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "MLX_DELETE_FAILED",
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
}
