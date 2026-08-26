# Voice intent and action engine package convention

Use the following Desktop package as the consolidated destination for NoteEchoes model documentation and releasable ML assets:

`/Users/vashishtdevasani/Desktop/NoteEchoes Voice Intent and Action Engine Documentation`

Use purpose-based folder and document names rather than generation labels such as V4 or V5. Preserve version identifiers inside existing artifact filenames when they are part of the model's technical identity.

Place finished MLX, GGUF, Hugging Face, adapter, tokenizer, manifest, and checksum artifacts under `04 Deployable Models`. Place datasets, schemas, notebooks, training programs, rewards, and evaluation inputs for the current voice intent/action system under `07 Current Intent and Action Model`. Do not label an unfinished checkpoint as a deployable model.

Keep repository-local copies only when code, tests, packaging, or automation depend on their paths. When a repository-local artifact changes, synchronize its purpose-named Desktop copy in the same task.
