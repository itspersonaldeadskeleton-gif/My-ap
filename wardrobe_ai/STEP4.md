# Step 4 - recommendation engine

1. `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
2. Make sure `.env` has your LLM key (same one as Step 2).
3. `flutter run` -> Plan -> answer the questions -> "See my outfits".

## Try these
- Shimmer skeleton while the AI works, then 3 swipeable cards (Best Match / Safe / Bold).
- Tap a card to flip it: colour theory, proportions, weather, occasion, and what to avoid.
- "Wardrobe gaps" sheet lists buy/borrow suggestions.
- "Wear this" logs the outfit and bumps wear counts: open Wardrobe -> stats to see "Most worn" fill in.
- Failure paths: airplane mode (retry), empty key, a wardrobe with fewer than 3 items.
- `flutter test` now includes recommendation parsing tests (labels, clamped scores, hallucinated ids dropped, fenced JSON, malformed gaps).

## Notes
- The model only ever sees item ids + tags (no photos), so it's cheap and fast.
- Ids returned by the model are validated against your real wardrobe; made-up ids are dropped.
- Rated outfits (Step 5/6) feed `feedbackSummary()` into the prompt for personalization.
- Production: proxy this call through your backend; don't ship keys in the app.
