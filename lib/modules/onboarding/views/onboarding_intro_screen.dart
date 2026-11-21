import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/providers/onboarding_provider.dart';
import '../../../data/providers/session_provider.dart';

/// Carrusel de bienvenida (4 pasos) que se muestra a los usuarios nuevos
/// la primera vez que entran a la aplicación, justo antes de aterrizar
/// en el dashboard correspondiente a su rol.
///
/// Diseño adaptable:
/// - Móvil / tablet: ilustración arriba y hoja blanca abajo con el texto.
/// - Escritorio (>= 1000 px): ilustración a la izquierda y panel a la derecha.
class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const double _desktopBreakpoint = 1000;
  static const double _tabletBreakpoint = 600;

  static const _slides = <_IntroSlide>[
    _IntroSlide(
      visual: _VisualKind.welcome,
      title: 'Te damos la bienvenida a Boccia Coaching',
      body:
          'El primer sistema global de evaluación y seguimiento del rendimiento en Boccia.',
      primaryCta: 'Comenzar',
      secondaryCta: 'Saltar',
      isWelcome: true,
    ),
    _IntroSlide(
      visual: _VisualKind.uncertainty,
      eyebrow: 'El problema',
      title: 'Entrenar sin datos genera incertidumbre',
      body:
          'Muchos entrenadores y atletas toman decisiones basadas en observaciones subjetivas. '
          'Boccia Coaching introduce evaluaciones estandarizadas para medir el rendimiento real.',
    ),
    _IntroSlide(
      visual: _VisualKind.evaluate,
      eyebrow: 'La solución',
      title: 'Evalúa. Compara. Mejora.',
      body:
          'Utiliza escalas profesionales para medir habilidades técnicas, físicas y tácticas en Boccia.',
      bullets: [
        _IntroBullet(Icons.fact_check_outlined, 'Evaluaciones estandarizadas'),
        _IntroBullet(Icons.show_chart_rounded, 'Seguimiento del progreso'),
        _IntroBullet(Icons.public_rounded, 'Comparación internacional'),
      ],
    ),
    _IntroSlide(
      visual: _VisualKind.steps,
      eyebrow: 'Cómo funciona',
      title: 'Un sistema simple en 3 pasos',
      body: '',
      steps: [
        _IntroStep(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Evaluar',
          description: 'Usa escalas COA para medir habilidades.',
        ),
        _IntroStep(
          icon: Icons.compare_arrows_rounded,
          title: 'Comparar',
          description: 'Compara contra estándares y tu propia evolución.',
        ),
        _IntroStep(
          icon: Icons.trending_up_rounded,
          title: 'Mejorar',
          description: 'Define objetivos y mide el avance real.',
        ),
      ],
    ),
  ];

  void _next() {
    if (_index < _slides.length - 1) {
      _goTo(_index + 1);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index > 0) _goTo(_index - 1);
  }

  void _goTo(int i) {
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        i,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      setState(() => _index = i);
    }
  }

  Future<void> _finish() async {
    await context.read<OnboardingProvider>().markIntroSeen();
    if (!mounted) return;
    NavigationHelper.goToDashboard(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.headerGradientTop,
      body: LayoutBuilder(
        builder: (context, c) => c.maxWidth >= _desktopBreakpoint
            ? _buildDesktop(c)
            : _buildCompact(c),
      ),
    );
  }

  // ── Móvil / tablet ─────────────────────────────────────────────────────

  Widget _buildCompact(BoxConstraints c) {
    final isTablet = c.maxWidth >= _tabletBreakpoint;
    final hPad = isTablet ? 40.0 : 24.0;
    final contentMax = isTablet ? 560.0 : double.infinity;
    final topInset = MediaQuery.of(context).padding.top;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: _backgroundGradient),
      child: Column(
        children: [
          SizedBox(height: topInset),
          _Header(
            showClose: _index > 0,
            onClose: _finish,
            padding: EdgeInsets.fromLTRB(hPad, 16, hPad - 8, 8),
          ),
          // Ilustraciones: lo único que se desliza
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: _slides.length,
              itemBuilder: (_, i) => Padding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, isTablet ? 32 : 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isTablet ? 520 : 360),
                    child: _SlideVisual(kind: _slides[i].visual),
                  ),
                ),
              ),
            ),
          ),
          // Hoja blanca fija: solo cambia el texto y su altura se ajusta
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v < -200) _next();
              if (v > 200) _back();
            },
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                hPad,
                isTablet ? 40 : 32,
                hPad,
                16 + MediaQuery.of(context).padding.bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMax),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedSize(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(maxHeight: c.maxHeight * 0.5),
                          child: SingleChildScrollView(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              layoutBuilder: (current, previous) => Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  ...previous,
                                  if (current != null) current,
                                ],
                              ),
                              child: SizedBox(
                                key: ValueKey(_index),
                                width: double.infinity,
                                child: _SlideText(
                                  slide: _slides[_index],
                                  index: _index,
                                  total: _slides.length,
                                  large: isTablet,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Escritorio ─────────────────────────────────────────────────────────

  Widget _buildDesktop(BoxConstraints c) {
    final slide = _slides[_index];
    return Row(
      children: [
        // Ilustración
        Expanded(
          flex: 11,
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: _backgroundGradient),
            child: Stack(
              children: [
                const Positioned(
                  top: 40,
                  left: 48,
                  child: _Logo(height: 40),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(64),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _SlideVisual(
                          key: ValueKey(_index),
                          kind: slide.visual,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Panel de contenido
        Expanded(
          flex: 9,
          child: Container(
            color: AppColors.surface,
            child: Stack(
              children: [
                if (_index > 0)
                  Positioned(
                    top: 32,
                    right: 32,
                    child: TextButton(
                      onPressed: _finish,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text('Saltar introducción'),
                    ),
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            layoutBuilder: (current, previous) => Stack(
                              alignment: Alignment.topLeft,
                              children: [...previous, if (current != null) current],
                            ),
                            child: _SlideText(
                              key: ValueKey(_index),
                              slide: slide,
                              index: _index,
                              total: _slides.length,
                              large: true,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Pie: indicador + botones ───────────────────────────────────────────

  Widget _buildFooter() {
    final slide = _slides[_index];
    final isLast = _index == _slides.length - 1;
    final secondaryLabel =
        slide.isWelcome ? (slide.secondaryCta ?? 'Saltar') : 'Atrás';
    final primaryLabel = slide.isWelcome
        ? (slide.primaryCta ?? 'Comenzar')
        : (isLast ? 'Empezar a usar la app' : 'Siguiente');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DotsIndicator(count: _slides.length, index: _index, onTap: _goTo),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: slide.isWelcome ? _finish : _back,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: Text(secondaryLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
                child: Text(primaryLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _backgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.headerGradientTop, AppColors.headerGradientBottom],
);

// ── Modelos privados ─────────────────────────────────────────────────────

enum _VisualKind { welcome, uncertainty, evaluate, steps }

class _IntroSlide {
  final _VisualKind visual;
  final String? eyebrow;
  final String title;
  final String body;
  final List<_IntroBullet> bullets;
  final List<_IntroStep> steps;
  final String? primaryCta;
  final String? secondaryCta;
  final bool isWelcome;

  const _IntroSlide({
    required this.visual,
    this.eyebrow,
    required this.title,
    required this.body,
    this.bullets = const [],
    this.steps = const [],
    this.primaryCta,
    this.secondaryCta,
    this.isWelcome = false,
  });
}

class _IntroBullet {
  final IconData icon;
  final String text;
  const _IntroBullet(this.icon, this.text);
}

class _IntroStep {
  final IconData icon;
  final String title;
  final String description;
  const _IntroStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ── Cabecera móvil ───────────────────────────────────────────────────────

class _Logo extends StatelessWidget {
  final double height;
  const _Logo({this.height = 32});

  @override
  Widget build(BuildContext context) {
    // Mismo logo que la pantalla de inicio de sesión (versión crema).
    return SvgPicture.asset(
      'assets/images/isologo-h-crema.svg',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class _Header extends StatelessWidget {
  final bool showClose;
  final VoidCallback onClose;
  final EdgeInsets padding;
  const _Header({
    required this.showClose,
    required this.onClose,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            const _Logo(height: 30),
            const Spacer(),
            AnimatedOpacity(
              opacity: showClose ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: showClose ? onClose : null,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.white,
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                child: const Text('Saltar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Texto del slide ──────────────────────────────────────────────────────

class _SlideText extends StatelessWidget {
  final _IntroSlide slide;
  final int index;
  final int total;
  final bool large;
  const _SlideText({
    super.key,
    required this.slide,
    required this.index,
    required this.total,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final eyebrow = slide.isWelcome
        ? 'Bienvenida'
        : '${slide.eyebrow ?? ''} · Paso $index de ${total - 1}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          slide.title,
          style: TextStyle(
            fontSize: large ? 32 : 26,
            fontWeight: FontWeight.w800,
            color: AppColors.black,
            height: 1.18,
            letterSpacing: -0.4,
          ),
        ),
        if (slide.body.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            slide.body,
            style: TextStyle(
              fontSize: large ? 17 : 15,
              color: AppColors.neutral3,
              height: 1.55,
            ),
          ),
        ],
        if (slide.bullets.isNotEmpty) ...[
          const SizedBox(height: 20),
          for (final b in slide.bullets) _BulletRow(bullet: b),
        ],
        if (slide.steps.isNotEmpty) ...[
          const SizedBox(height: 20),
          for (var i = 0; i < slide.steps.length; i++)
            _StepRow(
              step: slide.steps[i],
              number: i + 1,
              isLast: i == slide.steps.length - 1,
            ),
        ],
      ],
    );
  }
}

class _BulletRow extends StatelessWidget {
  final _IntroBullet bullet;
  const _BulletRow({required this.bullet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(bullet.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              bullet.text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _IntroStep step;
  final int number;
  final bool isLast;
  const _StepRow({
    required this.step,
    required this.number,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Número + línea que une los pasos
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.primary20,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(step.icon, size: 18, color: AppColors.primary60),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.neutral3,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  final ValueChanged<int> onTap;
  const _DotsIndicator({
    required this.count,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return GestureDetector(
          onTap: () => onTap(i),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: active ? 28 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.neutral7,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Ilustraciones de cada paso ───────────────────────────────────────────
//
// Marcadores de posición dibujados en código (cancha + bolas de boccia +
// iconos). Cuando haya fotos reales, se pueden sustituir aquí.

const _red = Color(0xFFD9483B);
const _blue = Color(0xFF2E6DB4);
const _jack = Color(0xFFF7F7F2);

class _SlideVisual extends StatelessWidget {
  final _VisualKind kind;
  const _SlideVisual({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: LayoutBuilder(
        builder: (context, c) {
          final s = c.maxWidth; // escala base
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Cancha
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(s * 0.07),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: CustomPaint(painter: _CourtPainter()),
                ),
              ),
              ..._content(s),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _content(double s) {
    switch (kind) {
      case _VisualKind.welcome:
        return [
          _ball(s, 0.50, 0.42, 0.07, _jack),
          _ball(s, 0.40, 0.52, 0.11, _red),
          _ball(s, 0.58, 0.30, 0.11, _blue),
          _ball(s, 0.62, 0.55, 0.11, _red),
          _ball(s, 0.30, 0.30, 0.11, _blue),
          _chip(s, 0.08, 0.78, Icons.emoji_events_outlined, 'Rendimiento real'),
        ];
      case _VisualKind.uncertainty:
        return [
          _ball(s, 0.52, 0.45, 0.07, _jack),
          _ball(s, 0.16, 0.18, 0.11, _red, faded: true),
          _ball(s, 0.80, 0.24, 0.11, _blue, faded: true),
          _ball(s, 0.22, 0.74, 0.11, _blue, faded: true),
          _ball(s, 0.76, 0.70, 0.11, _red, faded: true),
          _badge(s, 0.50, 0.45, Icons.question_mark_rounded, 0.20),
        ];
      case _VisualKind.evaluate:
        return [
          _ball(s, 0.50, 0.36, 0.07, _jack),
          _ball(s, 0.43, 0.43, 0.11, _red),
          _ball(s, 0.57, 0.27, 0.11, _blue),
          _metric(s, 0.06, 0.55, 'Fuerza', 0.76),
          _metric(s, 0.52, 0.55, 'Dirección', 0.70),
          _metric(s, 0.29, 0.73, 'SAREMAS+', 0.72),
        ];
      case _VisualKind.steps:
        return [
          Positioned(
            left: s * 0.20,
            right: s * 0.20,
            top: s * 0.45 - 1,
            child: Container(
              height: 2,
              color: AppColors.white.withValues(alpha: 0.35),
            ),
          ),
          _badge(s, 0.20, 0.45, Icons.assignment_turned_in_outlined, 0.16),
          _badge(s, 0.50, 0.45, Icons.compare_arrows_rounded, 0.16),
          _badge(s, 0.80, 0.45, Icons.trending_up_rounded, 0.16),
          _ball(s, 0.50, 0.78, 0.06, _jack),
          _ball(s, 0.44, 0.80, 0.09, _red),
          _ball(s, 0.57, 0.77, 0.09, _blue),
        ];
    }
  }

  /// Bola centrada en (x, y) relativos, con diámetro d relativo.
  Widget _ball(double s, double x, double y, double d, Color color,
      {bool faded = false}) {
    final size = s * d;
    return Positioned(
      left: s * x - size / 2,
      top: s * y - size / 2,
      child: Opacity(
        opacity: faded ? 0.45 : 1,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 0.9,
              colors: [Color.lerp(color, Colors.white, 0.45)!, color],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.25),
                blurRadius: size * 0.25,
                offset: Offset(0, size * 0.10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(double s, double x, double y, IconData icon, double d) {
    final size = s * d;
    return Positioned(
      left: s * x - size / 2,
      top: s * y - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: size * 0.5),
      ),
    );
  }

  Widget _chip(double s, double x, double y, IconData icon, String text) {
    return Positioned(
      left: s * x,
      top: s * y,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: s * 0.035, vertical: s * 0.022),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: s * 0.045, color: AppColors.primary),
            SizedBox(width: s * 0.02),
            Text(
              text,
              style: TextStyle(
                fontSize: s * 0.038,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(double s, double x, double y, String label, double value) {
    return Positioned(
      left: s * x,
      top: s * y,
      child: Container(
        width: s * 0.42,
        padding: EdgeInsets.all(s * 0.03),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(s * 0.03),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: s * 0.034,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral3,
                    ),
                  ),
                ),
                Text(
                  '${(value * 100).round()}%',
                  style: TextStyle(
                    fontSize: s * 0.036,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: s * 0.018),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: s * 0.016,
                backgroundColor: AppColors.primary10,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Líneas de cancha de boccia (zona de lanzamiento y cruz central).
class _CourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    // Líneas de los boxes de lanzamiento (parte inferior)
    final boxTop = h * 0.88;
    canvas.drawLine(Offset(w * 0.06, boxTop), Offset(w * 0.94, boxTop), p);
    for (var i = 1; i < 6; i++) {
      final x = w * 0.06 + (w * 0.88) * i / 6;
      canvas.drawLine(Offset(x, boxTop), Offset(x, h * 0.97), p);
    }
    // Línea en V
    canvas.drawLine(Offset(w * 0.30, boxTop), Offset(w * 0.5, h * 0.70), p);
    canvas.drawLine(Offset(w * 0.70, boxTop), Offset(w * 0.5, h * 0.70), p);
    // Cruz central
    final cx = w * 0.5, cy = h * 0.40, k = w * 0.03;
    canvas.drawLine(Offset(cx - k, cy), Offset(cx + k, cy), p);
    canvas.drawLine(Offset(cx, cy - k), Offset(cx, cy + k), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper para mostrar la intro automáticamente desde un dashboard cuando
/// el usuario aún no la ha visto.
void maybeShowOnboardingIntro(BuildContext context) {
  final session = context.read<SessionProvider>().session;
  if (session == null) return;
  final onboarding = context.read<OnboardingProvider>();
  // Cargar banderas para este usuario y, si no vio la intro, navegar.
  Future<void>.microtask(() async {
    if (onboarding.userId != session.userId) {
      await onboarding.loadFor(session.userId);
    }
    if (!context.mounted) return;
    if (!onboarding.introSeen) {
      Navigator.of(context).pushNamed('/onboarding-intro');
    }
  });
}
