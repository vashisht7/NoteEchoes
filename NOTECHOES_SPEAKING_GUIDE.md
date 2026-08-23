# How to Speak to NoteEchoes Core v4

Last verified: 2026-08-23

## 1. The short version

You do not need to memorize a command language. Speak naturally, but make the intended result explicit.

The most reliable sentence pattern is:

```text
intent + content + date/time if needed + person/place if needed
```

Examples:

```text
Save this as an idea: related notes should appear beside every project.
Add “send the design” to my task list.
Remind me tomorrow at 6 PM to call Ravi.
Schedule a review with Maya next Monday at 3 PM.
```

Telugu, Hindi, English words, and Romanized speech can be mixed naturally. Exact action words such as `task`, `checklist`, `reminder`, `calendar`, `idea`, `decision`, and `update` make routing more dependable.

## 2. What happens after you speak

1. Whisper or Apple Speech converts audio to text.
2. Core v4 interprets that text.
3. The app validates the model output and applies safety rules.
4. Notes/tasks are shown in the existing NoteEchoes UI.
5. Reminders and calendar events are proposed for review; the model does not silently schedule them.

If transcription is wrong, the action model may also be wrong. Check important names, dates, and times before confirming.

## 3. Plain notes

Use plain notes for facts, thoughts, or information that should be remembered without an action.

| Style | Example |
| --- | --- |
| English | Save this note: the offline model should remain optional. |
| Telugu | ఈ note save చెయ్యి: offline model optional గానే ఉండాలి. |
| Romanized Telugu | ee note save cheyyi: offline model optional gaane undali. |
| Hindi | यह note save कर लो: offline model optional रहना चाहिए। |
| Romanized Hindi | yeh note save kar lo: offline model optional rehna chahiye. |

Expected result: a normal note with no task, reminder, or calendar action.

## 4. Ideas and brainstorming

Start with “idea,” “quick idea,” or “brainstorm” when you do not want the thought converted into work automatically.

| Style | Example |
| --- | --- |
| English | Quick idea: show related notes beside every project. |
| Telugu | ఒక idea: ప్రతి project పక్కన related notes చూపించాలి. |
| Romanized Telugu | oka idea: prati project pakkana related notes chupinchali. |
| Hindi | एक idea है: हर project के साथ related notes दिखने चाहिए। |
| Romanized Hindi | ek idea hai: har project ke saath related notes dikhne chahiye. |

For extra safety:

```text
This is only an idea; do not make a task or reminder.
ఇది idea మాత్రమే; task లేదా reminder create చేయొద్దు.
idi idea matrame; task leka reminder create cheyyoddu.
यह सिर्फ idea है; task या reminder मत बनाना।
yeh sirf idea hai; task ya reminder mat banana.
```

## 5. Decisions

Use “decision” or “final decision” so the note is retained as a decision rather than a task.

| Style | Example |
| --- | --- |
| English | Final decision: reminders must always require confirmation. |
| Telugu | Final decision: reminder create చేసే ముందు confirmation తప్పనిసరి. |
| Romanized Telugu | final decision: reminder create chese mundu confirmation tappanisari. |
| Hindi | Final decision: reminder बनाने से पहले confirmation जरूरी है। |
| Romanized Hindi | final decision: reminder banane se pehle confirmation zaroori hai. |

Expected result: a saved decision note, not an automatically scheduled reminder.

## 6. Project updates

Say the project/product name followed by “update.”

| Style | Example |
| --- | --- |
| English | NoteEchoes update: model download works, but Telugu voice testing is pending. |
| Telugu | NoteEchoes update: model download పని చేస్తోంది, Telugu voice testing ఇంకా pending. |
| Romanized Telugu | NoteEchoes update: model download work avtundi, Telugu voice testing inka pending. |
| Hindi | NoteEchoes update: model download काम कर रहा है, Telugu voice testing अभी pending है। |
| Romanized Hindi | NoteEchoes update: model download kaam kar raha hai, Telugu voice testing abhi pending hai. |

Expected result: a project-update note. A status word such as “pending” alone does not necessarily create a task unless you ask for one.

## 7. Tasks

Use `task`, `to-do`, `task list`, or `checklist` when you want work created.

