import Foundation
import MLX
import MLXLLM
import MLXLMCommon

/// One shared MLX container keeps Metal memory predictable across note and PDF
/// requests. Model files are downloaded by the Hugging Face integration into
/// Application Support on first load, so they do not inflate the App Store IPA.
actor MLXTextGenerationService {
    static let shared = MLXTextGenerationService()

    static let modelID = "mlx-community/Qwen3-0.6B-4bit"
    private var container: ModelContainer?

    nonisolated static func installationStatus() -> [String: Any] {
        let configuration = ModelConfiguration(id: modelID)
        let directory = configuration.modelDirectory(hub: defaultHubApi)
        return inspectCache(at: directory)
    }

    func load() async throws {
        guard container == nil else { return }
        Memory.cacheLimit = 20 * 1024 * 1024
        let configuration = ModelConfiguration(id: Self.modelID)
        container = try await LLMModelFactory.shared.loadContainer(
            configuration: configuration
        ) { progress in
            NSLog(
                "notechoes: MLX model download %.0f%%",
                progress.fractionCompleted * 100
            )
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
        let configuration = ModelConfiguration(id: Self.modelID)
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
        let verified = names.contains("config.json")
            && names.contains("tokenizer_config.json")
            && extensions.contains("safetensors")
            && sizeBytes > 0
        return [
            "installed": sizeBytes > 0,
            "verified": verified,
            "path": directory.path,
            "sizeBytes": sizeBytes,
            "reason": verified ? "" : "The model cache is incomplete. Remove it and download it again."
        ]
    }
}

enum MLXTextGenerationError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        "The local MLX language model could not be loaded."
    }
}
