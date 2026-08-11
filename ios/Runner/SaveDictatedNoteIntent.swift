import AppIntents

/// Headless AppIntent that receives dictated text from Shortcuts
/// (e.g. "Dictate Text" action) and saves it to notechoes.
///
/// `inputConnectionBehavior: .connectToPreviousIntentResult` allows Shortcuts
/// to automatically pipe the output of "Dictate Text" into this parameter!
@available(iOS 16.0, *)
struct SaveDictatedNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Save Dictated Note"

    static var description = IntentDescription(
        "Saves dictated text privately to notechoes without opening the app."
    )

    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Note Text",
        description: "The dictated text to save",
        inputConnectionBehavior: .connectToPreviousIntentResult
    )
    var noteText: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Save \(\.$noteText) to notechoes")
    }

    func perform() async throws -> some IntentResult {
        let trimmed = (noteText ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmed.isEmpty {
            _ = try await PendingVoiceNoteStore.shared.append(text: trimmed)
        }

        return .result()
    }
}
