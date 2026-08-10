import AppIntents

@available(iOS 16.0, *)
struct SaveDictatedNoteIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Save Dictated Note"
    }

    static var description = IntentDescription(
        "Saves dictated text privately to notechoes."
    )

    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Note Text",
        description: "The dictated text to save"
    )
    var noteText: String

    static var parameterSummary: some ParameterSummary {
        Summary("Save \(\.$noteText) to notechoes")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        _ = try await PendingVoiceNoteStore.shared.append(
            text: noteText
        )

        return .result(dialog: "Saved to notechoes")
    }
}
