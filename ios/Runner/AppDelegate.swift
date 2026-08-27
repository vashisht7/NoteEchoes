import Flutter
import UIKit
import AppIntents
import PDFKit
import UserNotifications
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [
            UIApplication.LaunchOptionsKey: Any
        ]?
    ) -> Bool {
        if #available(iOS 16.0, *) {
            NotechoesShortcuts.updateAppShortcutParameters()
        }

        let launched = super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        let notificationCenter = UNUserNotificationCenter.current()
        ReminderNotificationCoordinator.configure(notificationCenter)
        notificationCenter.delegate = self
        return launched
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if ReminderNotificationCoordinator.handle(
            response,
            completion: completionHandler
        ) {
            return
        }
        super.userNotificationCenter(
            center,
            didReceive: response,
            withCompletionHandler: completionHandler
        )
    }

    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (
            UNNotificationPresentationOptions
        ) -> Void
    ) {
        if notification.request.content.categoryIdentifier ==
            ReminderNotificationCoordinator.categoryIdentifier {
            completionHandler([.banner, .list, .sound, .badge])
            return
        }
        super.userNotificationCenter(
            center,
            willPresent: notification,
            withCompletionHandler: completionHandler
        )
    }

    func didInitializeImplicitFlutterEngine(
        _ engineBridge: FlutterImplicitEngineBridge
    ) {
        let registry = engineBridge.pluginRegistry
        GeneratedPluginRegistrant.register(with: registry)

        if let pdfRegistrar = registry.registrar(
            forPlugin: "NoteEchoesPDFKitView"
        ) {
            pdfRegistrar.register(
                NoteEchoesPDFViewFactory(),
                withId: "noteechoes/pdf_view"
            )
        }

        if let mlxRegistrar = registry.registrar(forPlugin: "NoteEchoesMLX") {
            MLXTextGenerationChannelService.shared.register(with: mlxRegistrar.messenger())
            OfflineSpeechService.shared.register(with: mlxRegistrar.messenger())
        }

        if let speechRegistrar = registry.registrar(
            forPlugin: "NoteEchoesSpeechOutput"
        ) {
            SpeechOutputChannelService.shared.register(
                with: speechRegistrar.messenger()
            )
            if ProcessInfo.processInfo.arguments.contains(
                "--noteechoes-speech-smoke-test"
            ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    SpeechOutputChannelService.shared.runDeviceSmokeTest()
                }
            }
            if ProcessInfo.processInfo.arguments.contains(
                "--noteechoes-speech-language-switch-test"
            ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    SpeechOutputChannelService.shared
                        .runLanguageSwitchSmokeTest()
                }
            }
            if ProcessInfo.processInfo.arguments.contains(
                "--noteechoes-voice-capture-test"
            ) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    SpeechOutputChannelService.shared.runVoiceCaptureSmokeTest()
                }
            }
        }
    }
}

private final class NoteEchoesPDFViewFactory: NSObject,
    FlutterPlatformViewFactory {
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        NoteEchoesPDFPlatformView(frame: frame, arguments: args)
    }
}

private final class NoteEchoesPDFPlatformView: NSObject, FlutterPlatformView {
    private let pdfView: PDFView

    init(frame: CGRect, arguments: Any?) {
        pdfView = PDFView(frame: frame)
        super.init()

        pdfView.backgroundColor = UIColor(
            red: 8.0 / 255.0,
            green: 8.0 / 255.0,
            blue: 8.0 / 255.0,
            alpha: 1
        )
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.displaysPageBreaks = true
        pdfView.pageBreakMargins = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10
        )
        pdfView.usePageViewController(false)

        if let values = arguments as? [String: Any],
           let path = values["path"] as? String,
           let document = PDFDocument(url: URL(fileURLWithPath: path)) {
            pdfView.document = document
            pdfView.autoScales = true
            DispatchQueue.main.async { [weak pdfView] in
                guard let pdfView else { return }
                pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
            }
        }
    }

    func view() -> UIView { pdfView }
}

