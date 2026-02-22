import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_colors.dart';

/// Rutas que tienen entrada en el menú lateral.
enum AppDrawerRoute { inicio, evaluaciones, atletas, estadisticas }

/// Menú lateral compartido por todas las pantallas de la app.
///
/// Parámetros:
/// - [activeRoute]   → ítem que se muestra como activo.
/// - [teamName]      → nombre del equipo activo (para navegar a Atletas).
/// - [teamFlag]      → bandera del equipo activo.
/// - [onHomeSelected] → callback opcional para cuando se selecciona Inicio;
///                      útil en el Dashboard, que maneja su propia navegación
///                      interna (índice de tab).
/// - [onEvaluationsSelected] → igual que el anterior para Evaluaciones.
class AppDrawer extends StatelessWidget {
  final AppDrawerRoute activeRoute;
  final String teamName;
  final String teamFlag;
  final VoidCallback? onHomeSelected;
  final VoidCallback? onEvaluationsSelected;

  const AppDrawer({
    super.key,
    required this.activeRoute,
    this.teamName = 'Selección de Córdoba',
    this.teamFlag = '🇦🇷',
    this.onHomeSelected,
    this.onEvaluationsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header con logo y botón de cierre ──────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
              color: AppColors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/images/isologo-horizontal.png',
                      height: 40,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.neutral4, size: 22),
                    tooltip: 'Cerrar menú',
                  ),
                ],
              ),
            ),
            // Acento de color en la parte inferior del header
            Container(height: 3, color: AppColors.primary),

            // ── Navegación principal ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // — Sección principal
                    _sectionLabel('PRINCIPAL'),
                    _item(
                      context,
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Inicio',
                      active: activeRoute == AppDrawerRoute.inicio,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onHomeSelected != null) {
                          onHomeSelected!();
                        } else {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/dashboard', (r) => false);
                        }
                      },
                    ),
                    _item(
                      context,
                      icon: Icons.assignment_outlined,
                      activeIcon: Icons.assignment,
                      label: 'Evaluaciones',
                      active: activeRoute == AppDrawerRoute.evaluaciones,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (onEvaluationsSelected != null) {
                          onEvaluationsSelected!();
                        } else {
                          Navigator.of(context)
                              .pushNamedAndRemoveUntil('/dashboard', (r) => false);
                        }
                      },
                    ),
                    _item(
                      context,
                      icon: Icons.group_outlined,
                      activeIcon: Icons.group,
                      label: 'Atletas',
                      active: activeRoute == AppDrawerRoute.atletas,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (activeRoute != AppDrawerRoute.atletas) {
                          Navigator.of(context).pushNamed(
                            '/athletes',
                            arguments: {'teamName': teamName, 'teamFlag': teamFlag},
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 8),
                    // — Sección análisis
                    _sectionLabel('ANÁLISIS'),
                    _item(
                      context,
                      icon: Icons.bar_chart_outlined,
                      activeIcon: Icons.bar_chart,
                      label: 'Estadísticas',
                      active: activeRoute == AppDrawerRoute.estadisticas,
                      badge: 'Próximo',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ── Footer: perfil del usuario ──────────────────────────────
            Builder(
              builder: (ctx) {
                final session = ctx.watch<SessionProvider>().session;
                final fullName = session?.fullName ?? 'Usuario';
                final rolLabel = session != null
                    ? (session.isCoach
                        ? 'Entrenador'
                        : session.isAthlete
                            ? 'Deportista'
                            : 'Usuario')
                    : '';
                // Iniciales (máx. 2 letras)
                final parts = fullName.trim().split(RegExp(r'\s+'));
                final initials = parts.length >= 2
                    ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
                    : fullName.substring(0, fullName.length.clamp(0, 2)).toUpperCase();

                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(top: BorderSide(color: AppColors.neutral8)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushNamed('/profile');
                    },
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (rolLabel.isNotEmpty)
                                Text(
                                  '$rolLabel · Plan Premium',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 13, color: AppColors.neutral5),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          color: AppColors.neutral5,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static Widget _item(
    BuildContext context, {
    required IconData icon,
    IconData? activeIcon,
    required String label,
    bool active = false,
    String? badge,
    VoidCallback? onTap,
  }) {
    final Color iconColor = active ? AppColors.primary : AppColors.neutral4;
    final Color textColor = active ? AppColors.primary : AppColors.neutral2;
    final IconData displayIcon = active && activeIcon != null ? activeIcon : icon;

    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: active ? AppColors.primary10 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // Barra de acento lateral
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Ícono con fondo cuando está activo
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: active ? AppColors.primary20 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(displayIcon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent2x10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent2,
                  ),
                ),
              ),
            ] else if (!active) ...[
              const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.neutral6),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Icon(Icons.circle, size: 8, color: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
