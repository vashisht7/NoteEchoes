import AppIntents

/// Headless AppIntent that saves dictated text to the native pending
/// note queue WITHOUT opening the notechoes app.
///
/// Usage via Shortcuts:
///   1. "Dictate Text" action  →  output variable
///   2. "Save Dictated Note" action  →  pass output as Note Text
///
/// The user assigns this Shortcut to their iPhone Action Button.
/// On the next notechoes app launch or resume,
/// `ActionButtonNoteIngestionService` drains the queue, categorises
/// each note with `AiCategorizationEngine`, and persists it.
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

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmed = noteText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .result(
                dialog: "No text to save."
            )
        }

        _ = try await PendingVoiceNoteStore.shared.append(
            text: trimmed
        )

        return .result(
            dialog: "✓ Saved to notechoes"
        )
    }
}
