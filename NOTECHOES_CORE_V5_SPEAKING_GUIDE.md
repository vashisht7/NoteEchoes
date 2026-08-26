# How to speak to NoteEchoes Core v5

Core v5 is designed for natural speech. Say what you want captured or prepared; you do not need to speak JSON or special commands.

## Best pattern

Use one clear action per dictation:

> Create a [note/checklist/task/reminder/event/message/email/prompt] for [content], with [person/date/time/place] if needed.

You can correct yourself naturally with “actually,” “no,” or “I mean.” The final correction wins.

## Examples

- Note: “Save a note that offline search must remain available.”
- Idea: “Capture this idea: show related memories while I’m writing.”
- Decision: “Record the decision to move the launch to Tuesday.”
- Project update: “Save a project update that the demo is blocked by API review.”
- Checklist: “Create a checklist: first review the mockups, second update the timeline, and third send the summary.”
- Task: “Create a task to verify the backup.”
- Reminder: “Remind me tomorrow at 6 PM to call Priya about the launch review.”
- Calendar: “Create a calendar event for the launch review next Monday at 9:30 AM in Conference Room B.”
- Message: “Draft a message to Priya saying I will join the review at six.”
- Email: “Draft an email to Rahul, subject Updated Budget, saying the revised numbers are ready.”
- Prompt: “Write a short prompt for an assistant to review this code for data-loss risks.”
- Memory query: “What did I save about the Telugu transcription issue?”
- Cancel: “Cancel this recording.”
- Correction: “Remind me Friday—actually, no, remind me Monday at 6 PM—to call Priya.”

Hindi, Telugu, and Romanized/code-mixed speech are supported, for example:

- “कल शाम 6 बजे Priya को call करने का reminder लगाओ।”
- “Repu 6 PM ki Priya ki call cheyyadaniki reminder pettu.”
- “ఈ checklist create చేయి: first mockups review చేయి, second timeline update చేయి, third summary పంపు.”

## Safety behavior

Core v5 prepares proposals; it does not silently send or schedule anything. Messages, emails, reminders, and events must be shown for confirmation. If a recipient or time is unclear, NoteEchoes should ask instead of guessing.

For the most reliable first release, dictate different provider actions separately. A checklist can contain many items, but a combined request such as “send a message, schedule an event, and delete the note” should trigger clarification rather than silent multi-tool execution.
