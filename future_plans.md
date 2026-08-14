# NoteEchoes Future Plans

Last updated: August 14, 2026

## Product direction

NoteEchoes will remain a privacy-first iOS notes application. The core note,
voice-capture, local search, PDF, and offline-AI experience should stay useful
without a subscription. Paid plans will fund services with continuing costs,
such as encrypted synchronization, cloud storage, and optional cloud AI.

## Current free foundation

- Notes, tables, checklists, drawings, and the glass-style interface.
- Action Button and Apple Shortcut capture with durable background ingestion.
- Multilingual Unicode note storage and newest-note-first ordering.
- PDF import, on-device text/OCR extraction, indexing, summaries, and grounded
  document questions.
- Local notebook memory and grounded questions over saved notes.
- Optional Qwen3-0.6B MLX 4-bit model download for local summaries and chat.
- Export, local deletion, and private on-device storage.

The current app uses Apple or the user's Shortcut for speech transcription and
does not bundle a speech model. Telugu, Hindi, and English transcription depends
on the language chosen in the Shortcut/device speech configuration. A dedicated
offline Whisper model remains a future milestone.

## Device-aware downloads

The app should check Apple Foundation Models availability and locale support at
runtime instead of relying only on the iPhone model name.

| Device result | Recommendation shown to the user |
| --- | --- |
| Apple Intelligence available and selected locale supported | Use the system model; no separate text model is required. Offer the speech pack when released. |
| Apple Intelligence disabled or its model is not ready | Explain how to enable or finish downloading it, and offer Qwen as a fallback. |
| Apple Intelligence available but Telugu is unsupported | Recommend the Qwen text model and Telugu speech pack. |
| Device is not eligible | Recommend Qwen when RAM permits; otherwise keep basic notes, search, PDF extraction, and Shortcut transcription available. |
| Storage is limited | Install voice support first and make Qwen optional. Show the exact download and required free space before confirmation. |

### Planned local package sizes

| Component | Approximate size | Delivery |
| --- | ---: | --- |
| Current unsigned release application and frameworks | 77 MB measured | App installation |
| Whisper Small multilingual | 250 MB | Optional future download |
| Qwen3-0.6B MLX 4-bit | 351 MB | Optional download |
| Model/runtime overhead | 50-80 MB | As required |
| Complete local configuration | 728-758 MB estimated | App plus optional downloads |

The earlier 880-910 MB estimate used a much larger debug build measurement. The
current unsigned release build is approximately 77 MB before App Store thinning
or signing, so the updated complete-local estimate is 728-758 MB. The base app
is not 9-10 MB. User notes, recordings, PDFs, caches, and model updates can
increase storage beyond this estimate.

## Free plan

The following should remain free:

- Unlimited local notes and local search.
- Action Button capture and Shortcut ingestion.
- Telugu, Hindi, and English voice capture where supported by the selected
  device/Shortcut transcription language.
- Local note memory, PDF indexing, basic summaries, and grounded Q&A.
- Apple Intelligence integration on eligible devices.
- Optional local Qwen fallback.
- Privacy controls, export, and deletion.

## Sustainable monetization

| Offering | Suggested price | Ongoing value |
| --- | ---: | --- |
| Free | $0 | Complete local-first core experience |
| Supporter | $9.99-$19.99 one-time | Extra themes, advanced organization, automation templates, and supporter badge |
| Cloud Plus | $2.99-$4.99/month | Encrypted sync, cross-device memory, cloud backup, advanced multi-PDF reasoning, and a monthly cloud-AI allowance |
| Advanced AI credits | $1.99-$2.99 per pack | Optional high-cost cloud questions without a subscription |
| Bring Your Own Key | $0 platform markup | User supplies a supported AI-provider key |
| Tip jar | $0.99-$9.99 | Voluntary support for continued development |

Subscriptions should only be introduced when NoteEchoes delivers continuing
server-backed value. Local privacy, export, and essential accessibility should
not be paywalled.

## Recommended services

- Apple Foundation Models for system-provided on-device intelligence.
- MLX and Qwen for the downloadable offline fallback.
- WhisperKit for a future dedicated Telugu/Hindi/English speech pack.
- CloudKit for the simplest iOS-first encrypted synchronization path.
- OpenAI or another replaceable provider for opt-in advanced cloud reasoning.
- StoreKit 2 for one-time purchases, subscriptions, credit packs, and tips.
- Supabase only if NoteEchoes later expands to Android or the web.

## Custom-model roadmap

NoteEchoes should not train a foundation model from scratch.

1. Build private evaluation sets for Telugu, Hindi, English, and Telugu-English
   code-switching.
2. Collect only explicit opt-in corrections and quality ratings. Never train on
   personal notes or audio by default.
3. Fine-tune speech recognition first, because accurate Telugu and mixed-language
   capture is the strongest product differentiator.
4. Use LoRA or distillation on an existing compact model for note classification,
   retrieval-grounded answers, and prompt formatting.
5. Consider a larger server-side custom model only after usage and consented data
   justify its operating cost.

Broad planning estimates are $100-$1,000 for early fine-tuning compute,
$5,000-$25,000 for quality multilingual data and labeling, and $25,000-$100,000+
for a production multilingual system. Training a ChatGPT-scale model from
scratch is outside the sensible scope of this product.

## Release milestones

1. Stabilize the current note editor, Done/save flow, Shortcut queue, newest-note
   ordering, PDF ingestion, and Qwen download.
2. Add runtime Apple Intelligence eligibility and locale checks.
3. Add an optional WhisperKit multilingual download with Telugu, Hindi, English,
   and mixed-language evaluation.
4. Add encrypted sync and backup before launching Cloud Plus.
5. Add opt-in cloud reasoning, strict usage limits, transparent costs, and a
   bring-your-own-key option.
6. Begin custom fine-tuning only after consent, evaluation, and deletion
   workflows have been independently reviewed.
