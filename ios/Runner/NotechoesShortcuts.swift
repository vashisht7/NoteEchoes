import AppIntents

/// Registers the "Save Dictated Note" intent as an auto-discovered
/// App Shortcut so users can assign it to their Action Button in one tap.
@available(iOS 16.0, *)
struct NotechoesShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SaveDictatedNoteIntent(),
            phrases: [
                "Save a note in \(.applicationName)",
                "Quick note in \(.applicationName)",
                "Voice note to \(.applicationName)",
                "New note in \(.applicationName)",
            ],
            shortTitle: "Save Dictated Note",
            systemImageName: "mic.badge.plus"
        )
    }
}
