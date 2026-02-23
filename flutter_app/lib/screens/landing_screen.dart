import 'dart:math' as math;
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _scaleLogo;
  late Animation<double> _float;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut));
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainController, curve: const Interval(0.15, 0.7, curve: Curves.easeOutCubic)));
    _scaleLogo = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _float = Tween<double>(begin: -6, end: 6)
        .animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    _pulse = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _enterApp() {
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background circles
          _buildBackgroundDecor(cs, isDark),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Floating logo with glow
                  AnimatedBuilder(
                    animation: Listenable.merge([_mainController, _floatController]),
                    builder: (ctx, child) {
                      return Transform.translate(
                        offset: Offset(0, _float.value),
                        child: FadeTransition(
                          opacity: _fadeIn,
                          child: ScaleTransition(scale: _scaleLogo, child: child),
                        ),
                      );
                    },
                    child: _buildLogoSection(cs, isDark),
                  ),
                  const SizedBox(height: 32),
                  // Title & subtitle
                  FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: _buildTitleSection(cs),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Feature cards
                  FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: _buildFeatureCards(cs, isDark),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // CTA Button
                  FadeTransition(
                    opacity: _fadeIn,
                    child: SlideTransition(
                      position: _slideUp,
                      child: _buildCTAButton(cs),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Version
                  FadeTransition(
                    opacity: _fadeIn,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        'v2.0.0',
                        style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.25), letterSpacing: 1),
                      ),
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

  Widget _buildBackgroundDecor(ColorScheme cs, bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (ctx, _) {
        return CustomPaint(
          painter: _BgCirclePainter(
            color1: cs.primary.withValues(alpha: isDark ? 0.08 : 0.06),
            color2: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.05 : 0.04),
            color3: const Color(0xFFEC4899).withValues(alpha: isDark ? 0.04 : 0.03),
            animValue: _pulse.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildLogoSection(ColorScheme cs, bool isDark) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, const Color(0xFF8B5CF6)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.35),
            blurRadius: 40,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
            blurRadius: 60,
            offset: const Offset(0, 20),
            spreadRadius: -8,
          ),
        ],
      ),
      child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 48),
    );
  }

  Widget _buildTitleSection(ColorScheme cs) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [cs.primary, const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
          ).createShader(bounds),
          child: const Text(
            'CS Builder',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '3 minutes to set up your\ncustomer service center',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: cs.onSurface.withValues(alpha: 0.45),
            height: 1.5,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards(ColorScheme cs, bool isDark) {
    final features = [
      _FeatureInfo(Icons.auto_awesome_rounded, 'AI Auto-Gen', 'FAQ, Scripts, Ops', const Color(0xFF6366F1)),
      _FeatureInfo(Icons.analytics_rounded, 'QA Scoring', 'Real-time Eval', const Color(0xFF8B5CF6)),
      _FeatureInfo(Icons.tune_rounded, 'Presets', '10 Industries', const Color(0xFFEC4899)),
    ];

    return Row(
      children: features.map((f) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: f == features.first ? 0 : 6,
              right: f == features.last ? 0 : 6,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark ? cs.surface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: f.color.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: f.color.withValues(alpha: isDark ? 0.05 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [f.color.withValues(alpha: 0.15), f.color.withValues(alpha: 0.05)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(f.icon, size: 22, color: f.color),
                ),
                const SizedBox(height: 10),
                Text(f.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.2)),
                const SizedBox(height: 2),
                Text(f.subtitle, style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.4))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTAButton(ColorScheme cs) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (ctx, child) {
            return Transform.scale(scale: _pulse.value, child: child);
          },
          child: Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, const Color(0xFF8B5CF6)],
                begin: Alignment.centerLeft, end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _enterApp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Start Building', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: Colors.white)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '3 minutes to complete CS operations setup',
          style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.3)),
        ),
      ],
    );
  }
}

class _FeatureInfo {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _FeatureInfo(this.icon, this.title, this.subtitle, this.color);
}

class _BgCirclePainter extends CustomPainter {
  final Color color1, color2, color3;
  final double animValue;
  _BgCirclePainter({required this.color1, required this.color2, required this.color3, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = animValue;
    // Top-right circle
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.08),
      160 * scale,
      Paint()..color = color1,
    );
    // Left-center circle
    canvas.drawCircle(
      Offset(size.width * -0.1, size.height * 0.45),
      200 * scale,
      Paint()..color = color2,
    );
    // Bottom-right circle
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.85),
      140 * scale,
      Paint()..color = color3,
    );
  }

  @override
  bool shouldRepaint(covariant _BgCirclePainter old) => old.animValue != animValue;
}
