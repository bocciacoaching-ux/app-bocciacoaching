import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../data/providers/onboarding_provider.dart';
import '../../../data/providers/session_provider.dart';

/// Carrusel de bienvenida (4 pasos) que se muestra a los usuarios nuevos
/// la primera vez que entran a la aplicación, justo antes de aterrizar
/// en el dashboard correspondiente a su rol.
class OnboardingIntroScreen extends StatefulWidget {
  const OnboardingIntroScreen({super.key});

  @override
  State<OnboardingIntroScreen> createState() => _OnboardingIntroScreenState();
}

class _OnboardingIntroScreenState extends State<OnboardingIntroScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _slides = <_IntroSlide>[
    _IntroSlide(
      title: 'Te damos la bienvenida\na Boccia Coaching',
      body:
          'El primer sistema global de evaluación y seguimiento del rendimiento en Boccia.',
      primaryCta: 'Comenzar',
      secondaryCta: 'Saltar',
      isWelcome: true,
    ),
    _IntroSlide(
      title: 'Entrenar sin datos\ngenera incertidumbre',
      body:
          'Muchos entrenadores y atletas toman decisiones basadas en observaciones subjetivas. '
          'Boccia Coaching introduce evaluaciones estandarizadas para medir el rendimiento real.',
    ),
    _IntroSlide(
      title: 'Evalúa. Compara.\nMejora.',
      body:
          'Utiliza escalas profesionales para medir habilidades técnicas, físicas y tácticas en Boccia.',
      bullets: [
        'Evaluaciones estandarizadas',
        'Seguimiento del progreso',
        'Comparación internacional',
      ],
    ),
    _IntroSlide(
      title: 'Un sistema simple\nen 3 pasos',
      body: '',
      steps: [
        _IntroStep(
          number: '1. Evaluar',
          description: 'Usa escalas COA para medir habilidades.',
        ),
        _IntroStep(
          number: '2. Comparar',
          description: 'Compara contra estándares y tu propia evolución.',
        ),
        _IntroStep(
          number: '3. Mejorar',
          description: 'Define objetivos y mide el avance real.',
        ),
      ],
    ),
  ];

  void _next() {
    if (_index < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_index > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
      backgroundColor: AppColors.headerGradientBottom,
      body: Stack(
        children: [
          // Fondo degradado (sustituye la foto del mockup)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.headerGradientTop,
                  AppColors.headerGradientBottom,
                ],
              ),
            ),
          ),
          // Logo centrado en la zona superior
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/isologo-horizontal.png',
                height: 36,
                color: AppColors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
          ),

          // Botón de cerrar (X) – visible a partir del slide 2
          if (_index > 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: _finish,
              ),
            ),

          // Tarjeta inferior con contenido del slide
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.10),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicador de progreso (puntos)
                      _DotsIndicator(
                        count: _slides.length,
                        index: _index,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemCount: _slides.length,
                          itemBuilder: (_, i) =>
                              _SlideContent(slide: _slides[i]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildButtons(),
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

  Widget _buildButtons() {
    final slide = _slides[_index];
    if (slide.isWelcome) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _finish,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                slide.secondaryCta ?? 'Saltar',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                slide.primaryCta ?? 'Comenzar',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    final isLast = _index == _slides.length - 1;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _back,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Atrás',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isLast ? 'Comenzar' : 'Siguiente',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Modelos privados ─────────────────────────────────────────────────────

class _IntroSlide {
  final String title;
  final String body;
  final List<String> bullets;
  final List<_IntroStep> steps;
  final String? primaryCta;
  final String? secondaryCta;
  final bool isWelcome;

  const _IntroSlide({
    required this.title,
    required this.body,
    this.bullets = const [],
    this.steps = const [],
    this.primaryCta,
    this.secondaryCta,
    this.isWelcome = false,
  });
}

class _IntroStep {
  final String number;
  final String description;
  const _IntroStep({required this.number, required this.description});
}

class _SlideContent extends StatelessWidget {
  final _IntroSlide slide;
  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          if (slide.body.isNotEmpty)
            Text(
              slide.body,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          if (slide.bullets.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final b in slide.bullets) _BulletRow(text: b),
          ],
          if (slide.steps.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final s in slide.steps) _StepRow(step: s),
          ],
        ],
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  const _BulletRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
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
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
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
  const _DotsIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.neutral7,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
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
