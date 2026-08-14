import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    private let actionChannelName =
        "com.vashisht.notechoes/action_button"

    private let legacyPendingNotesKey =
        "notechoes_pending_voice_notes"

    private var sharedDefaults: UserDefaults { SharedDefaults.suite }

    private var actionChannel: FlutterMethodChannel?
    private var mlxChannel: FlutterMethodChannel?
    private var pdfVisionChannel: FlutterMethodChannel?

    override func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        super.scene(
            scene,
            willConnectTo: session,
            options: connectionOptions
        )

        configureActionChannel(for: scene)

        for context in connectionOptions.urlContexts {
            handleIncomingURL(context.url)
        }
    }

    override func sceneDidBecomeActive(_ scene: UIScene) {
        super.sceneDidBecomeActive(scene)
        // During willConnect the storyboard may not have attached Flutter's
        // controller yet. Retry here so the Dart queue bridge is never absent.
        configureActionChannel(for: scene)
    }

    override func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        for context in URLContexts {
            handleIncomingURL(context.url)
        }

        super.scene(scene, openURLContexts: URLContexts)
    }

    private func configureActionChannel(for scene: UIScene) {
        guard actionChannel == nil else { return }
        guard
            let windowScene = scene as? UIWindowScene,
            let flutterViewController = windowScene.windows
                .compactMap({ $0.rootViewController as? FlutterViewController })
                .first
        else {
            NSLog("notechoes: FlutterViewController unavailable")
            return
        }

        let channel = FlutterMethodChannel(
            name: actionChannelName,
            binaryMessenger: flutterViewController.binaryMessenger
        )

        actionChannel = channel

        let mlxChannel = FlutterMethodChannel(
            name: "notechoes/mlx_text_generation",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        self.mlxChannel = mlxChannel
        mlxChannel.setMethodCallHandler { call, result in
            Self.handleMLXMethodCall(call, result: result)
        }

        let pdfVisionChannel = FlutterMethodChannel(
            name: "notechoes/pdf_vision",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        self.pdfVisionChannel = pdfVisionChannel
        pdfVisionChannel.setMethodCallHandler { call, result in
            guard call.method == "extractPages",
                  let arguments = call.arguments as? [String: Any],
                  let path = arguments["path"] as? String else {
                result(FlutterMethodNotImplemented)
                return
            }
            Task {
                do {
                    let pages = try await PDFVisionExtractionService.extractPages(
                        at: path
                    )
                    await MainActor.run { result(pages) }
                } catch {
                    await MainActor.run {
                        result(FlutterError(
                            code: "PDF_VISION_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }
        }

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterMethodNotImplemented)
                return
            }

            self.handleMethodCall(call, result: result)
        }
    }

    private static func handleMLXMethodCall(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "load":
            Task {
                do {
                    try await MLXTextGenerationService.shared.load()
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleMethodCall(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "peekPendingActionButtonNote":
            Task {
                do {
                    let pending = try await PendingVoiceNoteStore.shared
                        .peek()

                    guard let pending else {
                        await MainActor.run { result(nil) }
                        return
                    }

                    await MainActor.run {
                        result([
                            "id": pending.id,
                            "text": pending.text,
                            "createdAt": pending.createdAt,
                            "source": pending.source
                        ])
                    }
                } catch {
                    await MainActor.run {
                        result(FlutterError(
                            code: "PENDING_QUEUE_READ_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }

        case "acknowledgePendingActionButtonNote":
            guard
                let arguments = call.arguments as? [String: Any],
                let id = arguments["id"] as? String
            else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "A pending note ID is required.",
                    details: nil
                ))
                return
            }

            Task {
                do {
                    try await PendingVoiceNoteStore.shared
                        .acknowledge(id: id)

                    await MainActor.run { result(nil) }
                } catch {
                    await MainActor.run {
                        result(FlutterError(
                            code: "ACKNOWLEDGE_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }

        case "getPendingVoiceNotes":
            let notes = sharedDefaults.stringArray(
                forKey: legacyPendingNotesKey
            ) ?? []

            sharedDefaults.removeObject(
                forKey: legacyPendingNotesKey
            )

            result(notes)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    /// Only handles `notechoes://save?text=...` URLs for direct note
    /// saving.  The `notechoes://record` URL that previously opened
    /// the in-app recorder has been removed — the Action Button now
    /// uses the headless SaveDictatedNoteIntent Shortcut instead,
    /// which never opens the app.
    private func handleIncomingURL(_ url: URL) {
        let urlString = url.absoluteString

        if url.host == "save" || urlString.contains("save") {
            let extractedText = extractText(from: url)

            guard !extractedText.isEmpty else { return }

            Task {
                do {
                    _ = try await PendingVoiceNoteStore.shared.append(
                        text: extractedText
                    )
                    await MainActor.run {
                        self.actionChannel?.invokeMethod(
                            "onPendingActionButtonNote",
                            arguments: nil
                        )
                    }
                } catch {
                    NSLog("notechoes: URL note queue failed: \(error)")
                }
            }
        }
        // NOTE: `notechoes://record` URL handling has been intentionally
        // removed. The Action Button should use the Shortcuts-based
        // SaveDictatedNoteIntent flow which never opens the app.
    }

    private func extractText(from url: URL) -> String {
        if
            let components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            ),
            let value = components.queryItems?
                .first(where: { $0.name == "text" })?.value
        {
            return value.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
        }

        return ""
    }
}
