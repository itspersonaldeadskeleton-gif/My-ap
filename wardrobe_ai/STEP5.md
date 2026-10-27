# Step 5 - animated styling guide

1. `flutter pub get && dart run build_runner build --delete-conflicting-outputs`
2. `flutter run` -> Plan -> answers -> outfits -> "Style me".

## Try these
- Steps: base layer, bottoms, top, layering, shoes, accessories, grooming & fragrance, final check.
- Each garment drops onto the canvas as you reach its step (go back and it leaves again).
- Swipe the instruction card or use Back / Next. Haptics on every step.
- The collage Hero-transitions from the results card into the guide canvas.
- "See final look": confetti, assembled outfit, confidence message, 5-star rating, "Share image".
- Rating saves to the outfit log and feeds the AI prompt next time (personalization).
- "Wear this" then "Style me" then rate does not double-count wear (it reuses the log id).
- `flutter test` adds step-builder tests and a guide widget test.

## Notes
- Instructions are generated locally from item tags (fit, fabric, formality, weather, time of day): instant and offline.
- The `lottie` dependency is still unused; drop a Lottie JSON into assets/lottie if you want an extra celebration.
- Share uses a temp PNG of the Final Look board via share_plus.
