# Sync Status

## Current State

- Recovered source files are in `../IslandLink-v4`.
- Raw recovered board text and snapshots are copied into `raw/`.
- Public share-link text is saved into `raw/share-link-full-text.txt` when available.
- Product and naming notes are in `notes/`.
- Current core Swift files pass syntax parsing in the local sandbox.
- Two plain-text `board-files` attachment URLs were found in the share page and are tracked in `ATTACHMENT_CHECKLIST.md`.
- Direct attachment download attempts returned YouMind sign-in redirect pages, which are archived in `raw/`; the original image binaries were not available through the public share text.

## Known Limitations

- Exact binary bodies for the two app-icon/image attachment URLs are not recovered. This is non-blocking because their surrounding design context is preserved in the notes.
- Treat `synced-board/` and `IslandLink-product-review.md` as the local authority unless a newer YouMind export is explicitly imported.
