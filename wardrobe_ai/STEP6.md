# Step 6 - extras and polish

1. `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
2. `flutter run`

## Try these
- Calendar tab: month grid with dots on days you logged an outfit; tap a day; History tab lists everything. Tap stars to re-rate, trash to delete.
- Profile: System / Light / Dark toggle (remembered after restart), stats, "Your taste" (what the AI learned from ratings), Reset to demo data.
- Profile -> Trip packing list: days, climate, style -> checklist built from your wardrobe (favourites and most-worn first). Share button exports a text checklist.
- Wardrobe: empty-filter state now has a "Clear filters" button.
- `flutter test` now also covers the packing list and calendar helpers.
