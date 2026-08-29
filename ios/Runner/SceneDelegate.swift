import Flutter
import UIKit
import EventKit
import UserNotifications

class SceneDelegate: FlutterSceneDelegate {
    private let actionChannelName =
        "com.vashisht.notechoes/action_button"

    private let legacyPendingNotesKey =
        "notechoes_pending_voice_notes"

    private var sharedDefaults: UserDefaults { SharedDefaults.suite }

    private var actionChannel: FlutterMethodChannel?
    private var mlxChannel: FlutterMethodChannel?
    private var pdfVisionChannel: FlutterMethodChannel?
    private var noteBackupChannel: FlutterMethodChannel?
    private var lockScreenActivityChannel: FlutterMethodChannel?
    private var isChannelRetryScheduled = false

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
        MLXTextGenerationChannelService.shared.register(with: flutterViewController)
        MLXMultilingualActionChannelService.shared.register(with: flutterViewController)

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

        let lockScreenActivityChannel = FlutterMethodChannel(
            name: "noteechoes/lock_screen_activity",
            binaryMessenger: flutterViewController.binaryMessenger
        )
        self.lockScreenActivityChannel = lockScreenActivityChannel
        lockScreenActivityChannel.setMethodCallHandler { call, result in
            if #available(iOS 16.2, *) {
                LockScreenActivityCoordinator.handle(call, result: result)
            } else {
                result(FlutterError(
                    code: "LIVE_ACTIVITY_UNAVAILABLE",
                    message: "Lock Screen notes require iOS 16.2 or later.",
                    details: nil
                ))
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

    private static var _eventStore: EKEventStore?
    private static var eventStore: EKEventStore {
        if let store = _eventStore { return store }
        let store = EKEventStore()
        _eventStore = store
        return store
    }

    private static func handleCalendar(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "requestReminderPermissions":
            if #available(iOS 17.0, *) {
                eventStore.requestFullAccessToReminders { granted, _ in
                    ReminderNotificationCoordinator.requestPermission { notificationsGranted in
                        DispatchQueue.main.async { result(granted && notificationsGranted) }
                    }
                }
            } else {
                eventStore.requestAccess(to: .reminder) { granted, _ in
                    ReminderNotificationCoordinator.requestPermission { notificationsGranted in
                        DispatchQueue.main.async { result(granted && notificationsGranted) }
                    }
                }
            }

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
                reminder.dueDateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute, .second],
                    from: dueDate
                )
                reminder.addAlarm(EKAlarm(absoluteDate: dueDate))
            }
            reminder.calendar = eventStore.defaultCalendarForNewReminders()
            do {
                try eventStore.save(reminder, commit: true)
                if let dueDate = reminder.dueDateComponents?.date {
                    ReminderNotificationCoordinator.schedule(
                        title: title,
                        dueDate: dueDate,
                        reminderIdentifier: reminder.calendarItemIdentifier
                    ) { error in
                        DispatchQueue.main.async {
                            if let error {
                                result(FlutterError(
                                    code: "REMINDER_NOTIFICATION_FAILED",
                                    message: error.localizedDescription,
                                    details: reminder.calendarItemIdentifier
                                ))
                            } else {
                                result(reminder.calendarItemIdentifier)
                            }
                        }
                    }
                    return
                }
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
                    try eventStore.remove(item, commit: true)
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

    private func handleMLXMethodCall(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        switch call.method {
        case "status":
            result(MLXTextGenerationService.installationStatus())
        case "load":
            Task {
                do {
                    try await MLXTextGenerationService.shared.load { [weak self] fraction, statusText in
                        DispatchQueue.main.async {
                            self?.mlxChannel?.invokeMethod("onMLXDownloadProgress", arguments: [
                                "progress": fraction,
                                "statusText": statusText
                            ])
                        }
                    }
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
