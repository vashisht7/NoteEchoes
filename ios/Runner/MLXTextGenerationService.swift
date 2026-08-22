import Foundation
import MLX
import MLXLLM
import MLXLMCommon

/// One shared MLX container keeps Metal memory predictable across note and PDF
/// requests. Model files are downloaded by the Hugging Face integration into
/// Application Support / Caches on first load, so they do not inflate the App Store IPA.
actor MLXTextGenerationService {
    static let shared = MLXTextGenerationService()

    static let primaryModelID = "mlx-community/Qwen2.5-0.5B-Instruct-4bit"
    static let alternateModelIDs = [
        "mlx-community/Qwen3-0.6B-4bit",
        "mlx-community/SmolLM2-360M-Instruct-4bit",
        "mlx-community/Qwen2.5-1.5B-Instruct-4bit"
    ]

    private var container: ModelContainer?
    private var isDownloading: Bool = false

    var isLoaded: Bool {
        return container != nil
    }

    nonisolated static func installationStatus() -> [String: Any] {
        let allIDs = [primaryModelID] + alternateModelIDs

        // 1. Check primary configuration path
        let configuration = ModelConfiguration(id: primaryModelID)
        let defaultDir = configuration.modelDirectory(hub: defaultHubApi)
        let defaultStatus = inspectCache(at: defaultDir)
        if defaultStatus["verified"] as? Bool == true {
            return defaultStatus
        }

        // 2. Check all alternate model ID directories
        for id in alternateModelIDs {
            let altConfig = ModelConfiguration(id: id)
            let altDir = altConfig.modelDirectory(hub: defaultHubApi)
            let status = inspectCache(at: altDir)
            if status["verified"] as? Bool == true {
                return status
            }
        }

        // 3. Search common application directories (Documents, Application Support, Caches)
        let manager = FileManager.default
        var alternateRoots: [URL] = []

        let candidateNames = [
            "Qwen2.5-0.5B-Instruct-4bit",
            "Qwen3-0.6B-4bit",
            "models--mlx-community--Qwen2.5-0.5B-Instruct-4bit",
            "models--mlx-community--Qwen3-0.6B-4bit",
            "SmolLM2-360M-Instruct-4bit"
        ]

        if let docs = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            for name in candidateNames {
                alternateRoots.append(docs.appendingPathComponent("huggingface/models/mlx-community/\(name)"))
                alternateRoots.append(docs.appendingPathComponent("huggingface/hub/\(name)"))
                alternateRoots.append(docs.appendingPathComponent("models/\(name)"))
                alternateRoots.append(docs.appendingPathComponent(name))
            }
        }
        if let appSupport = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            for name in candidateNames {
                alternateRoots.append(appSupport.appendingPathComponent("huggingface/models/mlx-community/\(name)"))
                alternateRoots.append(appSupport.appendingPathComponent("huggingface/hub/\(name)"))
                alternateRoots.append(appSupport.appendingPathComponent("models/\(name)"))
                alternateRoots.append(appSupport.appendingPathComponent(name))
            }
        }
        if let caches = manager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            for name in candidateNames {
                alternateRoots.append(caches.appendingPathComponent("huggingface/models/mlx-community/\(name)"))
                alternateRoots.append(caches.appendingPathComponent("huggingface/hub/\(name)"))
                alternateRoots.append(caches.appendingPathComponent("models/\(name)"))
                alternateRoots.append(caches.appendingPathComponent(name))
            }
        }

        for alt in alternateRoots {
            let status = inspectCache(at: alt)
            if status["verified"] as? Bool == true {
                return status
            }
        }

        return defaultStatus
    }

    func load(onProgress: (@Sendable (Double, String) -> Void)? = nil) async throws {
        if container != nil { return }
        Memory.cacheLimit = 20 * 1024 * 1024

        // Try primary model ID first, fall back to alternate ID if not found
        let candidateIDs = [Self.primaryModelID] + Self.alternateModelIDs

        var lastError: Error?
        for modelID in candidateIDs {
            do {
                let configuration = ModelConfiguration(id: modelID)
                let loaded = try await LLMModelFactory.shared.loadContainer(
                    configuration: configuration
                ) { progress in
                    let fraction = progress.fractionCompleted
                    let percent = Int(fraction * 100)
                    onProgress?(fraction, "Downloading local model (\(percent)%)…")
                }
                self.container = loaded
                return
            } catch {
                lastError = error
                NSLog("[MLXTextGenerationService] Model \(modelID) load attempt error: \(error.localizedDescription)")
            }
        }

        if let error = lastError {
            throw error
        }
    }

    func generate(prompt: String, systemPrompt: String?) async throws -> String {
        try await load()
        guard let container else {
            throw MLXTextGenerationError.modelUnavailable
        }

        let session = ChatSession(
            container,
            instructions: systemPrompt,
            generateParameters: GenerateParameters(
                maxTokens: 600,
                temperature: 0.2
            )
        )
        return try await session.respond(to: prompt)
    }

    func unload() {
        container = nil
        Memory.clearCache()
    }

    func deleteCachedModel() throws -> [String: Any] {
        unload()
        let configuration = ModelConfiguration(id: Self.primaryModelID)
        let directory = configuration.modelDirectory(hub: defaultHubApi)
        if FileManager.default.fileExists(atPath: directory.path) {
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

        var names = Set<String>()
        var extensions = Set<String>()
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
                names.insert(url.lastPathComponent)
                extensions.insert(url.pathExtension.lowercased())
                sizeBytes += Int64(values.fileSize ?? 0)
            }
        }
        let hasWeights = extensions.contains("safetensors") || extensions.contains("bin") || extensions.contains("gguf") || names.contains("weights.safetensors") || names.contains("model.safetensors")
        let hasConfig = names.contains("config.json") || names.contains("params.json") || names.contains("tokenizer.json") || names.contains("tokenizer_config.json")
        let verified = (hasWeights || sizeBytes > 40 * 1024 * 1024) && sizeBytes > 0
        return [
            "installed": sizeBytes > 0,
            "verified": verified,
            "path": directory.path,
            "sizeBytes": sizeBytes,
            "reason": verified ? "" : (sizeBytes > 0 ? "Model download in progress or incomplete." : "Model files are not downloaded.")
        ]
    }
}

enum MLXTextGenerationError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        "The local MLX language model could not be loaded."
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
        register(with: controller.binaryMessenger)
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
                Task {
                    do {
                        let text = try await MLXTextGenerationService.shared.generate(
                            prompt: prompt,
                            systemPrompt: systemPrompt
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
