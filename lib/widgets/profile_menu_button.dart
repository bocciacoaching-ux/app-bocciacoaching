import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Botón de menú de perfil compartido por todas las pantallas.
///
/// Muestra un [PopupMenuButton] con:
/// - Encabezado con avatar, nombre y email del usuario.
/// - Badge del plan activo.
/// - Opción «Mi Perfil» → navega a /profile.
/// - Opción «Cerrar sesión» → navega a /.
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.of(context).pushNamed('/profile');
        } else if (value == 'logout') {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      color: AppColors.surface,
      elevation: 4,
      shadowColor: AppColors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral8),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // ── Encabezado: info del usuario ─────────────────────────────
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.secondary,
                  child: Text(
                    'OB',
                    style: TextStyle(
                      color: AppColors.actionSecondaryInverted,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Oscar Barragán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'oscar.barragan@email.com',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ── Plan activo ──────────────────────────────────────────────
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.card_membership_outlined, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Premium Pro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Válido hasta 31 dic 2026',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 12),
        // ── Mi Perfil ────────────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'profile',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.neutral8,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline, size: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              const Text(
                'Mi Perfil',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 12),
        // ── Cerrar sesión ────────────────────────────────────────────
        PopupMenuItem<String>(
          value: 'logout',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, size: 18, color: AppColors.error),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cerrar sesión',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.secondary,
        child: Text(
          'OB',
          style: TextStyle(
            color: AppColors.actionSecondaryInverted,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
