import ActivityKit
import Flutter

@available(iOS 16.2, *)
enum LockScreenActivityCoordinator {
    private static let appGroup = "group.com.vashisht.notechoes"
    private static let checklistActionsKey =
        "noteechoes_lock_screen_checklist_actions_v1"

    static func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        if call.method == "consumeChecklistActions" {
            let defaults = UserDefaults(suiteName: appGroup)
            let actions = defaults?.array(forKey: checklistActionsKey) ?? []
            defaults?.removeObject(forKey: checklistActionsKey)
            result(actions)
            return
        }

        guard let arguments = call.arguments as? [String: Any],
              let noteId = arguments["noteId"] as? String else {
            result(FlutterError(
                code: "INVALID_LOCK_SCREEN_NOTE",
                message: "A note ID is required.",
                details: nil
            ))
            return
        }

        switch call.method {
        case "isActive":
            result(activity(for: noteId) != nil)
        case "show":
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                result(FlutterError(
                    code: "LIVE_ACTIVITIES_DISABLED",
                    message: "Enable Live Activities for NoteEchoes in Settings.",
                    details: nil
                ))
                return
            }
            let title = arguments["title"] as? String ?? "NoteEchoes"
            let subtitle = arguments["subtitle"] as? String ?? ""
            let items = checklistItems(from: arguments).prefix(4)
            let completed = arguments["completed"] as? Int ?? 0
            let total = arguments["total"] as? Int ?? 0
            let state = NoteEchoesActivityAttributes.ContentState(
                subtitle: subtitle,
                items: Array(items),
                completed: completed,
                total: total
            )
            Task {
                do {
                    if let current = activity(for: noteId) {
                        await current.update(ActivityContent(
                            state: state,
                            staleDate: nil
                        ))
                        await MainActor.run { result(current.id) }
                    } else {
                        let created = try Activity.request(
                            attributes: NoteEchoesActivityAttributes(
                                noteId: noteId,
                                title: title
                            ),
                            content: ActivityContent(
                                state: state,
                                staleDate: nil
                            ),
                            pushType: nil
                        )
                        await MainActor.run { result(created.id) }
                    }
                } catch {
                    await MainActor.run {
                        result(FlutterError(
                            code: "LIVE_ACTIVITY_FAILED",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }
        case "remove":
            Task {
                if let current = activity(for: noteId) {
                    await current.end(nil, dismissalPolicy: .immediate)
                }
                await MainActor.run { result(true) }
            }
        case "update":
            guard let current = activity(for: noteId) else {
                result(false)
                return
            }
            let state = NoteEchoesActivityAttributes.ContentState(
                subtitle: arguments["subtitle"] as? String ?? "",
                items: Array(checklistItems(from: arguments).prefix(4)),
                completed: arguments["completed"] as? Int ?? 0,
                total: arguments["total"] as? Int ?? 0
            )
            Task {
                await current.update(ActivityContent(
                    state: state,
                    staleDate: nil
                ))
                await MainActor.run { result(true) }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private static func activity(
        for noteId: String
    ) -> Activity<NoteEchoesActivityAttributes>? {
        Activity<NoteEchoesActivityAttributes>.activities.first {
            $0.attributes.noteId == noteId
        }
    }

    private static func checklistItems(
        from arguments: [String: Any]
    ) -> [NoteEchoesActivityAttributes.ChecklistItem] {
        guard let values = arguments["items"] as? [[String: Any]] else {
            return []
        }
        return values.compactMap { value in
            guard let id = value["id"] as? String,
                  let text = value["text"] as? String else {
                return nil
            }
            return NoteEchoesActivityAttributes.ChecklistItem(
                id: id,
                text: text,
                isCompleted: value["isCompleted"] as? Bool ?? false
            )
        }
    }
}
