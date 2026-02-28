import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Estado de permisos ──
  bool _locationPermission = false;
  bool _cameraPermission = true;
  bool _analyticsEnabled = true;
  bool _crashReportsEnabled = true;
  bool _marketingEmails = false;

  // ── Estado de sesiones ──
  final List<_SessionItem> _activeSessions = [
    _SessionItem(
      device: 'iPhone 15 Pro · iOS 17',
      location: 'Ciudad de México, MX',
      lastActive: 'Activa ahora',
      isCurrent: true,
    ),
    _SessionItem(
      device: 'MacBook Pro · macOS 14',
      location: 'Ciudad de México, MX',
      lastActive: 'Hace 2 horas',
      isCurrent: false,
    ),
    _SessionItem(
      device: 'iPad Air · iPadOS 17',
      location: 'Guadalajara, MX',
      lastActive: 'Hace 3 días',
      isCurrent: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.neutral8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Privacidad y seguridad',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, 20 + MediaQuery.of(context).padding.bottom),
            children: [
              // ── Banner de seguridad ─────────────────────────────────
              _securityBanner(),
              const SizedBox(height: 24),

              // ── Permisos del dispositivo ────────────────────────────
              _sectionTitle('Permisos del dispositivo'),
              const SizedBox(height: 12),
              _permissionToggle(
                icon: Icons.location_on_outlined,
                iconColor: AppColors.warning,
                title: 'Ubicación',
                subtitle: 'Usada para registrar la sede de los entrenamientos',
                value: _locationPermission,
                onChanged: (v) => setState(() => _locationPermission = v),
              ),
              const SizedBox(height: 10),
              _permissionToggle(
                icon: Icons.camera_alt_outlined,
                iconColor: AppColors.accent3,
                title: 'Cámara',
                subtitle: 'Necesaria para capturar fotos de perfil y ejercicios',
                value: _cameraPermission,
                onChanged: (v) => setState(() => _cameraPermission = v),
              ),
              const SizedBox(height: 24),

              // ── Recopilación de datos ───────────────────────────────
              _sectionTitle('Recopilación de datos'),
              const SizedBox(height: 4),
              _infoText(
                  'Estos datos nos ayudan a mejorar la experiencia de la aplicación. No se comparten con terceros sin tu consentimiento.'),
              const SizedBox(height: 12),
              _permissionToggle(
                icon: Icons.bar_chart_rounded,
                iconColor: AppColors.accent5,
                title: 'Análisis de uso',
                subtitle: 'Estadísticas anónimas sobre cómo usas la app',
                value: _analyticsEnabled,
                onChanged: (v) => setState(() => _analyticsEnabled = v),
              ),
              const SizedBox(height: 10),
              _permissionToggle(
                icon: Icons.bug_report_outlined,
                iconColor: AppColors.error,
                title: 'Reportes de errores',
                subtitle: 'Envío automático de fallos para corregirlos',
                value: _crashReportsEnabled,
                onChanged: (v) => setState(() => _crashReportsEnabled = v),
              ),
              const SizedBox(height: 10),
              _permissionToggle(
                icon: Icons.mail_outline_rounded,
                iconColor: AppColors.accent6,
                title: 'Correos de marketing',
                subtitle: 'Novedades, promociones y actualizaciones del plan',
                value: _marketingEmails,
                onChanged: (v) => setState(() => _marketingEmails = v),
              ),
              const SizedBox(height: 24),

              // ── Sesiones activas ────────────────────────────────────
              _sectionTitle('Sesiones activas'),
              const SizedBox(height: 4),
              _infoText(
                  'Revisa los dispositivos donde tienes sesión iniciada. Cierra las que no reconozcas.'),
              const SizedBox(height: 12),
              ..._activeSessions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _sessionCard(s),
                  )),
              const SizedBox(height: 4),
              _dangerButton(
                label: 'Cerrar todas las otras sesiones',
                icon: Icons.logout_rounded,
                onTap: () => _confirmCloseAllSessions(context),
              ),
              const SizedBox(height: 24),

              // ── Documentos legales ──────────────────────────────────
              _sectionTitle('Documentos legales'),
              const SizedBox(height: 12),
              _legalItem(
                icon: Icons.description_outlined,
                title: 'Política de privacidad',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 10),
              _legalItem(
                icon: Icons.gavel_rounded,
                title: 'Términos y condiciones',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 10),
              _legalItem(
                icon: Icons.cookie_outlined,
                title: 'Política de cookies',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 24),

              // ── Zona de peligro ─────────────────────────────────────
              _sectionTitle('Zona de peligro'),
              const SizedBox(height: 12),
              _dangerButton(
                label: 'Eliminar mi cuenta',
                icon: Icons.delete_forever_rounded,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets privados ────────────────────────────────────────────────

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _infoText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _securityBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF3F6F8D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_outlined,
                color: AppColors.white, size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu cuenta está protegida',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Última verificación de seguridad: hoy',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionToggle({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: iconColor, size: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionCard(_SessionItem session) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: session.isCurrent
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.03),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: session.isCurrent
                    ? AppColors.primary10
                    : AppColors.neutral8,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                session.device.contains('iPhone') ||
                        session.device.contains('iPad')
                    ? Icons.phone_iphone_rounded
                    : Icons.laptop_mac_rounded,
                color: session.isCurrent
                    ? AppColors.primary
                    : AppColors.neutral5,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.device,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (session.isCurrent) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Actual',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${session.location} · ${session.lastActive}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (!session.isCurrent)
              IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.error, size: 18),
                onPressed: () => _confirmCloseSession(context, session),
                tooltip: 'Cerrar sesión',
              ),
          ],
        ),
      ),
    );
  }

  Widget _legalItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.03),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    Center(child: Icon(icon, color: AppColors.primary, size: 20)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppColors.neutral5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dangerButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.errorBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Diálogos ─────────────────────────────────────────────────────

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Próximamente disponible'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _confirmCloseSession(BuildContext ctx, _SessionItem session) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión remota',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            '¿Deseas cerrar la sesión en "${session.device}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dCtx).pop();
              setState(() => _activeSessions.remove(session));
            },
            child: const Text('Cerrar sesión',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmCloseAllSessions(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar todas las sesiones',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
            '¿Deseas cerrar todas las sesiones excepto la actual?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dCtx).pop();
              setState(() =>
                  _activeSessions.removeWhere((s) => !s.isCurrent));
            },
            child: const Text('Cerrar todas',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar cuenta',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.error)),
        content: const Text(
            'Esta acción es irreversible. Todos tus datos, deportistas y evaluaciones serán eliminados permanentemente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dCtx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dCtx).pop();
              _showComingSoon(ctx);
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Modelo de sesión ──────────────────────────────────────────────────

class _SessionItem {
  final String device;
  final String location;
  final String lastActive;
  final bool isCurrent;

  const _SessionItem({
    required this.device,
    required this.location,
    required this.lastActive,
    required this.isCurrent,
  });
}
