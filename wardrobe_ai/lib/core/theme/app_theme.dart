import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Fashion-magazine look: soft neutrals, one bold accent,
/// Playfair Display headings + Inter body.
class AppTheme {
  /// The single bold accent (contrast on white ≈ 5.6:1, passes WCAG AA).
  static const accent = Color(0xFFB4442D);
  static const _paper = Color(0xFFF7F3EE);
  static const _ink = Color(0xFF1B1A19);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isLight = b == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: b,
    ).copyWith(
      primary: isLight ? accent : const Color(0xFFFF9A82),
      surface: isLight ? _paper : const Color(0xFF151413),
      onSurface: isLight ? _ink : const Color(0xFFF3EEE8),
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final body = GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    TextStyle? serif(TextStyle? s, [FontWeight w = FontWeight.w700]) =>
        GoogleFonts.playfairDisplay(textStyle: s, fontWeight: w);

    final text = body.copyWith(
      displayLarge: serif(body.displayLarge),
      displayMedium: serif(body.displayMedium),
      headlineLarge: serif(body.headlineLarge),
      headlineMedium: serif(body.headlineMedium),
      headlineSmall: serif(body.headlineSmall),
      titleLarge: serif(body.titleLarge, FontWeight.w600),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.headlineSmall,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: isLight ? Colors.white : const Color(0xFF211F1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStatePropertyAll(
            text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48), // 48dp tap target
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
