import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/microcycle.dart';
import '../../../data/models/training_session.dart';
import '../../../data/providers/training_session_provider.dart';

/// Pantalla que lista las sesiones de entrenamiento de un microciclo,
/// organizadas por día de la semana.
class TrainingSessionListScreen extends StatefulWidget {
  final Microcycle microcycle;

  const TrainingSessionListScreen({super.key, required this.microcycle});

  @override
  State<TrainingSessionListScreen> createState() =>
      _TrainingSessionListScreenState();
}

class _TrainingSessionListScreenState
    extends State<TrainingSessionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.microcycle.microcycleId != null) {
        context
            .read<TrainingSessionProvider>()
            .loadSessionsForMicrocycle(widget.microcycle.microcycleId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutral3),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.microcycle.label,
          style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateSession(context),
        backgroundColor: AppColors.actionPrimaryDefault,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Sesión'),
      ),
      body: Consumer<TrainingSessionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!provider.hasSessions) {
            return _buildEmptyState(context);
          }

          return _buildContent(context, provider);
        },
      ),
    );
  }

  // ── Estado vacío ─────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
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
              'Sin sesiones',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea la primera sesión de entrenamiento\npara este microciclo.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateSession(context),
              icon: const Icon(Icons.add),
              label: const Text('Crear Sesión'),
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

  Widget _buildContent(
      BuildContext context, TrainingSessionProvider provider) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMicrocycleHeader(),
        const SizedBox(height: 16),
        _buildSummaryCards(provider),
        const SizedBox(height: 20),
        ..._buildDaySections(provider),
      ],
    );
  }

  Widget _buildMicrocycleHeader() {
    final micro = widget.microcycle;
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.grid_view_outlined,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  micro.label,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(micro.startDate)} — ${_formatDate(micro.endDate)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              micro.type.label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(TrainingSessionProvider provider) {
    final total = provider.sessionSummaries.length;
    final scheduled = provider.sessionSummaries
        .where((s) => s.status == TrainingSessionStatus.programada.label)
        .length;
    final completed = provider.sessionSummaries
        .where((s) =>
            s.status == TrainingSessionStatus.terminada.label ||
            s.status == TrainingSessionStatus.finalizada.label)
        .length;

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.event_note_outlined,
            label: 'Total',
            value: '$total',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            icon: Icons.schedule_outlined,
            label: 'Programadas',
            value: '$scheduled',
            color: AppColors.accent2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _summaryCard(
            icon: Icons.check_circle_outline,
            label: 'Completadas',
            value: '$completed',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ── Secciones por día de la semana ───────────────────────────────

  List<Widget> _buildDaySections(TrainingSessionProvider provider) {
    final days = [
      DayOfWeek.lunes,
      DayOfWeek.martes,
      DayOfWeek.miercoles,
      DayOfWeek.jueves,
      DayOfWeek.viernes,
      DayOfWeek.sabado,
      DayOfWeek.domingo,
    ];

    final widgets = <Widget>[];
    for (final day in days) {
      final sessions = provider.sessionsForDay(day.label);
      if (sessions.isNotEmpty) {
        widgets.add(_dayHeader(day));
        widgets.add(const SizedBox(height: 8));
        for (final session in sessions) {
          widgets.add(_buildSessionCard(session));
        }
        widgets.add(const SizedBox(height: 16));
      }
    }

    // Si no hay sesiones asignadas a un día concreto
    final unassigned = provider.sessionSummaries
        .where((s) => s.dayOfWeek == null || s.dayOfWeek!.isEmpty)
        .toList();
    if (unassigned.isNotEmpty) {
      widgets.add(_dayHeader(null));
      widgets.add(const SizedBox(height: 8));
      for (final session in unassigned) {
        widgets.add(_buildSessionCard(session));
      }
      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  Widget _dayHeader(DayOfWeek? day) {
    return Row(
      children: [
        Icon(
          _dayIcon(day),
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          day?.label ?? 'Sin día asignado',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(TrainingSessionSummary session) {
    final statusColor = _statusColor(session.status);
    final statusLabel = session.status ?? 'Sin estado';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral8),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(session.trainingSessionId),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sesión #${session.trainingSessionId}',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.dayOfWeek ?? 'Sin día',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _statChip(
                    Icons.timer_outlined,
                    '${session.duration} min',
                    AppColors.primary,
                  ),
                  _statChip(
                    Icons.sports_baseball_outlined,
                    '${session.maxThrows} lanz.',
                    AppColors.accent5,
                  ),
                  _statChip(
                    Icons.percent,
                    '${session.throwPercentage.toStringAsFixed(0)}%',
                    AppColors.accent6,
                  ),
                  _statChip(
                    Icons.view_agenda_outlined,
                    '${session.totalParts} partes',
                    AppColors.accent4,
                  ),
                  _statChip(
                    Icons.list_alt,
                    '${session.totalSections} secciones',
                    AppColors.accent2,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Navegación ───────────────────────────────────────────────────

  void _navigateToCreateSession(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.trainingSessionForm,
      arguments: {
        'microcycleId': widget.microcycle.microcycleId,
        'microcycleLabel': widget.microcycle.label,
      },
    ).then((_) {
      if (!mounted) return;
      if (widget.microcycle.microcycleId != null) {
        context
            .read<TrainingSessionProvider>()
            .loadSessionsForMicrocycle(widget.microcycle.microcycleId!);
      }
    });
  }

  void _navigateToDetail(int sessionId) {
    Navigator.of(context).pushNamed(
      AppRoutes.trainingSessionDetail,
      arguments: sessionId,
    ).then((_) {
      if (!mounted) return;
      if (widget.microcycle.microcycleId != null) {
        context
            .read<TrainingSessionProvider>()
            .loadSessionsForMicrocycle(widget.microcycle.microcycleId!);
      }
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Color _statusColor(String? status) {
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

  IconData _dayIcon(DayOfWeek? day) {
    switch (day) {
      case DayOfWeek.lunes:
        return Icons.looks_one_outlined;
      case DayOfWeek.martes:
        return Icons.looks_two_outlined;
      case DayOfWeek.miercoles:
        return Icons.looks_3_outlined;
      case DayOfWeek.jueves:
        return Icons.looks_4_outlined;
      case DayOfWeek.viernes:
        return Icons.looks_5_outlined;
      case DayOfWeek.sabado:
        return Icons.looks_6_outlined;
      case DayOfWeek.domingo:
        return Icons.weekend_outlined;
      case null:
        return Icons.help_outline;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}
