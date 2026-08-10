import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
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
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }

    let controller = window?.rootViewController as? FlutterViewController
    guard let messenger = controller?.binaryMessenger else { return }
    let channel = FlutterMethodChannel(name: "com.vashisht.notechoes/action_button", binaryMessenger: messenger)

    if components.host == "save" || url.absoluteString.contains("save") {
      let queryItem = components.queryItems?.first(where: { $0.name == "text" })
      let text = queryItem?.value ?? ""
      channel.invokeMethod("onSaveVoiceNote", arguments: ["text": text])
    } else if components.host == "record-overlay" || url.absoluteString.contains("record") {
      channel.invokeMethod("onTriggerSiriOverlay", arguments: nil)
    }
  }
}