| Style | Example |
| --- | --- |
| English | Add “test the model on iPhone” to my task list. |
| Telugu | iPhone లో model test చేయడం task list లో పెట్టు. |
| Romanized Telugu | iPhone lo model test cheyyadam task list lo pettu. |
| Hindi | iPhone पर model test करना task list में डाल दो। |
| Romanized Hindi | iPhone par model test karna task list mein daal do. |

If there is a deadline, say it explicitly:

```text
Add “review the release build” to my task list; it is due Friday.
Release build review చేయడం task list లో పెట్టు, Friday లోపు పూర్తి చేయాలి.
Release build review task list mein daal do, Friday tak complete karna hai.
```

## 8. Checklists with real items

The model is instructed not to invent steps. Say each item that should appear.

| Style | Example |
| --- | --- |
| English | Create a checklist: verify download, test Telugu reminder, test Hindi calendar, and record the results. |
| Telugu | Checklist create చెయ్యి: download verify చేయాలి, Telugu reminder test చేయాలి, Hindi calendar test చేయాలి, results note చేయాలి. |
| Romanized Telugu | checklist create cheyyi: download verify cheyyali, Telugu reminder test cheyyali, Hindi calendar test cheyyali, results note cheyyali. |
| Hindi | Checklist बनाओ: download verify करना, Telugu reminder test करना, Hindi calendar test करना, और results note करना। |
| Romanized Hindi | checklist banao: download verify karna, Telugu reminder test karna, Hindi calendar test karna, aur results note karna. |

Expected result: only the spoken items. If you merely say “make a checklist for launch,” the model should not invent a complete launch plan.

## 9. Reminders

For the best result, include both day/date and exact time.

| Style | Example |
| --- | --- |
| English | Remind me tomorrow at 6 PM to call Ravi. |
| Telugu | రేపు సాయంత్రం 6కి Ravi కి call చేయాలని reminder పెట్టు. |
| Romanized Telugu | repu evening 6 ki Ravi ki call cheyyalani reminder pettu. |
| Hindi | कल शाम 6 बजे Ravi को call करना है, reminder लगा दो। |
| Romanized Hindi | kal evening 6 baje Ravi ko call karna hai, reminder laga do. |

Expected result: a reminder proposal. The app should resolve the spoken time, show it, and ask for confirmation before scheduling.

### Ambiguous reminder wording

These should trigger a clarification instead of guessing:

```text
Remind me later to check the oven.
తర్వాత అమ్మకి call చేయాలని గుర్తు చెయ్యి.
बाद में मुझे report भेजने की याद दिलाना।
```

The app should ask which time to use. For fewer follow-up questions, say an exact time initially.

## 10. Calendar events

Use `schedule`, `calendar`, `meeting`, or `appointment`, plus a date/time. The words `calendar` or `schedule` help distinguish an event from a reminder.

| Style | Example |
| --- | --- |
| English | Schedule a NoteEchoes review with Maya next Monday at 3 PM. |
| Telugu | వచ్చే సోమవారం 3 PM కి Maya తో NoteEchoes review calendar లో add చెయ్యి. |
| Romanized Telugu | next Monday 3 PM ki Maya tho NoteEchoes review calendar lo add cheyyi. |
| Hindi | अगले सोमवार 3 बजे Maya के साथ NoteEchoes review calendar में add कर दो। |
| Romanized Hindi | next Monday 3 PM par Maya ke saath NoteEchoes review calendar mein add kar do. |

Optional details can be spoken naturally:

```text
Schedule a design review with Maya and Ravi next Monday at 3 PM in Conference Room B.
```

Expected result: an event preview with people/place when extracted, followed by confirmation.

## 11. Task plus reminder in one sentence

Simple, clearly separated wording is more dependable than a long paragraph.

| Style | Example |
| --- | --- |
| English | Add “send the design” to my tasks, then remind me Friday at 9 AM. |
| Telugu | Design పంపడం task list లో పెట్టి, Friday 9 AM కి గుర్తు చెయ్యి. |
| Romanized Telugu | design pampadam task list lo pettu, alage Friday 9 AM ki gurthu cheyyi. |
| Hindi | Design भेजना task list में डालो, साथ में Friday 9 AM पर याद दिलाओ। |
| Romanized Hindi | design bhejna task list mein dalo, saath mein Friday 9 AM par yaad dilao. |

