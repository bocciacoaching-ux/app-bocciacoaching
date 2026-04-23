import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Chip del AppBar que muestra el equipo activo y abre el end-drawer
/// de cambio de equipo al ser pulsado.
///
/// Muestra (en orden de prioridad):
/// 1. La imagen del equipo ([teamImageUrl]) si está disponible.
/// 2. La inicial del nombre del equipo si no hay imagen.
/// 3. El emoji [teamFlag] si tampoco hay nombre.
class TeamSelectorChip extends StatelessWidget {
  final String teamName;
  final String teamFlag;
  final String teamSubtitle;
  final String? teamImageUrl;
  final VoidCallback onTap;

  const TeamSelectorChip({
    super.key,
    required this.teamName,
    required this.teamFlag,
    required this.teamSubtitle,
    required this.onTap,
    this.teamImageUrl,
  });

  static const double _avatarSize = 28;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Reservamos ~180px para leading + actions del AppBar y dejamos el resto
    // al chip, con un máximo razonable para no quedar excesivamente ancho
    // en pantallas grandes (tablets / web).
    final maxChipWidth =
        (screenWidth - 180).clamp(140.0, 320.0).toDouble();

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxChipWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(),
              const SizedBox(width: 8),
              Flexible(
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
                    if (teamSubtitle.isNotEmpty)
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
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_drop_down,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (teamImageUrl != null && teamImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          teamImageUrl!,
          width: _avatarSize,
          height: _avatarSize,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _placeholder(
              child: const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _fallbackAvatar(),
        ),
      );
    }
    return _fallbackAvatar();
  }

  Widget _fallbackAvatar() {
    if (teamName.isNotEmpty && teamName != 'Sin equipo') {
      final initial = teamName.trim()[0].toUpperCase();
      return _placeholder(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
    if (teamFlag.isNotEmpty) {
      return _placeholder(
        child: Text(teamFlag, style: const TextStyle(fontSize: 14)),
      );
    }
    return _placeholder(
      child: const Icon(
        Icons.group_outlined,
        color: AppColors.primary,
        size: 16,
      ),
    );
  }

  Widget _placeholder({required Widget child}) {
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
