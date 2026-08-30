# NoteEchoes Unique Daily Driver Roadmap

**Status:** Product and engineering roadmap  
**Updated:** August 29, 2026  
**Scope:** A private, fast, multilingual voice-to-action assistant that remains practical within an approximately 1 GB installed footprint.

## 1. Product Direction and North Star

NoteEchoes should not try to become a general ChatGPT replacement. Its strongest position is:

> A private, on-device voice action assistant that turns natural English, Telugu, Hindi, and code-mixed speech into trustworthy notes, tasks, reminders, checklists, drafts, and grounded follow-up answers.

The memorable product promise is **“One breath, many actions.”** A user should be able to speak naturally once and have NoteEchoes safely organize everything it understood.

### North-star release proof

- 50 real users use the app for at least two weeks.
- They attempt at least 2,000 real voice actions.
- More than 95% of those actions are completed correctly end to end.
- No recording is silently lost.
- No external action is performed without the required confirmation.
- At least 10 testers continue using the app voluntarily after the test period.

The 95% target must measure the **final action**, not merely transcription accuracy or a synthetic intent benchmark.

## 2. Current Baseline

The existing product already has a meaningful foundation:

- English-first voice capture and action handling.
- One combined approximately 0.6B multilingual action model.
- English, Telugu, Hindi, Telugu-English, and Hindi-English command support.
- Notes, tasks, reminders, checklists, grocery-style lists, email drafts, message drafts, and prompts.
- More flexible action wording and synonyms, including short commands such as “checklist” and “task.”
- Complete checklist saving without an artificial three-item limit.
- Lock Screen checklist presentation showing the top four pending items and rotating the next pending item into view after completion.
- A signed release application of approximately 104 MB before optional model downloads.
- Approximately 148 automated Flutter tests passing at the last verified build.

### Current model footprint

| Component | Approximate size | Role |
|---|---:|---|
| Release application | 104 MB | UI, local data, orchestration, Apple integrations |
| Whisper speech recognition | 154 MB | Converts speech to text |
| Combined 0.6B action model | 649 MB | Understands commands and produces structured actions |
| Semantic search model | 123 MB | Optional meaning-based note search |
| Core multilingual install | 907 MB | App + speech recognition + action model |
| Full install | 1.03 GB | Core install + semantic search |

Semantic search should remain optional. Normal local full-text search should work without it so the main multilingual experience remains below roughly 1 GB.

### Important accuracy distinction

The current synthetic text-level product-action evaluation reached approximately **99.49%** on 987 requested-action rows. This is useful engineering evidence, but it is not a claim that 99.49% of real microphone requests succeed. Real release confidence still requires different speakers, accents, background noise, code mixing, incomplete sentences, names, corrections, and device-level execution.

## 3. Scorecard and Improvement Targets

| Area | Current working assessment | Target | What closes the gap |
|---|---:|---:|---|
| Technical achievement | 8.5/10 | 9.5/10 | Real-audio evaluation, uncertainty handling, personalization, and device benchmarks |
| Product uniqueness | 6.5/10 | 8.5/10 | Code-mixed voice actions, multiple actions per utterance, evidence, and grounded follow-ups |
| Consumer readiness | 6/10 | 8.5/10 | Simple onboarding, robust downloads, safe failures, and no mandatory account |
| Product polish | 6/10 | 9/10 | A focused home screen, consistent result cards, human status language, and clean recovery flows |
| Daily-driver usefulness | 7/10 working target | 9/10 | Fast capture, Apple integrations, corrections, daily brief, and reliable lock-screen access |
| Career and portfolio value | 9/10 | 9.5/10 | Public engineering evidence, a concise demo, reproducible evaluation, and user metrics |

These are product judgments, not scientific measurements. The release gates later in this document are the measurable source of truth.

## 4. Technical Achievement

### 4.1 Build a real end-to-end audio evaluation

Create a representative test set of at least 2,000 recorded commands from 20–30 speakers. It should include:

- Quiet rooms, streets, cars, fans, televisions, and other realistic noise.
- Different ages, speaking speeds, accents, microphone distances, and phone models.
- English, Telugu, Hindi, Telugu-English, and Hindi-English.
- Natural corrections, hesitation, unfinished phrases, and self-rephrasing.
- Contact names, place names, project names, dates, quantities, and unusual grocery items.
- Short commands such as “task,” “checklist,” or “reminder,” followed by free-form content.
- Indirect and synonymous wording instead of only exact training templates.

