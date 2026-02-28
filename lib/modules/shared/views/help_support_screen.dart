import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: '¿Cómo registro a un nuevo deportista?',
      answer:
          'Desde el panel principal, accede a "Deportistas" y pulsa el botón "+" en la esquina superior derecha. Completa el formulario con los datos del atleta y guarda los cambios.',
    ),
    _FaqItem(
      question: '¿Cómo realizo una prueba de fuerza?',
      answer:
          'Ve a la sección "Pruebas" desde el menú inferior y selecciona "Prueba de Fuerza". Asegúrate de que el dispositivo esté conectado por Bluetooth antes de iniciar la sesión.',
    ),
    _FaqItem(
      question: '¿Puedo exportar los reportes de rendimiento?',
      answer:
          'Sí. Desde la pantalla de estadísticas de cualquier atleta, pulsa el ícono de compartir en la parte superior derecha. Podrás exportar en formato PDF o CSV.',
    ),
    _FaqItem(
      question: '¿Cómo cambio mi contraseña?',
      answer:
          'Dirígete a "Mi Perfil" → "Configuración" → "Cambiar contraseña". Necesitarás ingresar tu contraseña actual para confirmar el cambio.',
    ),
    _FaqItem(
      question: '¿Qué hago si olvidé mi contraseña?',
      answer:
          'En la pantalla de inicio de sesión, pulsa "¿Olvidaste tu contraseña?" y sigue las instrucciones. Recibirás un enlace de recuperación en tu correo registrado.',
    ),
    _FaqItem(
      question: '¿Cómo activo la autenticación biométrica?',
      answer:
          'En "Mi Perfil" → "Configuración" activa el interruptor de desbloqueo biométrico. Deberás verificar tu identidad la primera vez.',
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
          'Ayuda y soporte',
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
              // ── Contacto rápido ──────────────────────────────────────
              _sectionTitle('Contactar soporte'),
              const SizedBox(height: 12),
              _contactCard(
                icon: Icons.chat_bubble_outline_rounded,
                iconColor: AppColors.primary,
                title: 'Chat en vivo',
                subtitle: 'Lunes a viernes, 8:00 – 18:00',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _contactCard(
                icon: Icons.email_outlined,
                iconColor: AppColors.accent3,
                title: 'Correo electrónico',
                subtitle: 'soporte@bocciacoaching.com',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _contactCard(
                icon: Icons.phone_outlined,
                iconColor: AppColors.success,
                title: 'Teléfono',
                subtitle: '+1 800 123 4567',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 28),

              // ── Tutoriales ───────────────────────────────────────────
              _sectionTitle('Tutoriales y guías'),
              const SizedBox(height: 12),
              _tutorialCard(
                icon: Icons.play_circle_outline_rounded,
                iconColor: AppColors.accent4,
                title: 'Primeros pasos en la app',
                duration: '3 min',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _tutorialCard(
                icon: Icons.play_circle_outline_rounded,
                iconColor: AppColors.accent4,
                title: 'Cómo registrar una prueba de fuerza',
                duration: '5 min',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _tutorialCard(
                icon: Icons.play_circle_outline_rounded,
                iconColor: AppColors.accent4,
                title: 'Análisis y reportes de rendimiento',
                duration: '7 min',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 12),
              _tutorialCard(
                icon: Icons.article_outlined,
                iconColor: AppColors.accent5,
                title: 'Manual de usuario completo (PDF)',
                duration: 'Descargar',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(height: 28),

              // ── Preguntas frecuentes ─────────────────────────────────
              _sectionTitle('Preguntas frecuentes'),
              const SizedBox(height: 12),
              ..._faqs.map((faq) => _FaqTile(item: faq)),
              const SizedBox(height: 28),

              // ── Versión de la app ────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sports,
                          color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Boccia Coaching App',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers de UI ─────────────────────────────────────────────────

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

  Widget _contactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
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
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.neutral5),
        ],
      ),
    );
  }

  Widget _tutorialCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String duration,
    required VoidCallback onTap,
  }) {
    return _AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 22)),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              duration,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
}

// ── FAQ Tile con expansión ────────────────────────────────────────────

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}

class _FaqTile extends StatefulWidget {
  final _FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _rotation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _AppCard(
        onTap: _toggle,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(Icons.help_outline_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: _rotation,
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.neutral5, size: 20),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(46, 0, 16, 16),
                child: Text(
                  widget.item.answer,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tarjeta genérica reutilizable ─────────────────────────────────────

class _AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const _AppCard({required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
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
          child: child,
        ),
      ),
    );
  }
}
