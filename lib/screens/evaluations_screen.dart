import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/force_test_provider.dart';
import '../theme/app_colors.dart';

/// Widget reutilizable con el contenido de evaluaciones (sin Scaffold),
/// para poder embeberse dentro del DashboardScreen.
class EvaluationsBody extends StatelessWidget {
  const EvaluationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24.0,
          24.0,
          24.0,
          24.0 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta Evaluación de Fuerza (NUEVA IMPLEMENTACIÓN)
            GestureDetector(
              onTap: () async {
                // Reiniciar el provider para mostrar siempre el setup inicial
                final provider = context.read<ForceTestProvider>();
                await provider.resetForNewEvaluation();
                if (context.mounted) {
                  Navigator.of(context).pushNamed('/force-test-module');
                }
              },
              child: _buildEvaluationCard(
                context,
                icon: '⚡',
                title: 'Evaluación de Fuerza (Boccia)',
                description:
                    'Nuevo módulo completo de 36 tiros con estadísticas en tiempo real y mapa de calor.',
                badgeLabel: 'NUEVO',
                badgeColor: AppColors.infoBg,
                badgeTextColor: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            // Tarjeta Evaluación de Control de Dirección
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .pushNamed('/athlete-selection', arguments: 'direction');
              },
              child: _buildEvaluationCard(
                context,
                icon: '📖',
                title: 'Evaluación de Control de Dirección',
                description:
                    'Evalúa la precisión y el control de dirección del atleta',
                badgeLabel: 'TÉCNICA',
                badgeColor: AppColors.accent4x10,
                badgeTextColor: AppColors.accent4,
              ),
            ),
            const SizedBox(height: 32),
            // Información sobre las evaluaciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                    color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Información sobre las evaluaciones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Las evaluaciones están diseñadas para medir el rendimiento de los atletas de forma precisa y objetiva. Selecciona la evaluación apropiada según tus objetivos de entrenamiento.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
            color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Pantalla standalone (se mantiene para rutas directas si se necesitara)
// ──────────────────────────────────────────────────────────────────────────────
class EvaluationsScreen extends StatefulWidget {
  const EvaluationsScreen({super.key});

  @override
  State<EvaluationsScreen> createState() => _EvaluationsScreenState();
}

class _EvaluationsScreenState extends State<EvaluationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: const EvaluationsBody(),
    );
  }
}

