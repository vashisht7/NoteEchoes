import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let actionChannelName = "com.vashisht.notechoes/action_button"
  private let pendingNotesKey = "notechoes_pending_voice_notes"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let channel = FlutterMethodChannel(name: actionChannelName, binaryMessenger: messenger)
      channel.setMethodCallHandler { [weak self] (call, result) in
        guard let self = self else { return }
        if call.method == "getPendingVoiceNotes" {
          let notes = UserDefaults.standard.stringArray(forKey: self.pendingNotesKey) ?? []
          UserDefaults.standard.removeObject(forKey: self.pendingNotesKey)
          result(notes)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Check if launched with URL
    if let url = launchOptions?[.url] as? URL {
      handleIncomingUrl(url)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    handleIncomingUrl(url)
    return super.application(app, open: url, options: options)
  }

  private func handleIncomingUrl(_ url: URL) {
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

      if !extractedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        // 1. Always queue into UserDefaults so it's guaranteed to be read even on cold start
        var current = UserDefaults.standard.stringArray(forKey: pendingNotesKey) ?? []
        current.append(extractedText)
        UserDefaults.standard.set(current, forKey: pendingNotesKey)

        // 2. Also notify MethodChannel if app is active
        if let controller = window?.rootViewController as? FlutterViewController {
          let channel = FlutterMethodChannel(name: actionChannelName, binaryMessenger: controller.binaryMessenger)
          channel.invokeMethod("onSaveVoiceNote", arguments: ["text": extractedText])
        }
      }
    } else if urlString.contains("record") {
      if let controller = window?.rootViewController as? FlutterViewController {
        let channel = FlutterMethodChannel(name: actionChannelName, binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("onTriggerSiriOverlay", arguments: nil)
      }
    }
  }
}