/// Engine-owned speech bridge. Registering from the implicit Flutter engine
/// avoids the scene timing race that previously caused MissingPluginException.
final class SpeechOutputChannelService: NSObject,
    AVSpeechSynthesizerDelegate {
    static let shared = SpeechOutputChannelService()

    private var channel: FlutterMethodChannel?
    private var synthesizer = AVSpeechSynthesizer()
    private var segmentIndices: [ObjectIdentifier: Int] = [:]
    private var finalSegmentIndex: Int?
    private var pendingStartResult: FlutterResult?
    private var pendingStartResponse: [String: Any]?
    private var startTimeout: DispatchWorkItem?

    private override init() {
        super.init()
        synthesizer.delegate = self
    }

    func register(with messenger: FlutterBinaryMessenger) {
        let speechChannel = FlutterMethodChannel(
            name: "noteechoes/speech_output",
            binaryMessenger: messenger
        )
        channel = speechChannel
        speechChannel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }
    }

    /// Launch-argument diagnostic used to verify real speech on a connected
    /// device without depending on Flutter navigation or a generated report.
    func runDeviceSmokeTest() {
        speak(
            text: "NoteEchoes spoken reports are working.",
            arguments: [
                "language": "en-US",
                "segments": ["NoteEchoes spoken reports are working."],
                "startIndex": 0
            ]
        ) { response in
            print("[NoteEchoesSpeech] smoke result: \(String(describing: response))")
        }
    }

    /// Reproduces the reported Telugu-to-English sequence and proves a fresh
    /// synthesizer can start the new language after interrupting the old one.
    func runLanguageSwitchSmokeTest() {
        speak(
            text: "నోట్ ఎకోస్ తెలుగు వాయిస్ సిద్ధంగా ఉంది.",
            arguments: [
                "language": "te-IN",
                "segments": ["నోట్ ఎకోస్ తెలుగు వాయిస్ సిద్ధంగా ఉంది."],
                "startIndex": 0
            ]
        ) { response in
            print(
                "[NoteEchoesSpeech] Telugu switch test: "
                    + "\(String(describing: response))"
            )
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.speak(
                text: "NoteEchoes switched back to English successfully.",
                arguments: [
                    "language": "en-US",
                    "segments": [
                        "NoteEchoes switched back to English successfully."
                    ],
                    "startIndex": 0
                ]
            ) { response in
                print(
                    "[NoteEchoesSpeech] English switch test: "
                        + "\(String(describing: response))"
                )
            }
        }
    }

    func runVoiceCaptureSmokeTest() {
        do {
            let response = try prepareVoiceCapture()
            print("[NoteEchoesCapture] voice processing: \(response)")
        } catch {
            print("[NoteEchoesCapture] failed: \(error.localizedDescription)")
        }
    }

    private func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "speak":
            guard let arguments = call.arguments as? [String: Any],
                  let text = arguments["text"] as? String,
                  !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                result(FlutterError(
                    code: "INVALID_SPEECH",
                    message: "Text is required.",
                    details: nil
                ))
                return
            }
            speak(text: text, arguments: arguments, result: result)

        case "stop":
            cancelPendingStart(message: "Speech was stopped.")
            resetSynthesizer()
            segmentIndices.removeAll()
            finalSegmentIndex = nil
            result(true)

        case "prepareVoiceCapture":
            do {
                result(try prepareVoiceCapture())
            } catch {
                result(FlutterError(
                    code: "VOICE_CAPTURE_SETUP_FAILED",
                    message: error.localizedDescription,
                    details: nil
                ))
            }

        case "getAvailableVoices":
            result(AVSpeechSynthesisVoice.speechVoices().map { voice in
                [
                    "identifier": voice.identifier,
                    "name": voice.name,
                    "language": voice.language,
                    "quality": qualityName(voice.quality),
                    "gender": voice.gender == .female
                        ? "female"
                        : (voice.gender == .male ? "male" : "unspecified")
                ]
            })

        case "audioStatus":
            let session = AVAudioSession.sharedInstance()
            result([
                "handlerRegistered": true,
                "outputVolume": session.outputVolume,
                "route": outputRoute(session),
                "speaking": synthesizer.isSpeaking,
                "voice": bestInstalledVoice(for: "en-US")?.name
                    ?? "System voice",
                "voiceQuality": qualityName(
                    bestInstalledVoice(for: "en-US")?.quality
                )
            ])

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func prepareVoiceCapture() throws -> [String: Any] {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .voiceChat,
            options: [.defaultToSpeaker, .allowBluetoothHFP]
        )
        try? session.setPreferredSampleRate(16_000)
        try? session.setPreferredIOBufferDuration(0.02)
        try session.setActive(true, options: [])
        return [
            "voiceProcessing": session.mode == .voiceChat,
            "mode": session.mode.rawValue,
            "input": session.currentRoute.inputs.first?.portName
                ?? "iPhone microphone"
        ]
    }

    private func speak(
        text: String,
        arguments: [String: Any],
        result: @escaping FlutterResult
    ) {
        cancelPendingStart(message: "A newer spoken report replaced this one.")
        resetSynthesizer()
        segmentIndices.removeAll()
        finalSegmentIndex = nil

        do {
            let session = AVAudioSession.sharedInstance()
            try? session.setActive(false, options: [.notifyOthersOnDeactivation])
            // Output-only spoken playback uses the speaker by default, follows
            // AirPods when connected, and is not suppressed by silent mode.
            try session.setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers]
            )
            try session.setActive(true, options: [])

            let language = arguments["language"] as? String ?? "en-US"
            let voice = bestInstalledVoice(
                for: language,
                identifier: arguments["voiceIdentifier"] as? String
            )
            let supplied = arguments["segments"] as? [String]
            let segments = (supplied ?? naturalSegments(from: text)).filter {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            guard !segments.isEmpty else {
                result(FlutterError(
                    code: "EMPTY_SPEECH",
                    message: "The generated report had no readable text.",
                    details: nil
                ))
                return
            }

            let startIndex = arguments["startIndex"] as? Int ?? 0
            finalSegmentIndex = startIndex + segments.count - 1
            pendingStartResult = result
            pendingStartResponse = [
                "started": true,
                "voice": voice?.name ?? "System voice",
                "voiceIdentifier": voice?.identifier ?? "",
                "quality": qualityName(voice?.quality),
                "route": outputRoute(session),
                "outputVolume": session.outputVolume
            ]

            let rate = arguments["rate"] as? Double ?? 0.88
            let pitch = arguments["pitch"] as? Double ?? 0.98
            for (offset, segment) in segments.enumerated() {
                let utterance = AVSpeechUtterance(string: segment)
                segmentIndices[ObjectIdentifier(utterance)] = startIndex + offset
                utterance.voice = voice
                utterance.rate = Float(AVSpeechUtteranceDefaultSpeechRate)
                    * Float(rate)
                utterance.pitchMultiplier = Float(pitch)
                utterance.volume = 1.0
                utterance.preUtteranceDelay = offset == 0 ? 0.05 : 0.08
                utterance.postUtteranceDelay = 0.04
                synthesizer.speak(utterance)
            }

            let timeout = DispatchWorkItem { [weak self] in
                guard let self, let pending = self.pendingStartResult else {
                    return
                }
                self.pendingStartResult = nil
                self.pendingStartResponse = nil
                self.synthesizer.stopSpeaking(at: .immediate)
                pending(FlutterError(
                    code: "SPEECH_DID_NOT_START",
                    message: "iOS did not start spoken playback.",
                    details: ["route": self.outputRoute(session)]
                ))
            }
            startTimeout = timeout
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 5.0,
                execute: timeout
            )
        } catch {
            pendingStartResult = nil
            pendingStartResponse = nil
            result(FlutterError(
                code: "SPEECH_OUTPUT_FAILED",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        guard let index = segmentIndices[ObjectIdentifier(utterance)] else {
            return
        }
        print(
            "[NoteEchoesSpeech] didStart index=\(index) "
                + "route=\(outputRoute(AVAudioSession.sharedInstance()))"
        )
        if let pending = pendingStartResult {
            startTimeout?.cancel()
            startTimeout = nil
            pendingStartResult = nil
            let response = pendingStartResponse ?? ["started": true]
            pendingStartResponse = nil
            pending(response)
        }
        channel?.invokeMethod(
            "onSpeechSegment",
            arguments: ["index": index]
        )
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        let identifier = ObjectIdentifier(utterance)
        guard let index = segmentIndices.removeValue(forKey: identifier) else {
            return
        }
        if index == finalSegmentIndex {
            finalSegmentIndex = nil
            channel?.invokeMethod("onSpeechFinished", arguments: nil)
            try? AVAudioSession.sharedInstance().setActive(
                false,
                options: [.notifyOthersOnDeactivation]
            )
        }
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        segmentIndices.removeValue(forKey: ObjectIdentifier(utterance))
    }

    private func cancelPendingStart(message: String) {
        startTimeout?.cancel()
        startTimeout = nil
        if let pending = pendingStartResult {
            pendingStartResult = nil
            pendingStartResponse = nil
            pending(FlutterError(
                code: "SPEECH_REPLACED",
                message: message,
                details: nil
            ))
        }
    }

    /// AVSpeechSynthesizer can remain wedged after a recording category or
    /// voice-language transition. A fresh instance per request reliably
    /// releases that stale queue while keeping one Flutter channel owner.
    private func resetSynthesizer() {
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.delegate = nil
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
    }

    private func outputRoute(_ session: AVAudioSession) -> String {
        session.currentRoute.outputs.first?.portName ?? "iPhone speaker"
    }

    private func bestInstalledVoice(
        for requestedLanguage: String,
        identifier: String? = nil
    ) -> AVSpeechSynthesisVoice? {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        if let identifier,
           let selected = voices.first(where: { $0.identifier == identifier }) {
            return selected
        }
        let normalized = requestedLanguage.lowercased()
        let languageCode = normalized.split(separator: "-").first.map(String.init)
            ?? normalized
        let matching = voices.filter {
            let candidate = $0.language.lowercased()
            return candidate == normalized
                || candidate.hasPrefix("\(languageCode)-")
        }
        return matching.sorted {
            if $0.quality.rawValue != $1.quality.rawValue {
                return $0.quality.rawValue > $1.quality.rawValue
            }
            return $0.language.lowercased() == normalized
        }.first ?? AVSpeechSynthesisVoice(language: requestedLanguage)
    }

    private func naturalSegments(from text: String) -> [String] {
        var segments: [String] = []
        text.enumerateSubstrings(
            in: text.startIndex..<text.endIndex,
            options: [.bySentences, .substringNotRequired]
        ) { _, range, _, _ in
            let sentence = text[range]
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !sentence.isEmpty { segments.append(sentence) }
        }
        return segments.isEmpty ? [text] : segments
    }

    private func qualityName(
        _ quality: AVSpeechSynthesisVoiceQuality?
    ) -> String {
        switch quality {
        case .premium: return "Premium"
        case .enhanced: return "Enhanced"
        default: return "Standard"
        }
    }
}