Evaluate the complete path:

`microphone → transcription → intent/action model → validation → confirmation → saved or Apple action`

Track these separately:

- Speech transcription quality.
- Correct action type.
- Correct field extraction.
- Correct number and order of list items.
- Correct dates and times.
- Correct confirmation behavior.
- Successful final save or system integration.
- End-to-end action success rate.

### 4.2 Support multiple actions in one recording

The user should be able to say:

> “Remind me at six to call Rahul, add milk and coffee to groceries, and note that the client prefers Friday.”

The model should return an ordered bundle of independently validated actions. For the first release, cap a single utterance at five actions to keep review understandable. Each action must have its own status and editable fields.

### 4.3 Add calibrated uncertainty

The system should not treat every prediction as equally certain.

- **High confidence:** Save harmless local actions automatically and show Undo.
- **Medium confidence:** Show a compact review card before saving.
- **Low confidence:** Ask one precise clarification question.
- **Unsafe or incomplete:** Preserve the transcript as a raw note instead of discarding it.

Dates, recipients, and external communication require stricter thresholds than ordinary notes.

### 4.4 Add local correction memory

With explicit permission, store corrections only on the device. The app should learn:

- Contact names and their common misrecognitions.
- Project, company, location, and family names.
- Preferred reminder times and list names.
- Common Telugu/Hindi words that the user speaks inside English sentences.
- Repeated corrections to action type or extracted fields.

The interaction should be understandable: **“Remember this correction on this device.”** Users must be able to inspect and delete learned corrections.

### 4.5 Benchmark real devices

Test at minimum on an older supported iPhone, a mid-range device, and a recent Pro device. Measure:

- Cold-start and warm-start latency.
- Peak memory during transcription and action inference.
- Battery usage over repeated captures.
- Thermal behavior during long sessions.
- Crash-free sessions.
- Short, medium, and long utterances.
- Performance after the phone has been locked or the app backgrounded.

The target for a common warm request is a P95 end-to-end response below five seconds on supported devices.

## 5. Product Uniqueness

### 5.1 Treat code mixing as a first-class product feature

Do not market the product merely as another note-taking app with AI. Demonstrate commands people actually speak:

- “Repu morning nine ki dentist reminder pettu.”
- “Milk, coffee కొనాలి, grocery checklist create cheyyi.”
- “Kal Rahul ko call karna hai, six baje reminder laga do.”
- “Priya ki email draft karo saying the meeting moved to Friday.”

The value is not just recognizing these sentences. It is converting them into correct, editable, local actions.

### 5.2 Show evidence for every action

Trust becomes a differentiator when the result card shows:

- What the app heard.
- What words led to each important field.
- Which destination will receive the action.
- Whether it is saved, pending confirmation, or needs clarification.
- A clear Undo option after safe local actions.

### 5.3 Add grounded conversational follow-ups

Conversation should remain grounded in the user’s notes and current action context. Useful follow-ups include:

- “Move that reminder to Friday.”
- “Add this to the same grocery list.”
- “What tasks did I create yesterday?”
- “Draft a message about that meeting.”

If “that,” “same,” or “it” could refer to multiple records, the assistant should ask which one. It should never invent personal information that is absent from local data.

### 5.4 Match the user’s language style

A lightweight response renderer can answer in English, Telugu, Hindi, or the detected code-mixed style without loading a large conversational model. Keep responses short and assistant-like:

- “Done — I added four items to Groceries.”
- “సరే — రేపు ఉదయం 9కి reminder పెట్టాను.”
- “ठीक है — शुक्रवार के लिए reminder तैयार है.”

The approximately 1.84 GB conversation model should not ship in the first release. A constrained multilingual response layer plus grounded templates gives more practical value within the size limit.

### 5.5 Make system access part of the product

Use Apple App Intents, Shortcuts, widgets, Live Activities where appropriate, and the Action Button to expose a small number of reliable entry points:

