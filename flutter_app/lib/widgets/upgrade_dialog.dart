import 'package:flutter/material.dart';
import '../screens/subscription_screen.dart';

class UpgradeDialog {
  static void show(BuildContext context, {
    required String feature,
    String requiredPlan = 'Basic',
  }) {
    showDialog(
      context: context,
      builder: (c) {
        final cs = Theme.of(c).colorScheme;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B64DA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.lock_rounded, size: 30, color: Color(0xFF1B64DA)),
                ),
                const SizedBox(height: 16),
                Text(
                  '$requiredPlan 플랜이 필요해요',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  '$feature 기능은\n$requiredPlan 이상 플랜에서 사용할 수 있어요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.5), height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B64DA).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF1B64DA).withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFF1B64DA)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$requiredPlan 플랜', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1B64DA))),
                            Text(
                              requiredPlan == 'Basic' ? '월 ₩9,900' : (requiredPlan == 'Pro' ? '월 ₩19,900' : '월 ₩39,900'),
                              style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(c);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B64DA),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('플랜 보기', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text('나중에', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4), fontSize: 13)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
