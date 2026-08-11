import AppIntents
import Speech

/// Headless AppIntent that receives a recorded audio file from Shortcuts
/// (e.g. "Record Audio" action), transcribes it on-device using SFSpeechRecognizer,
/// and saves it as a note in notechoes — without opening the app.
///
/// `inputConnectionBehavior: .connectToPreviousIntentResult` allows Shortcuts
/// to automatically pipe the output of "Record Audio" directly into `audioFile`!
@available(iOS 16.0, *)
struct TranscribeAudioNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Transcribe & Save Voice Note"

    static var description = IntentDescription(
        "Transcribes a voice recording on-device and saves it as a note in notechoes — without opening the app."
    )

    static var openAppWhenRun: Bool = false

    @Parameter(
        title: "Audio Recording",
        description: "The audio file to transcribe",
        inputConnectionBehavior: .connectToPreviousIntentResult
    )
    var audioFile: IntentFile?

    static var parameterSummary: some ParameterSummary {
        Summary("Transcribe \(\.$audioFile) and save to notechoes")
    }

    func perform() async throws -> some IntentResult {
        guard let file = audioFile else {
            return .result()
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = file.filename ?? "recording.m4a"
        let tempURL = tempDir.appendingPathComponent(
            "notechoes_\(UUID().uuidString)_\(fileName)"
        )

        do {
            try file.data.write(to: tempURL)
        } catch {
            return .result()
        }

        defer { try? FileManager.default.removeItem(at: tempURL) }

        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized, let recognizer = SFSpeechRecognizer() else {
            return .result()
        }

        let request = SFSpeechURLRecognitionRequest(url: tempURL)
        request.shouldReportPartialResults = false

        if recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        }

        let transcription: String? = try? await withCheckedThrowingContinuation {
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

        if let text = transcription?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            _ = try await PendingVoiceNoteStore.shared.append(text: text)
        }

        return .result()
    }
}