- Capture a thought.
- Add to a checklist.
- Create a reminder.
- Ask about existing notes or tasks.
- Review pending confirmations.

## 6. Consumer Readiness

### 6.1 Finish onboarding in under one minute

The first-run flow should ask only for:

1. Recognition language or automatic multilingual mode.
2. A plain-language privacy choice.
3. Permission to download the required language/action pack.
4. One guided sample action.
5. Optional Action Button or Shortcut setup.

Avoid terms such as adapter, quantization, GGUF, MLX, Whisper, or parameter count in the consumer interface.

### 6.2 Use progressive model installation

Show exact sizes before downloading and let the user install only what is required. The core recommendation is:

- Bundle only the application.
- Download speech recognition and the action model after permission.
- Keep semantic search optional.
- Verify model checksums before activation.
- Support pause, resume, repair, and delete.
- Prefer Wi-Fi and warn clearly about mobile data and low storage.

The existing four-bit action model should remain a candidate rather than an automatic release choice. A smaller model is valuable only if it passes every action and safety gate. A realistic target may be approximately 330–400 MB, but measured quality decides promotion.

### 6.3 Keep memory use predictable

Load large components sequentially:

1. Load Whisper, transcribe, then release its memory.
2. Load the action model, generate structured actions, then clear its temporary state.
3. Load semantic search only when the user performs meaning-based search.

The app should continue to function when optional packs are missing, damaged, or being repaired.

### 6.4 Make failure safe and visible

Every request must end in one understandable state:

- Saved.
- Ready for confirmation.
- Needs one clarification.
- Preserved safely as a raw note.
- Failed with a specific recovery action.

Never lose a recording, show an endless spinner, or silently perform a different action. Preserve audio temporarily until the resulting transcript/action is safely stored or the user discards it.

### 6.5 Do not require login for the core product

Core capture, transcription, action creation, and local search should work without an account. Optional private backup or multi-device sync can require authentication later. This keeps onboarding fast and reinforces the privacy position.

## 7. Product Polish

### 7.1 Simplify the home screen

The primary screen should emphasize only:

- One clear capture control.
- Recent notes and actions.
- Search.
- Pending confirmations.

Model management and diagnostics belong in Settings, not on the main path.

### 7.2 Use one consistent action result card

After every voice request, show the same hierarchy:

1. What NoteEchoes understood.
2. The proposed action or actions.
3. Critical editable fields.
4. Confirm, Edit, or Cancel when needed.
5. Undo after safe local creation.

This card should work for notes, tasks, reminders, checklists, emails, messages, and multi-action bundles.

### 7.3 Use human status language

Prefer:

- Listening…
- Understanding…
- Creating three actions…
- Needs confirmation.
- Saved safely.

Avoid exposing engine, adapter, model, checkpoint, or inference terminology.

### 7.4 Make model downloads feel professional

The download screen should provide:

- Exact download and installed sizes.
- Wi-Fi/cellular state.
- Persistent progress after app backgrounding.
- Pause and resume.
- Storage requirement and low-storage recovery.
- Verification status.
- Repair and delete controls.
- A clear explanation of what stops working if a pack is removed.

## 8. Daily-Driver Usefulness

Build in this order:

| Priority | Capability | Why it matters |
|---:|---|---|
| 1 | Lock Screen and Action Button capture | Removes the friction of opening the app |
| 2 | Notes, tasks, reminders, and unlimited checklists | Covers the most frequent daily actions |
| 3 | Multiple actions from one recording | Creates a distinctive speed advantage |
| 4 | Local correction memory | Makes the product improve for each user |
| 5 | Grounded follow-up commands | Turns isolated commands into an assistant workflow |
| 6 | Apple Reminders and Calendar integration | Places actions where users already work |
| 7 | Email and message drafts | Adds communication value without unsafe autonomous sending |
| 8 | Daily “What’s on my plate?” brief | Builds a repeatable morning habit |
| 9 | Optional encrypted private backup | Protects user data without weakening local-first use |
| 10 | Export and sharing | Prevents lock-in and supports collaboration |

The daily brief must be factual and sourced from local records. It can summarize today’s reminders, unfinished tasks, recently updated lists, and items awaiting confirmation. It must not fabricate priorities or events.

## 9. Reliability and Release Gates

