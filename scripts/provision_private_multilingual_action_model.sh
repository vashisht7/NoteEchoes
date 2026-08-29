#!/bin/zsh
set -euo pipefail

repo_id="Vashisht7/noteechoes-multilingual-action-qwen3-0.6b-mlx-8bit"
revision="4620ecb38c23d4b15d3da5c6c9762b72a5a701e7"
destination="${1:-ios/PrivateModelAssets/NoteEchoesMultilingualAction}"
expected_model_sha="80dbb40b0cb6273e4f841ce89753aebb9d78ab90690d6cdd07f320e6011c46e7"

if [[ -n "${HF_BIN:-}" ]]; then
  hf_bin="$HF_BIN"
elif command -v hf >/dev/null 2>&1; then
  hf_bin="$(command -v hf)"
else
  print -u2 "Hugging Face CLI not found. Install it or set HF_BIN to its full path."
  exit 1
fi

if ! "$hf_bin" auth whoami >/dev/null 2>&1; then
  print -u2 "Hugging Face CLI is not authenticated. Run: $hf_bin auth login"
  exit 1
fi

staging="$(mktemp -d)"
trap 'rm -rf "$staging"' EXIT

"$hf_bin" download "$repo_id" \
  --revision "$revision" \
  --local-dir "$staging/runtime"

actual_model_sha="$(shasum -a 256 "$staging/runtime/model.safetensors" | awk '{print $1}')"
if [[ "$actual_model_sha" != "$expected_model_sha" ]]; then
  print -u2 "Private model checksum mismatch. Refusing to provision the app."
  exit 1
fi

mkdir -p "$destination"
rsync -a --delete --exclude '.cache/' "$staging/runtime/" "$destination/"
print "Provisioned private multilingual action runtime at $destination"
