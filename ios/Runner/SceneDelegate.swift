import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
    private let actionChannelName =
        "com.vashisht.notechoes/action_button"

    private let legacyPendingNotesKey =
        "notechoes_pending_voice_notes"

    private var actionChannel: FlutterMethodChannel?

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
        guard
            let windowScene = scene as? UIWindowScene,
            let flutterViewController = windowScene.windows
                .first?.rootViewController as? FlutterViewController
        else {
            NSLog("notechoes: FlutterViewController unavailable")
            return
        }

        let channel = FlutterMethodChannel(
            name: actionChannelName,
            binaryMessenger: flutterViewController.binaryMessenger
        )

        actionChannel = channel

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterMethodNotImplemented)
                return
            }

            self.handleMethodCall(call, result: result)
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
            let notes = UserDefaults.standard.stringArray(
                forKey: legacyPendingNotesKey
            ) ?? []

            UserDefaults.standard.removeObject(
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

            var current = UserDefaults.standard.stringArray(
                forKey: legacyPendingNotesKey
            ) ?? []

            current.append(extractedText)

            UserDefaults.standard.set(
                current,
                forKey: legacyPendingNotesKey
            )

            actionChannel?.invokeMethod(
                "onSaveVoiceNote",
                arguments: ["text": extractedText]
            )
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
