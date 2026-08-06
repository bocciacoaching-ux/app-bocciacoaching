import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/force_test_provider.dart';
import '../../../data/models/athlete.dart' as model;
import '../../../core/theme/app_colors.dart';
import 'athletes_screen.dart' show Athlete;

// ---------------------------------------------------------------------------
// Pantalla de perfil de un atleta
// ---------------------------------------------------------------------------
class AthleteProfileScreen extends StatelessWidget {
  final Athlete athlete;

  const AthleteProfileScreen({super.key, required this.athlete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                32 + MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 14),
                  _buildStatsRow(),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Mostrar más',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildEvaluationsSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SliverAppBar con foto de fondo a pantalla completa ──────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    final hasPhoto = athlete.image != null && athlete.image!.isNotEmpty;
    final initials = athlete.name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0])
        .take(2)
        .join();

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.black,
      // Bordes redondeados en la parte inferior
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left, color: AppColors.white, size: 32),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
          child: Stack(
          fit: StackFit.expand,
          children: [
            // Foto o fondo de color
            hasPhoto
                ? Image.network(
                    athlete.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackBackground(initials),
                  )
                : _fallbackBackground(initials),
            // Gradiente oscuro inferior
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.4, 1.0],
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            // Nombre y subtítulo sobre la foto
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    athlete.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    athlete.nationality.isNotEmpty
                        ? ' Ciudad | ${athlete.nationality}'
                        : '—',
                    style: TextStyle(
                      color: AppColors.white.withAlpha(210),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ), // ClipRRect
      ),
    );
  }

  Widget _fallbackBackground(String initials) {
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  // ── Tarjeta de información general ──────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: título + chip de estado
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Información del atleta',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black),
                ),
              ),
              _StatusChipSmall(status: athlete.status),
            ],
          ),
          const SizedBox(height: 18),
          // Fila 1
          Row(
            children: [
              Expanded(
                  child: _infoField(
                      'Clasificación',
                      athlete.classification.isNotEmpty
                          ? athlete.classification
                          : '—')),
              Expanded(
                  child: _infoField(
                      'Posición',
                      athlete.position.isNotEmpty
                          ? athlete.position
                          : '—')),
            ],
          ),
          const SizedBox(height: 16),
          // Fila 2
          Row(
            children: [
              Expanded(
                  child: _infoField(
                      'Edad',
                      athlete.age > 0
                          ? '${athlete.age} años'
                          : '—')),
              Expanded(
                  child: _infoField(
                      'Nacionalidad',
                      athlete.nationality.isNotEmpty
                          ? athlete.nationality
                          : '—')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.black)),
      ],
    );
  }

  // ── Fila de estadísticas rápidas ─────────────────────────────────────────
  Widget _buildStatsRow() {
    final precision = athlete.avgScore > 0
        ? '${(athlete.avgScore * 14).clamp(0, 100).toStringAsFixed(0)}%'
        : '—';
    return Row(
      children: [
        _statCard('Promedio',
            athlete.avgScore > 0 ? athlete.avgScore.toStringAsFixed(1) : '—'),
        const SizedBox(width: 10),
        _statCard('Precisión', precision),
        const SizedBox(width: 10),
        _statCard('Sesiones', '12'),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Sección de evaluaciones ──────────────────────────────────────────────
  Widget _buildEvaluationsSection(BuildContext context) {
    final firstName = athlete.name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Iniciar evaluación de $firstName',
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.black),
        ),
        const SizedBox(height: 4),
        const Text(
          'Selecciona el tipo de evaluación que quieres comenzar',
          style: TextStyle(
              fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 16),
        _evaluationCard(
          context,
          iconColor: const Color(0xFFD6E8F5),
          title: 'Control de Fuerza',
          description:
              'Módulo de 36 tiros con estadísticas en tiempo real y mapa de calor.',
          onTap: () => _startForceEvaluation(context),
        ),
        const SizedBox(height: 12),
        _evaluationCard(
          context,
          iconColor: const Color(0xFFD6E8F5),
          title: 'Control de Dirección',
          description:
              'Módulo de 36 tiros para evaluar la presisión y el control de dirección.',
          onTap: () => _startDirectionEvaluation(context),
        ),
      ],
    );
  }

  Widget _evaluationCard(
    BuildContext context, {
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Ícono cuadrado de color
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 14),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 26, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // ── Acciones ─────────────────────────────────────────────────────────────
  void _startForceEvaluation(BuildContext context) async {
    final providerAthlete = model.Athlete(
      id: athlete.id,
      name: athlete.name,
    );
    final provider = context.read<ForceTestProvider>();
    await provider.resetForNewEvaluation();
    if (!context.mounted) return;
    provider.addAthlete(providerAthlete);
    Navigator.of(context).pushNamed('/force-test-module');
  }

  void _startDirectionEvaluation(BuildContext context) {
    Navigator.of(context)
        .pushNamed('/athlete-selection', arguments: 'direction');
  }
}

// ---------------------------------------------------------------------------
// Chip de estado para la tarjeta de info
// ---------------------------------------------------------------------------
class _StatusChipSmall extends StatelessWidget {
  final String status;
  const _StatusChipSmall({required this.status});

  Color get _bg {
    switch (status) {
      case 'Lesionado':
        return AppColors.warning.withAlpha(30);
      case 'Inactivo':
        return AppColors.error.withAlpha(30);
      default:
        return AppColors.success.withAlpha(30);
    }
  }

  Color get _fg {
    switch (status) {
      case 'Lesionado':
        return AppColors.warning;
      case 'Inactivo':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: _fg),
      ),
    );
  }
}
