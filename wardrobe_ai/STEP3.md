# Step 3 - occasion questionnaire

1. `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
2. Make sure location permissions from README.md are in AndroidManifest / Info.plist.
3. `flutter run` -> Plan tab -> Start.

## Try these
- 12 one-per-screen questions; the progress bar animates; Next stays disabled until a required question is answered.
- Weather: allow location to auto-detect via Open-Meteo, or deny it / go offline to see the retry + manual override.
- Colours: switch Wear / Avoid and tap swatches (a colour can't be in both).
- Last screen shows the answers as JSON. That exact JSON is what Step 4 sends to the LLM.
- `flutter test` (adds a questionnaire widget test and a weather-code test).
