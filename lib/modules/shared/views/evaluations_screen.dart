import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/active_evaluation.dart';
import '../../../data/providers/force_test_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/info_card.dart';

/// Widget reutilizable con el contenido de evaluaciones (sin Scaffold),
/// para poder embeberse dentro del DashboardScreen.
class EvaluationsBody extends StatefulWidget {
  const EvaluationsBody({super.key});

  @override
  State<EvaluationsBody> createState() => _EvaluationsBodyState();
}

class _EvaluationsBodyState extends State<EvaluationsBody> {
  /// `null` = no se ha consultado o no hay evaluación activa.
  ActiveEvaluation? _activeEval;

  /// `true` mientras se ejecuta la petición GET tras hacer clic.
  bool _checking = false;

  // ─────────────────────────────────────────────────────────────────
  //  Clic en la tarjeta de Evaluación de Fuerza
  // ─────────────────────────────────────────────────────────────────
  Future<void> _onForceCardTap() async {
    // Evitar doble tap mientras carga
    if (_checking) return;

    setState(() {
      _checking = true;
      _activeEval = null;
    });

    final provider = context.read<ForceTestProvider>();
    final session = context.read<SessionProvider>().session;
    final team = context.read<TeamProvider>().selectedTeam;

    final coachId = session?.userId ?? 1;
    final teamId = team?.teamId ?? 1;

    final result = await provider.checkForActiveEvaluation(teamId, coachId);

    if (!mounted) return;

    if (result != null) {
      // Hay una evaluación activa → mostrar la card con info
      setState(() {
        _activeEval = result;
        _checking = false;
      });
    } else {
      // No hay evaluación activa → confirmar antes de navegar al setup
      setState(() {
        _activeEval = null;
        _checking = false;
      });
      if (!mounted) return;
      final confirmed = await AppDialog.confirm(
        context,
        title: 'Nueva evaluación',
        message:
            '¿Deseas iniciar una nueva evaluación de fuerza? Asegúrate de tener a los atletas listos.',
        confirmLabel: 'Iniciar',
        icon: Icons.assignment_add,
      );
      if (!confirmed || !mounted) return;
      await provider.resetForNewEvaluation();
      if (!mounted) return;
      Navigator.of(context).pushNamed('/force-test-module');
    }
  }

  // ─────────────────────────────────────────────────────────────────
  //  Continuar la evaluación activa
  // ─────────────────────────────────────────────────────────────────
  Future<void> _continueActiveEvaluation() async {
    final provider = context.read<ForceTestProvider>();
    await provider.resumeEvaluation(_activeEval!);
    if (!mounted) return;
    // Limpiar estado para que al volver la card desaparezca
    setState(() => _activeEval = null);
    Navigator.of(context).pushNamed('/force-test-module');
  }

  // ─────────────────────────────────────────────────────────────────
  //  Descartar la card (volver al estado normal sin navegar)
  // ─────────────────────────────────────────────────────────────────
  void _dismissActiveCard() {
    setState(() => _activeEval = null);
  }

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
            // ── Tarjeta Evaluación de Fuerza ──────────────────────
            GestureDetector(
              onTap: _checking ? null : _onForceCardTap,
              child: _buildForceEvaluationCard(),
            ),

            // ── Card de evaluación activa (aparece después del clic) ─
            if (_activeEval != null) ...[
              const SizedBox(height: 16),
              _buildActiveEvaluationCard(_activeEval!),
            ],

            const SizedBox(height: 24),

            // ── Tarjeta Evaluación de Control de Dirección ─────────
            GestureDetector(
              onTap: () => Navigator.of(context)
                  .pushNamed('/athlete-selection', arguments: 'direction'),
              child: _buildEvaluationCard(
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

            // ── Info ───────────────────────────────────────────────
            InfoCard.info(
              title: 'Información sobre las evaluaciones',
              message:
                  'Las evaluaciones están diseñadas para medir el rendimiento de los atletas de forma precisa y objetiva. Selecciona la evaluación apropiada según tus objetivos de entrenamiento.',
              margin: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Tarjeta de Evaluación de Fuerza con indicador de loading
  // ─────────────────────────────────────────────────────────────────
  Widget _buildForceEvaluationCard() {
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
              const Text('⚡', style: TextStyle(fontSize: 24)),
              Row(
                children: [
                  if (_checking)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 18,
                      height: 18,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NUEVO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Evaluación de Fuerza (Boccia)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _checking
                ? 'Verificando evaluaciones pendientes…'
                : 'Módulo completo de 36 tiros con estadísticas en tiempo real y mapa de calor.',
            style: TextStyle(
              fontSize: 14,
              color: _checking ? AppColors.primary : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Card: evaluación activa pendiente
  // ─────────────────────────────────────────────────────────────────
  Widget _buildActiveEvaluationCard(ActiveEvaluation eval) {
    final athleteNames = eval.athletes.map((a) => a.athleteName).join(', ');
    final throwsDone = eval.completedThrowsCount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary30, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary20,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.actionPrimaryActive],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary20,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pending_actions_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Evaluación Pendiente',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
                // Botón cerrar
                GestureDetector(
                  onTap: _dismissActiveCard,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary20,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Cuerpo ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.edit_note_rounded, 'Nombre', eval.description),
                const SizedBox(height: 10),
                _infoRow(Icons.groups_rounded, 'Equipo', eval.teamName),
                if (athleteNames.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _infoRow(
                      Icons.person_outline_rounded, 'Atletas', athleteNames),
                ],
                const SizedBox(height: 10),
                _infoRow(
                  Icons.sports_rounded,
                  'Lanzamientos',
                  '$throwsDone registrados',
                ),
                const SizedBox(height: 16),

                // ── Barra de progreso ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$throwsDone / 36 tiros',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: throwsDone / 36,
                    minHeight: 7,
                    backgroundColor: AppColors.neutral8,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Aviso ──────────────────────────────────────────
                InfoCard.info(
                  message:
                      'No puedes crear una nueva prueba mientras tengas una pendiente.',
                  margin: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                // ── Botón continuar ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _continueActiveEvaluation,
                    icon: const Icon(Icons.play_arrow_rounded, size: 20),
                    label: const Text(
                      'CONTINUAR EVALUACIÓN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral2,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────
  //  Tarjeta genérica de tipo de evaluación
  // ─────────────────────────────────────────────────────────────────
  Widget _buildEvaluationCard({
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
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

