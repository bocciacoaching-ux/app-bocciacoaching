import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../data/providers/team_provider.dart';
import '../../../data/models/user_session.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_dialog.dart';
import '../../../shared/widgets/profile_image_picker.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _activeRole = 'Entrenador';

  /// Flag para saber si estamos subiendo una nueva foto rápida.
  bool _uploadingPhoto = false;

  // ── Biometría ──
  final BiometricService _biometricService = BiometricService();
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  String _biometricLabel = 'Biometría';

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();
    final label = await _biometricService.getBiometricLabel();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = enabled;
        _biometricLabel = label;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Al activar, verificamos que el usuario puede autenticarse
      final authenticated = await _biometricService.authenticate(
        reason: 'Autentícate para activar el desbloqueo con $_biometricLabel',
      );
      if (!authenticated) return;
    }
    await _biometricService.setBiometricEnabled(value);
    if (mounted) {
      setState(() => _biometricEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '$_biometricLabel activado correctamente'
                : '$_biometricLabel desactivado',
          ),
        ),
      );
    }
  }

  /// Devuelve las iniciales del nombre completo (máx. 2 letras).
  static String _initials(UserSession s) {
    final parts = s.fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first
        .substring(0, parts.first.length.clamp(0, 2))
        .toUpperCase();
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
    final availableRoles =
        session != null ? _availableRoles([session.rolId]) : <String>[];
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
        title: const Text('Mi Perfil',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
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
                  // Avatar con botón cámara
                  _buildAvatarWithCamera(session, initials),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                              color: AppColors.neutral4, fontSize: 12),
                        ),
                        if (country.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            country,
                            style: TextStyle(
                                color: AppColors.neutral5, fontSize: 12),
                          ),
                        ],
                        if (category.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
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
                        const SizedBox(height: 10),
                        // Botón "Editar perfil"
                        SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updated =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                              if (updated == true && mounted) {
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Editar perfil'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(
                                  color: AppColors.primary, width: 1.2),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── Plan Activo ────────────────────────────────────────────
            const Text('Plan Activo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                      child: Icon(Icons.card_membership,
                          color: AppColors.primary, size: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Premium Pro',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Válido hasta 31 dic 2026',
                            style: TextStyle(
                                color: AppColors.neutral4, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 16, color: AppColors.neutral5),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Rol Activo (según la API) ──────────────────────────────
            const Text('Rol Activo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ...availableRoles.map((role) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _roleOption(role, _activeRole == role),
                )),
            const SizedBox(height: 24),
            // Settings section
            const Text('Configuración',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            // ── Desbloqueo biométrico ──
            if (_biometricAvailable) _biometricToggle(),
            if (_biometricAvailable) const SizedBox(height: 12),

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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _settingItem(
              title: 'Privacidad y seguridad',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacySecurityScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _settingItem(
              title: 'Ayuda y soporte',
              icon: Icons.help_outline,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HelpSupportScreen(),
                  ),
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
          border:
              isActive ? Border.all(color: AppColors.primary, width: 2) : null,
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
              child: Text(role,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            if (isActive)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 24),
          ],
        ),
      ),
    );
  }

  // ── Avatar con botón cámara (cambio rápido de foto) ──────────────
  Widget _buildAvatarWithCamera(UserSession? session, String initials) {
    final imageProvider = _avatarImageProvider(session);
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.secondary,
            backgroundImage: imageProvider,
            child: imageProvider == null
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
          Positioned(
            bottom: -2,
            right: -2,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.white, width: 2),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _uploadingPhoto ? null : _onQuickPhotoTap,
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: _uploadingPhoto
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(
                          Icons.photo_camera_rounded,
                          size: 16,
                          color: AppColors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _avatarImageProvider(UserSession? session) {
    final value = session?.image;
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    final base64Str = value.contains(',') ? value.split(',').last : value;
    try {
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return null;
    }
  }

  /// Acción rápida: tomar/elegir foto y subirla automáticamente al backend.
  Future<void> _onQuickPhotoTap() async {
    final sessionProvider = context.read<SessionProvider>();
    final session = sessionProvider.session;
    if (session == null) return;

    final file = await ProfileImagePicker.pick(context);
    if (file == null || !mounted) return;

    final size = await ProfileImagePicker.sizeInBytes(file);
    if (size > 5 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imagen es demasiado grande (máx. 5 MB).'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _uploadingPhoto = true);

    String imageBase64;
    try {
      final bytes = await File(file.path).readAsBytes();
      imageBase64 = base64Encode(bytes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo procesar la imagen seleccionada.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final result = await UserService().updateUserInfo(
      userId: session.userId,
      image: imageBase64,
    );

    if (!mounted) return;
    setState(() => _uploadingPhoto = false);

    if (result['success'] == true) {
      String? newImage = imageBase64;
      final data = result['data'];
      if (data is Map<String, dynamic>) {
        final apiImage = data['image'];
        if (apiImage is String && apiImage.isNotEmpty) {
          newImage = apiImage;
        }
      }
      await sessionProvider.patchSession(image: newImage);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto de perfil actualizada'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] as String? ??
                'No se pudo actualizar la foto de perfil.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _biometricToggle() {
    return Container(
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
              color: AppColors.primary.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child:
                  Icon(Icons.fingerprint, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Desbloqueo con $_biometricLabel',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  _biometricEnabled ? 'Activado' : 'Desactivado',
                  style: TextStyle(
                    color: _biometricEnabled
                        ? AppColors.primary
                        : AppColors.neutral5,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _biometricEnabled,
            onChanged: _toggleBiometric,
            activeColor: AppColors.primary,
          ),
        ],
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
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.neutral5),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await AppDialog.destructive(
      context,
      title: 'Cerrar sesión',
      message: '¿Estás seguro de que deseas cerrar sesión?',
      confirmLabel: 'Cerrar sesión',
      icon: Icons.logout_rounded,
    );
    if (!confirmed || !mounted) return;
    await context.read<SessionProvider>().clearSession();
    if (!mounted) return;
    context.read<TeamProvider>().clear();
    Navigator.of(context).pushReplacementNamed('/');
  }
}
