# Automatic Grounded Conversation and Web Fallback Release

## Release

- App version: `2.11.1+18`
- Product scope: iPhone conversation mode and recognition-language switching
- Primary experience: English-first, with Telugu, Telugu-English mixed, Hindi, and automatic recognition modes

## Conversation flow

Conversation mode now follows one visible, automatic sequence:

1. Listen to the user's question.
2. Detect a natural pause after meaningful speech.
3. Stop and release the microphone.
4. Transcribe using the recognition language selected in Settings.
5. Search saved notes, checklists, tasks, and reminders.
6. If no relevant note evidence exists and the device is online, search an attributable public web source.
7. Build a new report for the current question only.
8. Open the report and begin native iPhone speech after iOS confirms playback.

The screen exposes progress such as `Transcribing your question`, `Searching your notes`, `Searching the web`, and `Preparing a grounded answer`. A second tap is no longer required after the user finishes speaking. A typed question field with the iOS Send action remains available as an alternative.

## Correctness and grounding

- Every new question clears the previous response before retrieval begins.
- Empty, gasp-only, cough-only, or filler-only transcription asks the user to try again; it never becomes a request to summarize old notes.
- Non-summary questions require exact meaningful-term overlap with retrieved note evidence. Short terms use whole-token matching, so `pi` cannot match an unrelated word such as `shopping`.
- Broad summary requests still use the user's recent notes intentionally.
- Retrieval or generation errors produce an explicit failure message instead of a recycled note summary.
- The finished report contains only the answer and sources—not internal processing text.

## Web fallback

When no relevant note evidence exists, NoteEchoes queries Wikipedia's public API and uses only a plaintext article introduction with an article title and URL. Search snippets are not treated as answers.

- Online with a reliable result: show the answer and label the report `Web • Wikipedia`.
- Offline: say that nothing was found in the user's notes and ask the user to connect before requesting a web search again.
- Online without a reliable result: ask for a more specific topic rather than inventing an answer.

Note queries and local note contents remain on-device. Only the unanswered user question is sent to the public web source.

## Recognition language correction

The `Telugu & English Mixed` setting was visible in the UI but missing from the preference layer's accepted values. It is now persisted correctly. Every language change also stops the recorder and speech output, clears the stale audio route, and selects a fresh transcription and response voice locale.

## Spoken playback correction

The native speech bridge now creates a fresh `AVSpeechSynthesizer` for every playback request. This prevents a synthesizer that was left in a stale recording or previous-language state from timing out. Native startup has five seconds to load a newly selected voice, while Flutter waits eight seconds for the confirmed `didStart` result. The audio session is released when the final spoken segment completes.

A device diagnostic reproduces the reported Telugu-to-English transition and requires both languages to reach the native `didStart` callback.

## Verification

- Full Flutter suite: 125 tests passed.
- Changed-file static analysis: no issues.
- Focused coverage includes mixed-language persistence, automatic silence submission, fresh-report reset, typed Send behavior, exact evidence gating, attributed web answers, and offline non-invention.
- Live Wikipedia API query for `Calculate the value of pi` resolved to the `Pi` article.
- Signed iPhone Release build `2.11.0 (17)` passed strict code-signature verification.
- Physical iPhone language-switch diagnostic passed: Telugu reached native `didStart` with Apple Geeta, followed by English reaching native `didStart` with Enhanced Rishi; both used the phone speaker.
- The update was installed in place. The app database UUID remained `7B579E2E-5573-452B-BED8-7EADDCF99B56`, confirming that existing app data was preserved.

## Focused listening experience and voice activity correction

The rotating prompt-suggestion wheel has been removed from the listening page. The page now contains only the live listening surface and an optional typed-question field.

Turn detection no longer treats every sound above one fixed loudness as speech. It now:

- calibrates an adaptive room-noise floor at the start of listening;
- requires sustained probable-voice frames rather than a tap, gasp, or brief noise;
- enables Apple's `voiceChat` capture mode, voice processing, echo cancellation, noise suppression, and automatic gain control;
- submits after a natural 900 ms pause, with a 25-second turn ceiling so continuous environmental sound cannot leave the app listening forever;
- publishes and opens the finished report before beginning spoken playback.

This filters non-speech environmental noise. It is not speaker identification: another nearby person speaking may still be transcribed.

Physical-device diagnostics confirmed `AVAudioSessionModeVoiceChat`, `voiceProcessing: true`, and the iPhone microphone input. Version `2.11.1 (18)` was installed in place with the same database UUID.
