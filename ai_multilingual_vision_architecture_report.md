# Note Echoes: Multilingual (Telugu, Tamil, Hindi, English), Document Vision & Synchronized Media Architecture

## 1. Executive Summary & Core Requirements

This report outlines the architecture for extending **Note Echoes** to:
1. **Multilingual Support**: High-fidelity understanding, Speech-to-Text, and Text-to-Speech across **Telugu, Tamil, Hindi, and English**.
2. **Deep Document & PDF Intelligence**: High-precision extraction of **tables, formulas/equations, and diagrammatic images**, with contextual question-answering.
3. **Synchronized Media Presentation during Voice Playback**: Dynamically showcasing the specific referenced image, table, or formula on-screen while speaking, pausing scroll movement during visual explanation, and resuming smooth karaoke text afterwards.
4. **Zero-Bloat App Packaging**: Keeping the base application ultra-lightweight (**~28 MB**) for pure text native AI, while supporting **optional on-demand MLX/CoreML modules** for vision and heavy multilingual offline reasoning.

---

## 2. Multilingual Speech & Language Intelligence Matrix

```
+---------------------------------------------------------------------------------------------------------------+
|                                      MULTILINGUAL SPEECH & TEXT MATRIX                                        |
+------------------------------------+---------------+-------------+---------------+----------------------------+
| Component                          | Engine        | Bundle Size | Latency       | Languages Supported        |
+------------------------------------+---------------+-------------+---------------+----------------------------+
| Real-Time Speech-to-Text (STT)     | Apple Native  | 0 MB        | < 30ms        | en-US, en-IN, hi-IN,       |
|                                    | SFSpeech      | (Built-in)  | (Stream)      | te-IN, ta-IN               |
+------------------------------------+---------------+-------------+---------------+----------------------------+
| High-Accuracy Offline STT Fallback | MLX Whisper   | 140 MB      | ~160ms        | English, Telugu, Tamil,    |
|                                    | Small (Q4)    | (On-demand) |               | Hindi + 95 languages       |
+------------------------------------+---------------+-------------+---------------+----------------------------+
| Real-Time Speech Synthesis (TTS)   | Apple Neural  | 0 MB        | Instant       | Siri Indian English,       |
| & Word Markers (Karaoke)           | AVSpeech      | (Built-in)  | (±20ms sync)  | Hindi, Telugu, Tamil       |
+------------------------------------+---------------+-------------+---------------+----------------------------+
| Multilingual Semantic Embeddings   | NLEmbedding + | 0 MB +      | 1.4ms         | Universal Cross-Lingual    |
| (Vector Similarity Search)         | bge-m3-micro  | 28 MB       | (SIMD vDSP)   | (Query in Telugu/Tamil     |
|                                    |               |             |               |  matches English notes)    |
+------------------------------------+---------------+-------------+---------------+----------------------------+
```

---

## 3. Best-in-Class On-Device Language & Vision Models

To understand complex PDFs (tables, images, formulas) in Telugu, Tamil, Hindi, and English with minimal latency on Apple Silicon (MLX / CoreML):

### 3.1 Model Comparison & Benchmark

| Model | Parameter Count | Modality | Multilingual Quality (Indic + EN) | 4-bit Quantized Size | Inference Speed (M3 / A17 Pro) | Recommended Role |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`Sarvam-2B` (Sarvam AI)** | 2.0 Billion | Text | **Top Tier for Indic** (Native Telugu, Tamil, Hindi tokenizers) | **~1.15 GB** | **~42 tok/sec** | Dedicated Indian Language text reasoning |
| **`Qwen2.5-1.5B-Instruct`** | 1.54 Billion | Text | **Exceptional** across 29+ languages (High Telugu, Tamil, Hindi score) | **~890 MB** | **~52 tok/sec** | Best balance of size and multilingual reasoning |
| **`Qwen2.5-0.5B-Instruct`** | 490 Million | Text | **Good** for categorization, tagging, concise synthesis | **~290 MB** | **~75 tok/sec** | **Ultra-light offline text brain** |
| **`Qwen2.5-VL-3B-Instruct`** | 3.07 Billion | **Vision + Text** | **State-of-the-Art** for tables, math LaTeX formulas, chart reading & Indic | **~1.85 GB** | **~28 tok/sec** | **Full Document Vision & PDF comprehending engine** |
| **`SmolVLM-500M`** | 500 Million | Vision + Text | Moderate Indic, fast English vision | **~340 MB** | **~60 tok/sec** | Lightweight mobile vision |

