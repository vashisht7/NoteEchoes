import AppIntents
import Speech

/// Headless AppIntent that receives a recorded audio file from the
/// Shortcuts "Record Audio" action, transcribes it entirely on-device
/// using SFSpeechRecognizer, and saves the transcript as a pending
/// note — all WITHOUT opening the notechoes app.
///
/// Shortcut flow:
///   1. "Record Audio" → user speaks as long as they want, taps Stop
///   2. "Transcribe & Save Voice Note" → receives audio, transcribes, saves
///
/// The user controls when recording ends.  No 10-second timeout.
@available(iOS 16.0, *)
struct TranscribeAudioNoteIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Transcribe & Save Voice Note"
    }

    static var description = IntentDescription(
        "Transcribes a voice recording on-device and saves it as a note in notechoes — without opening the app."
    )

    // ── CRITICAL: never open the app ──
    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Audio Recording",
        description: "The audio file to transcribe (from Record Audio)"
    )
    var audioFile: IntentFile

    static var parameterSummary: some ParameterSummary {
        Summary("Transcribe \(\.$audioFile) and save to notechoes")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {

        // 1. Write IntentFile data to a temporary URL that
        //    SFSpeechURLRecognitionRequest can read
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = audioFile.filename ?? "recording.m4a"
        let tempURL = tempDir.appendingPathComponent(
            "notechoes_\(UUID().uuidString)_\(fileName)"
        )

        try audioFile.data.write(to: tempURL)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        // 2. Verify speech recognition permission
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            _ = try? await PendingVoiceNoteStore.shared.append(
                text: "[Voice recording — speech recognition not yet authorized. Open notechoes to grant permission.]"
            )
            return .result(
                dialog: "Speech recognition not authorized. Open notechoes once to grant permission."
            )
        }

        guard let recognizer = SFSpeechRecognizer() else {
            return .result(dialog: "Speech recognizer is unavailable on this device.")
        }

        // 3. Build recognition request — prefer on-device for privacy
        //    and to avoid the 1-minute server-side session cap
        let request = SFSpeechURLRecognitionRequest(url: tempURL)
        request.shouldReportPartialResults = false

        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        // 4. Transcribe (async bridge from delegate callback)
        let transcription: String = try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<String, Error>) in

            var hasResumed = false

            recognizer.recognitionTask(with: request) { result, error in
                guard !hasResumed else { return }

                if let error = error {
                    hasResumed = true
                    continuation.resume(throwing: error)
                    return
                }

                if let result = result, result.isFinal {
                    hasResumed = true
                    continuation.resume(
                        returning: result.bestTranscription.formattedString
                    )
                }
            }
        }

        let trimmed = transcription
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .result(dialog: "No speech detected in the recording.")
        }

        // 5. Save to the durable native pending-note queue
        _ = try await PendingVoiceNoteStore.shared.append(text: trimmed)

        let wordCount = trimmed.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }.count

        return .result(
            dialog: "✓ Saved to notechoes (\(wordCount) words)"
        )
    }
}
