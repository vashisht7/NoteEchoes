# NoteEchoes v2.9.1

This update fixes PDFs that could stop opening after an iOS development install and upgrades PDF notes into a visual, readable document experience.

## Reliable PDF attachments

- New uploads use stable relative attachment references instead of an iOS container-specific absolute path.
- Existing PDF references are repaired automatically when iOS changes the app container identifier.
- PDF reading remains completely local and works without Qwen.

## Real PDF cover previews

- PDF note cards on the home page now render the actual first page as their cover.
- PDF attachments inside a note also show the first page instead of a generic PDF icon.
- Covers retain the matte-black NoteEchoes treatment, filename overlay, and clear PDF badge.

## Improved reader and clean text

- Original PDF mode preserves page layout, photographs, diagrams, and embedded images on a matte-black canvas.
- Pinch zoom, scrolling, page controls, and native text selection remain available.
- A new **Read clean text** action converts selectable PDF text into a clean Markdown-style view.
- Clean text is selectable and can be copied in full with one button.
- Scanned PDFs use the existing on-device Apple Vision OCR when clean text is requested.
- Users can switch between the original PDF and clean text without leaving the reader.

## Verification

- Added a regression test that simulates an iOS app-container path change.
- All 26 Flutter tests pass.
- Targeted static analysis is clean.
