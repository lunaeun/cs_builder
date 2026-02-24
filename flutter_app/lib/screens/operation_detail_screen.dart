import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/export_service.dart';
import '../widgets/upgrade_dialog.dart';

class OperationDetailScreen extends StatefulWidget {
  const OperationDetailScreen({super.key});
  @override
  State<OperationDetailScreen> createState() => _OperationDetailScreenState();
}

class _OperationDetailScreenState extends State<OperationDetailScreen> {
  final _scrollController = ScrollController();
  final _sectionKeys = <GlobalKey>[];

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  void _scrollToSection(int index) {
    if (index < _sectionKeys.length) {
      final ctx = _sectionKeys[index].currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppProvider>(builder: (ctx, provider, _) {
      final op = provider.operationDesign;
      if (op == null) return Scaffold(body: Center(child: Text('생성된 문서가 없습니다.', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))));
      final brand = provider.profile.brandName.isEmpty ? provider.profile.companyName : provider.profile.brandName;
      final sections = [
        _SectionData('overview', '개요', Icons.info_outline_rounded, op.overview),
        _SectionData('systemArchitecture', '시스템 아키텍처', Icons.hub_rounded, op.systemArchitecture),
        _SectionData('channelOperations', '채널별 운영 정책', Icons.tune_rounded, op.channelOperations),
        _SectionData('ivrDesign', 'IVR 설계', Icons.phone_in_talk_rounded, op.ivrDesign),
        _SectionData('workflowDesign', '워크플로우 설계', Icons.account_tree_rounded, op.workflowDesign),
        _SectionData('agentSchedule', '상담원 운영', Icons.groups_rounded, op.agentSchedule),
        _SectionData('slaKpi', 'SLA & KPI', Icons.analytics_rounded, op.slaKpi),
        _SectionData('escalationRules', '에스컬레이션', Icons.trending_up_rounded, op.escalationRules),
        _SectionData('vocProcess', 'VOC 프로세스', Icons.record_voice_over_rounded, op.vocProcess),
        _SectionData('budget', '예산', Icons.payments_rounded, op.budget),
      ];
      while (_sectionKeys.length < sections.length) _sectionKeys.add(GlobalKey());

      return Scaffold(
        appBar: AppBar(
          title: const Text('운영설계서'),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
              onSelected: (val) {
                if (!provider.canDownload) {
                  UpgradeDialog.show(context, feature: '운영설계서 내보내기', requiredPlan: provider.requiredPlanForDownload);
                  return;
                }
                if (val == 'copy_all') {
                  final text = DocumentExportService.exportOperationDesignAsText(op, brand);
                  Clipboard.setData(ClipboardData(text: text));
                  _showSnack('운영설계서 전체가 복사되었습니다');
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'copy_all', child: Row(children: [Icon(Icons.content_copy, size: 16), SizedBox(width: 8), Text('전체 텍스트 복사')])),
              ],
            ),
          ],
        ),
        endDrawer: Drawer(
          child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(padding: const EdgeInsets.all(16), child: Text('목차 (TOC)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface))),
            const Divider(height: 1),
            Expanded(child: ListView.builder(itemCount: sections.length, itemBuilder: (_, i) {
              final s = sections[i];
              final isEdited = op.editedSections[s.key] == true;
              return ListTile(leading: Icon(s.icon, size: 20, color: cs.primary), title: Text(s.title, style: TextStyle(fontSize: 14, color: cs.onSurface)),
                trailing: isEdited ? Icon(Icons.edit_note_rounded, size: 16, color: cs.primary) : null, onTap: () => _scrollToSection(i));
            })),
          ])),
        ),
        body: ListView.builder(
          controller: _scrollController, padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), itemCount: sections.length,
          itemBuilder: (_, i) {
            final s = sections[i];
            final isEdited = op.editedSections[s.key] == true;
            return Container(key: _sectionKeys[i], margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: isEdited ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant)),
              child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  leading: Container(width: 36, height: 36, decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(s.icon, size: 18, color: cs.primary)),
                  title: Row(children: [Expanded(child: Text(s.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface))), if (isEdited) Icon(Icons.edit_note_rounded, size: 16, color: cs.primary)]),
                  children: [Container(width: double.infinity, padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        InkWell(onTap: () => _showSectionEditDialog(s.key, s.title, s.content, provider, cs), borderRadius: BorderRadius.circular(6),
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.edit_rounded, size: 14, color: cs.primary), const SizedBox(width: 4), Text('편집', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary))]))),
                        InkWell(onTap: () { Clipboard.setData(ClipboardData(text: '${s.title}\n\n${s.content}')); _showSnack('${s.title} 섹션이 복사되었습니다'); }, borderRadius: BorderRadius.circular(6),
                          child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.content_copy_rounded, size: 14, color: cs.onSurface.withValues(alpha: 0.5)), const SizedBox(width: 4), Text('복사', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5)))]))),
                      ]),
                      const SizedBox(height: 8),
                      SelectableText(s.content, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6), height: 1.7)),
                    ]))],
                )),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.small(onPressed: () => Scaffold.of(context).openEndDrawer(), tooltip: '목차', child: const Icon(Icons.toc_rounded, size: 20)),
      );
    });
  }

  void _showSectionEditDialog(String key, String title, String content, AppProvider provider, ColorScheme cs) {
    final ctrl = TextEditingController(text: content);
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('$title 편집', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 16),
          SizedBox(height: 300, child: TextField(controller: ctrl, maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top, decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { provider.updateOperationSection(key, ctrl.text); Navigator.pop(ctx); _showSnack('$title 섹션이 수정되었습니다'); }, child: const Text('저장'))),
        ])));
  }

  void _showSnack(String msg) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2))); }
}

class _SectionData {
  final String key, title;
  final IconData icon;
  final String content;
  _SectionData(this.key, this.title, this.icon, this.content);
}