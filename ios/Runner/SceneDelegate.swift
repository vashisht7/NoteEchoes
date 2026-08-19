import Flutter
import UIKit
import AVFoundation
import EventKit

class SceneDelegate: FlutterSceneDelegate, AVSpeechSynthesizerDelegate {
    private let actionChannelName =
        "com.vashisht.notechoes/action_button"

    private let legacyPendingNotesKey =
        "notechoes_pending_voice_notes"

    private var sharedDefaults: UserDefaults { SharedDefaults.suite }

    private var actionChannel: FlutterMethodChannel?
    private var mlxChannel: FlutterMethodChannel?
    private var pdfVisionChannel: FlutterMethodChannel?
    private var speechOutputChannel: FlutterMethodChannel?
    private var noteBackupChannel: FlutterMethodChannel?
    private var isChannelRetryScheduled = false
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var speechSegmentIndices: [ObjectIdentifier: Int] = [:]
    private var finalSpeechSegmentIndex: Int?

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
                .compactMap({ findFlutterViewController(in: $0.rootViewController) })
                .first
        else {
            if !isChannelRetryScheduled {
                isChannelRetryScheduled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self, weak scene] in
                    guard let self, let scene else { return }
                    self.isChannelRetryScheduled = false
                    self.configureActionChannel(for: scene)
                }
            }
            return
        }
        isChannelRetryScheduled = false

        let channel = FlutterMethodChannel(
            name: actionChannelName,
            binaryMessenger: flutterViewController.binaryMessenger
        )

        actionChannel = channel
        OfflineSpeechService.shared.register(with: flutterViewController)

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
            guard let arguments = call.arguments as? [String: Any],
                  let path = arguments["path"] as? String else {
                result(FlutterMethodNotImplemented)
                return
            }
            switch call.method {
            case "extractPages":
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
            case "renderFirstPage":
                do {
                    let data = try PDFVisionExtractionService.renderFirstPage(
                        at: path
                    )
                    result(FlutterStandardTypedData(bytes: data))
                } catch {
                    result(FlutterError(
                        code: "PDF_RENDER_FAILED",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        let speechOutputChannel = FlutterMethodChannel(
            name: "notechoes/speech_output",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        self.speechOutputChannel = speechOutputChannel
        speechSynthesizer.delegate = self
        speechOutputChannel.setMethodCallHandler { [weak self] call, result in
            self?.handleSpeechOutput(call, result: result)
        }

        let noteBackupChannel = FlutterMethodChannel(
            name: "notechoes/note_backup",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        self.noteBackupChannel = noteBackupChannel
        noteBackupChannel.setMethodCallHandler { call, result in
            Self.handleNoteBackup(call, result: result)
        }

        let calendarChannel = FlutterMethodChannel(
            name: "notechoes/calendar",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        calendarChannel.setMethodCallHandler { call, result in
            Self.handleCalendar(call, result: result)
        }

        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterMethodNotImplemented)
                return
            }

            self.handleMethodCall(call, result: result)
        }
    }

    private func findFlutterViewController(
        in controller: UIViewController?
    ) -> FlutterViewController? {
        guard let controller else { return nil }
        if let flutter = controller as? FlutterViewController {
            return flutter
        }
        if let navigation = controller as? UINavigationController {
            for child in navigation.viewControllers {
                if let flutter = findFlutterViewController(in: child) {
                    return flutter
                }
            }
        }
        if let tab = controller as? UITabBarController {
            for child in tab.viewControllers ?? [] {
                if let flutter = findFlutterViewController(in: child) {
                    return flutter
                }
            }
        }
        for child in controller.children {
            if let flutter = findFlutterViewController(in: child) {
                return flutter
            }
        }
        return findFlutterViewController(in: controller.presentedViewController)
    }

    private static func handleNoteBackup(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        let defaultsKey = "notechoes_notes_recovery_backup_v1"
        let fileName = "notechoes_notes_recovery_backup_v1.json"
        let defaults = SharedDefaults.suite
        let fileURL = SharedDefaults.sharedContainerURL?
            .appendingPathComponent(fileName)

        switch call.method {
        case "readBackup":
            if let fileURL,
               let data = try? Data(contentsOf: fileURL),
               let payload = String(data: data, encoding: .utf8),
               !payload.isEmpty {
                result(payload)
                return
            }
            result(defaults.string(forKey: defaultsKey))

        case "writeBackup":
            guard let payload = call.arguments as? String else {
                result(FlutterError(
                    code: "INVALID_BACKUP",
                    message: "A JSON note backup is required.",
                    details: nil
                ))
                return
            }
            do {
                if let fileURL {
                    try payload.data(using: .utf8)?.write(
                        to: fileURL,
                        options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
                    )
                }
                defaults.set(payload, forKey: defaultsKey)
                result(nil)
            } catch {
                result(FlutterError(
                    code: "BACKUP_WRITE_FAILED",
                    message: error.localizedDescription,
                    details: nil
                ))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private static let eventStore = EKEventStore()

    private static func handleCalendar(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "requestPermissions":
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToEvents { grantedEvents, _ in
                    eventStore.requestFullAccessToReminders { grantedReminders, _ in
                        DispatchQueue.main.async {
                            result(grantedEvents && grantedReminders)
                        }
                    }
                }
            } else {
                eventStore.requestAccess(to: .event) { grantedEvents, _ in
                    eventStore.requestAccess(to: .reminder) { grantedReminders, _ in
                        DispatchQueue.main.async {
                            result(grantedEvents && grantedReminders)
                        }
                    }
                }
            }

        case "createEvent":
            guard let args = call.arguments as? [String: Any],
                  let title = args["title"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Title required", details: nil))
                return
            }
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            if let startMs = args["startDateMs"] as? Double {
                event.startDate = Date(timeIntervalSince1970: startMs / 1000.0)
            } else {
                event.startDate = Date()
            }
            if let endMs = args["endDateMs"] as? Double {
                event.endDate = Date(timeIntervalSince1970: endMs / 1000.0)
            } else {
                event.endDate = event.startDate.addingTimeInterval(3600)
            }
            if let location = args["location"] as? String {
                event.location = location
            }
            if let notes = args["notes"] as? String {
                event.notes = notes
            }
            event.calendar = eventStore.defaultCalendarForNewEvents
            do {
                try eventStore.save(event, span: .thisEvent)
                result(event.eventIdentifier)
            } catch {
                result(FlutterError(code: "EVENT_SAVE_FAILED", message: error.localizedDescription, details: nil))
            }

        case "createReminder":
            guard let args = call.arguments as? [String: Any],
                  let title = args["title"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Title required", details: nil))
                return
            }
            let reminder = EKReminder(eventStore: eventStore)
            reminder.title = title
            if let notes = args["notes"] as? String {
                reminder.notes = notes
            }
            if let dueMs = args["dueDateMs"] as? Double {
                let dueDate = Date(timeIntervalSince1970: dueMs / 1000.0)
                reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
                reminder.addAlarm(EKAlarm(absoluteDate: dueDate))
            }
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
            do {
                try eventStore.save(reminder, commit: true)
                result(reminder.calendarItemIdentifier)
            } catch {
                result(FlutterError(code: "REMINDER_SAVE_FAILED", message: error.localizedDescription, details: nil))
            }

        case "deleteEvent":
            guard let args = call.arguments as? [String: Any],
                  let id = args["id"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Event ID required", details: nil))
                return
            }
            if let event = eventStore.event(withIdentifier: id) {
                do {
                    try eventStore.remove(event, span: .thisEvent)
                    result(true)
                } catch {
                    result(FlutterError(code: "DELETE_FAILED", message: error.localizedDescription, details: nil))
                }
            } else {
                result(true)
            }

        case "deleteReminder":
            guard let args = call.arguments as? [String: Any],
                  let id = args["id"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Reminder ID required", details: nil))
                return
            }
            if let item = eventStore.calendarItem(withIdentifier: id) as? EKReminder {
                do {
                    try eventStore.remove(reminder: item, commit: true)
                    result(true)
                } catch {
                    result(FlutterError(code: "DELETE_FAILED", message: error.localizedDescription, details: nil))
                }
            } else {
                result(true)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleSpeechOutput(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "speak":
            guard let arguments = call.arguments as? [String: Any],
                  let text = arguments["text"] as? String,
                  !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                result(FlutterError(code: "INVALID_SPEECH", message: "Text is required.", details: nil))
                return
            }
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
                try session.setActive(true)
                speechSynthesizer.stopSpeaking(at: .immediate)
                let language = arguments["language"] as? String ?? "en-US"
                let voice = bestInstalledVoice(for: language)
                let suppliedSegments = arguments["segments"] as? [String]
                let sentences = suppliedSegments?.filter {
                    !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                } ?? naturalSpeechSegments(from: text)
                let startIndex = arguments["startIndex"] as? Int ?? 0
                speechSegmentIndices.removeAll()
                finalSpeechSegmentIndex = sentences.isEmpty
                    ? nil
                    : startIndex + sentences.count - 1

                for (index, sentence) in sentences.enumerated() {
                    let utterance = AVSpeechUtterance(string: sentence)
                    speechSegmentIndices[ObjectIdentifier(utterance)] =
                        startIndex + index
                    utterance.voice = voice
                    utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.88
                    utterance.pitchMultiplier = 0.98
                    utterance.volume = 1.0
                    utterance.preUtteranceDelay = index == 0 ? 0.02 : 0.06
                    utterance.postUtteranceDelay = 0.05
                    speechSynthesizer.speak(utterance)
                }
                result([
                    "started": true,
                    "voice": voice?.name ?? "System voice",
                    "quality": voiceQualityName(voice?.quality)
                ])
            } catch {
                result(FlutterError(code: "SPEECH_OUTPUT_FAILED", message: error.localizedDescription, details: nil))
            }
        case "stop":
            speechSynthesizer.stopSpeaking(at: .immediate)
            speechSegmentIndices.removeAll()
            finalSpeechSegmentIndex = nil
            result(true)
        case "audioStatus":
            let session = AVAudioSession.sharedInstance()
            result([
                "outputVolume": session.outputVolume,
                "route": session.currentRoute.outputs.first?.portName ?? "iPhone speaker",
                "speaking": speechSynthesizer.isSpeaking,
                "voice": bestInstalledVoice(for: "en-US")?.name ?? "System voice",
                "voiceQuality": voiceQualityName(bestInstalledVoice(for: "en-US")?.quality)
            ])
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didStart utterance: AVSpeechUtterance
    ) {
        guard let index = speechSegmentIndices[ObjectIdentifier(utterance)] else {
            return
        }
        speechOutputChannel?.invokeMethod(
            "onSpeechSegment",
            arguments: ["index": index]
        )
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        let identifier = ObjectIdentifier(utterance)
        guard let index = speechSegmentIndices.removeValue(forKey: identifier) else {
            return
        }
        if index == finalSpeechSegmentIndex {
            finalSpeechSegmentIndex = nil
            speechOutputChannel?.invokeMethod(
                "onSpeechFinished",
                arguments: nil
            )
        }
    }

    func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        speechSegmentIndices.removeValue(forKey: ObjectIdentifier(utterance))
    }

    private func bestInstalledVoice(
        for requestedLanguage: String
    ) -> AVSpeechSynthesisVoice? {
        let normalized = requestedLanguage.lowercased()
        let languageCode = normalized.split(separator: "-").first.map(String.init)
            ?? normalized
        let matching = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            let candidate = voice.language.lowercased()
            return candidate == normalized || candidate.hasPrefix("\(languageCode)-")
        }

        return matching.sorted { first, second in
            if first.quality.rawValue != second.quality.rawValue {
                return first.quality.rawValue > second.quality.rawValue
            }
            let firstExact = first.language.lowercased() == normalized
            let secondExact = second.language.lowercased() == normalized
            if firstExact != secondExact { return firstExact }
            return first.name.localizedCaseInsensitiveCompare(second.name)
                == .orderedAscending
        }.first ?? AVSpeechSynthesisVoice(language: requestedLanguage)
    }

    private func naturalSpeechSegments(from text: String) -> [String] {
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

    private func voiceQualityName(
        _ quality: AVSpeechSynthesisVoiceQuality?
    ) -> String {
        switch quality {
        case .premium: return "Premium"
        case .enhanced: return "Enhanced"
        default: return "Standard"
        }
    }

    private static func handleMLXMethodCall(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "status":
            result(MLXTextGenerationService.installationStatus())
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
        case "deleteCachedModel":
            Task {
                do {
                    let status = try await MLXTextGenerationService.shared.deleteCachedModel()
                    await MainActor.run { result(status) }
                } catch {
                    await MainActor.run {
                        result(FlutterError(
                            code: "MLX_DELETE_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
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
