import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/macrocycle.dart';
import '../../../data/models/microcycle.dart';
import '../../../data/models/training_session.dart';
import '../../../data/providers/macrocycle_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../data/providers/training_session_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/profile_menu_button.dart';

/// Pantalla de acceso directo que muestra el microciclo actual y el
/// próximo por cada atleta del equipo, con acceso rápido a sesiones
/// y creación de secciones.
class MicrocycleOverviewScreen extends StatefulWidget {
  const MicrocycleOverviewScreen({super.key});

  @override
  State<MicrocycleOverviewScreen> createState() =>
      _MicrocycleOverviewScreenState();
}

class _MicrocycleOverviewScreenState extends State<MicrocycleOverviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final teamId = context.read<TeamProvider>().selectedTeam?.teamId;
      context.read<MacrocycleProvider>().loadMacrocycles(teamId: teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(
        activeRoute: AppDrawerRoute.entrenamiento,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.neutral3),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Entrenamiento',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
        actions: const [
          ProfileMenuButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Consumer<MacrocycleProvider>(
        builder: (context, macroProvider, _) {
          if (macroProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!macroProvider.hasMacrocycles) {
            return _buildEmptyState();
          }

          return _buildContent(macroProvider);
        },
      ),
    );
  }

  // ── Estado vacío ─────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin macrociclos activos',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea un macrociclo para empezar a planificar\nlas sesiones de entrenamiento.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.macrocycleBuilder),
              icon: const Icon(Icons.add),
              label: const Text('Crear Macrociclo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.actionPrimaryDefault,
                foregroundColor: AppColors.white,
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contenido principal ──────────────────────────────────────────

  Widget _buildContent(MacrocycleProvider macroProvider) {
    final now = DateTime.now();

    // Agrupar macrociclos por atleta
    final grouped = <String, List<Macrocycle>>{};
    for (final macro in macroProvider.macrocycles) {
      // Solo macrociclos vigentes (que contengan la fecha actual o futura)
      if (macro.endDate.isAfter(now.subtract(const Duration(days: 30)))) {
        final key = macro.athleteName.isEmpty
            ? 'Sin asignar'
            : macro.athleteName;
        grouped.putIfAbsent(key, () => []).add(macro);
      }
    }

    if (grouped.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final teamId = context.read<TeamProvider>().selectedTeam?.teamId;
        await context
            .read<MacrocycleProvider>()
            .loadMacrocycles(teamId: teamId);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDateHeader(now),
          const SizedBox(height: 16),
          for (final entry in grouped.entries) ...[
            _buildAthleteSection(entry.key, entry.value, now),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader(DateTime now) {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    const weekDays = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.headerGradientTop, AppColors.headerGradientBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '${now.day}',
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.white,
                    fontSize: 28,
                  ),
                ),
                Text(
                  months[now.month - 1].substring(0, 3).toUpperCase(),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekDays[now.weekday - 1],
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Semana ${_weekOfYear(now)} del ${now.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.calendar_today,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sección por atleta ───────────────────────────────────────────

  Widget _buildAthleteSection(
      String athleteName, List<Macrocycle> macros, DateTime now) {
    // Para cada macro, encontrar el micro actual y el próximo
    final allMicros = <_MicroWithMacro>[];
    for (final macro in macros) {
      for (final micro in macro.microcycles) {
        allMicros.add(_MicroWithMacro(micro: micro, macro: macro));
      }
    }

    // Ordenar por fecha de inicio
    allMicros.sort((a, b) => a.micro.startDate.compareTo(b.micro.startDate));

    // Encontrar actual (que contiene hoy) y próximo
    _MicroWithMacro? current;
    _MicroWithMacro? next;

    for (int i = 0; i < allMicros.length; i++) {
      final m = allMicros[i];
      if (!m.micro.startDate.isAfter(now) && !m.micro.endDate.isBefore(now)) {
        current = m;
        if (i + 1 < allMicros.length) next = allMicros[i + 1];
        break;
      }
    }

    // Si no hay "actual", buscar el próximo futuro
    if (current == null) {
      for (final m in allMicros) {
        if (m.micro.startDate.isAfter(now)) {
          next = m;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header del atleta
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                _initials(athleteName),
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                athleteName,
                style: AppTextStyles.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (current != null) ...[
          _buildMicrocycleCard(
            current,
            isCurrent: true,
            now: now,
          ),
          const SizedBox(height: 10),
        ],
        if (next != null)
          _buildMicrocycleCard(
            next,
            isCurrent: false,
            now: now,
          ),
        if (current == null && next == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.neutral8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppColors.neutral5, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Sin microciclos activos o próximos',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMicrocycleCard(
    _MicroWithMacro data, {
    required bool isCurrent,
    required DateTime now,
  }) {
    final micro = data.micro;
    final macro = data.macro;
    final color = isCurrent ? AppColors.primary : AppColors.accent5;
    final badge = isCurrent ? 'ACTUAL' : 'PRÓXIMO';

    // Calcular días restantes
    final daysLeft = micro.endDate.difference(now).inDays;
    final daysStr = isCurrent
        ? (daysLeft >= 0 ? '$daysLeft días restantes' : 'Finalizó')
        : 'Inicia en ${micro.startDate.difference(now).inDays} días';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? AppColors.primary30 : AppColors.neutral8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del microciclo
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(Icons.grid_view_outlined, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            micro.label,
                            style: AppTextStyles.titleMedium
                                .copyWith(fontSize: 15),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${macro.name} · ${micro.type.label}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Info + acciones
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _infoChip(Icons.date_range,
                        '${_formatDate(micro.startDate)} — ${_formatDate(micro.endDate)}',
                        AppColors.primary),
                    const Spacer(),
                    Text(
                      daysStr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Acciones rápidas
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        icon: Icons.visibility_outlined,
                        label: 'Ver Sesiones',
                        color: AppColors.primary,
                        onTap: () {
                          if (micro.microcycleId != null) {
                            Navigator.of(context).pushNamed(
                              AppRoutes.trainingSessions,
                              arguments: micro,
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Nueva Sesión',
                        color: AppColors.success,
                        onTap: () {
                          if (micro.microcycleId != null) {
                            Navigator.of(context).pushNamed(
                              AppRoutes.trainingSessionForm,
                              arguments: {
                                'microcycleId': micro.microcycleId,
                                'microcycleLabel': micro.label,
                              },
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        icon: Icons.list_alt_outlined,
                        label: 'Secciones',
                        color: AppColors.accent6,
                        onTap: () => _showSessionPickerForSections(micro),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Picker de sesión para agregar secciones ──────────────────────

  /// Carga las sesiones del microciclo y permite elegir una para
  /// luego navegar a la pantalla de agregar sección.
  Future<void> _showSessionPickerForSections(Microcycle micro) async {
    if (micro.microcycleId == null) return;

    final provider = context.read<TrainingSessionProvider>();
    await provider.loadSessionsForMicrocycle(micro.microcycleId!);

    if (!mounted) return;

    final sessions = provider.sessionSummaries;

    if (sessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'No hay sesiones en este microciclo. Crea una primero.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: 'Crear',
            textColor: AppColors.white,
            onPressed: () {
              Navigator.of(context).pushNamed(
                AppRoutes.trainingSessionForm,
                arguments: {
                  'microcycleId': micro.microcycleId,
                  'microcycleLabel': micro.label,
                },
              );
            },
          ),
        ),
      );
      return;
    }

    // Mostrar bottom sheet con sesiones para elegir
    if (!mounted) return;
    final selectedSessionId = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SessionPickerSheet(sessions: sessions),
    );

    if (selectedSessionId != null && mounted) {
      // Cargar sesión completa para ver sus partes
      final fullSession =
          await provider.loadFullSession(selectedSessionId);
      if (fullSession != null && mounted) {
        _showPartPickerForSection(fullSession);
      }
    }
  }

  /// Muestra las partes de la sesión para elegir dónde agregar sección.
  void _showPartPickerForSection(TrainingSession session) {
    if (session.parts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Esta sesión no tiene partes configuradas.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PartPickerSheet(
        parts: session.parts,
        onPartSelected: (part) {
          Navigator.of(ctx).pop();
          Navigator.of(context).pushNamed(
            AppRoutes.sectionForm,
            arguments: {
              'sessionPartId': part.sessionPartId,
              'partName': part.name,
            },
          );
        },
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return (daysDiff / 7).ceil() + 1;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Helper model
// ═══════════════════════════════════════════════════════════════════════

class _MicroWithMacro {
  final Microcycle micro;
  final Macrocycle macro;
  const _MicroWithMacro({required this.micro, required this.macro});
}

// ═══════════════════════════════════════════════════════════════════════
// Bottom sheet para elegir sesión
// ═══════════════════════════════════════════════════════════════════════

class _SessionPickerSheet extends StatelessWidget {
  final List<TrainingSessionSummary> sessions;
  const _SessionPickerSheet({required this.sessions});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral6,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccionar Sesión',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Elige la sesión donde quieres agregar una sección',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...sessions.map((s) => _sessionTile(context, s)),
          ],
        ),
      ),
    );
  }

  Widget _sessionTile(BuildContext context, TrainingSessionSummary session) {
    final statusColor = _statusColor(session.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.neutral8),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.fitness_center, color: statusColor, size: 20),
        ),
        title: Text(
          '${session.dayOfWeek ?? 'Sin día'} · Sesión #${session.trainingSessionId}',
          style: AppTextStyles.bodyMedium
              .copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${session.duration} min · ${session.totalParts} partes · ${session.totalSections} secciones',
          style: AppTextStyles.bodySmall
              .copyWith(color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.neutral5),
        onTap: () => Navigator.of(context).pop(session.trainingSessionId),
      ),
    );
  }

  static Color _statusColor(String? status) {
    switch (status) {
      case 'Programada':
        return AppColors.accent2;
      case 'EnProceso':
        return AppColors.accent3;
      case 'Terminada':
        return AppColors.accent5;
      case 'Finalizada':
        return AppColors.success;
      case 'Cancelada':
        return AppColors.error;
      default:
        return AppColors.neutral5;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Bottom sheet para elegir parte
// ═══════════════════════════════════════════════════════════════════════

class _PartPickerSheet extends StatelessWidget {
  final List<SessionPart> parts;
  final void Function(SessionPart part) onPartSelected;

  const _PartPickerSheet({
    required this.parts,
    required this.onPartSelected,
  });

  @override
  Widget build(BuildContext context) {
    const partColors = [
      AppColors.primary,
      AppColors.accent5,
      AppColors.accent6,
      AppColors.accent4,
    ];
    const partIcons = [
      Icons.rocket_launch_outlined,
      Icons.sports_outlined,
      Icons.group_outlined,
      Icons.stadium_outlined,
    ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral6,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Seleccionar Parte',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '¿En qué parte de la sesión quieres agregar la sección?',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...parts.asMap().entries.map((entry) {
              final idx = entry.key;
              final part = entry.value;
              final color = partColors[idx % partColors.length];
              final icon = partIcons[idx % partIcons.length];

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: AppColors.neutral8),
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(
                    part.name ?? 'Parte ${idx + 1}',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${part.sections.length} secciones · ${part.totalThrows} lanzamientos',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  trailing: Icon(Icons.add_circle_outline,
                      color: color, size: 22),
                  onTap: () => onPartSelected(part),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