Do not advertise 95% real-world reliability until all of these gates are measured:

| Gate | Minimum release requirement |
|---|---|
| Real voice attempts | At least 2,000 |
| Distinct speakers | At least 20 |
| Language modes | English, Telugu, Hindi, Telugu-English, Hindi-English |
| End-to-end action success | Above 95% in every supported language mode |
| Unconfirmed external actions | Zero |
| Lost recordings | Zero |
| Warm-request latency | P95 below 5 seconds on supported devices |
| Model download resume success | Above 98% |
| Crash-free sessions | Above 99.5% |
| Beta duration | 30 testers for two weeks |
| Voluntary retention signal | At least 10 testers continue afterward |

### Evaluation categories

Report results independently for:

- Notes.
- Tasks.
- Reminders.
- Checklists and grocery lists.
- Email drafts.
- Message drafts.
- Prompts or questions.
- Multiple-action requests.
- Follow-up edits.
- Ambiguous requests requiring clarification.

A combined average must not hide a weak language or action category.

## 10. Career and Portfolio Value

NoteEchoes can be a strong resume project because it combines product design, mobile engineering, on-device ML, multilingual evaluation, privacy, and deployment constraints. To make that value obvious:

- Publish an architecture case study without publishing private weights or private datasets.
- Create a 60–90 second demonstration showing a real code-mixed request becoming multiple actions.
- Publish reproducible benchmark methodology and aggregate results.
- Explain why the 0.6B model, progressive downloads, and sequential memory loading were chosen.
- Show failure handling and corrections, not only successful demos.
- Collect TestFlight/App Store usage, reliability, latency, and retention evidence.
- Write resume bullets around measurable outcomes rather than “built an AI app.”

The strongest interview story is the disciplined tradeoff: achieving useful multilingual behavior, privacy, and dependable actions under a strict mobile storage and memory budget.

## 11. Explicit Non-Goals for the First Release

Do not spend first-release time on:

- Shipping the approximately 1.84 GB general conversation model.
- Adding more languages before the current five language modes pass release gates.
- Fancy or highly realistic text-to-speech voices.
- Image generation or social-feed features.
- Competing with general-purpose chatbots.
- Automatically sending email or messages without confirmation.
- Large cloud infrastructure before user demand proves it necessary.
- More consumer-facing model selection screens.

These can be reconsidered only after the core capture-to-action loop is reliable and used repeatedly.

## 12. Recommended Execution Plan

### Phase 1 — Prove reliability

- Add privacy-safe telemetry for stage timing and failure reason.
- Build the 2,000-command real-audio test set.
- Automate end-to-end result comparison.
- Fix the weakest language/action combinations first.
- Benchmark all supported iPhone classes.

### Phase 2 — Build the unique loop

- Implement multiple actions from one utterance.
- Add uncertainty thresholds and focused clarification.
- Add local correction memory.
- Add evidence to every result card.
- Add grounded follow-up actions.

### Phase 3 — Finish the consumer experience

- Simplify onboarding and home.
- Complete resumable, verifiable model downloads.
- Add safe raw-note fallback and recording recovery.
- Finish Action Button, Shortcut, Lock Screen, and Apple action integrations.
- Run accessibility, localization, battery, memory, and offline tests.

### Phase 4 — Validate and release

- Run a two-week TestFlight program with at least 30 people.
- Review failures daily and freeze model/app versions during final measurement.
- Publish an honest model card and privacy explanation.
- Release only after every safety and reliability gate passes.
- Use real retention and failure data to choose the next feature.

## 13. Final Definition of Success

NoteEchoes is ready to be called a unique daily-driver assistant when a user can naturally speak in English, Telugu, Hindi, or a supported mixed style; the app reliably understands the request; proposes the correct structured actions; explains uncertain details; completes or safely stores the result; and remains fast, private, recoverable, and simple enough to use from the Lock Screen every day.

The product wins through **trustworthy action completion**, not through the largest model or the longest list of AI features.

## Reference Links

- [Apple App Intents](https://developer.apple.com/documentation/AppIntents)
- [Apple Core ML model deployment and optimization](https://developer.apple.com/documentation/coreml)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Apple TestFlight](https://developer.apple.com/testflight/)

