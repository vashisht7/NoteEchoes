# NoteEchoes v2.7.0

This release brings the current app work together into a polished, daily-use iPhone build.

## What changed

- Refined the app-wide visual theme, spacing, navigation, editor surfaces, and voice experience.
- Added durable SQLite note storage with migration and recovery safeguards for existing notes.
- Added on-device checks for the Qwen and Whisper models, with clear feature availability and download guidance.
- Improved conversational voice mode with a more natural Apple voice, accurate spoken-text highlighting, and immediate speech cancellation when leaving the screen.
- Fixed search-to-home navigation and conversation-mode layout overflow.
- Added inline checklists at the cursor position.
- Improved tables with column insertion and Return-key row creation.
- Added reduced-motion, Dynamic Type, and VoiceOver support throughout key flows.
- Updated native iOS services and the Xcode project so the Flutter app can be built and run directly on an iPhone.

## Verification

- Flutter interaction, accessibility, and storage tests pass.
- The Release app passes deep code-signature verification.
- The build was installed and launched successfully on the connected physical iPhone.

## IPA installation note

The attached IPA is a development-signed build. It can be installed on devices registered in its Apple development provisioning profile. This signing profile expires on August 21, 2026. For wider or longer-lived distribution, publish the same source through TestFlight or the App Store.
