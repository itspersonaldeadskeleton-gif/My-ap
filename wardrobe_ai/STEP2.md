# Step 2 - wardrobe, camera, AI tagging

1. Put your key in `.env` (see `.env.example`): `ANTHROPIC_API_KEY` (or set `LLM_PROVIDER=gemini` + `GEMINI_API_KEY`).
   Optional: `REMOVE_BG_API_KEY` for background removal on iOS / as fallback.
2. `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
3. Apply the Android/iOS permissions from README.md (camera + photos) and set Android `minSdk = 24`.
4. `flutter run`, then `flutter test`.

## Try these
- Wardrobe -> Add item -> camera or gallery: skeleton shimmer while the AI analyzes, then edit tags and save.
- Tap any card to edit its tags (trash icon deletes).
- Search, category chips, the filter button (colour / season / formality / favorites) and the stats button.
- Failure paths: airplane mode (offline retry), blurry photo (retake prompt), empty API key (clear message), denied camera permission.

## Notes
- ML Kit subject segmentation is Android-only and its raw bitmap may not decode on every plugin version;
  the service then falls back to remove.bg, and finally keeps the original photo.
- Wear counts feed the "most worn" stat once outfits can be marked worn (Step 4/6).
- Keys in `.env` are for development. Proxy LLM/remove.bg calls through your own backend in production.
