import ActivityKit
import Foundation

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
