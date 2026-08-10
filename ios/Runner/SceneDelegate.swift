import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private let actionChannelName = "com.vashisht.notechoes/action_button"
  private let pendingNotesKey = "notechoes_pending_voice_notes"

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }
    handleIncomingUrl(url, scene: scene)
    super.scene(scene, openURLContexts: URLContexts)
  }

  private func handleIncomingUrl(_ url: URL, scene: UIScene) {
    let urlString = url.absoluteString

    if urlString.contains("save") {
      var extractedText = ""
      if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
         let queryItem = components.queryItems?.first(where: { $0.name == "text" }),
         let val = queryItem.value {
        extractedText = val
      } else if let range = urlString.range(of: "text=") {
        let rawParam = String(urlString[range.upperBound...])
        extractedText = rawParam.removingPercentEncoding ?? rawParam
      }

      let trimmed = extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmed.isEmpty {
        // 1. Queue into UserDefaults so it is 100% saved even if Flutter is initializing
        var current = UserDefaults.standard.stringArray(forKey: pendingNotesKey) ?? []
        current.append(trimmed)
        UserDefaults.standard.set(current, forKey: pendingNotesKey)

        // 2. Notify Flutter MethodChannel
        if let windowScene = scene as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(name: actionChannelName, binaryMessenger: rootVC.binaryMessenger)
          channel.invokeMethod("onSaveVoiceNote", arguments: ["text": trimmed])
        }
      }
    } else if urlString.contains("record") {
      if let windowScene = scene as? UIWindowScene,
         let rootVC = windowScene.windows.first?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: actionChannelName, binaryMessenger: rootVC.binaryMessenger)
        channel.invokeMethod("onTriggerSiriOverlay", arguments: nil)
      }
    }
  }
}
