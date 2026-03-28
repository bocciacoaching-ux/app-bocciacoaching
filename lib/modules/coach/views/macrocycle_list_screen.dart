import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/macrocycle.dart';
import '../../../data/providers/macrocycle_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../coach/services/macrocycle_excel_export.dart';

/// Pantalla que lista todos los macrociclos creados.
/// Permite ver, crear y eliminar macrociclos.
class MacrocycleListScreen extends StatefulWidget {
  const MacrocycleListScreen({super.key});

  @override
  State<MacrocycleListScreen> createState() => _MacrocycleListScreenState();
}

class _MacrocycleListScreenState extends State<MacrocycleListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MacrocycleProvider>().loadMacrocycles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(
        activeRoute: AppDrawerRoute.macrociclos,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.neutral3),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Macrociclos',
          style: AppTextStyles.titleLarge,
        ),
        centerTitle: true,
        actions: const [
          ProfileMenuButton(),
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(
          AppRoutes.macrocycleBuilder,
        ),
        backgroundColor: AppColors.actionPrimaryDefault,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Macro'),
      ),
      body: Consumer<MacrocycleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (!provider.hasMacrocycles) {
            return _buildEmptyState(context);
          }

          return _buildMacrocycleList(context, provider);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin macrociclos',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu primer macrociclo para planificar\nel entrenamiento de tus atletas.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed(
                AppRoutes.macrocycleBuilder,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Crear Macrociclo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrocycleList(
      BuildContext context, MacrocycleProvider provider) {
    // Agrupar por atleta
    final grouped = <String, List<Macrocycle>>{};
    for (final macro in provider.macrocycles) {
      final key = macro.athleteName.isEmpty
          ? 'Sin asignar'
          : macro.athleteName;
      grouped.putIfAbsent(key, () => []).add(macro);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Resumen
        _buildSummaryCards(provider),
        const SizedBox(height: 20),

        // Lista agrupada por atleta
        for (final entry in grouped.entries) ...[
          _sectionHeader(entry.key, entry.value.length),
          const SizedBox(height: 8),
          ...entry.value.map((macro) => _buildMacrocycleCard(
                context,
                macro,
                provider,
              )),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSummaryCards(MacrocycleProvider provider) {
    final total = provider.macrocycles.length;
    final athletes = provider.macrocycles
        .map((m) => m.athleteId)
        .toSet()
        .length;

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.calendar_month,
            label: 'Macrociclos',
            value: '$total',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.people_outline,
            label: 'Atletas',
            value: '$athletes',
            color: AppColors.accent5,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        const Icon(Icons.person_outline,
            size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacrocycleCard(
    BuildContext context,
    Macrocycle macro,
    MacrocycleProvider provider,
  ) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final startStr =
        '${macro.startDate.day} ${months[macro.startDate.month - 1]} ${macro.startDate.year}';
    final endStr =
        '${macro.endDate.day} ${months[macro.endDate.month - 1]} ${macro.endDate.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.neutral8),
      ),
      color: AppColors.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.macrocycleDetail,
          arguments: macro,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título y acciones
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          macro.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$startStr — $endStr',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        color: AppColors.neutral5, size: 20),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _confirmDelete(context, macro, provider);
                      } else if (value == 'view') {
                        Navigator.of(context).pushNamed(
                          AppRoutes.macrocycleDetail,
                          arguments: macro,
                        );
                      } else if (value == 'export') {
                        _exportMacro(context, macro);
                      } else if (value == 'share') {
                        _shareMacro(context, macro);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility_outlined,
                                size: 18, color: AppColors.neutral3),
                            SizedBox(width: 8),
                            Text('Ver detalle'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            Icon(Icons.file_download_outlined,
                                size: 18, color: AppColors.success),
                            SizedBox(width: 8),
                            Text('Exportar Excel'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share_outlined,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Compartir'),
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
                            Text('Eliminar',
                                style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
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
                    Icons.date_range,
                    '${macro.totalWeeks} semanas',
                    AppColors.primary,
                  ),
                  _statChip(
                    Icons.layers_outlined,
                    '${macro.periods.length} etapas',
                    AppColors.accent5,
                  ),
                  _statChip(
                    Icons.view_week_outlined,
                    '${macro.mesocycles.length} mesociclos',
                    AppColors.accent6,
                  ),
                  _statChip(
                    Icons.event_outlined,
                    '${macro.events.length} eventos',
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

  Future<void> _exportMacro(BuildContext context, Macrocycle macro) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 20),
              Text('Exportando a Excel...'),
            ],
          ),
        ),
      );

      final filePath = await MacrocycleExcelExport.exportToExcel(macro);

      if (!mounted) return;
      Navigator.of(context).pop();

      final fileName = filePath.split('/').last;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.success),
              SizedBox(width: 8),
              Expanded(child: Text('Exportado exitosamente')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('El archivo se ha guardado correctamente:'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.neutral9,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined,
                        size: 20, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cerrar'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await OpenFilex.open(filePath);
                  },
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Abrir'),
                ),
                const SizedBox(width: 4),
                FilledButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _shareExcelFile(context, macro, filePath);
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Compartir'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al exportar: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareMacro(BuildContext context, Macrocycle macro) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 20),
              Text('Preparando archivo...'),
            ],
          ),
        ),
      );

      final filePath = await MacrocycleExcelExport.exportToExcel(macro);

      if (!mounted) return;
      Navigator.of(context).pop();

      await _shareExcelFile(context, macro, filePath);
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareExcelFile(
    BuildContext context,
    Macrocycle macro,
    String filePath,
  ) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        subject: 'Macrociclo: ${macro.name}',
        text:
            'Macrociclo de ${macro.athleteName} — '
            '${macro.startDate.day}/${macro.startDate.month}/${macro.startDate.year} '
            'al ${macro.endDate.day}/${macro.endDate.month}/${macro.endDate.year}',
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Macrocycle macro,
    MacrocycleProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Eliminar macrociclo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${macro.name}"?\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMacrocycle(macro.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Macrociclo "${macro.name}" eliminado'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
