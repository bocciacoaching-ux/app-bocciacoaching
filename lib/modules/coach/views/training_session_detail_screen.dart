import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/models/training_session.dart';
import '../../../data/providers/training_session_provider.dart';

/// Pantalla de detalle de una sesión de entrenamiento.
///
/// Muestra la información completa de la sesión, sus 4 partes
/// (Propulsion, Saremas, 2x1, Escenarios de juego) y las secciones
/// dentro de cada parte, con opción de agregar/editar secciones
/// y cambiar el estado de la sesión.
class TrainingSessionDetailScreen extends StatefulWidget {
  final int sessionId;

  const TrainingSessionDetailScreen({super.key, required this.sessionId});

  @override
  State<TrainingSessionDetailScreen> createState() =>
      _TrainingSessionDetailScreenState();
}

class _TrainingSessionDetailScreenState
    extends State<TrainingSessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingSessionProvider>().loadFullSession(widget.sessionId);
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
          'Sesión #${widget.sessionId}',
          style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.neutral5),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined,
                        size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Editar sesión'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline,
                        size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<TrainingSessionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final session = provider.currentSession;
          if (session == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.neutral5),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Sesión no encontrada',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildBody(context, session, provider);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TrainingSession session,
    TrainingSessionProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSessionHeader(session),
          const SizedBox(height: 16),
          _buildThrowsSummary(session),
          const SizedBox(height: 16),
          _buildStatusSection(session, provider),
          const SizedBox(height: 20),
          if (session.photoEvidences.isNotEmpty) ...[
            _sectionTitle(
                'Evidencias Fotográficas', Icons.photo_library_outlined),
            const SizedBox(height: 8),
            _buildPhotoEvidences(session),
            const SizedBox(height: 20),
          ],
          _sectionTitle('Partes de la Sesión', Icons.view_agenda_outlined),
          const SizedBox(height: 8),
          ...session.parts
              .asMap()
              .entries
              .map((entry) => _buildPartCard(entry.value, entry.key)),
          if (session.parts.isEmpty) _buildEmptyParts(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Header de la sesión ──────────────────────────────────────────

  Widget _buildSessionHeader(TrainingSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.dayOfWeek ?? 'Sin día asignado',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Duración: ${session.duration} minutos',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (session.startTime != null || session.endTime != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.neutral8),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (session.startTime != null)
                  _infoChip(
                    Icons.play_arrow_outlined,
                    'Inicio: ${_formatDateTime(session.startTime!)}',
                    AppColors.success,
                  ),
                if (session.endTime != null)
                  _infoChip(
                    Icons.stop_outlined,
                    'Fin: ${_formatDateTime(session.endTime!)}',
                    AppColors.error,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Resumen de lanzamientos ──────────────────────────────────────

  Widget _buildThrowsSummary(TrainingSession session) {
    final assigned = session.assignedThrows;
    final max = session.maxThrows;
    final remaining = session.remainingThrows;
    final progress = max > 0 ? (assigned / max).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_baseball_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Lanzamientos',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
              ),
              const Spacer(),
              Text(
                '${session.throwPercentage.toStringAsFixed(0)}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.neutral8,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _throwStat('Asignados', '$assigned', AppColors.primary),
              _throwStat('Máximo', '$max', AppColors.accent5),
              _throwStat(
                'Restantes',
                '$remaining',
                remaining < 0 ? AppColors.error : AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _throwStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: color,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Estado de la sesión ──────────────────────────────────────────

  Widget _buildStatusSection(
      TrainingSession session, TrainingSessionProvider provider) {
    final currentStatus = session.status ?? 'Programada';
    const statuses = TrainingSessionStatus.values;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_outlined,
                  size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Estado de la Sesión',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: statuses.map((status) {
              final isSelected = status.label == currentStatus;
              final color = _statusColor(status.label);
              return GestureDetector(
                onTap: isSelected
                    ? null
                    : () => _changeStatus(
                          session.trainingSessionId!,
                          status.label,
                          provider,
                        ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.15)
                        : AppColors.neutral9,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : AppColors.neutral7,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? color : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Evidencias fotográficas ──────────────────────────────────────

  Widget _buildPhotoEvidences(TrainingSession session) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: session.photoEvidences.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final url = session.photoEvidences[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 120,
              height: 120,
              color: AppColors.neutral8,
              child: Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.neutral5,
                    size: 32,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Partes de la sesión ──────────────────────────────────────────

  Widget _buildEmptyParts() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.view_agenda_outlined,
                size: 40, color: AppColors.neutral6),
            const SizedBox(height: 8),
            Text(
              'Sin partes registradas',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartCard(SessionPart part, int index) {
    final partType = _resolvePartType(part.name);
    final color = _partColor(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_partIcon(index), color: color, size: 20),
          ),
          title: Text(
            partType ?? part.name ?? 'Parte ${index + 1}',
            style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
          ),
          subtitle: Text(
            '${part.sections.length} secciones · ${part.totalThrows} lanzamientos',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: color, size: 22),
                tooltip: 'Agregar sección',
                onPressed: () =>
                    _showAddSectionDialog(part.sessionPartId!, part.name),
              ),
              const Icon(Icons.expand_more, color: AppColors.neutral5),
            ],
          ),
          children: [
            if (part.sections.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Sin secciones aún. Toca + para agregar.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...part.sections.asMap().entries.map(
                  (entry) => _buildSectionTile(entry.value, entry.key, color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTile(SessionSection section, int index, Color partColor) {
    final statusColor = _statusColor(section.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral9,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 32,
                decoration: BoxDecoration(
                  color: partColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name ?? 'Sección ${index + 1}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sports_baseball,
                                size: 13, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${section.numberOfThrows} lanzamientos',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              section.isOwnDiagonal
                                  ? Icons.person
                                  : Icons.person_outline,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              section.isOwnDiagonal
                                  ? 'Diag. propia'
                                  : 'Diag. rival',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (section.status != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    section.status!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_vert,
                    size: 18, color: AppColors.neutral5),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditSectionDialog(section);
                  } else if (value == 'delete') {
                    _confirmDeleteSection(section);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 16, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Eliminar',
                            style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (section.observation != null &&
              section.observation!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                section.observation!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Section Title helper ─────────────────────────────────────────

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            text,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  // ── Acciones ─────────────────────────────────────────────────────

  void _handleMenuAction(String action) {
    final provider = context.read<TrainingSessionProvider>();
    final session = provider.currentSession;
    if (session == null) return;

    switch (action) {
      case 'edit':
        Navigator.of(context).pushNamed(
          AppRoutes.trainingSessionForm,
          arguments: {
            'session': session,
            'microcycleId': session.microcycleId,
          },
        ).then((_) {
          provider.loadFullSession(widget.sessionId);
        });
        break;
      case 'delete':
        _confirmDeleteSession(session, provider);
        break;
    }
  }

  Future<void> _changeStatus(
      int sessionId, String newStatus, TrainingSessionProvider provider) async {
    final error = await provider.updateSessionStatus(sessionId, newStatus);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _confirmDeleteSession(
      TrainingSession session, TrainingSessionProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar sesión'),
        content: const Text(
            '¿Estás seguro de que deseas eliminar esta sesión de entrenamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final success =
                  await provider.deleteSession(session.trainingSessionId!);
              if (!mounted) return;
              if (success) {
                Navigator.of(context).pop(); // Volver a la lista
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Error al eliminar la sesión'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ── Sección: navegación para agregar/editar/eliminar ──────────────

  void _showAddSectionDialog(int sessionPartId, String? partName) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.sectionForm,
      arguments: {
        'sessionPartId': sessionPartId,
        'partName': partName,
      },
    );
    // Recargar la sesión si se guardó algo
    if (result == true) {
      context.read<TrainingSessionProvider>().loadFullSession(widget.sessionId);
    }
  }

  void _showEditSectionDialog(SessionSection section) async {
    final result = await Navigator.of(context).pushNamed(
      AppRoutes.sectionForm,
      arguments: {
        'sessionPartId': section.sessionPartId,
        'section': section,
      },
    );
    if (result == true) {
      context.read<TrainingSessionProvider>().loadFullSession(widget.sessionId);
    }
  }

  void _confirmDeleteSection(SessionSection section) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar sección'),
        content: Text('¿Eliminar "${section.name ?? 'esta sección'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final provider = context.read<TrainingSessionProvider>();
              await provider.deleteSection(section.sessionSectionId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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

  Color _partColor(int index) {
    const colors = [
      AppColors.primary,
      AppColors.accent5,
      AppColors.accent6,
      AppColors.accent4,
    ];
    return colors[index % colors.length];
  }

  IconData _partIcon(int index) {
    const icons = [
      Icons.rocket_launch_outlined, // Propulsión
      Icons.sports_outlined, // Saremas
      Icons.group_outlined, // 2x1
      Icons.stadium_outlined, // Escenarios de juego
    ];
    return icons[index % icons.length];
  }

  String? _resolvePartType(String? name) {
    if (name == null) return null;
    for (final type in SessionPartType.values) {
      if (type.label.toLowerCase() == name.toLowerCase()) return type.label;
    }
    return name;
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
