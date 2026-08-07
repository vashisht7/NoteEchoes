# `design.md` — Note Echoes System Architecture & UI/UX Specification

---

## 1. Executive Summary & Design Philosophy

**Note Echoes** is a next-generation AI-powered note-taking application designed for Google Stage. It bridges spatial visual note organization with conversational voice interaction. 

### Core Pillars
1. **Matte Black Aesthetics**: Dark, modern, glare-free layout inspired by Apple Music's vibrant tile art and dark glassmorphism.
2. **Hybrid Grid System**:
   - **Rich Media Notes** (Images, future PDFs): Displayed as prominent Apple Music-style album tiles with image artwork, subtle gradient overlays, and brief note descriptions.
   - **Text-Only Notes**: Displayed in a responsive dual-column staggered masonry grid inspired by Google Keep.
3. **Immersive Voice Interaction**: Pure pitch-black full-screen voice mode featuring liquid ripple audio capture, nebula context visualization, synchronized lyric-style playback highlighting, and single-tap copy actions.

---

## 2. Visual Design System

### 2.1 Color Palette

```
+-------------------------------------------------------------------+
| BASE BACKGROUNDS                                                  |
|  - Deep Matte Black:       #0A0A0C  (Primary Screen Canvas)       |
|  - Elevation 1 (Cards):    #141418  (Surface Tiles)               |
|  - Elevation 2 (Elevated): #1E1E24  (Search & Modals)            |
|  - Glassmorphic Tint:      rgba(255, 255, 255, 0.05)              |
+-------------------------------------------------------------------+
| VOICE & STATE ACCENTS                                            |
|  - Droplet Red (Mic):      #FF2D55  (Ripple Active State)         |
|  - Droplet Red Soft:       rgba(255, 45, 85, 0.25)                |
|  - Nebula Violet:          #7D2AE8  (AI Thinking Gradient A)      |
|  - Nebula Cyan:            #00F2FE  (AI Thinking Gradient B)      |
|  - Nebula Magenta:         #FF0844  (AI Thinking Gradient C)      |
+-------------------------------------------------------------------+
| TYPOGRAPHY & OVERLAYS                                             |
|  - Primary Text:           #F5F5F7  (100% Opacity White)          |
|  - Secondary Text:         #8E8E93  (60% Opacity Muted)           |
|  - Highlighted Lyric:      #FFFFFF  (Active Voice Text + Glow)    |
|  - Dimmed Lyric:           #48484A  (Past/Future Text)            |
+-------------------------------------------------------------------+
```

### 2.2 Typography System

- **Primary Font Family**: `SF Pro Display` / `Inter` / `Roboto`
- **Voice Lyrics Font**: `SF Pro Rounded` / `Outfit`
  - *Active Lyric*: 28pt, Extra-Bold (Weight 800), Line Height 1.3, Letter Spacing -0.5px.
  - *Inactive Lyric*: 22pt, Medium (Weight 500), Line Height 1.3, Opacity 0.35, Blur 1px.

---

## 3. Screen Breakdown & UI Specifications

---

### Screen 1: Home Page (`/home`)

#### Header Section
- **App Name**: `"Note Echoes"` positioned top-left (Font: Bold 24pt, White `#F5F5F7`).
- **Search Button**: Positioned top-right (Magnifying Glass Icon inside `#1E1E24` pill badge).
  - **Search Focus Interaction**:
    - When clicked, all background note tiles dim down to 20% opacity.
    - The search bar expands horizontally across the entire top header, highlighting with a sleek white border glow (`#FFFFFF` at 20% opacity) and showing an active blinking cursor.
    - Live search results filter instantaneously below.

