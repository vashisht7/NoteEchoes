# NoteEchoes Core v5 contract

Core v5 emits one action proposal; it never reports execution. The canonical machine contract is `schema/core_v5.schema.json`.

## Intent and provider mapping

| Intent | Proposed provider | Confirmation |
| --- | --- | --- |
| note, idea, decision, project_update | `notes.create` | application policy |
| checklist | `checklists.create` | application policy |
| task | `tasks.create` | application policy |
| reminder | `reminders.propose` | always |
| calendar | `calendar.propose_event` | always |
| message | `messages.compose` | always before send |
| email | `email.compose` | always before send |
| prompt | `prompts.save` | application policy |
| memory_query | `memory.search` | no external write |
| cancel, clarify, noop | no provider | no execution |

Recipient resolution happens after inference. A recipient name is only a query; the application must not silently pick among multiple contacts. Relative date and time phrases remain verbatim for deterministic application resolution.

NORMALIZE and ACTION use the same weights but separate mode tokens. The app validates every response, rejects unsupported keys and enums, checks grounded fields against the raw transcript, and converts invalid or ambiguous proposals to `clarify`/`noop` before storage or execution.

## Dataset truth labels

`approved` means a named reviewer checked the raw transcript, normalized text, full JSON, and spans. `ai_preapproved` from older assets is imported as `unreviewed`; it is never promoted automatically. Validation, test, and challenge rows are release-blocking unless every row is approved, and Hindi/Telugu rows additionally require `native_language_verified=true`.
