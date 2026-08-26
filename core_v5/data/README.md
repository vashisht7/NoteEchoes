# Core v5 dataset pipeline

`build_staging_dataset.py` converts the available Core v4 and multilingual v2 assets into a provenance-preserving review queue. It does not create a training-ready corpus and cannot promote legacy `ai_preapproved` rows.

Example:

```bash
python3 core_v5/data/build_staging_dataset.py \
  --v4-ready /Users/vashishtdevasani/Downloads/NoteEchoes-model-pipeline-v4-core/ready \
  --v2-zip "/Users/vashishtdevasani/Desktop/Model dataset/Note Echoes Multilingual v2.zip" \
  --output core_v5/staging
```

`audit_dataset.py --release` is the mandatory pre-training gate. It checks intent/tool consistency, spans, exact and semantic-family leakage, target split counts, named review records, and native-language verification. A Kaggle run must consume only a manifest whose release audit exits successfully.

Reviewer decisions are separate append-only JSONL records and are applied with `apply_review_decisions.py`. Approval requires a reviewer ID and timestamp; multilingual approval additionally requires an explicit native-language verification flag. Every correction records before/after hashes in the row history.
