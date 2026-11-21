import 'package:material_ui/material_ui.dart';

enum StudioPalette { light, dark, oled, slate }

class StudioTokens extends ThemeExtension<StudioTokens> {
  final Color bg;
  final Color surface;
  final Color surfaceSubtle;
  final Color border;
  final Color textPrimary;
  final Color textMuted;
  final Color glassBg;
  final Color accent;
  final Color accentSoft;
  final double cardRadius;
  final double gridGap;
  final bool pureImageCard;

  const StudioTokens({
    required this.bg,
    required this.surface,
    required this.surfaceSubtle,
    required this.border,
    required this.textPrimary,
    required this.textMuted,
    required this.glassBg,
    required this.accent,
    required this.accentSoft,
    this.cardRadius = 14.0,
    this.gridGap = 10.0,
    this.pureImageCard = true,
  });

  factory StudioTokens.fromPalette(
    StudioPalette palette, {
    Color accent = const Color(0xFF0096FA),
    double cardRadius = 14.0,
    double gridGap = 10.0,
    bool pureImageCard = true,
  }) {
    final accentSoft = accent.withOpacity(0.14);
    switch (palette) {
      case StudioPalette.light:
        return StudioTokens(
          bg: const Color(0xFFF6F8FB),
          surface: const Color(0xFFFFFFFF),
          surfaceSubtle: const Color(0xFFEEF2F7),
          border: const Color(0x140F172A),
          textPrimary: const Color(0xFF0F172A),
          textMuted: const Color(0xFF64748B),
          glassBg: const Color(0xCCFFFFFF),
          accent: accent,
          accentSoft: accentSoft,
          cardRadius: cardRadius,
          gridGap: gridGap,
          pureImageCard: pureImageCard,
        );
      case StudioPalette.oled:
        return StudioTokens(
          bg: const Color(0xFF000000),
          surface: const Color(0xFF0D0F12),
          surfaceSubtle: const Color(0xFF171A20),
          border: const Color(0x1AFFFFFF),
          textPrimary: const Color(0xFFF8FAFC),
          textMuted: const Color(0xFF8B95A5),
          glassBg: const Color(0xD10A0C10),
          accent: accent,
          accentSoft: accentSoft,
          cardRadius: cardRadius,
          gridGap: gridGap,
          pureImageCard: pureImageCard,
        );
      case StudioPalette.slate:
        return StudioTokens(
          bg: const Color(0xFFEDF1F6),
          surface: const Color(0xFFF8FAFC),
          surfaceSubtle: const Color(0xFFE3E9F1),
          border: const Color(0x171E293B),
          textPrimary: const Color(0xFF1E293B),
          textMuted: const Color(0xFF64748B),
          glassBg: const Color(0xD6F8FAFC),
          accent: accent,
          accentSoft: accentSoft,
          cardRadius: cardRadius,
          gridGap: gridGap,
          pureImageCard: pureImageCard,
        );
      case StudioPalette.dark:
        return StudioTokens(
          bg: const Color(0xFF0F131A),
          surface: const Color(0xFF171D27),
          surfaceSubtle: const Color(0xFF202836),
          border: const Color(0x14FFFFFF),
          textPrimary: const Color(0xFFF1F5F9),
          textMuted: const Color(0xFF94A3B8),
          glassBg: const Color(0xCC171D27),
          accent: accent,
          accentSoft: accentSoft,
          cardRadius: cardRadius,
          gridGap: gridGap,
          pureImageCard: pureImageCard,
        );
    }
  }

  @override
  StudioTokens copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceSubtle,
    Color? border,
    Color? textPrimary,
    Color? textMuted,
    Color? glassBg,
    Color? accent,
    Color? accentSoft,
    double? cardRadius,
    double? gridGap,
    bool? pureImageCard,
  }) {
    return StudioTokens(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      glassBg: glassBg ?? this.glassBg,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      cardRadius: cardRadius ?? this.cardRadius,
      gridGap: gridGap ?? this.gridGap,
      pureImageCard: pureImageCard ?? this.pureImageCard,
    );
  }

  @override
  StudioTokens lerp(ThemeExtension<StudioTokens>? other, double t) {
    if (other is! StudioTokens) return this;
    return StudioTokens(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      glassBg: Color.lerp(glassBg, other.glassBg, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      cardRadius: cardRadius + (other.cardRadius - cardRadius) * t,
      gridGap: gridGap + (other.gridGap - gridGap) * t,
      pureImageCard: t < 0.5 ? pureImageCard : other.pureImageCard,
    );
  }
}

class StudioTheme {
  static ThemeData build({
    StudioPalette palette = StudioPalette.dark,
    Color accent = const Color(0xFF0096FA),
    double cardRadius = 14.0,
    double gridGap = 10.0,
    bool pureImageCard = true,
  }) {
    final isDark = palette == StudioPalette.dark || palette == StudioPalette.oled;
    final tokens = StudioTokens.fromPalette(
      palette,
      accent: accent,
      cardRadius: cardRadius,
      gridGap: gridGap,
      pureImageCard: pureImageCard,
    );

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: tokens.accent,
      onPrimary: Colors.white,
      secondary: tokens.accent,
      onSecondary: Colors.white,
      error: const Color(0xFFF43F5E),
      onError: Colors.white,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bg,
      canvasColor: tokens.bg,
      dividerColor: tokens.border,
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.glassBg,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: tokens.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(color: tokens.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: tokens.accent, width: 1.5),
        ),
      ),
      extensions: [tokens],
    );
  }
}

extension StudioThemeContext on BuildContext {
  StudioTokens get studio =>
      Theme.of(this).extension<StudioTokens>() ??
      StudioTokens.fromPalette(
        Theme.of(this).brightness == Brightness.dark
            ? StudioPalette.dark
            : StudioPalette.light,
      );
}
