# WardrobeAI

Flutter 3 / Dart 3 app: digitize your wardrobe from photos, answer a few questions about the
occasion, get three AI-picked outfits, then follow an animated step-by-step styling guide.

## Setup
```bash
flutter create wardrobe_ai --org com.example --platforms android,ios
# copy this project's files over the generated one (overwrite pubspec.yaml, lib/, test/, .env.example)
cd wardrobe_ai
cp .env.example .env              # .env is a declared asset, so it must exist
# edit .env and add a key (see below)
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
flutter test
```
If a version fails to resolve: `flutter pub upgrade --major-versions`.
Needs Flutter >= 3.27.

## .env (see .env.example)
```
LLM_PROVIDER=claude            # claude | gemini
ANTHROPIC_API_KEY=
GEMINI_API_KEY=
REMOVE_BG_API_KEY=             # optional: background removal on iOS / fallback
CLAUDE_MODEL=claude-sonnet-4-6
GEMINI_MODEL=gemini-2.0-flash
```
Never commit `.env`. **Production:** proxy all LLM and remove.bg calls through your own backend;
keys shipped inside an app can be extracted.

## Permissions
**android/app/src/main/AndroidManifest.xml** (inside `<manifest>`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
```
**android/app/build.gradle(.kts)**: `minSdk = 24` (ML Kit).

**ios/Runner/Info.plist**:
```xml
<key>NSCameraUsageDescription</key><string>Photograph your clothes to add them to your wardrobe.</string>
<key>NSPhotoLibraryUsageDescription</key><string>Pick clothing photos from your library.</string>
<key>NSLocationWhenInUseUsageDescription</key><string>Used to check the weather for outfit suggestions.</string>
```
**ios/Podfile**: `platform :ios, '15.5'`.

## Structure
```
lib/
  core/        theme, routing (go_router), database (Drift), network (LLM client), utils
  features/
    wardrobe/        data (tagging, background removal), domain (freezed), presentation
    questionnaire/   12-step PageView, weather (Open-Meteo)
    recommendation/  prompt + parser, flip cards, collage
    styling_guide/   steps builder, animated canvas, final look
    calendar/        month grid, wear history, ratings
    profile/         theme toggle, stats, taste, trip packing list
```

## Features
- Wardrobe: camera/gallery, background removal (ML Kit on Android, remove.bg fallback), AI tagging, editable tags, filters, search, favorites, stats, shimmer skeleton.
- Questionnaire: 12 animated one-per-screen questions with auto + manual weather.
- Recommendations: Best Match / Safe / Bold, score, why it works, what to avoid, buy/borrow gaps.
- Styling guide: 8 swipeable steps, items drop onto the canvas, tips, confetti Final Look, share as image.
- Extras: outfit calendar, wear history, rating feedback that personalizes future prompts, trip packing list, light/dark/system theme.

## Tests
`flutter test`: item card widget, tagging + recommendation parsing, weather codes, questionnaire widget,
styling steps + guide widget, packing list, calendar helpers.

## Known limitations
- ML Kit subject segmentation is Android-only; iOS needs the remove.bg key (or keeps the original photo).
- Styling instructions are rule-based from item tags (instant/offline), not LLM-written.
- The outfit calendar shows outfits you logged; scheduling future outfits is not implemented.
- `lottie` is a dependency but no animation asset is bundled yet.
