import Flutter
import UIKit
import AppIntents

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication.LaunchOptionsKey: Any
        ]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        if #available(iOS 16.0, *) {
            NotechoesShortcuts.updateAppShortcutParameters()
        }

        let launched = super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )

        if let controller = window?.rootViewController as? FlutterViewController {
            OfflineSpeechService.shared.register(with: controller)
        }

        return launched
    }
}
