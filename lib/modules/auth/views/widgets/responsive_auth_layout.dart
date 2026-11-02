import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';

class ResponsiveAuthLayout extends StatelessWidget {
  final Widget logo;
  final Widget content;
  final double mobileHeaderHeight;
  final Widget? mobileHeaderExtra;
  final Animation<double>? fadeIn;
  final Animation<Offset>? slideUp;

  const ResponsiveAuthLayout({
    super.key,
    required this.logo,
    required this.content,
    this.mobileHeaderHeight = 220,
    this.mobileHeaderExtra,
    this.fadeIn,
    this.slideUp,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 800;

    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  Widget _buildDesktopLayout(BuildContext context) {
    Widget innerContent = content;
    if (fadeIn != null && slideUp != null) {
      innerContent = FadeTransition(
        opacity: fadeIn!,
        child: SlideTransition(
          position: slideUp!,
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        children: [
          // Left Panel: Gradient and Logo
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                // Fondo azul gradiente horizontal de #477D9E a #2F536A
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF477D9E),
                    Color(0xFF2F536A),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(64.0),
                  // Logo isologo-h-crema.svg, 30% más grande (80 → 104)
                  child: SvgPicture.asset(
                    'assets/images/isologo-h-crema.svg',
                    height: 104,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          // Right Panel: White background and form
          Expanded(
            flex: 1,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: innerContent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    Widget innerContent = Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: content,
    );

    if (fadeIn != null && slideUp != null) {
      innerContent = FadeTransition(
        opacity: fadeIn!,
        child: SlideTransition(
          position: slideUp!,
          child: innerContent,
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF477D9E),
      resizeToAvoidBottomInset: true,
      body: SizedBox.expand(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            // Fondo azul gradiente vertical de #477D9E a #2F536A
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF477D9E),
                Color(0xFF2F536A),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header with logo
              SizedBox(
                height: mobileHeaderHeight + topPadding,
                child: Stack(
                  children: [
                    if (mobileHeaderExtra != null) mobileHeaderExtra!,
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: logo,
                      ),
                    ),
                  ],
                ),
              ),
              // White card content
              Expanded(child: innerContent),
            ],
          ),
        ),
      ),
    );
  }
}
