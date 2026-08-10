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
    let controller = window?.rootViewController as? FlutterViewController
    guard let messenger = controller?.binaryMessenger else { return }
    let channel = FlutterMethodChannel(name: "com.vashisht.notechoes/action_button", binaryMessenger: messenger)

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

      channel.invokeMethod("onSaveVoiceNote", arguments: ["text": extractedText])
    } else if urlString.contains("record") {
      channel.invokeMethod("onTriggerSiriOverlay", arguments: nil)
    }
  }
}
