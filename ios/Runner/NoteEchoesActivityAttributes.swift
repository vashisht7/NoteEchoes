import ActivityKit
import AppIntents
import Foundation

private let noteEchoesAppGroup = "group.com.vashisht.notechoes"
private let checklistActionsKey = "noteechoes_lock_screen_checklist_actions_v1"

struct NoteEchoesActivityAttributes: ActivityAttributes {
    struct ChecklistItem: Codable, Hashable, Identifiable {
        var id: String
        var text: String
        var isCompleted: Bool
    }

    struct ContentState: Codable, Hashable {
        var subtitle: String
        var items: [ChecklistItem]
        var completed: Int
        var total: Int
    }

    var noteId: String
    var title: String
}

/// LiveActivityIntent must be included in the containing app target. Apple
/// executes this protocol in the app process, which is what gives the intent
/// immediate access to the ActivityKit activity that Runner created.
struct ToggleLockScreenChecklistIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Update Checklist Item"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Note ID") var noteId: String
    @Parameter(title: "Item ID") var itemId: String
    @Parameter(title: "Completed") var completed: Bool

    init() {
        noteId = ""
        itemId = ""
        completed = false
    }

    init(noteId: String, itemId: String, completed: Bool) {
        self.noteId = noteId
        self.itemId = itemId
        self.completed = completed
    }

    func perform() async throws -> some IntentResult {
        let activity = Activity<NoteEchoesActivityAttributes>.activities.first {
            $0.attributes.noteId == noteId
        }
        if let activity {
            var state = activity.content.state
            if let index = state.items.firstIndex(where: { $0.id == itemId }) {
                let oldVisibleCompleted = state.items.filter(\.isCompleted).count
                state.items[index].isCompleted = completed
                let newVisibleCompleted = state.items.filter(\.isCompleted).count
                state.completed = min(
                    state.total,
                    max(0, state.completed - oldVisibleCompleted + newVisibleCompleted)
                )
                state.subtitle = "\(state.completed) of \(state.total) completed"
                await activity.update(
                    ActivityContent(
                        state: state,
                        staleDate: nil,
                        relevanceScore: 1
                    )
                )
            }
        }
        enqueueChecklistAction()
        return .result()
    }

    private func enqueueChecklistAction() {
        guard let defaults = UserDefaults(suiteName: noteEchoesAppGroup) else {
            return
        }
        var actions = defaults.array(forKey: checklistActionsKey) ?? []
        actions.append([
            "noteId": noteId,
            "itemId": itemId,
            "completed": completed,
            "createdAt": Date().timeIntervalSince1970,
        ])
        defaults.set(actions, forKey: checklistActionsKey)
    }
}