Expected result: one task and one reminder proposal. If the two actions are complex, speak them as two separate captures for maximum reliability.

## 12. Natural mind dumps

NoteEchoes can preserve a longer thought while extracting a clearly requested task. Explicitly say which portion is actionable.

```text
Mind dump: the home screen should stay simple, related notes might be useful, and I need to discuss it with Ravi on Friday. Put only “discuss home screen with Ravi” in my task list. Do not create a reminder.
```

For long, high-stakes mind dumps, review the resulting note and actions. The raw compact model is less reliable on repetitive multi-action speech; the app guardrails cover known patterns but not every possible sentence.

## 13. Questions about saved notes

Ask about a concrete subject, project, person, or decision so retrieval can find the supporting notes.

| Style | Example |
| --- | --- |
| English | What did I decide about reminder confirmation? |
| Telugu | Reminder confirmation గురించి నేను ఏం decide చేశాను? |
| Romanized Telugu | reminder confirmation gurinchi nenu em decide chesanu? |
| Hindi | Reminder confirmation के बारे में मैंने क्या decide किया था? |
| Romanized Hindi | reminder confirmation ke baare mein maine kya decide kiya tha? |

Other useful forms:

```text
What is the latest update on NoteEchoes model testing?
Maya గురించి నా notes లో ఏముంది?
Personal Finance project ka latest decision kya tha?
```

The model weights do not contain the user's memories. The application must retrieve relevant saved notes and provide them as context. If the note does not exist or retrieval misses it, the model cannot answer reliably.

## 14. Explicitly preventing actions

Use direct negative wording when mentioning an action word without wanting the action.

```text
Save this as a note only; do not create a task or reminder.
Note గా మాత్రమే save చెయ్యి; task లేదా reminder create చేయొద్దు.
note ga matrame save cheyyi; task leka reminder create cheyyoddu.
सिर्फ note save करो; task या reminder मत बनाना।
sirf note save karo; task ya reminder mat banana.
```

## 15. Email, messages, and coding prompts: current limitation

The historical v2 training pack contains multilingual email, Slack-message, and coding-prompt examples. The final Core v4 model intentionally excludes all three categories. Its current system prompt says to store these requests as ordinary notes with no actions.

Therefore these spoken phrases are **not a verified Core v4 generation feature**, even in English:

```text
Draft an email to Priya saying the build is ready.
Write a Slack message asking whether 4 PM works.
Turn this into a Codex prompt.
```

The broader application contains separate prompt-generation infrastructure, but the current spoken Core v4 router does not route to it. Until a separate English draft/prompt route is implemented, expect these to be captured as notes rather than polished drafts.

Telugu/Hindi email and prompt generation remain intentionally out of scope according to the stated product requirement.

## 16. Journal and meeting labels

The JSON schema contains `journal` and `meeting`, but the final dataset report does not show dedicated journal/meeting training rows. You may still save meeting notes or journal text as normal notes, but do not depend on consistent specialized classification yet.

Safer phrasing:

```text
Save this note: meeting with Maya—download works, device testing is pending.
Save this as a journal note: I felt focused after completing the model release.
```

## 17. Features that are not controlled by this action model

Some NoteEchoes functions are UI or separate-engine features:

- Drawing and Apple Pencil markup
- Rich text, Markdown, tables, and manual checklists
- PDF import, reading, OCR, and document chat
- Whisper/Apple Speech transcription quality
- E5 semantic embeddings and topic clustering
- Manual note editing, pinning, deletion, and export

Speaking examples in this guide describe the Core v4 capture/action path, not every screen in the application.

## 18. Best-practice checklist

- State the desired object: note, idea, decision, task, reminder, or calendar event.
- For reminders/events, say a day/date and exact time.
- Say checklist items individually; do not expect invented planning steps.
- Use `calendar` or `schedule` for events.
- Name the person and place explicitly when important.
- Separate multiple complex actions into separate captures.
- Say “do not create…” when mentioning actions only as discussion.
- Review transcription before confirming important dates/names.
- Ask memory questions with concrete keywords.
- Keep the app open during the one-time Core v4 model download.
