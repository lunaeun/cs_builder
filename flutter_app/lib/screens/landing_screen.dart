import 'package:flutter/material.dart';
import 'dart:async';

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

  final PageController _previewController =
      PageController(viewportFraction: 0.88);
  int _currentPreview = 0;
  Timer? _autoScrollTimer;

  final List<_PreviewCard> _previewCards = [
    _PreviewCard(
      type: 'FAQ',
      badge: '29\uAC1C \uC790\uB3D9 \uC0DD\uC131',
      icon: Icons.help_center_rounded,
      color: Color(0xFF1B64DA),
      industry: '\uC790\uB3D9\uCC28/\uD280\uB2DD \uC5C5\uC885 \uC608\uC2DC',
      items: [
        _PreviewItem(
          'Q. \uCC28\uB7C9 \uD280\uB2DD\uC5D0 \uB9DE\uB294 \uC81C\uD488\uC740 \uC5B4\uB514\uC11C?',
          'A. \uCC28\uB7C9 \uBAA8\uB378\uACFC \uC6A9\uB3C4\uB97C \uC54C\uB824\uC8FC\uC2DC\uBA74 \uCD5C\uC801\uC758 \uC81C\uD488\uC744 \uC548\uB0B4\uD574\uB4DC\uB9BD\uB2C8\uB2E4.',
        ),
        _PreviewItem(
          'Q. DIY \uC124\uCE58 \uC9C0\uC6D0\uC774 \uAC00\uB2A5\uD55C\uAC00\uC694?',
          'A. \uC7AC\uB8CC\uC640 \uC548\uB0B4\uC11C\uB97C \uC81C\uACF5\uD558\uBA70, \uC804\uBB38 \uC124\uCE58\uB3C4 \uAC00\uB2A5\uD569\uB2C8\uB2E4.',
        ),
        _PreviewItem(
          'Q. \uAD50\uD658\uC774\uB098 \uBC18\uD488\uC740 \uC5B4\uB5BB\uAC8C \uD558\uB098\uC694?',
          'A. \uC81C\uD488 \uC218\uB839 7\uC77C \uC774\uB0B4, \uBBF8\uAC1C\uBD09 \uC0C1\uD0DC\uC5D0\uC11C \uAD50\uD658/\uBC18\uD488 \uAC00\uB2A5\uD569\uB2C8\uB2E4.',
        ),
      ],
    ),
    _PreviewCard(
      type: '\uC0C1\uB2F4 \uC2A4\uD06C\uB9BD\uD2B8',
      badge: '\uCC44\uB110\uBCC4 \uC2DC\uB098\uB9AC\uC624',
      icon: Icons.article_rounded,
      color: Color(0xFF3B82F6),
      industry: '\uC804\uD654 \uC0C1\uB2F4 \uC608\uC2DC',
      items: [
        _PreviewItem(
          '1. \uC778\uC0AC',
          '"\uC548\uB155\uD558\uC138\uC694, \uD2F0\uD30C\uCE20 \uC0C1\uB2F4\uC6D0 OOO\uC785\uB2C8\uB2E4. \uBB34\uC5C7\uC744 \uB3C4\uC640\uB4DC\uB9B4\uAE4C\uC694?"',
        ),
        _PreviewItem(
          '2. \uB2C8\uC988 \uD655\uC778',
          '"\uAC10\uC0AC\uD569\uB2C8\uB2E4. \uC5B4\uB5A4 \uC81C\uD488\uC5D0 \uAD00\uC2EC\uC774 \uC788\uC73C\uC2E0\uC9C0 \uC54C\uB824\uC8FC\uC2DC\uACA0\uC5B4\uC694?"',
        ),
        _PreviewItem(
          '3. \uB9C8\uBB34\uB9AC',
          '"\uBB38\uC758 \uAC10\uC0AC\uD569\uB2C8\uB2E4. \uC88B\uC740 \uD558\uB8E8 \uB418\uC138\uC694!"',
        ),
      ],
    ),
    _PreviewCard(
      type: 'QA \uD3C9\uAC00 \uC2DC\uD2B8',
      badge: '5\uAC1C \uAE30\uC900 \u00B7 25\uC810 \uB9CC\uC810',
      icon: Icons.grading_rounded,
      color: Color(0xFF2563EB),
      industry: '\uC0C1\uB2F4 \uD488\uC9C8 \uAD00\uB9AC',
      items: [
        _PreviewItem(
          '\uC778\uC0AC/\uB9C8\uBB34\uB9AC (5\uC810)',
          '\uCD08\uAE30 \uC778\uC0AC \uC900\uC218, \uC885\uB8CC \uC2DC \uCD94\uAC00 \uBB38\uC758 \uD655\uC778',
        ),
        _PreviewItem(
          '\uACBD\uCCAD/\uACF5\uAC10 (5\uC810)',
          '\uACE0\uAC1D \uBB38\uC758 \uC815\uD655\uD55C \uD30C\uC545, \uACF5\uAC10 \uD45C\uD604',
        ),
        _PreviewItem(
          '\uC815\uD655\uC131 (5\uC810)',
          '\uC81C\uD488 \uC815\uBCF4, \uC815\uCC45, \uB9E4\uC7A5 \uC815\uBCF4 \uC815\uD655 \uC548\uB0B4',
        ),
      ],
    ),
    _PreviewCard(
      type: '\uC6B4\uC601\uC124\uACC4\uC11C',
      badge: '10\uAC1C \uC139\uC158 \uC790\uB3D9 \uAD6C\uC131',
      icon: Icons.architecture_rounded,
      color: Color(0xFF60A5FA),
      industry: '\uCC44\uB110\uBCC4 \uC6B4\uC601 \uAC00\uC774\uB4DC',
      items: [
        _PreviewItem(
          '\uCC44\uB110\uBCC4 \uC6B4\uC601 \uC815\uCC45',
          '\uC804\uD654\u00B7\uCC44\uB110\uD1A1\u00B7SNS\u00B7\uAC8C\uC2DC\uD310 \uAC01 \uCC44\uB110 \uC6B4\uC601 \uC2DC\uAC04 \uBC0F SLA \uAE30\uC900',
        ),
        _PreviewItem(
          '\uC0C1\uB2F4\uC6D0 \uBC30\uCE58',
          '\uC778\uC6D0\uBCC4 \uC5ED\uD560 \uBD84\uB2F4, \uD53C\uD06C\uD0C0\uC784 \uAD50\uB300 \uADFC\uBB34',
        ),
        _PreviewItem(
          '\uC5D0\uC2A4\uCEEC\uB808\uC774\uC158 \uADDC\uCE59',
          '1\uCC28\u2192 2\uCC28\u2192 \uAD00\uB9AC\uC790 \uB2E8\uACC4\uBCC4 \uCC98\uB9AC \uAE30\uC900 \uBC0F \uC2DC\uAC04',
        ),
      ],
    ),
  ];

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

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_previewController.hasClients) {
        final next = (_currentPreview + 1) % _previewCards.length;
        _previewController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _previewController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? cs.surface : Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildLogo(cs),
                const SizedBox(height: 20),
                _buildTitle(cs),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    '3\uBD84 \uB9CC\uC5D0 FAQ \u00B7 \uC2A4\uD06C\uB9BD\uD2B8 \u00B7 \uC6B4\uC601\uC124\uACC4\uC11C\n\uC790\uB3D9 \uC0DD\uC131',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: cs.onSurface.withValues(alpha: 0.5),
                      height: 1.5,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureCards(cs, isDark),
                const SizedBox(height: 24),
                _buildPreviewSection(cs, isDark),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _buildCTAButton(cs),
                ),
                const SizedBox(height: 10),
                Text(
                  'v2.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.2),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme cs) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B64DA), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B64DA).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: const Icon(
        Icons.support_agent_rounded,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Widget _buildTitle(ColorScheme cs) {
    return Text(
      'CS Builder',
      style: TextStyle(
        fontSize: 32,
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
          Icons.auto_awesome_rounded, 'AI \uC790\uB3D9 \uC0DD\uC131', const Color(0xFF1B64DA)),
      _FeatureItem(
          Icons.grading_rounded, 'QA \uD488\uC9C8 \uD3C9\uAC00', const Color(0xFF3B82F6)),
      _FeatureItem(
          Icons.tune_rounded, '\uC5C5\uC885\uBCC4 \uD504\uB9AC\uC14B', const Color(0xFF2563EB)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: features.asMap().entries.map((entry) {
          final i = entry.key;
          final f = entry.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 4,
                right: i == 2 ? 0 : 4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color:
                    isDark ? cs.surface.withValues(alpha: 0.8) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.icon, size: 20, color: f.color),
                  const SizedBox(height: 6),
                  Text(
                    f.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreviewSection(ColorScheme cs, bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B64DA),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\uC2E4\uC81C \uC0DD\uC131 \uC608\uC2DC',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentPreview + 1}/${_previewCards.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _previewController,
            itemCount: _previewCards.length,
            onPageChanged: (i) => setState(() => _currentPreview = i),
            itemBuilder: (context, index) {
              return _buildPreviewCardWidget(
                  _previewCards[index], cs, isDark);
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_previewCards.length, (i) {
            final isActive = i == _currentPreview;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF1B64DA)
                    : cs.onSurface.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPreviewCardWidget(
      _PreviewCard card, ColorScheme cs, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? cs.surface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: card.color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: card.color.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(card.icon, size: 16, color: card.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      card.industry,
                      style: TextStyle(
                        fontSize: 10,
                        color: cs.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: card.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  card.badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: card.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...card.items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                        color: card.color.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface.withValues(alpha: 0.8),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurface.withValues(alpha: 0.4),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
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
              '\uBB34\uB8CC\uB85C \uC2DC\uC791\uD558\uAE30',
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
  final Color color;
  const _FeatureItem(this.icon, this.title, this.color);
}

class _PreviewCard {
  final String type;
  final String badge;
  final IconData icon;
  final Color color;
  final String industry;
  final List<_PreviewItem> items;
  const _PreviewCard({
    required this.type,
    required this.badge,
    required this.icon,
    required this.color,
    required this.industry,
    required this.items,
  });
}

class _PreviewItem {
  final String title;
  final String subtitle;
  const _PreviewItem(this.title, this.subtitle);
}
