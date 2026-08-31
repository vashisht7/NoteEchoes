import ActivityKit
import AppIntents
import Foundation

private let noteEchoesAppGroup = "group.com.vashisht.notechoes"
private let checklistActionsKey = "noteechoes_lock_screen_checklist_actions_v1"

enum NoteEchoesLockScreenLayout {
    // Three rows leave enough room for the app name, list title and progress
    // on every supported Lock Screen Live Activity height.
    static let maximumVisibleChecklistItems = 3
}

/// The complete checklist lives in the App Group rather than ActivityKit's
/// small content-state payload. This lets the Live Activity rotate the next
/// pending item into view immediately, even while Flutter is suspended.
enum LockScreenChecklistStore {
    private static let listsKey = "noteechoes_lock_screen_checklists_v2"

    static func noteIds() -> [String] {
        guard let defaults = UserDefaults(suiteName: noteEchoesAppGroup),
              let lists = defaults.dictionary(forKey: listsKey) else {
            return []
        }
        return lists.keys.sorted()
    }

    static func replace(
        noteId: String,
        items: [NoteEchoesActivityAttributes.ChecklistItem]
    ) {
        guard let defaults = UserDefaults(suiteName: noteEchoesAppGroup) else {
            return
        }
        var lists = defaults.dictionary(forKey: listsKey) ?? [:]
        lists[noteId] = items.map { item in
            [
                "id": item.id,
                "text": item.text,
                "isCompleted": item.isCompleted,
            ] as [String: Any]
        }
        defaults.set(lists, forKey: listsKey)
    }

    static func items(noteId: String) -> [NoteEchoesActivityAttributes.ChecklistItem] {
        guard let defaults = UserDefaults(suiteName: noteEchoesAppGroup),
              let lists = defaults.dictionary(forKey: listsKey),
              let values = lists[noteId] as? [[String: Any]] else {
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

    static func setCompleted(
        noteId: String,
        itemId: String,
        completed: Bool
    ) -> [NoteEchoesActivityAttributes.ChecklistItem] {
        var allItems = items(noteId: noteId)
        if let index = allItems.firstIndex(where: { $0.id == itemId }) {
            allItems[index].isCompleted = completed
            replace(noteId: noteId, items: allItems)
        }
        return allItems
    }

    static func remove(noteId: String) {
        guard let defaults = UserDefaults(suiteName: noteEchoesAppGroup) else {
            return
        }
        var lists = defaults.dictionary(forKey: listsKey) ?? [:]
        lists.removeValue(forKey: noteId)
        defaults.set(lists, forKey: listsKey)
    }
}

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
            var allItems = LockScreenChecklistStore.setCompleted(
                noteId: noteId,
                itemId: itemId,
                completed: completed
            )
            if allItems.isEmpty {
                allItems = state.items
                if let index = allItems.firstIndex(where: { $0.id == itemId }) {
                    allItems[index].isCompleted = completed
                }
            }
            if !allItems.isEmpty {
                state.items = Array(
                    allItems
                        .filter { !$0.isCompleted }
                        .prefix(NoteEchoesLockScreenLayout.maximumVisibleChecklistItems)
                )
                state.completed = allItems.filter(\.isCompleted).count
                state.total = allItems.count
                state.subtitle = state.completed == state.total
                    ? "All \(state.total) completed"
                    : "\(state.completed) of \(state.total) completed"
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