#### Main Canvas Layout
```
+-----------------------------------------------------------------------+
|  Note Echoes                                                 [ 🔍 ]   |
+-----------------------------------------------------------------------+
|                                                                       |
|  +-----------------------------------------------------------------+  |
|  | [ RICH MEDIA TILE - APPLE MUSIC ALBUM ART STYLE ]               |  |
|  | +-------------------------------------------------------------+ |  |
|  | |                                                             | |  |
|  | |                   [ Image / PDF Canvas ]                    | |  |
|  | |                                                             | |  |
|  | +-------------------------------------------------------------+ |  |
|  | | Project UI Specs                                            | |  |
|  | | Updated design tokens and system architecture diagrams...   | |  |
|  | +-------------------------------------------------------------+ |  |
|  +-----------------------------------------------------------------+  |
|                                                                       |
|  +-------------------------------+ +-------------------------------+  |
|  | [ TEXT NOTE TILE ]            | | [ TEXT NOTE TILE ]            |  |
|  | Grocery List                  | | AI Prompts                    |  |
|  | • Almond milk                 | | 1. Generate design specs    |  |
|  | • Dark roast coffee           | | 2. Refactor state machine     |  |
|  | • Oats                        | |                               |  |
|  +-------------------------------+ +-------------------------------+  |
|                                                                       |
+-----------------------------------------------------------------------+
|              [  + Add Note  ]     [ 🎙️ Voice Mode ]     [ ⚙️ ]         |
+-----------------------------------------------------------------------+
```

#### Tile Rendering Rules
1. **Rich Media Note Tiles (Images & PDFs)**:
   - Aspect Ratio: 1:1 or 16:9 full card presentation.
   - Design: Apple Music album cover layout with full-bleed background image, dark gradient vignette at the bottom, crisp rounded corners (`18px`), elevated subtle dropshadow, and a 2-line preview description overlaid over frosted glass blur (`backdrop-filter: blur(12px)`).
   - Future PDF Integration: Render PDF page 1 high-res preview thumbnail with a small PDF badge tag in the upper right.
2. **Standard Text Note Tiles**:
   - Layout: Dual-column masonry grid (Google Keep / Google Notes style).
   - Design: Flat `#141418` surface card, subtle inner border (`rgba(255, 255, 255, 0.08)`), rounded corners (`12px`), title in bold white, and content truncated at 4 lines.

#### Bottom Floating Navigation Bar
- Frosted glass floating pill elevated at the bottom center (`#1E1E24` with 80% backdrop blur).
- Buttons:
  1. **`+` (Add Note)**: Opens standard text/media editor sheet.
  2. **`🎙️` (Voice Button)**: Primary accent trigger for Voice Assistant Mode.
  3. **`⚙️` (Settings Button)**: Gear icon leading to app configurations.

---

### Screen 2: Voice Mode Screen (`/voice-assistant`)

When the user taps the mic button at the bottom, the screen transitions smoothly into full-screen Pitch Black (`#000000`). This mode transitions across 3 synchronized operational states:

---

#### State 2.1: Listening State
- **Background**: Pitch Black (`#000000`).
- **Center Visualizer**: 
  - A vivid red core droplet (`#FF2D55`) positioned at the lower-center.
  - When the user speaks, concentric circular ripples radiate outward from the droplet (`rgba(255, 45, 85, 0.35)` to `transparent`), scaling dynamically based on realtime mic input amplitude.
- **Transcript Display (Apple Music Lyrics Style)**:
  - Speech-to-Text output streams in real-time.
  - Words scroll smoothly upward in large, rounded typography.
  - The current active sentence is crisp, bold, and bright white (`#FFFFFF`), while previous lines drift upward and softly fade out with a subtle motion blur.

```
+-----------------------------------------------------------------------+
|                                                                       |
|                     "Summarize my notes about                         |
|                      the Gemini API integration..."                   |  <-- Bold, Glowing
|                                                                          Apple Music Lyric
|                                                                          Typography
|                                                                       |
|                                                                       |
|                                                                       |
|                                ( ( 🔴 ) )                             |  <-- Rippling Red Water
|                                                                          Droplet Visualizer
+-----------------------------------------------------------------------+
```

---

#### State 2.2: Thinking / Processing State
- **Trigger**: System stops detecting audio input / processes AI inference.
- **Center Visualizer (The Nebula)**:
  - Red droplet smoothly morphs into an organic, liquid **Nebula** with irregular, wiggling fluid physics (combining Cyan `#00F2FE`, Violet `#7D2AE8`, and Pink `#FF0844`).
- **Orbiting Context Notes (Circular Carousel)**:
  - Existing relevant note cards shrink into miniature circular preview badges orbiting in a 360-degree ring around the central wiggling Nebula.
  - **1-Second Step Rotation**: Every 1 second, the ring rotates by `360 / N` degrees, highlighting each candidate note for 1 second to show the AI actively scanning context memories.

