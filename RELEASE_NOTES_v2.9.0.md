# NoteEchoes v2.9.0

This update adds a complete in-app PDF reading flow and improves navigation reliability from notes.

## PDF reader

- Tapping any PDF attachment now opens a dedicated full-page reader instead of opening AI chat.
- PDFs remain fully local and can be read without downloading Qwen or another AI model.
- Pinch zoom, vertical reading, selectable text, page count, and previous/next page controls are included.
- A clear back button returns to the original note; the note can then return to the home page normally.
- Document chat remains available as a separate **Ask this PDF** action when the PDF was indexed.
- Missing, damaged, encrypted, or unavailable PDF files show a calm user-facing message instead of a raw engine error.
- VoiceOver labels and compact layouts are included.

## Navigation reliability

- Fixed the note-save/pop timing that could prevent the Notes back control from returning to the home page.
- Fixed a compact-width overflow in the Notes back control.

## Verification

- Dedicated PDF → note navigation test passes.
- Full Flutter test suite and signed iPhone Release build verified for this release.
