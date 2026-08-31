import ActivityKit
import Flutter

@available(iOS 16.2, *)
enum LockScreenActivityCoordinator {
    private static let appGroup = "group.com.vashisht.notechoes"
    private static let checklistActionsKey =
        "noteechoes_lock_screen_checklist_actions_v1"
    private static let recoveredBuildKey =
        "noteechoes_lock_screen_recovered_build_v1"

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

        if call.method == "recoverAfterAppUpdate" {
            recoverAfterAppUpdate(result: result)
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
            let allItems = checklistItems(from: arguments)
            LockScreenChecklistStore.replace(noteId: noteId, items: allItems)
            let items = visibleItems(from: allItems)
            let completed = arguments["completed"] as? Int ?? 0
            let total = arguments["total"] as? Int ?? 0
            let state = NoteEchoesActivityAttributes.ContentState(
                subtitle: subtitle,
                items: items,
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
            LockScreenChecklistStore.remove(noteId: noteId)
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
            let allItems = checklistItems(from: arguments)
            LockScreenChecklistStore.replace(noteId: noteId, items: allItems)
            let state = NoteEchoesActivityAttributes.ContentState(
                subtitle: arguments["subtitle"] as? String ?? "",
                items: visibleItems(from: allItems),
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

    /// ActivityKit can retain sessions whose rendered widget archives were
    /// removed when the containing app/extension was replaced. On the first
    /// launch of each build, end those sessions and return the intended note
    /// IDs so Flutter can recreate them from its authoritative local notes.
    private static func recoverAfterAppUpdate(
        result: @escaping FlutterResult
    ) {
        let build = Bundle.main.object(
            forInfoDictionaryKey: "CFBundleVersion"
        ) as? String ?? "unknown"
        guard let defaults = UserDefaults(suiteName: appGroup) else {
            result([])
            return
        }
        guard defaults.string(forKey: recoveredBuildKey) != build else {
            result([])
            return
        }

        let intendedNoteIds = LockScreenChecklistStore.noteIds()
        Task {
            for activity in Activity<NoteEchoesActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            defaults.set(build, forKey: recoveredBuildKey)
            await MainActor.run { result(intendedNoteIds) }
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

    private static func visibleItems(
        from items: [NoteEchoesActivityAttributes.ChecklistItem]
    ) -> [NoteEchoesActivityAttributes.ChecklistItem] {
        Array(
            items
                .filter { !$0.isCompleted }
                .prefix(NoteEchoesLockScreenLayout.maximumVisibleChecklistItems)
        )
    }
}
