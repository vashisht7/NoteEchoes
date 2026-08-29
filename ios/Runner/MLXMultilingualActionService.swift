import Foundation
import CryptoKit
#if os(macOS)
import FlutterMacOS
#else
import Flutter
#endif
import MLX
import MLXLLM
import MLXLMCommon

/// Loads the private multilingual action runtime bundled by the developer.
///
/// The model is copied into the signed app at build time. No Hugging Face token
/// or private download credential is present on the phone.
actor MLXMultilingualActionService {
    static let shared = MLXMultilingualActionService()

    static let modelName = "noteechoes-multilingual-action-qwen3-0.6b-mlx-8bit"
    static let repositoryRevision = "4620ecb38c23d4b15d3da5c6c9762b72a5a701e7"
    static let bundleFolderName = "NoteEchoesMultilingualAction"
    static let expectedRuntimeBytes: Int64 = 644_921_794
    static let requiredFiles: [(name: String, size: Int64, sha256: String)] = [
        ("README.md", 818, "1eade581cded43b5dc816f918d1ac1314ed9abd06f538fb50cd9073a36d6a9c4"),
        ("chat_template.jinja", 4_116, "87a2728cb8dc9fe424d624542f6060ec05a1d285ebbec578bb078900e33396b5"),
        ("config.json", 989, "b89ddbb1a113d393154f56a0431fbc5d1d09f3509e333d16552e7fe11e1a0d1c"),
        ("model.safetensors", 633_443_038, "80dbb40b0cb6273e4f841ce89753aebb9d78ab90690d6cdd07f320e6011c46e7"),
        ("model.safetensors.index.json", 49_770, "9e9d09d5f0eb73a33663314f68b24dd91d33e245ca3af15daed8e69b5adff982"),
        ("tokenizer.json", 11_422_650, "be75606093db2094d7cd20f3c2f385c212750648bd6ea4fb2bf507a6a4c55506"),
        ("tokenizer_config.json", 413, "d93ac1a2c7adb9ad022f354d822f1f0f57e32e62ef2989e902782d6ab896acfe")
    ]

    private var container: ModelContainer?
    private var integrityVerified = false

    nonisolated static func installationStatus() -> [String: Any] {
        guard let directory = bundledModelDirectory() else {
            return [
                "installed": false,
                "verified": false,
                "bundled": true,
                "sizeBytes": Int64(0),
                "expectedSizeBytes": expectedRuntimeBytes,
                "revision": repositoryRevision,
                "reason": "The private multilingual model was not provisioned before building the app."
            ]
        }
        let missing = requiredFiles.compactMap { expected -> String? in
            let file = directory.appendingPathComponent(expected.name)
            guard FileManager.default.fileExists(atPath: file.path),
                  let values = try? file.resourceValues(forKeys: [.fileSizeKey]),
                  Int64(values.fileSize ?? -1) == expected.size else {
                return expected.name
            }
            return nil
        }
        let complete = missing.isEmpty
        return [
            "installed": complete,
            // The app bundle is code signed. Full SHA-256 verification is also
            // performed before the first model load.
            "verified": complete,
            "bundled": true,
            "sizeBytes": complete ? expectedRuntimeBytes : Int64(0),
            "expectedSizeBytes": expectedRuntimeBytes,
            "revision": repositoryRevision,
            "missingComponents": missing,
            "reason": complete ? "" : "The bundled multilingual model is incomplete. Re-run the provisioning script and rebuild."
        ]
    }

    func load() async throws {
        if container != nil { return }
        guard let directory = Self.bundledModelDirectory() else {
            throw MLXMultilingualActionError.modelUnavailable
        }

        // The English and multilingual 0.6B models never occupy Metal memory
        // together. Switching recognition language unloads the previous brain.
        await MLXTextGenerationService.shared.unload()
        Memory.cacheLimit = 20 * 1_024 * 1_024
        if !integrityVerified {
            try Self.verify(directory: directory)
            integrityVerified = true
        }
        container = try await LLMModelFactory.shared.loadContainer(
            configuration: ModelConfiguration(directory: directory)
        )
    }

    func generate(
        prompt: String,
        systemPrompt: String?,
        maxTokens: Int = 300,
        temperature: Float = 0
    ) async throws -> String {
        try await load()
        guard let container else {
            throw MLXMultilingualActionError.modelUnavailable
        }
        let session = ChatSession(
            container,
            instructions: systemPrompt,
            generateParameters: GenerateParameters(
                maxTokens: min(max(maxTokens, 1), 512),
                temperature: min(max(temperature, 0), 1)
            )
        )
        return try await session.respond(to: prompt)
    }

    func unload() {
        container = nil
        Memory.clearCache()
    }

    nonisolated private static func bundledModelDirectory() -> URL? {
        guard let directory = Bundle.main.resourceURL?
            .appendingPathComponent(bundleFolderName, isDirectory: true),
              FileManager.default.fileExists(atPath: directory.path) else {
            return nil
        }
        return directory
    }

    nonisolated private static func verify(directory: URL) throws {
        for expected in requiredFiles {
            let file = directory.appendingPathComponent(expected.name)
            guard FileManager.default.fileExists(atPath: file.path) else {
                throw MLXMultilingualActionError.integrityFailure("Missing \(expected.name).")
            }
            let values = try file.resourceValues(forKeys: [.fileSizeKey])
            guard Int64(values.fileSize ?? -1) == expected.size else {
                throw MLXMultilingualActionError.integrityFailure("Unexpected size for \(expected.name).")
            }
            guard try sha256(of: file) == expected.sha256 else {
                throw MLXMultilingualActionError.integrityFailure("SHA-256 mismatch for \(expected.name).")
            }
        }
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
}

enum MLXMultilingualActionError: LocalizedError {
    case modelUnavailable
    case integrityFailure(String)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            "The private multilingual action model is not bundled in this build."
        case .integrityFailure(let detail):
            "The private multilingual action model failed verification. \(detail)"
        }
    }
}

@MainActor
final class MLXMultilingualActionChannelService: NSObject {
    static let shared = MLXMultilingualActionChannelService()
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
            name: "noteechoes/mlx_multilingual_action",
            binaryMessenger: messenger
        )
        methodChannel = channel
        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "status":
                result(MLXMultilingualActionService.installationStatus())
            case "load":
                Task {
                    do {
                        try await MLXMultilingualActionService.shared.load()
                        await MainActor.run { result(true) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "MULTILINGUAL_MLX_LOAD_FAILED",
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
                let maxTokens = arguments["maxTokens"] as? Int ?? 300
                let temperature = Float(
                    (arguments["temperature"] as? NSNumber)?.doubleValue ?? 0
                )
                Task {
                    do {
                        let text = try await MLXMultilingualActionService.shared.generate(
                            prompt: prompt,
                            systemPrompt: systemPrompt,
                            maxTokens: maxTokens,
                            temperature: temperature
                        )
                        await MainActor.run { result(text) }
                    } catch {
                        await MainActor.run {
                            result(FlutterError(
                                code: "MULTILINGUAL_MLX_GENERATION_FAILED",
                                message: error.localizedDescription,
                                details: nil
                            ))
                        }
                    }
                }
            case "unload":
                Task {
                    await MLXMultilingualActionService.shared.unload()
                    await MainActor.run { result(nil) }
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
}