---

## 4. PDF Structure & OCR Pipeline (Tables, Formulas & Images)

```
                            UPLOADED PDF DOCUMENT
                                      │
                                      ├───► Apple PDFKit (0 MB)
                                      │     • Vector text extraction, headings (#, ##), lists
                                      │     • Image bounding boxes & diagram extraction
                                      │
                                      ├───► Apple Vision OCR VNRecognizeTextRequest (0 MB)
                                      │     • On-device OCR for scanned Telugu, Tamil, Hindi, English
                                      │
                                      └───► Structural Formatter & LaTeX Recognizer
                                            • Table grid reconstruction (Markdown table pipes |---|)
                                            • Equation parsing into LaTeX ($$ ... $$)
                                            • Extracts standalone image artifacts (assets/fig_1.png)
```

---

## 5. Synchronized Media Karaoke & Speech Playback Physics

When the AI answers a question about a PDF or note containing an image, formula, or table:

```
[ AI Spoken Answer Stream ]
           │
           ├── "According to the system architecture diagram..."
           │      │
           │      ▼
           │  [ [[SHOW_MEDIA: arch_diagram.png]] ] ──► POPUP / SPOTLIGHT MEDIA TILE
           │                                            • Image scales smoothly onto center stage
           │                                            • Ambient glow radiates around diagram
           │                                            • Karaoke scroll holds position
           │
           └── "...as shown here, the latency target is 120ms."
                  │
                  ▼
              [ [[RESUME_TEXT]] ] ──────────────────► KARAOKE SCROLL RESUMES
                                                        • Active text phrase glows luminous white
```

---

## 6. App Size & Packaging Architecture

```
+-----------------------------------------------------------------------------------------------------+
|                                      APP PACKAGING BREAKDOWN                                        |
+-----------------------------------------------------------------------------------------------------+
| 📦 BASE APPLICATION (Shipped via App Store / Play Store):                                            |
|   • Core Flutter UI + Apple Music Hybrid Grid + Voice Surfaces: ~24 MB                              |
|   • Apple Native Speech Engine (SFSpeech + AVSpeech): 0 MB (Built into OS)                          |
|   • Apple Native OCR & PDFKit: 0 MB (Built into OS)                                                 |
|   • Native Multilingual Embeddings: 0 MB (Built into OS)                                            |
|   ------------------------------------------------------------------------------------------------- |
|   🎯 TOTAL BASE APP SIZE: ~24 MB – 28 MB (Ultra-Minimal, Installs in Seconds)                      |
+-----------------------------------------------------------------------------------------------------+
| 🚀 OPTIONAL IN-APP DOWNLOADABLE "AI BRAIN PACKS" (On-Demand Resources):                              |
|   1. Tier 1: Light Multilingual Text Brain (Qwen2.5-0.5B CoreML): ~290 MB                           |
|   2. Tier 2: Indic Master Brain (Sarvam-2B CoreML / Telugu, Tamil, Hindi, English): ~1.15 GB        |
|   3. Tier 3: Full Document Vision Brain (Qwen2.5-VL-3B CoreML for Tables & LaTeX Formulas): ~1.85 GB |
+-----------------------------------------------------------------------------------------------------+
```

---

## 7. Recommended Next Steps

1. Keep the active codebase light and fast with **Native Text AI & Speech** as the foundation.
2. Wire up the **Native Swift Bridge** for multi-dialect speech capture (`te-IN`, `ta-IN`, `hi-IN`, `en-IN`).
3. Connect the **Media Tagging & PDF Markdown structural parser** ready to accept future on-demand vision models.
