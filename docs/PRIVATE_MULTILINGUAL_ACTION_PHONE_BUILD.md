# Private multilingual action phone build

Status on 2026-08-29: **implemented and device build compiled; physical-phone behavior still requires the owner's morning test**.

## What is in this build

- English recognition mode uses the existing proven English Qwen3 0.6B action
  model.
- Telugu, Hindi, and Telugu-English mixed recognition modes use the private
  multilingual Qwen3 0.6B action runtime.
- Auto mode detects the transcript: English stays on the English model and any
  Telugu, Hindi, or mixed result uses the multilingual model.
- The optional conversation model is not activated. Conversation continues to
  use the existing cited extractive path.
- Only one action model is retained in Metal memory at a time.

The multilingual LoRA adapter has already been fused into the accepted 8-bit
runtime. The phone does not load a loose adapter and base model separately.

## Private distribution

The multilingual repository remains private. Before building, the developer
runs:

```bash
HF_BIN=/full/path/to/hf scripts/provision_private_multilingual_action_model.sh
```

That command authenticates on the development Mac, downloads the immutable Hub
revision, verifies the model SHA-256, and stages it under the ignored
`ios/PrivateModelAssets` directory. Xcode copies the runtime into the signed app
bundle. Neither GitHub nor the installed phone receives the Hugging Face token.

Pinned repository revision:
`Vashisht7/noteechoes-multilingual-action-qwen3-0.6b-mlx-8bit@4620ecb38c23d4b15d3da5c6c9762b72a5a701e7`

Weight SHA-256:
`80dbb40b0cb6273e4f841ce89753aebb9d78ab90690d6cdd07f320e6011c46e7`

## Telugu-English checklist result

The accepted fused runtime was evaluated on all 25 held-out Telugu-English
checklist examples:

- Valid JSON: 25/25
- Valid schema: 25/25
- Correct checklist intent: 25/25
- Exact operational fields: 24/25 (96%)

One output duplicated part of a Telugu word inside a doctor-appointment item.
The app's grounding validator rejects that altered item because it is not in the
transcript. The deterministic spoken-checklist parser was extended to recognize
`మొదట`, `తర్వాత`, and `చివరగా`, so the original three spoken items remain
available when model output is rejected. Comma-separated Telugu-English items
are also covered.

This makes short checklists and task items suitable for guarded phone testing,
not autonomous production claims. The note is saved before model enhancement;
timeouts and invalid model output cannot delete the user's recording.

## Verification completed

- The complete Flutter suite passed: 140/140 tests. The focused multilingual,
  routing, parser, and conversation-regression selection passed 34/34.
- Targeted Dart static analysis passed with no issues.
- The locally provisioned runtime manifest and all hashes passed verification.
- A direct iPhoneOS Debug build succeeded.
- The built `Runner.app` contains the 644,921,794-byte multilingual runtime and
  the bundled weight checksum matches the accepted model.

## Morning phone test

1. Connect the iPhone and open `ios/Runner.xcworkspace` in Xcode.
2. Select the phone and run the `Runner` scheme. The private runtime is already
   provisioned on this Mac.
3. In NoteEchoes Settings, select **English** and verify an English checklist.
4. Select **Telugu & English Mixed** and say:
   `checklist తయారు చేయి: మొదట milk కొనాలి, తర్వాత Ravi కి report పంపాలి, చివరగా laptop charge చేయాలి.`
5. Confirm that the saved note contains exactly three unchecked items.
6. Also try a non-enumerated form:
   `నా checklist: milk కొనాలి, Ravi కి report పంపాలి, మరియు laptop charge చేయాలి.`

The first multilingual use can take longer while MLX verifies and loads the
bundled weights. Subsequent requests should be faster. Record the exact
transcript and observed checklist if any item differs.
