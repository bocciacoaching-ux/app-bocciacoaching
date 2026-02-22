import 'package:flutter/material.dart';

/// Paleta de colores centralizada de Boccia Coaching App.
/// Basada en el sistema de diseño (Design Tokens – Mode 1).
abstract final class AppColors {
  // ──────────────────────────────────────────────────────────────────
  // Primary
  // ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF477D9E);
  static const Color primary90 = Color(0xE5477D9E);
  static const Color primary80 = Color(0xCC477D9E);
  static const Color primary70 = Color(0xB2477D9E);
  static const Color primary60 = Color(0x99477D9E);
  static const Color primary50 = Color(0x80477D9E);
  static const Color primary40 = Color(0x66477D9E);
  static const Color primary30 = Color(0x4D477D9E);
  static const Color primary20 = Color(0x33477D9E);
  static const Color primary10 = Color(0x1A477D9E);

  // ──────────────────────────────────────────────────────────────────
  // Secondary
  // ──────────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFFA9D9DB);
  static const Color secondary90 = Color(0xE5A9D9DB);
  static const Color secondary80 = Color(0xCCA9D9DB);
  static const Color secondary70 = Color(0xB2A9D9DB);
  static const Color secondary60 = Color(0x99A9D9DB);
  static const Color secondary50 = Color(0x80A9D9DB);
  static const Color secondary40 = Color(0x66A9D9DB);
  static const Color secondary30 = Color(0x4DA9D9DB);
  static const Color secondary20 = Color(0x33A9D9DB);
  static const Color secondary10 = Color(0x1AA9D9DB);

  // ──────────────────────────────────────────────────────────────────
  // Neutral
  // ──────────────────────────────────────────────────────────────────
  static const Color black = Color(0xFF09101D);
  static const Color neutral1 = Color(0xFF2C3A4B);
  static const Color neutral2 = Color(0xFF394452);
  static const Color neutral3 = Color(0xFF545D69);
  static const Color neutral4 = Color(0xFF6D7580);
  static const Color neutral5 = Color(0xFF858C94);
  static const Color neutral6 = Color(0xFFA5ABB3);
  static const Color neutral7 = Color(0xFFDADEE3);
  static const Color neutral8 = Color(0xFFEBEEF2);
  static const Color neutral9 = Color(0xFFF4F6F9);
  static const Color white = Color(0xFFFFFFFF);

  // ──────────────────────────────────────────────────────────────────
  // Accent
  // ──────────────────────────────────────────────────────────────────
  static const Color accent1 = Color(0xFFF2F7ED);
  static const Color accent1x28 = Color(0x47F2F7ED);
  static const Color accent2 = Color(0xFFEAB308); // Yellow
  static const Color accent2x10 = Color(0x1AEAB308);
  static const Color accent3 = Color(0xFF0EA5E9); // Sky Blue
  static const Color accent3x23 = Color(0x1A0EA5E9);
  static const Color accent4 = Color(0xFFA855F7); // Purple
  static const Color accent4x10 = Color(0x1AA855F7);
  static const Color accent5 = Color(0xFF14B8A6); // Teal
  static const Color accent5x25 = Color(0x1A14B8A6);
  static const Color accent6 = Color(0xFF6366F1); // Indigo
  static const Color accent6x15 = Color(0x1A6366F1);

  // ──────────────────────────────────────────────────────────────────
  // Status
  // ──────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1B9337);
  static const Color successBg = Color(0x1A1B9337);
  static const Color warning = Color(0xFFDA821E);
  static const Color warningBg = Color(0x1ADA821E);
  static const Color error = Color(0xFFEE1619);
  static const Color errorBg = Color(0x1AEE1619);
  static const Color info = Color(0xFF477D9E);
  static const Color infoBg = Color(0x1A477D9E);

  // ──────────────────────────────────────────────────────────────────
  // Action – Primary
  // ──────────────────────────────────────────────────────────────────
  static const Color actionPrimaryDefault = Color(0xFF477D9E);
  static const Color actionPrimaryHover = Color(0xFF3F6F8D);
  static const Color actionPrimaryActive = Color(0xFF2F536A);
  static const Color actionPrimaryDisabled = Color(0xFFE6E6E6);
  static const Color actionPrimaryHover10 = Color(0x1A3F6F8D);
  static const Color actionPrimaryActive20 = Color(0x333F6F8D);
  static const Color actionPrimaryInverted = Color(0xFFFFFFFF);
  static const Color actionPrimaryVisited = Color(0xFF123145);

  // ──────────────────────────────────────────────────────────────────
  // Action – Secondary
  // ──────────────────────────────────────────────────────────────────
  static const Color actionSecondaryDefault = Color(0xFFA9D9DB);
  static const Color actionSecondaryHover = Color(0xFF97C3C5);
  static const Color actionSecondaryActive = Color(0xFF83ADAF);
  static const Color actionSecondaryDisabled = Color(0xFFE6E6E6);
  static const Color actionSecondaryHover10 = Color(0x1A97C3C5);
  static const Color actionSecondaryActive20 = Color(0x3397C3C5);
  static const Color actionSecondaryInverted = Color(0xFF1D3557);
  static const Color actionSecondaryVisited = Color(0xFF123145);

  // ──────────────────────────────────────────────────────────────────
  // Action – Neutral
  // ──────────────────────────────────────────────────────────────────
  static const Color actionNeutralDefault = Color(0xFF9098A1);
  static const Color actionNeutralHover = Color(0xFF858C94);
  static const Color actionNeutralActive = Color(0xFF798087);
  static const Color actionNeutralDisabled = Color(0xB29098A1);
  static const Color actionNeutralHover10 = Color(0x1A6D7580);
  static const Color actionNeutralActive20 = Color(0x336D7580);
  static const Color actionNeutralInverted = Color(0xFFFFFFFF);
  static const Color actionNeutralVisited = Color(0xFF123145);

  // ──────────────────────────────────────────────────────────────────
  // Semantic aliases (convenience)
  // ──────────────────────────────────────────────────────────────────

  /// Fondo general de la app (gris muy claro).
  static const Color background = neutral9;

  /// Fondo de tarjetas / paneles.
  static const Color surface = white;

  /// Borde de inputs.
  static const Color inputBorder = neutral8;

  /// Color de texto principal.
  static const Color textPrimary = neutral1;

  /// Color de texto secundario / hint.
  static const Color textSecondary = neutral4;

  /// Color de texto deshabilitado.
  static const Color textDisabled = neutral6;
}
