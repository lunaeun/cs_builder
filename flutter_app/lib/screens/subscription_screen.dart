import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/payment_service.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    ㅍbool _isYearly = false;
  bool _isProcessing = false;

  final List<_PlanInfo> _plans = [
    _PlanInfo(
      id: 'free', name: 'Free', monthlyPrice: 0, yearlyPrice: 0,
      description: '체험용',
      features: ['AI 생성 3회', '기본 템플릿', '미리보기만 가능'],
      limitations: ['다운로드 불가', 'QA 평가 불가', '팀 기능 없음'],
      color: Color(0xFF94A3B8),
    ),
    _PlanInfo(
      id: 'basic', name: 'Basic', monthlyPrice: 9900, yearlyPrice: 99000,
      description: '1인 사장님',
      features: ['AI 생성 30회/월', '스크립트 다운로드', 'FAQ 다운로드', '이메일 지원'],
      limitations: ['QA 평가 불가', '팀 기능 없음'],
      color: Color(0xFF3B82F6),
    ),
    _PlanInfo(
      id: 'pro', name: 'Pro', monthlyPrice: 19900, yearlyPrice: 199000,
      description: '성장하는 비즈니스',
      features: ['무제한 AI 생성', 'IVR 시나리오', 'QA 평가 시트', '전화/채팅 지원', '우선 업데이트'],
      limitations: ['팀 기능 없음'],
      color: Color(0xFF1B64DA), isPopular: true,
    ),
    _PlanInfo(
      id: 'business', name: 'Business', monthlyPrice: 39900, yearlyPrice: 399000,
      description: '팀 운영',
      features: ['Pro 전체 기능', '팀 멤버 관리', '월간 리포트', '전담 매니저', 'API 연동'],
      limitations: [],
      color: Color(0xFF1E40AF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _buildCurrentPlan(cs),
              const SizedBox(height: 20),
              _buildToggle(cs),
              const SizedBox(height: 16),
              ..._plans.map((plan) => _buildPlanCard(plan, cs)),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF1B64DA)),
                    SizedBox(height: 16),
                    Text('결제 처리 중...', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlan(ColorScheme cs) {
    final current = _plans.firstWhere((p) => p.id == _currentPlan);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('현재 플랜', style: TextStyle(fontSize: 12, color: Colors.white70)),
                const SizedBox(height: 2),
                Text(current.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              current.monthlyPrice == 0 ? '무료' : '₩${_formatPrice(current.monthlyPrice)}/월',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isYearly ? cs.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_isYearly ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                ),
                child: Center(child: Text('월간 결제', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: !_isYearly ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4),
                ))),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isYearly ? cs.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _isYearly ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
                ),
                child: Center(child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('연간 결제 ', style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: _isYearly ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4),
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B64DA).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('17%↓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1B64DA))),
                    ),
                  ],
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(_PlanInfo plan, ColorScheme cs) {
    final isCurrent = plan.id == _currentPlan;
    final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;
    final monthlyEquiv = _isYearly ? (plan.yearlyPrice / 12).round() : plan.monthlyPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: plan.isPopular ? const Color(0xFF1B64DA) : (isCurrent ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.4)),
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: plan.isPopular ? [BoxShadow(color: const Color(0xFF1B64DA).withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: plan.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.workspace_premium_rounded, size: 18, color: plan.color),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                  Text(plan.description, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                ],
              ),
              const Spacer(),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF1B64DA), borderRadius: BorderRadius.circular(6)),
                  child: const Text('추천', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('현재', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.primary)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price == 0 ? '무료' : '₩${_formatPrice(monthlyEquiv)}',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -1),
              ),
              if (price > 0) ...[
                const SizedBox(width: 2),
                Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('/월', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4)))),
              ],
              if (_isYearly && price > 0) ...[
                const SizedBox(width: 8),
                Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('연 ₩${_formatPrice(price)}', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.35)))),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ...plan.features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 16, color: plan.color),
              const SizedBox(width: 8),
              Text(f, style: TextStyle(fontSize: 13, color: cs.onSurface)),
            ]),
          )),
          ...plan.limitations.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Icon(Icons.remove_circle_outline_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.2)),
              const SizedBox(width: 8),
              Text(l, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.35), decoration: TextDecoration.lineThrough)),
            ]),
          )),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: isCurrent
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('현재 플랜'),
                  )
                : ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handleSubscribe(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.isPopular ? const Color(0xFF1B64DA) : cs.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      price == 0 ? '무료로 시작' : '구독하기',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _handleSubscribe(_PlanInfo plan) async {
    final price = _isYearly ? plan.yearlyPrice : plan.monthlyPrice;

    // 무료 플랜은 결제 없이 바로 변경
    if (price == 0) {
      setState(() => _currentPlan = plan.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plan.name} 플랜으로 변경되었습니다'),
            backgroundColor: const Color(0xFF1B64DA),
          ),
        );
      }
      return;
    }

    // 결제 확인 다이얼로그
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('${plan.name} 플랜 구독'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('결제 금액: ₩${_formatPrice(price)}${_isYearly ? "/년" : "/월"}'),
            const SizedBox(height: 8),
            Text('토스페이먼츠 결제창이 열립니다.', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('결제하기', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1B64DA))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 결제 호출
    setState(() => _isProcessing = true);

    try {
      final result = await PaymentService.requestPayment(
        planId: plan.id,
        planName: '${plan.name} 플랜 (${_isYearly ? "연간" : "월간"})',
        amount: price,
        buyerName: 'CS Builder 사용자',
        buyerEmail: 'user@csbuilder.app',
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _currentPlan = plan.id;
          _isProcessing = false;
        });
        _showResultDialog(
          success: true,
          title: '결제 완료!',
          message: '${plan.name} 플랜이 활성화되었습니다.\n결제 ID: ${result['paymentId']}',
        );
      } else {
        setState(() => _isProcessing = false);
        _showResultDialog(
          success: false,
          title: '결제 실패',
          message: result['message'] ?? '결제 처리 중 오류가 발생했습니다.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showResultDialog(
        success: false,
        title: '결제 오류',
        message: '결제 처리 중 오류가 발생했습니다.\n$e',
      );
    }
  }

  void _showResultDialog({required bool success, required String title, required String message}) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('확인', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _PlanInfo {
  final String id, name, description;
  final int monthlyPrice, yearlyPrice;
  final List<String> features, limitations;
  final Color color;
  final bool isPopular;

  _PlanInfo({
    required this.id, required this.name, required this.description,
    required this.monthlyPrice, required this.yearlyPrice,
    required this.features, required this.limitations,
    required this.color, this.isPopular = false,
  });
}
