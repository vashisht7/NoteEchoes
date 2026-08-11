import AppIntents

/// Headless AppIntent that saves dictated text to the native pending
/// note queue WITHOUT opening the notechoes app and WITHOUT requiring
/// any button taps.
@available(iOS 16.0, *)
struct SaveDictatedNoteIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Save Dictated Note"
    }

    static var description = IntentDescription(
        "Saves dictated text privately to notechoes without opening the app."
    )

    // ── CRITICAL: never open the app ──
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Note Text",
        description: "The dictated text to save as a new note"
    )
    var noteText: String

    static var parameterSummary: some ParameterSummary {
        Summary("Save \(\.$noteText) to notechoes")
    }

    func perform() async throws -> some IntentResult {
        let trimmed = noteText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmed.isEmpty {
            _ = try await PendingVoiceNoteStore.shared.append(
                text: trimmed
            )
        }

        return .result()
    }
}
