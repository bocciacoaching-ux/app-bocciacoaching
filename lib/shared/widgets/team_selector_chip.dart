import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Chip del AppBar que muestra el equipo activo y abre el end-drawer
/// de cambio de equipo al ser pulsado.
///
/// Parámetros:
/// - [teamName]     → nombre del equipo activo.
/// - [teamFlag]     → emoji de bandera del equipo.
/// - [teamSubtitle] → subtítulo del equipo (ej. "Solo Córdoba").
/// - [onTap]        → callback que se ejecuta al pulsar (típicamente
///                    `scaffoldKey.currentState?.openEndDrawer()`).
class TeamSelectorChip extends StatelessWidget {
  final String teamName;
  final String teamFlag;
  final String teamSubtitle;
  final VoidCallback onTap;

  const TeamSelectorChip({
    super.key,
    required this.teamName,
    required this.teamFlag,
    required this.teamSubtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.neutral7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(teamFlag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    teamSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
