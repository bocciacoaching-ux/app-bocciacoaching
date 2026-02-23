import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  // ── Ajustes globales ──
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // ── Categorías de notificaciones ──
  bool _trainingAlerts = true;
  bool _evaluationReminders = true;
  bool _athleteUpdates = true;
  bool _teamNews = false;
  bool _appUpdates = true;
  bool _weeklyReport = true;
  bool _systemAlerts = true;
  bool _promotions = false;

  // ── Horario silencioso ──
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);

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

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickTime({
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) onPicked(picked);
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
          'Notificaciones',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: SlideTransition(
          position: _slideUp,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, 20 + MediaQuery.of(context).padding.bottom),
            children: [
              // ── Canales de envío ─────────────────────────────────────
              _sectionTitle('Canales de notificación'),
              const SizedBox(height: 12),
              _channelCard(
                icon: Icons.notifications_active_outlined,
                iconColor: AppColors.primary,
                title: 'Notificaciones push',
                subtitle: 'Alertas en tiempo real en tu dispositivo',
                value: _pushEnabled,
                onChanged: (v) => setState(() => _pushEnabled = v),
              ),
              const SizedBox(height: 10),
              _channelCard(
                icon: Icons.email_outlined,
                iconColor: AppColors.accent3,
                title: 'Notificaciones por correo',
                subtitle: 'Resúmenes y alertas en tu email',
                value: _emailEnabled,
                onChanged: (v) => setState(() => _emailEnabled = v),
              ),
              const SizedBox(height: 24),

              // ── Sonido y vibración ───────────────────────────────────
              _sectionTitle('Sonido y vibración'),
              const SizedBox(height: 12),
              _channelCard(
                icon: Icons.volume_up_outlined,
                iconColor: AppColors.accent5,
                title: 'Sonido',
                subtitle: 'Reproducir sonido al recibir notificaciones',
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              const SizedBox(height: 10),
              _channelCard(
                icon: Icons.vibration_rounded,
                iconColor: AppColors.accent4,
                title: 'Vibración',
                subtitle: 'Vibrar al recibir notificaciones',
                value: _vibrationEnabled,
                onChanged: (v) => setState(() => _vibrationEnabled = v),
              ),
              const SizedBox(height: 24),

              // ── Categorías ───────────────────────────────────────────
              _sectionTitle('Tipos de notificaciones'),
              const SizedBox(height: 4),
              _infoText(
                  'Selecciona qué tipos de alertas deseas recibir.'),
              const SizedBox(height: 12),
              _categoryGroup(children: [
                _categoryRow(
                  icon: Icons.fitness_center_rounded,
                  iconColor: AppColors.success,
                  title: 'Alertas de entrenamiento',
                  subtitle: 'Sesiones completadas, ausencias y avances',
                  value: _trainingAlerts,
                  onChanged: (v) => setState(() => _trainingAlerts = v),
                ),
                _divider(),
                _categoryRow(
                  icon: Icons.assignment_outlined,
                  iconColor: AppColors.warning,
                  title: 'Recordatorios de evaluación',
                  subtitle: 'Evaluaciones programadas y pendientes',
                  value: _evaluationReminders,
                  onChanged: (v) =>
                      setState(() => _evaluationReminders = v),
                ),
                _divider(),
                _categoryRow(
                  icon: Icons.person_outline_rounded,
                  iconColor: AppColors.accent3,
                  title: 'Actualizaciones de deportistas',
                  subtitle: 'Cambios en perfiles y logros alcanzados',
                  value: _athleteUpdates,
                  onChanged: (v) => setState(() => _athleteUpdates = v),
                ),
                _divider(),
                _categoryRow(
                  icon: Icons.group_outlined,
                  iconColor: AppColors.accent6,
                  title: 'Noticias del equipo',
                  subtitle: 'Cambios en equipos y convocatorias',
                  value: _teamNews,
                  onChanged: (v) => setState(() => _teamNews = v),
                ),
                _divider(),
                _categoryRow(
                  icon: Icons.bar_chart_rounded,
                  iconColor: AppColors.accent5,
                  title: 'Reporte semanal',
                  subtitle: 'Resumen de rendimiento cada lunes',
                  value: _weeklyReport,
                  onChanged: (v) => setState(() => _weeklyReport = v),
                ),
                _divider(),
                _categoryRow(
                  icon: Icons.system_update_outlined,
                  iconColor: AppColors.neutral4,
                  title: 'Actualizaciones de la app',
                  subtitle: 'Nuevas funciones y correcciones',
                  value: _appUpdates,
                  onChanged: (v) => setState(() => _appUpdates = v),
                ),
                _divider(),
                _categoryRow(
                  icon: Icons.warning_amber_rounded,
                  iconColor: AppColors.error,
                  title: 'Alertas del sistema',
                  subtitle: 'Problemas de sincronización y seguridad',
                  value: _systemAlerts,
                  onChanged: (v) => setState(() => _systemAlerts = v),
                ),
                _divider(),
                _categoryRow(
                  icon: Icons.local_offer_outlined,
                  iconColor: AppColors.accent2,
                  title: 'Promociones y ofertas',
                  subtitle: 'Descuentos en planes y novedades',
                  value: _promotions,
                  onChanged: (v) => setState(() => _promotions = v),
                ),
              ]),
              const SizedBox(height: 24),

              // ── Horario silencioso ───────────────────────────────────
              _sectionTitle('Horario silencioso'),
              const SizedBox(height: 4),
              _infoText(
                  'Durante este horario no recibirás notificaciones, salvo alertas críticas del sistema.'),
              const SizedBox(height: 12),
              _channelCard(
                icon: Icons.bedtime_outlined,
                iconColor: AppColors.accent6,
                title: 'Activar horario silencioso',
                subtitle: 'Silenciar notificaciones en horas específicas',
                value: _quietHoursEnabled,
                onChanged: (v) => setState(() => _quietHoursEnabled = v),
              ),
              if (_quietHoursEnabled) ...[
                const SizedBox(height: 10),
                _quietHoursCard(),
              ],
              const SizedBox(height: 24),

              // ── Botón restablecer ────────────────────────────────────
              Center(
                child: TextButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(Icons.refresh_rounded,
                      color: AppColors.neutral4, size: 18),
                  label: const Text(
                    'Restablecer valores predeterminados',
                    style: TextStyle(
                      color: AppColors.neutral4,
                      fontSize: 13,
                    ),
                  ),
                ),
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

  Widget _channelCard({
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

  Widget _categoryGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _categoryRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
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
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: AppColors.neutral8,
    );
  }

  Widget _quietHoursCard() {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary20),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inicio',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _pickTime(
                      initial: _quietStart,
                      onPicked: (t) =>
                          setState(() => _quietStart = t),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTime(_quietStart),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('—',
                  style: TextStyle(
                      color: AppColors.neutral5,
                      fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fin',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => _pickTime(
                      initial: _quietEnd,
                      onPicked: (t) =>
                          setState(() => _quietEnd = t),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatTime(_quietEnd),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
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
    );
  }

  // ── Acciones ──────────────────────────────────────────────────────

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Configuración de notificaciones guardada'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _pushEnabled = true;
      _emailEnabled = true;
      _soundEnabled = true;
      _vibrationEnabled = true;
      _trainingAlerts = true;
      _evaluationReminders = true;
      _athleteUpdates = true;
      _teamNews = false;
      _appUpdates = true;
      _weeklyReport = true;
      _systemAlerts = true;
      _promotions = false;
      _quietHoursEnabled = false;
      _quietStart = const TimeOfDay(hour: 22, minute: 0);
      _quietEnd = const TimeOfDay(hour: 7, minute: 0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ajustes restablecidos'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
