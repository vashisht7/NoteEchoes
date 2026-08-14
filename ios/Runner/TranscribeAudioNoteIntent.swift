import AppIntents
import Speech
import AVFoundation

/// Headless AppIntent that receives a recorded audio file from Shortcuts ("Record Audio" action),
/// supports recordings from 5 seconds up to 1+ hour conversations via seamless chunked transcription,
/// and saves the complete, multi-paragraph transcribed note into notechoes.
@available(iOS 16.0, *)
struct TranscribeAudioNoteIntent: AppIntent {
    static var title: LocalizedStringResource = "Transcribe & Save Voice Note"

    static var description = IntentDescription(
        "Transcribes any voice recording (from short notes up to 1-hour conversations) and saves it to notechoes."
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
            // Save a fallback placeholder if no file was passed
            let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
            _ = try await PendingVoiceNoteStore.shared.append(text: "Voice Note (\(dateStr))")
            return .result()
        }

        // Copy audio data to a clean local temporary file in our process sandbox
        // This avoids any cross-sandbox or security-scoped URL read restrictions
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "notechoes_recording_\(UUID().uuidString).m4a"
        let localTempURL = tempDir.appendingPathComponent(fileName)

        var audioReady = false
        if let directURL = file.fileURL {
            let hasSecurityScope = directURL.startAccessingSecurityScopedResource()
            do {
                if FileManager.default.fileExists(atPath: localTempURL.path) {
                    try? FileManager.default.removeItem(at: localTempURL)
                }
                try FileManager.default.copyItem(at: directURL, to: localTempURL)
                audioReady = true
            } catch {
                // Try reading data
                if let data = try? Data(contentsOf: directURL) {
                    try? data.write(to: localTempURL)
                    audioReady = true
                }
            }
            if hasSecurityScope {
                directURL.stopAccessingSecurityScopedResource()
            }
        }

        if !audioReady {
            do {
                try file.data.write(to: localTempURL)
                audioReady = true
            } catch {
                let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
                _ = try await PendingVoiceNoteStore.shared.append(text: "Voice Recording (\(dateStr))")
                return .result()
            }
        }

        defer { try? FileManager.default.removeItem(at: localTempURL) }

        // Perform chunked speech recognition supporting up to 1-hour audio
        let transcribedText = await transcribeFullAudio(at: localTempURL)

        let finalNoteText: String
        if let text = transcribedText?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            finalNoteText = text
        } else {
            let dateStr = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
            finalNoteText = "Voice Memo (\(dateStr))"
        }

        _ = try await PendingVoiceNoteStore.shared.append(text: finalNoteText)

        return .result()
    }

    /// Transcribes an entire audio file (from seconds up to 1 hour) using chunked Apple Neural Speech Recognition.
    private func transcribeFullAudio(at url: URL) async -> String? {
        // Ensure speech authorization
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

        // Determine audio duration
        let asset = AVURLAsset(url: url)
        var totalDurationSeconds: Double = 30.0
        if let track = try? await asset.loadTracks(withMediaType: .audio).first {
            if let time = try? await track.load(.timeRange) {
                totalDurationSeconds = time.duration.seconds
            }
        }

        guard let recognizer = SFSpeechRecognizer(locale: Locale.current) ??
              SFSpeechRecognizer(locale: Locale(identifier: "en-US")) ??
              SFSpeechRecognizer() else {
            return nil
        }

        // If audio is under 60 seconds, transcribe in a single fast pass
        if totalDurationSeconds <= 60.0 {
            if let result = await performRecognitionOnChunk(recognizer: recognizer, url: url, timeout: max(45.0, totalDurationSeconds * 2.0)) {
                return result
            }
        }

        // For long recordings (up to 1 hour), slice into 60-second chunks to avoid buffer limits & timeouts
        var transcribedParagraphs: [String] = []
        let chunkDuration: Double = 60.0
        var currentStart: Double = 0.0
        let tempDir = FileManager.default.temporaryDirectory

        while currentStart < totalDurationSeconds {
            let chunkLength = min(chunkDuration, totalDurationSeconds - currentStart)
            let chunkFileName = "chunk_\(UUID().uuidString).m4a"
            let chunkURL = tempDir.appendingPathComponent(chunkFileName)

            let sliced = await sliceAudio(sourceURL: url, startTime: currentStart, duration: chunkLength, outputURL: chunkURL)

            if sliced {
                if let chunkText = await performRecognitionOnChunk(recognizer: recognizer, url: chunkURL, timeout: 50.0) {
                    let trimmed = chunkText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        transcribedParagraphs.append(trimmed)
                    }
                }
                try? FileManager.default.removeItem(at: chunkURL)
            }

            currentStart += chunkDuration
        }

        let combined = transcribedParagraphs.joined(separator: "\n\n")
        return combined.isEmpty ? nil : combined
    }

    /// Slices a sub-range of audio into a temporary M4A file
    private func sliceAudio(sourceURL: URL, startTime: Double, duration: Double, outputURL: URL) async -> Bool {
        let asset = AVURLAsset(url: sourceURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            return false
        }

        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        let start = CMTime(seconds: startTime, preferredTimescale: 600)
        let len = CMTime(seconds: duration, preferredTimescale: 600)
        exportSession.timeRange = CMTimeRange(start: start, duration: len)

        await exportSession.export()
        return exportSession.status == .completed
    }

    /// Recognizes speech within a single audio chunk
    private func performRecognitionOnChunk(
        recognizer: SFSpeechRecognizer,
        url: URL,
        timeout: Double
    ) async -> String? {
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.taskHint = .dictation
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        request.requiresOnDeviceRecognition = false

        return await withCheckedContinuation { continuation in
            var bestFormattedText: String = ""
            var hasResumed = false

            let task = recognizer.recognitionTask(with: request) { result, error in
                if let result = result {
                    let formatted = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !formatted.isEmpty {
                        bestFormattedText = formatted
                    }
                    if result.isFinal && !hasResumed {
                        hasResumed = true
                        continuation.resume(returning: bestFormattedText.isEmpty ? nil : bestFormattedText)
                        return
                    }
                }

                if error != nil && !hasResumed {
                    hasResumed = true
                    continuation.resume(returning: bestFormattedText.isEmpty ? nil : bestFormattedText)
                    return
                }
            }

            // Safety timeout per chunk
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                if !hasResumed {
                    hasResumed = true
                    task.cancel()
                    continuation.resume(returning: bestFormattedText.isEmpty ? nil : bestFormattedText)
                }
            }
        }
    }
}
