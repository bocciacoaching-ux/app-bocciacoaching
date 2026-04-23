import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/team.dart';
import '../../data/providers/team_provider.dart';
import '../../data/providers/session_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/routes/app_routes.dart';

/// Modelo de datos para un equipo en el selector (legacy / datos estáticos).
class TeamOption {
  final String name;
  final String country;
  final String flag;
  final String subtitle;
  final int athletes;

  const TeamOption({
    required this.name,
    required this.country,
    required this.flag,
    required this.subtitle,
    required this.athletes,
  });
}

/// End-drawer de cambio de equipo, compartido por todas las pantallas.
///
/// Obtiene los equipos directamente del [TeamProvider] (datos reales de la API).
///
/// Parámetros:
/// - [onTeamSelected]  → callback con el [Team] seleccionado;
///                       cierra el drawer automáticamente.
/// - [showAdminSection]→ si es `true` muestra la sección "Administración"
///                       con las opciones de crear y administrar equipos.
///                       Por defecto es `true`.
/// - [onLeaveTeam]     → callback que se ejecuta cuando un atleta pulsa
///                       "Abandonar equipo". Si es `null` no se muestra.
class TeamEndDrawer extends StatelessWidget {
  final ValueChanged<Team> onTeamSelected;
  final bool showAdminSection;
  final VoidCallback? onLeaveTeam;

  const TeamEndDrawer({
    super.key,
    required this.onTeamSelected,
    this.showAdminSection = true,
    this.onLeaveTeam,
  });

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();
    final teams = teamProvider.teams;
    final selectedTeam = teamProvider.selectedTeam;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 20, 8, 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.group_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cambiar equipo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          'Selecciona tu equipo activo',
                          style: TextStyle(fontSize: 11, color: AppColors.neutral2),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.neutral2, size: 20),
                  ),
                ],
              ),
            ),
            // ── Línea de acento ───────────────────────────────────────
            Container(height: 3, color: AppColors.primary),

            // ── Lista ─────────────────────────────────────────────────
            Expanded(
              child: teamProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : teams.isEmpty
                      ? _buildEmptyTeams()
                      : ListView(
                          padding: const EdgeInsets.only(top: 20, bottom: 16),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                              child: Text(
                                'EQUIPOS ACTIVOS',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: AppColors.neutral5,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            ...teams.map((team) => _TeamItem(
                                  team: team,
                                  isSelected: selectedTeam?.teamId == team.teamId,
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    onTeamSelected(team);
                                  },
                                  onEdit: showAdminSection
                                      ? () async {
                                          Navigator.of(context).pop();
                                          final result =
                                              await Navigator.of(context)
                                                  .pushNamed(
                                            AppRoutes.teamForm,
                                            arguments: team,
                                          );
                                          if (result == true && context.mounted) {
                                            final session =
                                                context.read<SessionProvider>().session;
                                            if (session != null) {
                                              context
                                                  .read<TeamProvider>()
                                                  .fetchTeams(session.userId);
                                            }
                                          }
                                        }
                                      : null,
                                )),
                            if (showAdminSection) ...[
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                child: Text(
                                  'ADMINISTRACIÓN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: AppColors.neutral5,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              _AdminItem(
                                icon: Icons.add_circle_outline,
                                label: 'Crear nuevo equipo',
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final result = await Navigator.of(context)
                                      .pushNamed(AppRoutes.teamForm);
                                  if (result == true && context.mounted) {
                                    final session =
                                        context.read<SessionProvider>().session;
                                    if (session != null) {
                                      context
                                          .read<TeamProvider>()
                                          .fetchTeams(session.userId);
                                    }
                                  }
                                },
                              ),
                              _AdminItem(
                                icon: Icons.settings_outlined,
                                label: 'Administrar equipos',
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pushNamed('/teams');
                                },
                              ),
                            ],
                            // ── Opciones de atleta (abandonar equipo) ──
                            if (!showAdminSection && selectedTeam != null) ...[
                              const SizedBox(height: 24),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                child: Text(
                                  'OPCIONES',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: AppColors.neutral5,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              _AdminItem(
                                icon: Icons.exit_to_app_rounded,
                                label: 'Abandonar equipo',
                                isDanger: true,
                                onTap: () {
                                  Navigator.of(context).pop();
                                  if (onLeaveTeam != null) {
                                    onLeaveTeam!();
                                  } else {
                                    _showLeaveTeamDialog(
                                        context, selectedTeam);
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveTeamDialog(BuildContext context, Team team) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Abandonar equipo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          '¿Estás seguro de que deseas abandonar el equipo '
          '"${team.nameTeam}"? Esta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              // TODO: Llamar al endpoint de la API para abandonar el equipo.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Has abandonado el equipo "${team.nameTeam}"'),
                ),
              );
            },
            child: const Text('Abandonar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTeams() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_off_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin equipos',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aún no tienes equipos asignados.\nCrea uno para empezar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ítem de equipo ─────────────────────────────────────────────────────────
class _TeamItem extends StatelessWidget {
  final Team team;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _TeamItem({
    required this.team,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          // Acento lateral
          Container(
            width: 4,
            height: 72,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: AppColors.primary10,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Avatar del equipo
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.nameTeam,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isSelected ? AppColors.black : AppColors.neutral2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [team.country, team.region]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.neutral5),
                        ),
                      ],
                    ),
                  ),
                  // Contador de atletas
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary10 : AppColors.neutral9,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: isSelected ? AppColors.primary : AppColors.neutral5,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${team.memberCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : AppColors.neutral5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary, size: 20)
                      : const Icon(Icons.radio_button_unchecked, color: AppColors.neutral5, size: 20),
                  if (onEdit != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.primary10,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (team.image != null && team.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          team.image!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        ),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    final initial = team.nameTeam.isNotEmpty
        ? team.nameTeam[0].toUpperCase()
        : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary10 : AppColors.neutral9,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.neutral5,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ── Ítem de administración ─────────────────────────────────────────────────
class _AdminItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  const _AdminItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isDanger ? AppColors.error : AppColors.primary;
    final Color bgColor =
        isDanger ? AppColors.errorBg : AppColors.primary10;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: accentColor, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDanger ? AppColors.error : AppColors.neutral2,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 13, color: accentColor),
          ],
        ),
      ),
    );
  }
}
