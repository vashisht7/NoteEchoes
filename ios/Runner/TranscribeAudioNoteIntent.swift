import AppIntents
import Speech

/// Headless AppIntent that receives a recorded audio file from Shortcuts
/// (e.g. "Record Audio" action), transcribes it on-device using SFSpeechRecognizer,
/// and saves it as a note in notechoes — guaranteed to save even if speech recognition fails.
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
            _ = try? await PendingVoiceNoteStore.shared.append(
                text: "Voice Note (\(Date().formatted()))"
            )
            return .result()
        }

        defer { try? FileManager.default.removeItem(at: tempURL) }

        // Attempt transcription via SFSpeechRecognizer
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        var transcribedText: String? = nil

        if authStatus == .authorized, let recognizer = SFSpeechRecognizer() {
            let request = SFSpeechURLRecognitionRequest(url: tempURL)
            request.shouldReportPartialResults = false
            if recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            }

            transcribedText = try? await withCheckedThrowingContinuation { continuation in
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
                        continuation.resume(returning: result.bestTranscription.formattedString)
                    }
                }
            }
        }

        let finalText: String
        if let text = transcribedText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            finalText = text
        } else {
            let nowStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
            finalText = "Voice Memo Recording (\(nowStr))"
        }

        // Guaranteed persistence to pending queue
        _ = try await PendingVoiceNoteStore.shared.append(text: finalText)

        return .result()
    }
}