```
+-----------------------------------------------------------------------+
|                                                                       |
|                            [ Note Tile 1 ]                            |
|                          /                 \                          |
|             [ Note Tile 4 ]    ( NEBULA )   [ Note Tile 2 ]           |
|                          \                 /                          |
|                            [ Note Tile 3 ]                            |
|                                                                       |
|                       "Thinking & searching..."                       |
+-----------------------------------------------------------------------+
```

---

#### State 2.3: Result & Speaking State
- **Voice Response Playback**: Google AI text-to-speech voice answers the user query.
- **Synchronized Lyric Highlighting**:
  - Response text displays in Apple Music Karaoke / Lyric format.
  - As the voice speaks each word/phrase, the corresponding text line transitions from muted grey (`#48484A`) to luminous white (`#FFFFFF`) with a dynamic ambient light glow behind the active phrase.
- **Copy & Quick Actions**:
  - **Copy Button**: Floating quick-action pill (`[ 📋 Copy Note ]`) appears at the top right of the transcript display for single-tap clipboard copying.

```
+-----------------------------------------------------------------------+
|                                                      [ 📋 Copy Note ] |
|                                                                       |
|  I found 2 notes matching your query.                                 |  <-- Past Lyric (Muted)
|                                                                       |
|  Here is the summary of the Gemini API specifications                 |  <-- ACTIVE SPOKEN LYRIC
|  and data structures...                                               |     (Bright White Glow)
|                                                                       |
|  Would you like me to create a new task list?                         |  <-- Future Lyric (Dimmed)
|                                                                       |
|                                  🔊                                   |
+-----------------------------------------------------------------------+
```

---

### Screen 3: Settings Screen (`/settings`)

Designed following standard modern AI note-taking standards (Google Keep / Google Notes / Stage baseline specifications):

1. **AI & Voice Configuration**:
   - Voice Model Speed & Pitch controls.
   - Automatic Speech Recognition Language selection.
   - Context Retrieval Memory Threshold (Slider).
2. **Storage & Cloud Sync**:
   - Google Drive Auto-Sync Toggle.
   - Media Compression Quality (Original vs. Optimized for PDF / Images).
3. **Display & Visuals**:
   - Pitch Black OLED Mode (Default: Always On).
   - Tile Grid Density (Compact / Cozy / Apple Music Large Tiles).
4. **Data Management**:
   - Export Notes (`.md`, `.json`, `.pdf`).
   - Import Notes from Google Keep / Markdown files.

---

## 4. Animation & Physics Specifications

| Component | Trigger State | Animation / Transition Type | Duration & Easing |
| :--- | :--- | :--- | :--- |
| **Search Focus** | Tap Search Icon | Horizontal Expansion + Opacity Blur on Notes | `300ms`, cubic-bezier(0.16, 1, 0.3, 1) |
| **Mic Ripple** | Audio input detected | Concentric scale out (`1.0` -> `2.4`) + Fade Out | Continuous dynamic frame rendering |
| **Nebula Morph** | Listening -> Thinking | Liquid shape deformation + Multi-color blur blend | `600ms`, spring(1, 80, 10) |
| **Orbital Note Scan**| Thinking State | 360° Circular step rotation | `1000ms` per step rotation interval |
| **Karaoke Text** | Audio TTS playback | Linear line highlight with scale bump (`1.0` -> `1.04`) | Synced to audio timestamp cues (`±50ms`) |

---

## 5. Technical Data Structure (JSON Architecture)

```json
{
  "note_id": "echo_98412",
  "title": "Stage UI System Architecture",
  "content_type": "rich_media",
  "media_assets": [
    {
      "type": "image",
      "url": "assets/diagram.png",
      "preview_tile_aspect": "1:1"
    },
    {
      "type": "pdf",
      "url": "assets/specs.pdf",
      "page_count": 12
    }
  ],
  "summary_snippet": "Updated design tokens and system architecture diagrams for Note Echoes matte black interface.",
  "text_content": "Full markdown content goes here...",
  "created_at": "2026-08-07T16:42:00Z",
  "tags": ["design", "stage", "google-ai"]
}
```
