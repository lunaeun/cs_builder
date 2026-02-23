import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/export_service.dart';

class ScriptsDetailScreen extends StatefulWidget {
  const ScriptsDetailScreen({super.key});

  @override
  State<ScriptsDetailScreen> createState() => _ScriptsDetailScreenState();
}

class _ScriptsDetailScreenState extends State<ScriptsDetailScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final scripts = provider.scripts;
        if (scripts.isEmpty) return Scaffold(body: Center(child: Text('생성된 문서가 없습니다.', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))));

        final brand = provider.profile.brandName.isEmpty ? provider.profile.companyName : provider.profile.brandName;
        if (_selectedIndex >= scripts.length) _selectedIndex = 0;
        final selected = scripts[_selectedIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text('상담 스크립트'),
            actions: [
              Center(child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text('${scripts.length}개', style: TextStyle(fontSize: 13, color: cs.primary, fontWeight: FontWeight.w600)),
              )),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
                onSelected: (val) {
                  if (val == 'copy_all') {
                    final text = DocumentExportService.exportScriptsAsText(scripts, brand);
                    Clipboard.setData(ClipboardData(text: text));
                    _showSnack('전체 스크립트가 클립보드에 복사되었습니다');
                  } else if (val == 'copy_current') {
                    final text = DocumentExportService.exportScriptsAsText([selected], brand);
                    Clipboard.setData(ClipboardData(text: text));
                    _showSnack('현재 스크립트가 클립보드에 복사되었습니다');
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'copy_all', child: Row(children: [Icon(Icons.content_copy, size: 16), SizedBox(width: 8), Text('전체 스크립트 복사')])),
                  const PopupMenuItem(value: 'copy_current', child: Row(children: [Icon(Icons.copy, size: 16), SizedBox(width: 8), Text('현재 스크립트 복사')])),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Script selector
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: scripts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final isSelected = i == _selectedIndex;
                    final s = scripts[i];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? cs.primary : cs.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? cs.primary : cs.outlineVariant),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (s.isEdited) Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(Icons.edit_note, size: 14, color: isSelected ? Colors.white : cs.primary),
                          ),
                          Text(s.scenarioName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.6))),
                        ]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    // Script header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(selected.channel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
                              child: Text(selected.id, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                            ),
                          ]),
                          const SizedBox(height: 10),
                          Text(selected.scenarioName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
                          const SizedBox(height: 4),
                          Text(selected.situation, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Steps
                    ...selected.steps.asMap().entries.map((entry) {
                      final step = entry.value;
                      final i = entry.key;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                                child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white))),
                              ),
                              if (i < selected.steps.length - 1)
                                Container(width: 1, height: 40, color: cs.outlineVariant),
                            ]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: cs.outlineVariant)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Text(step.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary)),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () => _showStepEditDialog(_selectedIndex, i, step, provider, cs),
                                        child: Icon(Icons.edit_rounded, size: 14, color: cs.onSurface.withValues(alpha: 0.3)),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () {
                                          Clipboard.setData(ClipboardData(text: '[${step.label}]\n${step.content}'));
                                          _showSnack('스텝이 복사되었습니다');
                                        },
                                        child: Icon(Icons.content_copy_rounded, size: 14, color: cs.onSurface.withValues(alpha: 0.3)),
                                      ),
                                    ]),
                                    const SizedBox(height: 6),
                                    SelectableText(step.content, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6), height: 1.6)),
                                    if (step.note.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                        child: Text(step.note, style: TextStyle(fontSize: 11, color: const Color(0xFFF59E0B).withValues(alpha: 0.8))),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStepEditDialog(int scriptIdx, int stepIdx, dynamic step, AppProvider provider, ColorScheme cs) {
    final contentCtrl = TextEditingController(text: step.content);
    final noteCtrl = TextEditingController(text: step.note);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('스텝 편집: ${step.label}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 16),
            TextField(controller: contentCtrl, maxLines: 6, decoration: InputDecoration(labelText: '대화 내용', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, decoration: InputDecoration(labelText: '참고사항 (선택)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                provider.updateScriptStep(scriptIdx, stepIdx, content: contentCtrl.text, note: noteCtrl.text);
                Navigator.pop(ctx);
                _showSnack('스크립트가 수정되었습니다');
              },
              child: const Text('저장'),
            )),
          ]),
        );
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}
