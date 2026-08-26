# Conversational Memory, Spoken Reports, and Tag Taxonomy Release

## Release identity

- App version: 2.10.0 (build 14)
- Product position: English-first personal voice memory and action assistant.
- Bundle identifier: `com.vashisht.notechoes`
- Deployment rule: install in place. Never uninstall the previous app, because the local notes, feedback, and downloaded models live in its existing container.

## User-visible behavior

### Report-first spoken conversation

The conversation state now changes in this order:

1. Finish retrieval and generate the grounded report.
2. Publish the completed report to the interface.
3. Open the report at three-quarter height.
4. Wait for the report transition to render.
5. Start spoken playback.

Recording and playback now share the iOS voice-prompt audio session. It defaults to the iPhone speaker when no accessory is selected and supports AirPods through Bluetooth HFP/A2DP routing. Replay remains available in the report.

### Deterministic personal-memory answers

Before general semantic retrieval, the app now resolves common personal-memory questions directly from persisted notes:

- what I wanted or needed to do yesterday, today, or tomorrow;
- pending, forgotten, completed, and remaining checklist work;
- reminders and events by due date;
- saved decisions and ideas;
- saved messages, emails, calls, and follow-ups;
- broad time-based recaps such as “what do I have today?”

Answers cite the real note records shown in the report. The app does not invent a completion date: the current schema stores the current checklist state but not the time at which a checkbox changed. When relevant, the answer states that limitation.

### Canonical tags

Tags are lowercased, deduplicated, and mapped to one purpose-based vocabulary whenever notes load, save, or update. Examples:

- `#task`, `#tasks`, `#task_list`, `#checklist`, and `#todo` become `#tasks`.
- `#reminder` becomes `#reminders`.
- `#calendar_event` becomes `#events`.
- `#email_draft` becomes `#email`.
- `#sms` and `#message_draft` become `#message`.

Operational tags such as `#voice-memo` and `#reminder-scheduled` remain distinct. Existing notes are migrated in place and persisted; content is not deleted.

### Simplified settings

The redundant Privacy & Storage and System Accessibility presentation cards were removed from Settings. The privacy, local-storage, Dynamic Type, and VoiceOver behavior remains implemented; only the unnecessary explanatory rows were removed.

## Verification

- Complete Flutter suite: 115 tests passed.
- New personal-memory tests cover yesterday task recall, tomorrow reminder due dates, forgotten pending work, and unrelated-query fallthrough.
- New taxonomy tests cover duplicate task aliases, reminders, events, email, message, and preservation of operational tags.
- Signed iOS release build passed and its deep code signature was verified.
- Parent app and Live Activity extension both use build 14.
- Version 2.10.0 was installed over 2.9.9 on the connected iPhone using the same bundle identifier.
- The post-install container still contains the note backup and both downloaded MLX model directories, confirming that the upgrade did not erase local data.
- The app launched successfully after installation.

## Manual acceptance on the phone

1. Open Conversation and ask, “What did I want to do yesterday?”
2. Confirm the completed report opens first at three-quarter height and then starts speaking.
3. Test once with the iPhone speaker and once with connected AirPods.
4. Tap Replay and confirm the same answer is spoken from the beginning.
5. Open Topics and confirm equivalent tags no longer appear as separate task/reminder/message filters.

Native route configuration, report ordering, callbacks, signature, and installation are verified in code and build tooling. Human audible-output confirmation still requires listening on the physical device.
