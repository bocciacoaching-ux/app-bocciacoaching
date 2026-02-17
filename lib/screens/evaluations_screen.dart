import 'package:flutter/material.dart';

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
        backgroundColor: const Color(0xFF477D9E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta Evaluación de Fuerza
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/athlete-selection', arguments: 'strength');
              },
              child: _buildEvaluationCard(
                context,
                icon: '⚡',
                title: 'Evaluación de Fuerza',
                description: 'Realiza la evaluación de control de fuerza para medir la capacidad del atleta',
                badgeLabel: 'FÍSICA',
                badgeColor: const Color(0xFFD4E8F7),
                badgeTextColor: const Color(0xFF477D9E),
              ),
            ),
            const SizedBox(height: 24),
            // Tarjeta Evaluación de Control de Dirección
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/athlete-selection', arguments: 'direction');
              },
              child: _buildEvaluationCard(
                context,
                icon: '📖',
                title: 'Evaluación de Control de Dirección',
                description: 'Evalúa la precisión y el control de dirección del atleta',
                badgeLabel: 'TÉCNICA',
                badgeColor: const Color(0xFFF0E6F6),
                badgeTextColor: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(height: 32),
            // Información sobre las evaluaciones
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E8F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info,
                      color: Color(0xFF477D9E),
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
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Las evaluaciones están diseñadas para medir el rendimiento de los atletas de forma precisa y objetiva. Selecciona la evaluación apropiada según tus objetivos de entrenamiento.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
