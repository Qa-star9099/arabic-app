import 'package:flutter/material.dart';

/// Design-system color tokens extracted from the HTML mockups.
/// All colours come from the dark-space visual identity of Arabcha.
abstract final class AppColors {
  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFF080B1A);
  static const Color surface = Color(0xFF0D1020);
  static const Color surfaceElevated = Color(0xFF111428);

  // ── Brand — Emerald (primary) ─────────────────────────────────────────────
  static const Color emerald = Color(0xFF1D9E75);
  static const Color emeraldLight = Color(0xFF5DCAA5);
  static const Color emeraldDark = Color(0xFF0F6E56);

  // ── Brand — Violet (accent) ───────────────────────────────────────────────
  static const Color violet = Color(0xFF533AB7);
  static const Color violetLight = Color(0xFFAFA9EC);

  // ── Brand — Gold (streaks / highlights) ───────────────────────────────────
  static const Color gold = Color(0xFFBA7517);
  static const Color goldLight = Color(0xFFFAC775);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x80FFFFFF); // 50%
  static const Color textTertiary = Color(0x40FFFFFF); // 25%
  static const Color textHint = Color(0x29FFFFFF); // 16%

  // ── Borders / Dividers ────────────────────────────────────────────────────
  static const Color border = Color(0x0FFFFFFF); // 6%
  static const Color borderSubtle = Color(0x12FFFFFF); // 7%
  static const Color borderEmerald = Color(0x33FFFFFF); // emerald tinted

  // ── Overlays / Cards ─────────────────────────────────────────────────────
  static const Color cardSurface = Color(0x0AFFFFFF); // 4%
  static const Color glassWhite = Color(0x07FFFFFF); // 3%

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = emerald;
  static const Color error = Color(0xFFE05252);
  static const Color warning = gold;
}
