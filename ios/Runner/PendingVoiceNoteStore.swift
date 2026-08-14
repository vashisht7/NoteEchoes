import Foundation

/// Shared container between the main app and App Intent extensions.
/// Both `TranscribeAudioNoteIntent` and the main app must use this
/// same App Group UserDefaults so that notes recorded via the
/// Action Button Shortcut actually appear in the app.
enum SharedDefaults {
    static let appGroup = "group.com.vashisht.notechoes"

    static var suite: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }

    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroup
        )
    }
}

actor PendingVoiceNoteStore {
    static let shared = PendingVoiceNoteStore()

    private var defaults: UserDefaults { SharedDefaults.suite }
    private let queueKey = "notechoes_pending_action_button_notes_v1"
    private let fallbackFile = "pending_voice_notes_v1.json"

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
        // Deduplicate
        if !queue.contains(where: { $0.id == pendingNote.id }) {
            queue.append(pendingNote)
        }
        try persist(queue)

        return pendingNote
    }

    func peek() throws -> PendingNote? {
        try loadQueue().first
    }

    func acknowledge(id: String) throws {
        var queue = try loadQueue()
        queue.removeAll { $0.id == id }
        try persist(queue)
    }

    private func loadQueue() throws -> [PendingNote] {
        // Tier 1: Try App Group shared file container
        if let containerURL = SharedDefaults.sharedContainerURL {
            let fileURL = containerURL.appendingPathComponent(fallbackFile)
            if let data = try? Data(contentsOf: fileURL),
               let items = try? JSONDecoder().decode([PendingNote].self, from: data),
               !items.isEmpty {
                return items
            }
        }

        // Tier 2: App Group suite UserDefaults
        if let data = defaults.data(forKey: queueKey),
           let items = try? JSONDecoder().decode([PendingNote].self, from: data),
           !items.isEmpty {
            return items
        }

        // Tier 3: Standard UserDefaults
        if let data = UserDefaults.standard.data(forKey: queueKey),
           let items = try? JSONDecoder().decode([PendingNote].self, from: data),
           !items.isEmpty {
            return items
        }

        return []
    }

    private func persist(_ queue: [PendingNote]) throws {
        let data = try JSONEncoder().encode(queue)

        // Tier 1: Write to App Group suite
        defaults.set(data, forKey: queueKey)
        defaults.synchronize()

        // Tier 2: Write to standard defaults as fallback
        UserDefaults.standard.set(data, forKey: queueKey)
        UserDefaults.standard.synchronize()

        // Tier 3: Write to shared App Group file if available
        if let containerURL = SharedDefaults.sharedContainerURL {
            let fileURL = containerURL.appendingPathComponent(fallbackFile)
            try? data.write(to: fileURL, options: .atomic)
        }
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
