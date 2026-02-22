import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/session_provider.dart';
import '../models/user_session.dart';
import '../theme/app_colors.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _activeRole = 'Entrenador';

  /// Devuelve las iniciales del nombre completo (máx. 2 letras).
  static String _initials(UserSession s) {
    final parts = s.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
  }

  /// Etiqueta legible del rol.
  static String _roleLabel(int rolId) {
    switch (rolId) {
      case 1:
        return 'Entrenador';
      case 3:
        return 'Deportista';
      default:
        return 'Usuario';
    }
  }

  /// Lista de roles disponibles según los rolIds que devuelve la API.
  static List<String> _availableRoles(List<int> rolIds) {
    return rolIds.map(_roleLabel).toList();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>().session;
    final initials = session != null ? _initials(session) : '?';
    final fullName = session?.fullName ?? 'Usuario';
    final email = session?.email ?? '';
    final rolLabel = session != null ? _roleLabel(session.rolId) : '';
    final availableRoles = session != null ? _availableRoles([session.rolId]) : <String>[];
    final country = session?.country ?? '';
    final category = session?.category ?? '';

    // Sincronizar rol activo con el que devuelve la API
    if (session != null && _activeRole != rolLabel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _activeRole = rolLabel);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Mi Perfil', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── User info card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar: imagen de red si existe, si no iniciales
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.secondary,
                    backgroundImage: (session?.image != null && session!.image!.isNotEmpty)
                        ? NetworkImage(session.image!)
                        : null,
                    child: (session?.image == null || session!.image!.isEmpty)
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(color: AppColors.neutral4, fontSize: 12),
                        ),
                        if (country.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            country,
                            style: TextStyle(color: AppColors.neutral5, fontSize: 12),
                          ),
                        ],
                        if (category.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary10,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Categoría: $category',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Plan Activo ────────────────────────────────────────────
            const Text('Plan Activo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.card_membership, color: AppColors.primary, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Válido hasta 31 dic 2026', style: TextStyle(color: AppColors.neutral4, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.neutral5),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Rol Activo (según la API) ──────────────────────────────
            const Text('Rol Activo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...availableRoles.map((role) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _roleOption(role, _activeRole == role),
            )),
            const SizedBox(height: 24),
          // Settings section
          const Text('Configuración', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _settingItem(
            title: 'Cambiar contraseña',
            icon: Icons.lock_outline,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _settingItem(
            title: 'Notificaciones',
            icon: Icons.notifications_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función en desarrollo')),
              );
            },
          ),
          const SizedBox(height: 12),
          _settingItem(
            title: 'Privacidad y seguridad',
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función en desarrollo')),
              );
            },
          ),
          const SizedBox(height: 12),
          _settingItem(
            title: 'Ayuda y soporte',
            icon: Icons.help_outline,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función en desarrollo')),
              );
            },
          ),
          const SizedBox(height: 12),
          _settingItem(
            title: 'Cerrar sesión',
            icon: Icons.logout,
            iconColor: AppColors.error,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
      ),
    );
  }

  Widget _roleOption(String role, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() => _activeRole = role);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.person_outline, color: AppColors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            if (isActive)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _settingItem({
    required String title,
    required IconData icon,
    Color iconColor = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.neutral5),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await context.read<SessionProvider>().clearSession();
              if (!mounted) return;
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Cerrar sesión', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
