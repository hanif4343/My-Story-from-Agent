// lib/core/constants/app_enums.dart

/// Enumeration of available app themes.
enum AppTheme {
  darkRomantic,
  goldenWedding,
  moonNight,
  roseGarden,
  pinkLove,
  sunset,
  galaxy,
  hospital,
  nursery,
  home,
}

/// Enumeration of chapter identifiers.
/// Each chapter has a human‑readable Bengali title accessible via the
/// [title] getter.
enum ChapterId {
  chapter1,
  chapter2,
  chapter3,
  chapter4,
  chapter5,
  chapter6,
  chapter7,
  chapter8,
  chapter9,
  chapter10,
  chapter11,
  chapter12,
  chapter13,
  chapter14,
  chapter15,
  chapter16,
  chapter17,
}

extension ChapterIdExtension on ChapterId {
  /// Returns the Bengali title for the chapter.
  String get title {
    return switch (this) {
      ChapterId.chapter1 => 'প্রথম অধ্যায়',
      ChapterId.chapter2 => 'দ্বিতীয় অধ্যায়',
      ChapterId.chapter3 => 'তৃতীয় অধ্যায়',
      ChapterId.chapter4 => 'চতুর্থ অধ্যায়',
      ChapterId.chapter5 => 'পঞ্চম অধ্যায়',
      ChapterId.chapter6 => 'ষষ্ঠ অধ্যায়',
      ChapterId.chapter7 => 'সপ্তম অধ্যায়',
      ChapterId.chapter8 => 'অষ্টম অধ্যায়',
      ChapterId.chapter9 => 'নবম অধ্যায়',
      ChapterId.chapter10 => 'দশম অধ্যায়',
      ChapterId.chapter11 => 'একাদশ অধ্যায়',
      ChapterId.chapter12 => 'দ্বাদশ অধ্যায়',
      ChapterId.chapter13 => 'ত্রয়োদশ অধ্যায়',
      ChapterId.chapter14 => 'চতুর্দশ অধ্যায়',
      ChapterId.chapter15 => 'পঞ্চদশ অধ্যায়',
      ChapterId.chapter16 => 'ষোড়শ অধ্যায়',
      ChapterId.chapter17 => 'সপ্তদশ অধ্যায়',
    };
  }
}

/// Enumeration of available animation types.
enum AnimationType {
  heartRain,
  roseRain,
  butterfly,
  sparkle,
  goldenDust,
  fireworks,
  cloud,
  rain,
  moon,
  stars,
  letter,
  envelope,
  ring,
  book,
  pageTurn,
  typewriter,
  lensFlare,
  lightRays,
  confetti,
  magicGlow,
}

/// Enumeration of available transition types.
enum TransitionType {
  fade,
  zoom,
  slide,
  rotate,
  flip,
  blur,
  film,
  inkReveal,
  pageCurl,
  cameraFlash,
  glass,
  ripple,
}
