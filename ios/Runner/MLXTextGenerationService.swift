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
}

enum MLXTextGenerationError: LocalizedError {
    case modelUnavailable

    var errorDescription: String? {
        "The local MLX language model could not be loaded."
    }
}
