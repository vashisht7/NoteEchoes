import AppIntents
import Speech

/// Headless AppIntent that receives a recorded audio file from Shortcuts,
/// transcribes the spoken text using SFSpeechRecognizer (with automatic fallbacks),
/// and saves the full transcribed text as a note in notechoes.
@available(iOS 16.0, *)
struct TranscribeAudioNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Transcribe & Save Voice Note"

    static var description = IntentDescription(
        "Transcribes a voice recording and saves it as a note in notechoes — without opening the app."
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

        // Perform speech recognition with robust fallbacks
        let transcribedText = await transcribeAudioFile(at: tempURL)

        if let text = transcribedText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            _ = try await PendingVoiceNoteStore.shared.append(text: text)
        }

        return .result()
    }

    /// Transcribes audio from file URL using SFSpeechRecognizer.
    /// Tries on-device first, falls back to standard recognition if on-device model is unavailable.
    private func transcribeAudioFile(at url: URL) async -> String? {
        // Ensure speech authorization status
        var authStatus = SFSpeechRecognizer.authorizationStatus()
        if authStatus == .notDetermined {
            authStatus = await withCheckedContinuation { continuation in
                SFSpeechRecognizer.requestAuthorization { status in
                    continuation.resume(returning: status)
                }
            }
        }

        guard authStatus == .authorized || authStatus == .notDetermined else {
            return nil
        }

        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US")) ?? SFSpeechRecognizer() else {
            return nil
        }

        // Attempt 1: Try on-device recognition
        if let text = await performRecognition(recognizer: recognizer, url: url, requireOnDevice: true), !text.isEmpty {
            return text
        }

        // Attempt 2: Try standard recognition (fallback if local model not downloaded)
        if let text = await performRecognition(recognizer: recognizer, url: url, requireOnDevice: false), !text.isEmpty {
            return text
        }

        return nil
    }

    private func performRecognition(recognizer: SFSpeechRecognizer, url: URL, requireOnDevice: Bool) async -> String? {
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = true

        if requireOnDevice && recognizer.supportsOnDeviceRecognition {
            request.requiresOnDeviceRecognition = true
        } else {
            request.requiresOnDeviceRecognition = false
        }

        return await withCheckedContinuation { continuation in
            var bestText: String? = nil
            var hasResumed = false

            let task = recognizer.recognitionTask(with: request) { result, error in
                if let result = result {
                    let text = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty {
                        bestText = text
                    }
                    if result.isFinal && !hasResumed {
                        hasResumed = true
                        continuation.resume(returning: bestText)
                        return
                    }
                }

                if error != nil && !hasResumed {
                    hasResumed = true
                    continuation.resume(returning: bestText)
                    return
                }
            }

            // Safety timeout after 10 seconds of processing
            DispatchQueue.global().asyncAfter(deadline: .now() + 10.0) {
                if !hasResumed {
                    hasResumed = true
                    task.cancel()
                    continuation.resume(returning: bestText)
                }
            }
        }
    }
}
