# TASK SPECIFICATION: Add Pitch-Black Voice Mode with Meta AI Dream Bubble & Water Droplet Physics

## 🎯 OBJECTIVE
Integrate the "Note Echoes" Voice Assistant surface into our existing Flutter codebase as a new modal/route screen. Ensure zero breaking changes to existing home screen widgets or data models.

---

## 🛠️ STEP-BY-STEP IMPLEMENTATION PLAN FOR ANTIGRAVITY AGENTS

### STEP 1: Add Data Model & Core Types
Create a new file `lib/models/note_node.dart` (if not already existing):

```dart
class NoteNode {
  final String id;
  final String title;
  final String snippet;

  const NoteNode({
    required this.id,
    required this.title,
    required this.snippet,
  });
}

enum VoiceState { listening, thinking, speaking }
```

---

### STEP 2: Create Custom Painter Widget
Create `lib/widgets/voice_visualizer_painter.dart`:
- Implement `VoiceVisualizerPainter` extending `CustomPainter`.
- **State 1 (`listening`)**: Draw concentric light red (`#FF2D55`) liquid ripple circles expanding outward from center. Render impact center point.
- **State 2 (`thinking`)**: Draw a translucent light red Meta AI style **Dream Bubble** with an outer ambient glow (`#FF0844`), an organic wiggling border path using trigonometric noise, and a specular highlight rim.

---

### STEP 3: Create Full-Screen Voice Surface
Create `lib/screens/voice_assistant_screen.dart`:
1. Use `Scaffold` with pitch black background (`Color(0xFF000000)`).
2. Stack layers:
   - **Layer 1**: `CustomPaint` driven by `AnimationController`.
   - **Layer 2 (Thinking)**: Wrap candidate `NoteNode` cards inside an `AnimatedRotation` widget that steps `(2 * pi / N)` radians every 1000ms. Keep card text upright using counter-rotation.
   - **Layer 3 (Listening / Speaking)**: Large bold Apple Music Lyrics style typography (`TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)`).
   - **Layer 3 Action**: Add a floating sticky `[ 📋 Copy Note ]` button in Speaking State using `Clipboard.setData()`.

---

### STEP 4: Connect Trigger to Existing Home Screen
Open our existing `HomeScreen` widget (or main bottom navigation bar):
- Locate the central Mic floating action button (`🎙️`).
- Attach `onPressed`:
  ```dart
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const VoiceAssistantScreen(
        currentState: VoiceState.listening,
      ),
    ),
  );
  ```

---

### STEP 5: Verification Checklist for Antigravity Subagent
1. Run `flutter analyze` to ensure zero compilation errors.
2. Launch Flutter Web / Emulator via Antigravity Browser tool.
3. Click the Mic button to confirm smooth transition into pitch-black voice mode.
4. Verify the water drop ripples outward on `listening`.
5. Verify candidate nodes float and rotate **inside** the light red Dream Bubble on `thinking`.
6. Test the "Copy Note" button on `speaking`.
