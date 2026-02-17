import 'package:flutter/material.dart';

class TestStatisticsScreen extends StatefulWidget {
  final String evaluationType;
  final List<String> athletes;
  final Map<String, List<Map<String, dynamic>>> results;

  const TestStatisticsScreen({
    super.key,
    required this.evaluationType,
    required this.athletes,
    required this.results,
  });

  @override
  State<TestStatisticsScreen> createState() => _TestStatisticsScreenState();
}

class _TestStatisticsScreenState extends State<TestStatisticsScreen> {
  String _getEvaluationTitle() {
    return widget.evaluationType == 'strength'
        ? 'Estadísticas - Prueba de Fuerza'
        : 'Estadísticas - Prueba de Dirección';
  }

  double? _getAverageForAthlete(String athlete, String distance) {
    final athleteResults = widget.results[athlete] ?? [];
    if (athleteResults.isEmpty) return null;

    final values = athleteResults
        .where((result) => result[distance]?.isNotEmpty ?? false)
        .map((result) => double.tryParse(result[distance] as String) ?? 0)
        .toList();

    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getEvaluationTitle()),
        backgroundColor: const Color(0xFF477D9E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultados y Análisis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            // Athletes results
            ...widget.athletes.map((athlete) {
              final athleteResults = widget.results[athlete] ?? [];
              return _buildAthleteCard(athlete, athleteResults);
            }),
            const SizedBox(height: 24),
            // Summary
            _buildSummaryCard(),
            const SizedBox(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E7EB),
                      foregroundColor: const Color(0xFF1F2937),
                    ),
                    child: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Exportar o guardar resultados
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resultados guardados correctamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF477D9E),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleteCard(
    String athlete,
    List<Map<String, dynamic>> results,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            athlete,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          if (results.isEmpty)
            const Text(
              'Sin resultados registrados',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow('Distancia Corta', _getAverageForAthlete(athlete, 'corta')),
                const SizedBox(height: 8),
                _buildResultRow('Distancia Media', _getAverageForAthlete(athlete, 'media')),
                const SizedBox(height: 8),
                _buildResultRow('Distancia Larga', _getAverageForAthlete(athlete, 'larga')),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Total de pruebas: ${results.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, double? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value != null ? '${value.toStringAsFixed(2)} m' : 'Sin datos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: value != null ? const Color(0xFF477D9E) : const Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF477D9E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Atletas evaluados: ${widget.athletes.length}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total de pruebas: ${widget.results.values.fold(0, (sum, list) => sum + list.length)}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tipo de evaluación: ${widget.evaluationType == 'strength' ? 'Prueba de Fuerza' : 'Prueba de Dirección'}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
