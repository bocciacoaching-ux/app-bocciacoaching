import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../models/user_session.dart';
import '../theme/app_colors.dart';

/// Botón de menú de perfil compartido por todas las pantallas.
///
/// Muestra un [PopupMenuButton] con:
/// - Encabezado con avatar, nombre y email del usuario (datos reales de sesión).
/// - Badge del plan activo.
/// - Opción «Mi Perfil» → navega a /profile.
/// - Opción «Cerrar sesión» → limpia sesión y navega a /.
class ProfileMenuButton extends StatelessWidget {
  const ProfileMenuButton({super.key});

  /// Calcula las iniciales a partir del nombre completo (máx. 2 letras).
  static String _initials(UserSession s) {
    final parts = s.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return s.fullName.substring(0, s.fullName.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>().session;
    final initials = session != null ? _initials(session) : '?';
    final fullName = session?.fullName ?? 'Usuario';
    final email = session?.email ?? '';

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'profile') {
          Navigator.of(context).pushNamed('/profile');
        } else if (value == 'logout') {
          await context.read<SessionProvider>().clearSession();
          if (context.mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
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
          child: SizedBox(
            width: 260,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.secondary,
                    backgroundImage: (session?.image != null && session!.image!.isNotEmpty)
                        ? NetworkImage(session.image!)
                        : null,
                    child: (session?.image == null || session!.image!.isEmpty)
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.actionSecondaryInverted,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
      // ── Avatar del botón (trigger) ───────────────────────────────
      child: CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.secondary,
        backgroundImage: (session?.image != null && session!.image!.isNotEmpty)
            ? NetworkImage(session.image!)
            : null,
        child: (session?.image == null || session!.image!.isEmpty)
            ? Text(
                initials,
                style: const TextStyle(
                  color: AppColors.actionSecondaryInverted,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
            : null,
      ),
    );
  }
}
