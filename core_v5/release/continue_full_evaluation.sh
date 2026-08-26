#!/bin/zsh
set -euo pipefail

WORKSPACE='/Users/vashishtdevasani/Desktop/Notechoes App'
MODEL_ROOT='/Users/vashishtdevasani/Desktop/NoteEchoes Voice Intent and Action Engine Documentation/04 Deployable Models/Voice-Intent-and-Action-Qwen3-0.6B'
REPORT_DIR='/Users/vashishtdevasani/Desktop/NoteEchoes Voice Intent and Action Engine Documentation/07 Current Intent and Action Model/Behavioral Evaluation/MLX-4bit'
RUNNING_PID="${1:-}"

cd "$WORKSPACE"
if [[ -n "$RUNNING_PID" ]]; then
  while kill -0 "$RUNNING_PID" 2>/dev/null; do
    sleep 15
  done
fi

for split in validation test challenge; do
  if [[ -s "$REPORT_DIR/${split}.json" ]]; then
    continue
  fi
  .venv-model-release/bin/python core_v5/release/evaluate_behavior_mlx.py \
    --model "$MODEL_ROOT/MLX-4bit-RECOMMENDED" \
    --suite "core_v5/ready_synthetic_v1/sft/${split}.jsonl" \
    --annotations "core_v5/ready_synthetic_v1/annotations/${split}.annotated.jsonl" \
    --schema core_v5/schema/core_v5.schema.json \
    --output "$REPORT_DIR/${split}.json" \
    --batch-size 16 --max-new-tokens 272 --log-every 400
done
