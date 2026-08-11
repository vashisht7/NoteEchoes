import AppIntents

/// Registers notechoes App Shortcuts so they auto-appear in the
/// Shortcuts app and can be assigned to the Action Button in one tap.
@available(iOS 16.0, *)
struct NotechoesShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TranscribeAudioNoteIntent(),
            phrases: [
                "Record a voice note in \(.applicationName)",
                "Voice note to \(.applicationName)",
                "Save a recording to \(.applicationName)",
            ],
            shortTitle: "Record & Save Voice Note",
            systemImageName: "mic.badge.plus"
        )

        AppShortcut(
            intent: SaveDictatedNoteIntent(),
            phrases: [
                "Quick note in \(.applicationName)",
                "Dictate a note to \(.applicationName)",
            ],
            shortTitle: "Quick Dictated Note",
            systemImageName: "text.badge.plus"
        )
    }
}
