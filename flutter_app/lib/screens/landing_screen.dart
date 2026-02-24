import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  _buildLogo(cs),
                  const SizedBox(height: 28),
                  _buildTitle(cs),
                  const SizedBox(height: 12),
                  Text(
                    '1인 사장님을 위한\nCS 운영 자동 설계 도구',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      height: 1.5,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(flex: 2),
                  _buildFeatureCards(cs, isDark),
                  const Spacer(flex: 2),
                  _buildCTAButton(cs),
                  const SizedBox(height: 12),
                  Text(
                    '3분이면 CS 운영 설계 완료',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'v2.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.2),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme cs) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B64DA), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B64DA).withValues(alpha: 0.3),
            blurRadius: 32,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: const Icon(
        Icons.support_agent_rounded,
        color: Colors.white,
        size: 44,
      ),
    );
  }

  Widget _buildTitle(ColorScheme cs) {
    return Text(
      'CS Builder',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: cs.onSurface,
        letterSpacing: -1.5,
        height: 1.1,
      ),
    );
  }

  Widget _buildFeatureCards(ColorScheme cs, bool isDark) {
    final features = [
      _FeatureItem(
        Icons.auto_awesome_rounded,
        'AI 자동 생성',
        'FAQ · 스크립트 · 운영설계',
        const Color(0xFF1B64DA),
      ),
      _FeatureItem(
        Icons.grading_rounded,
        'QA 품질 평가',
        '상담 품질 실시간 관리',
        const Color(0xFF3B82F6),
      ),
      _FeatureItem(
        Icons.tune_rounded,
        '업종별 프리셋',
        '10개 업종 맞춤 템플릿',
        const Color(0xFF2563EB),
      ),
    ];

    return Row(
      children: features.asMap().entries.map((entry) {
        final i = entry.key;
        final f = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: i == 0 ? 0 : 5,
              right: i == 2 ? 0 : 5,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? cs.surface.withValues(alpha: 0.8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.onSurface.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: f.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(f.icon, size: 22, color: f.color),
                ),
                const SizedBox(height: 10),
                Text(
                  f.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  f.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    color: cs.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCTAButton(ColorScheme cs) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/onboarding');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B64DA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '시작하기',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _FeatureItem(this.icon, this.title, this.subtitle, this.color);
}