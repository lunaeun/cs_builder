import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/generated_documents.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import 'subscription_screen.dart';
import '../widgets/upgrade_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [_buildHome(cs), _buildDocuments(cs), _buildSettings(cs)],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3))),
        ),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_copy_rounded), label: '문서'),
            BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: '설정'),
          ],
        ),
      ),
    );
  }

  // ============ HOME TAB ============
  Widget _buildHome(ColorScheme cs) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        if (provider.lastError != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        provider.lastError!,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: '다시 시도',
                  textColor: Colors.white,
                  onPressed: () => provider.generateAllDocuments(),
                ),
              ),
            );
            provider.clearError();
          });
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _buildHomeHeader(provider, cs),
            const SizedBox(height: 20),
            _buildHeroCard(provider, cs),
            const SizedBox(height: 16),
            if (provider.isGenerated) ...[
              _buildProgressGauge(provider, cs),
              const SizedBox(height: 16),
            ],
            _buildQuickStats(provider, cs),
            const SizedBox(height: 20),
            _buildDocSection(provider, cs),
            const SizedBox(height: 16),
            if (provider.isGenerated && provider.actionItems.isNotEmpty) ...[
              _buildActionCenter(provider, cs),
              const SizedBox(height: 16),
            ],
            if (!provider.isGenerated && !provider.isGenerating)
              _buildGenerateButton(provider, cs),
            if (provider.isGenerating) _buildGeneratingState(cs),
          ],
        );
      },
    );
  }

  Widget _buildHomeHeader(AppProvider provider, ColorScheme cs) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? '좋은 아침이에요' : (hour < 18 ? '안녕하세요' : '좋은 저녁이에요');
    return Row(
      children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CS Builder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.5)),
              Text(greeting, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
            ],
          ),
        ),
        _buildIconBtn(
          provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          () => provider.toggleDarkMode(),
          cs,
        ),
      ],
    );
  }

  Widget _buildHeroCard(AppProvider provider, ColorScheme cs) {
    final p = provider.profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(colors: [cs.primary.withValues(alpha: 0.15), cs.primary.withValues(alpha: 0.05)])
            : AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [
          BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isDark ? 0.1 : 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.store_rounded, color: isDark ? cs.primary : Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.brandName.isEmpty ? '브랜드' : p.brandName,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? cs.onSurface : Colors.white, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.industryType.isEmpty ? '업종 미설정' : p.industryType,
                      style: TextStyle(fontSize: 13, color: isDark ? cs.onSurface.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              _buildIconBtn(Icons.edit_rounded, () => Navigator.pushReplacementNamed(context, '/onboarding'), cs, light: !isDark),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isDark ? 0.06 : 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildStatChip(Icons.people_alt_rounded, '${p.agentCount}명', isDark ? cs.onSurface : Colors.white),
                _buildStatDivider(isDark ? cs.onSurface : Colors.white),
                _buildStatChip(Icons.headset_mic_rounded, '${p.dailyCalls}건/일', isDark ? cs.onSurface : Colors.white),
                _buildStatDivider(isDark ? cs.onSurface : Colors.white),
                _buildStatChip(Icons.account_balance_wallet_rounded, _formatBudget(p.monthlyBudget), isDark ? cs.onSurface : Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color.withValues(alpha: 0.7)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildStatDivider(Color color) {
    return Container(width: 1, height: 16, color: color.withValues(alpha: 0.2));
  }

  Widget _buildProgressGauge(AppProvider provider, ColorScheme cs) {
    final progress = provider.completionProgress;
    final completed = provider.completedActionCount;
    final total = provider.actionItems.length;
    final isComplete = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isComplete ? AppTheme.success.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isComplete ? AppTheme.success.withValues(alpha: 0.1) : cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isComplete ? Icons.check_circle_rounded : Icons.rocket_launch_rounded,
                  size: 18,
                  color: isComplete ? AppTheme.success : cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CS 운영 진행률', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface)),
                    Text(isComplete ? '모두 완료!' : '다음 할 일을 확인하세요', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: isComplete
                      ? LinearGradient(colors: [AppTheme.success.withValues(alpha: 0.15), AppTheme.success.withValues(alpha: 0.05)])
                      : LinearGradient(colors: [cs.primary.withValues(alpha: 0.12), cs.primary.withValues(alpha: 0.04)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$completed/$total', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: isComplete ? AppTheme.success : cs.primary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
              color: isComplete ? AppTheme.success : cs.primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppProvider provider, ColorScheme cs) {
    final p = provider.profile;
    final channels = <_ChInfo>[];
    if (p.usePhoneChannel) channels.add(_ChInfo('전화', Icons.phone_rounded, const Color(0xFF1B64DA)));
    if (p.useChannelTalk) channels.add(_ChInfo('채널톡', Icons.chat_rounded, const Color(0xFF3B82F6)));
    if (p.useEmailChannel) channels.add(_ChInfo('이메일', Icons.email_rounded, const Color(0xFF2563EB)));
    if (p.useSnsChannel) channels.add(_ChInfo('SNS', Icons.forum_rounded, const Color(0xFF2563EB)));
    if (p.useBoardChannel) channels.add(_ChInfo('게시판', Icons.dashboard_rounded, const Color(0xFF60A5FA)));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cell_tower_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
              const SizedBox(width: 6),
              Text('활성 채널', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.5))),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)),
                child: Text('${channels.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: channels.map((ch) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ch.color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ch.color.withValues(alpha: 0.12)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(ch.icon, size: 15, color: ch.color),
                const SizedBox(width: 6),
                Text(ch.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ch.color)),
              ]),
            )).toList(),
          ),
          if (provider.profile.agentRoles.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: cs.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.badge_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
                const SizedBox(width: 6),
                Text('상담원', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.5))),
                const Spacer(),
                Text('${provider.profile.agentRoles.length}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary)),
              ],
            ),
            const SizedBox(height: 10),
            ...provider.profile.agentRoles.map((role) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    gradient: role.isPrimary
                        ? LinearGradient(colors: [cs.primary.withValues(alpha: 0.15), cs.primary.withValues(alpha: 0.05)])
                        : null,
                    color: role.isPrimary ? null : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(child: Text(
                    role.name.replaceAll('Agent ', '').replaceAll('agent ', '').replaceAll('상담원 ', ''),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: role.isPrimary ? cs.primary : cs.onSurface.withValues(alpha: 0.4)),
                  )),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(role.title, style: TextStyle(fontSize: 13, color: cs.onSurface))),
                if (role.isPrimary) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('Lead', style: TextStyle(fontSize: 10, color: cs.primary, fontWeight: FontWeight.w700)),
                ),
              ]),
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildDocSection(AppProvider provider, ColorScheme cs) {
    final generated = provider.documents.where((d) => d.status == DocumentStatus.generated).length;
    return Column(
      children: [
        Row(children: [
          Icon(Icons.description_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
          const SizedBox(width: 6),
          Text('문서', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.5))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cs.primary.withValues(alpha: 0.1), cs.primary.withValues(alpha: 0.04)]),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$generated/${provider.documents.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
          ),
        ]),
        const SizedBox(height: 12),
        ...provider.documents.map((doc) => _buildDocRow(doc, cs)),
      ],
    );
  }

  Widget _buildDocRow(GeneratedDocument doc, ColorScheme cs) {
    final isGenerated = doc.status == DocumentStatus.generated;
    final isGenerating = doc.status == DocumentStatus.generating;
    final iconMap = <String, IconData>{
      'quiz': Icons.help_center_rounded,
      'architecture': Icons.architecture_rounded,
      'grading': Icons.star_rate_rounded,
      'description': Icons.article_rounded,
    };
    final colorMap = <String, Color>{
      'quiz': const Color(0xFF1B64DA),
      'architecture': const Color(0xFF3B82F6),
      'grading': const Color(0xFF2563EB),
      'description': const Color(0xFF60A5FA),
    };
    final docColor = colorMap[doc.iconName] ?? cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isGenerated ? docColor.withValues(alpha: 0.2) : cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isGenerated ? () => Navigator.pushNamed(context, '/document/${doc.type}') : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: isGenerated
                        ? LinearGradient(colors: [docColor.withValues(alpha: 0.15), docColor.withValues(alpha: 0.05)])
                        : null,
                    color: isGenerated ? null : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isGenerating
                      ? Padding(padding: const EdgeInsets.all(11), child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary))
                      : Icon(iconMap[doc.iconName] ?? Icons.article_rounded, size: 20, color: isGenerated ? docColor : cs.onSurface.withValues(alpha: 0.3)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      const SizedBox(height: 2),
                      Text(doc.subtitle, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isGenerated ? docColor.withValues(alpha: 0.08) : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isGenerated ? '보기' : (isGenerating ? '...' : '대기'),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isGenerated ? docColor : cs.onSurface.withValues(alpha: 0.35)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCenter(AppProvider provider, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.checklist_rtl_rounded, size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
            const SizedBox(width: 6),
            Text('할 일 목록', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
        const SizedBox(height: 10),
        ...provider.actionItems.map((item) => _buildActionItem(item, provider, cs)),
      ],
    );
  }

  Widget _buildActionItem(ActionItem item, AppProvider provider, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.isCompleted ? AppTheme.success.withValues(alpha: 0.2) : cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (item.documentType.isNotEmpty) {
            Navigator.pushNamed(context, '/document/${item.documentType}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => provider.toggleActionItem(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    gradient: item.isCompleted ? LinearGradient(colors: [AppTheme.success, AppTheme.success.withValues(alpha: 0.8)]) : null,
                    color: item.isCompleted ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: item.isCompleted ? AppTheme.success : cs.outlineVariant, width: 2),
                  ),
                  child: item.isCompleted ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: item.isCompleted ? cs.onSurface.withValues(alpha: 0.35) : cs.onSurface,
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(item.description, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.35))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(6)),
                child: Text(item.actionLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(AppProvider provider, ColorScheme cs) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton.icon(
        onPressed: provider.profile.isComplete ? () {
          if (!provider.canGenerate) {
            UpgradeDialog.show(context, feature: 'AI 문서 생성 (${provider.aiGenerateCount}/${provider.aiGenerateLimit} 사용)', requiredPlan: 'Basic');
            return;
          }
          provider.incrementAICount();
          provider.generateAllDocuments();
        } : null,
        icon: const Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.white),
        label: const Text('전체 문서 생성', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  Widget _buildGeneratingState(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            SizedBox(
              width: 40, height: 40,
              child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
            ),
            const SizedBox(height: 16),
            Text('문서 생성 중...', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.5), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ============ DOCUMENTS TAB ============
  Widget _buildDocuments(ColorScheme cs) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final brand = provider.profile.brandName.isEmpty ? provider.profile.companyName : provider.profile.brandName;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('문서', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.8)),
            const SizedBox(height: 4),
            Text('생성된 문서를 확인하고 관리하세요', style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.4))),
            const SizedBox(height: 16),
            if (provider.isGenerated) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: OutlinedButton.icon(
                  icon: Icon(Icons.file_copy_rounded, size: 16, color: cs.primary),
                  label: Text('전체 복사', style: TextStyle(color: cs.primary)),
                  onPressed: () {
                    if (!provider.canDownload) {
                      UpgradeDialog.show(context, feature: '문서 내보내기', requiredPlan: provider.requiredPlanForDownload);
                      return;
                    }
                    final text = DocumentExportService.exportAllAsText(
                      brandName: brand, faqs: provider.faqs, op: provider.operationDesign, qa: provider.qaSheet, scripts: provider.scripts,
                    );
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('전체 문서가 복사되었습니다 (${text.length}자)')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: cs.primary.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ...provider.documents.map((doc) => _buildDocCard(doc, cs)),
          ],
        );
      },
    );
  }

  Widget _buildDocCard(GeneratedDocument doc, ColorScheme cs) {
    final isGenerated = doc.status == DocumentStatus.generated;
    final colorMap = <String, Color>{
      'quiz': const Color(0xFF1B64DA),
      'architecture': const Color(0xFF3B82F6),
      'grading': const Color(0xFF2563EB),
      'description': const Color(0xFF60A5FA),
    };
    final docColor = colorMap[doc.iconName] ?? cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isGenerated ? () => Navigator.pushNamed(context, '/document/${doc.type}') : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 4, height: 48,
              decoration: BoxDecoration(
                gradient: isGenerated ? LinearGradient(colors: [docColor, docColor.withValues(alpha: 0.4)], begin: Alignment.topCenter, end: Alignment.bottomCenter) : null,
                color: isGenerated ? null : cs.outlineVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: cs.onSurface)),
              const SizedBox(height: 2),
              Text(doc.subtitle, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
            ])),
            if (isGenerated) Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [docColor.withValues(alpha: 0.12), docColor.withValues(alpha: 0.04)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('보기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: docColor)),
            ),
          ]),
        ),
      ),
    );
  }

  // ============ SETTINGS TAB ============
  Widget _buildSettings(ColorScheme cs) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Text('설정', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.8)),
            const SizedBox(height: 20),
            _buildSettingsCard(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    provider.isDarkMode ? const Color(0xFF818CF8) : const Color(0xFFFBBF24),
                    provider.isDarkMode ? const Color(0xFFA78BFA) : const Color(0xFFF97316),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(provider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 20, color: Colors.white),
              ),
              title: '다크 모드',
              trailing: Switch(value: provider.isDarkMode, onChanged: (_) => provider.toggleDarkMode(), activeColor: const Color(0xFF1B64DA)),
              cs: cs,
            ),
            const SizedBox(height: 8),
            _buildSettingsTile('구독 관리', Icons.workspace_premium_rounded, const Color(0xFF1B64DA),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())), cs),
            const SizedBox(height: 8),
            _buildSettingsTile('사업 프로필 수정', Icons.business_center_rounded, const Color(0xFF1B64DA),
              () => Navigator.pushReplacementNamed(context, '/onboarding'), cs),
            const SizedBox(height: 8),
            _buildSettingsTile('문서 전체 재생성', Icons.refresh_rounded, const Color(0xFF3B82F6),
              () => provider.generateAllDocuments(), cs),
            const SizedBox(height: 8),
            _buildSettingsTile('데이터 초기화', Icons.delete_forever_rounded, const Color(0xFFEF4444), () {
              showDialog(
                context: context,
                builder: (c) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('데이터 초기화'),
                  content: const Text('모든 데이터가 영구적으로 삭제됩니다. 계속하시겠습니까?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('취소')),
                    TextButton(
                      onPressed: () { provider.resetAll(); Navigator.pop(c); Navigator.pushReplacementNamed(context, '/landing'); },
                      child: const Text('초기화', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              );
            }, cs),
            const SizedBox(height: 40),
            Center(
              child: Text('CS Builder v2.0.0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1B64DA))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsCard({required Widget leading, required String title, required Widget trailing, required ColorScheme cs}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface))),
          trailing,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, Color color, VoidCallback onTap, ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
        trailing: Icon(Icons.chevron_right_rounded, size: 22, color: cs.onSurface.withValues(alpha: 0.3)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // ============ HELPERS ============
  Widget _buildIconBtn(IconData icon, VoidCallback onTap, ColorScheme cs, {bool light = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: light ? Colors.white.withValues(alpha: 0.2) : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: light ? Colors.white : cs.onSurface.withValues(alpha: 0.5)),
      ),
    );
  }

  String _formatBudget(int amount) {
    if (amount >= 10000) {
      final man = amount ~/ 10000;
      return '${man}만';
    }
    return '${amount}원';
  }
}

class _ChInfo {
  final String name;
  final IconData icon;
  final Color color;
  _ChInfo(this.name, this.icon, this.color);
}