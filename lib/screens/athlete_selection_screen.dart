import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AthleteSelectionScreen extends StatefulWidget {
  final String evaluationType;

  const AthleteSelectionScreen({
    super.key,
    required this.evaluationType,
  });

  @override
  State<AthleteSelectionScreen> createState() => _AthleteSelectionScreenState();
}

class _AthleteSelectionScreenState extends State<AthleteSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedAthletes = [];

  // Simulación de atletas disponibles
  final List<Map<String, String>> allAthletes = [
    {'name': 'Juan Pérez', 'team': 'Equipo A'},
    {'name': 'María García', 'team': 'Equipo A'},
    {'name': 'Carlos López', 'team': 'Equipo B'},
    {'name': 'Ana Martínez', 'team': 'Equipo B'},
    {'name': 'David Rodríguez', 'team': 'Equipo C'},
    {'name': 'Elena Sánchez', 'team': 'Equipo C'},
    {'name': 'Roberto Díaz', 'team': 'Equipo A'},
    {'name': 'Lucia Fernández', 'team': 'Equipo B'},
  ];

  List<Map<String, String>> filteredAthletes = [];

  @override
  void initState() {
    super.initState();
    filteredAthletes = allAthletes;
    _searchController.addListener(_filterAthletes);
  }

  void _filterAthletes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredAthletes = allAthletes;
      } else {
        filteredAthletes = allAthletes
            .where((athlete) =>
                athlete['name']!.toLowerCase().startsWith(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startTest() {
    if (selectedAthletes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona al menos un atleta'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navegar a la pantalla de prueba
    Navigator.of(context).pushNamed(
      '/strength-test',
      arguments: {
        'evaluationType': widget.evaluationType,
        'athletes': selectedAthletes,
      },
    );
  }

  String _getEvaluationTitle() {
    return widget.evaluationType == 'strength'
        ? 'Prueba de control de fuerza'
        : 'Prueba de control de dirección';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getEvaluationTitle()),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          // Header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Elige la/o(s) atletas que harán la prueba',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Escribe las primeras 3 letras del nombre del atleta y selecciónalo.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar atleta...',
                    hintStyle: const TextStyle(color: AppColors.neutral7),
                    prefixIcon: const Icon(Icons.search, color: AppColors.neutral5),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.neutral8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.neutral8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Athletes list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredAthletes.length,
              itemBuilder: (context, index) {
                final athlete = filteredAthletes[index];
                final isSelected = selectedAthletes.contains(athlete['name']);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.infoBg : AppColors.surface,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.neutral8,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedAthletes.remove(athlete['name']);
                          } else {
                            selectedAthletes.add(athlete['name']!);
                          }
                        });
                      },
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.surface,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ),
                    title: Text(
                      athlete['name']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      athlete['team']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral6,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedAthletes.remove(athlete['name']);
                        } else {
                          selectedAthletes.add(athlete['name']!);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // Start button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startTest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionPrimaryDefault,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Comenzar Prueba',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.actionPrimaryInverted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
