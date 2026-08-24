import ActivityKit
import Foundation

struct NoteEchoesActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var subtitle: String
        var items: [String]
        var completed: Int
        var total: Int
    }

    var noteId: String
    var title: String
}
