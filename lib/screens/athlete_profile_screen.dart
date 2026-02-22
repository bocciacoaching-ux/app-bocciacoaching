import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/force_test_provider.dart';
import '../models/athlete.dart' as model;
// El modelo UI de atleta viene de athletes_screen.dart
import 'athletes_screen.dart' show Athlete;

// ---------------------------------------------------------------------------
// Pantalla de perfil de un atleta
// ---------------------------------------------------------------------------
class AthleteProfileScreen extends StatelessWidget {
  final Athlete athlete;

  const AthleteProfileScreen({super.key, required this.athlete});

  // Color principal de la app
  static const _primary = Color(0xFF477D9E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FB),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildEvaluationsSection(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SliverAppBar con avatar grande ──────────────────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    final initials = athlete.name.split(' ').map((w) => w[0]).take(2).join();
    final statusColor = _getStatusColor(athlete.status);

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: _primary,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2C5F7A), Color(0xFF477D9E)],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withAlpha(38),
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Indicador de estado
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  athlete.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(athlete.flag, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      athlete.nationality,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        title: Text(
          athlete.name,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
      ),
    );
  }

  // ── Tarjeta de información general ──────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información del atleta',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F2336))),
          const SizedBox(height: 16),
          _infoRow(Icons.category_outlined,      'Clasificación', athlete.classification),
          _infoRow(Icons.sports_outlined,         'Posición',      athlete.position),
          _infoRow(Icons.cake_outlined,            'Edad',          '${athlete.age} años'),
          _infoRow(Icons.flag_outlined,            'Nacionalidad',  '${athlete.flag} ${athlete.nationality}'),
          _infoRow(Icons.circle, 'Estado', athlete.status,
              valueColor: _getStatusColor(athlete.status)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: _primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF0F2336),
            ),
          ),
        ],
      ),
    );
  }

  // ── Fila de estadísticas rápidas ─────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('⭐ Promedio', athlete.avgScore.toStringAsFixed(1), 'pts'),
        const SizedBox(width: 12),
        _statCard('🎯 Precisión', '${(athlete.avgScore * 10).toStringAsFixed(0)}%', ''),
        const SizedBox(width: 12),
        _statCard('📋 Sesiones', '12', 'total'),
      ],
    );
  }

  Widget _statCard(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2336))),
            if (unit.isNotEmpty)
              Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
          ],
        ),
      ),
    );
  }

  // ── Sección de evaluaciones ──────────────────────────────────────────────
  Widget _buildEvaluationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Iniciar evaluación',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F2336)),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecciona el tipo de evaluación para ${athlete.name.split(' ').first}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        const SizedBox(height: 14),
        _evaluationCard(
          context,
          icon: '⚡',
          title: 'Evaluación de Fuerza',
          description: 'Módulo de 36 tiros con estadísticas en tiempo real y mapa de calor.',
          badgeLabel: 'NUEVO',
          badgeColor: const Color(0xFFD4E8F7),
          badgeTextColor: _primary,
          onTap: () => _startForceEvaluation(context),
        ),
        const SizedBox(height: 14),
        _evaluationCard(
          context,
          icon: '📖',
          title: 'Evaluación de Dirección',
          description: 'Evalúa la precisión y el control de dirección del atleta.',
          badgeLabel: 'TÉCNICA',
          badgeColor: const Color(0xFFF0E6F6),
          badgeTextColor: const Color(0xFF8B5CF6),
          onTap: () => _startDirectionEvaluation(context),
        ),
      ],
    );
  }

  Widget _evaluationCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required String badgeLabel,
    required Color badgeColor,
    required Color badgeTextColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F8FB),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F2336))),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(badgeLabel,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeTextColor)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF477D9E)),
          ],
        ),
      ),
    );
  }

  // ── Navegación a evaluaciones ────────────────────────────────────────────

  void _startForceEvaluation(BuildContext context) async {
    // Construimos el Athlete del modelo del provider con los datos del atleta UI
    final providerAthlete = model.Athlete(
      id: int.tryParse(athlete.id) ?? 0,
      name: athlete.name,
    );

    final provider = context.read<ForceTestProvider>();
    await provider.resetForNewEvaluation();

    if (!context.mounted) return;

    // Pre-seleccionamos el atleta en el provider
    provider.addAthlete(providerAthlete);

    Navigator.of(context).pushNamed('/force-test-module');
  }

  void _startDirectionEvaluation(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/athlete-selection',
      arguments: 'direction',
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Lesionado':
        return Colors.orange;
      case 'Inactivo':
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}
