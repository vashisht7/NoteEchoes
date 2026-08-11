import AppIntents

/// Headless AppIntent that receives dictated text from Shortcuts
/// and saves it to notechoes without opening the app.
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

        let finalText = !trimmed.isEmpty
            ? trimmed
            : "Voice Memo (\(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)))"

        _ = try await PendingVoiceNoteStore.shared.append(text: finalText)

        return .result()
    }
}
