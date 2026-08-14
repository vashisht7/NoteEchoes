import Foundation

/// Shared container between the main app and App Intent extensions.
/// Both `TranscribeAudioNoteIntent` and the main app must use this
/// same App Group UserDefaults so that notes recorded via the
/// Action Button Shortcut actually appear in the app.
enum SharedDefaults {
    static let appGroup = "group.com.vashisht.notechoes"

    static var suite: UserDefaults {
        // Falls back to standard if the App Group hasn't been provisioned yet
        UserDefaults(suiteName: appGroup) ?? .standard
    }
}

actor PendingVoiceNoteStore {
    static let shared = PendingVoiceNoteStore()

    // Use the shared App Group container — accessible from both the
    // main app process and App Intent extension processes.
    private var defaults: UserDefaults { SharedDefaults.suite }
    private let queueKey = "notechoes_pending_action_button_notes_v1"

    struct PendingNote: Codable, Sendable {
        let id: String
        let text: String
        let createdAt: String
        let source: String
    }

    func append(text: String) throws -> PendingNote {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalized.isEmpty else {
            throw PendingVoiceNoteError.emptyText
        }

        let pendingNote = PendingNote(
            id: UUID().uuidString,
            text: normalized,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            source: "action_button_system_dictation"
        )

        var queue = try loadQueue()
        queue.append(pendingNote)
        try persist(queue)

        // Force-sync so the main app picks it up immediately on resume
        defaults.synchronize()

        return pendingNote
    }

    func peek() throws -> PendingNote? {
        try loadQueue().first
    }

    func acknowledge(id: String) throws {
        var queue = try loadQueue()
        queue.removeAll { $0.id == id }
        try persist(queue)
        defaults.synchronize()
    }

    private func loadQueue() throws -> [PendingNote] {
        guard let data = defaults.data(forKey: queueKey) else {
            return []
        }

        return try JSONDecoder().decode(
            [PendingNote].self,
            from: data
        )
    }

    private func persist(_ queue: [PendingNote]) throws {
        let data = try JSONEncoder().encode(queue)
        defaults.set(data, forKey: queueKey)
    }
}

enum PendingVoiceNoteError: LocalizedError {
    case emptyText

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "No dictated text was received."
        }
    }
}
