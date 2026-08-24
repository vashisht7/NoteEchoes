import ActivityKit
import Flutter

@available(iOS 16.2, *)
enum LockScreenActivityCoordinator {
    static func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
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
            let items = (arguments["items"] as? [String] ?? []).prefix(3)
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
                items: Array(
                    (arguments["items"] as? [String] ?? []).prefix(3)
                ),
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
}
