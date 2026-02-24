import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/export_service.dart';
import '../widgets/upgrade_dialog.dart';

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
        if (scripts.isEmpty) {
          return Scaffold(body: Center(child: Text('스크립트를 먼저 생성해주세요.', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))));
        }

        final brand = provider.profile.brandName.isEmpty ? provider.profile.companyName : provider.profile.brandName;
        if (_selectedIndex >= scripts.length) _selectedIndex = 0;
        final current = scripts[_selectedIndex];

        return Scaffold(
          appBar: AppBar(
            title: const Text('응대 스크립트', style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (provider.currentPlan == 'free') {
		UpgradeDialog.show(context, feature: '스크립트 내보내기');
                    return;
                  }
                  if (v == 'all') {
                    final buf = StringBuffer();
                    for (final s in scripts) {
                      buf.writeln('[$brand] ${s.scenarioName}');
                      buf.writeln('채널: ${s.channel} | 상황: ${s.situation}');
                      for (int i = 0; i < s.steps.length; i++) {
                        buf.writeln('${i + 1}. ${s.steps[i].content}');
                        if (s.steps[i].note.isNotEmpty) {
                          buf.writeln('   메모: ${s.steps[i].note}');
                        }
                      }
                      buf.writeln('---');
                    }
                    Clipboard.setData(ClipboardData(text: buf.toString()));
                    _showSnack('전체 스크립트 복사됨');
                  } else {
                    final buf = StringBuffer();
                    buf.writeln('[$brand] ${current.scenarioName}');
                    buf.writeln('채널: ${current.channel} | 상황: ${current.situation}');
                    for (int i = 0; i < current.steps.length; i++) {
                      buf.writeln('${i + 1}. ${current.steps[i].content}');
                      if (current.steps[i].note.isNotEmpty) {
                        buf.writeln('   메모: ${current.steps[i].note}');
                      }
                    }
                    Clipboard.setData(ClipboardData(text: buf.toString()));
                    _showSnack('스크립트 복사됨');
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'all', child: Text('전체 스크립트 복사')),
                  const PopupMenuItem(value: 'current', child: Text('현재 스크립트 복사')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Text('총 ${scripts.length}건', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5))),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: scripts.length,
                  itemBuilder: (_, i) {
                    final isSelected = i == _selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${i + 1}'),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedIndex = i),
                        selectedColor: cs.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : cs.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(current.scenarioName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _infoBadge('채널', current.channel, cs),
                                const SizedBox(width: 8),
                                _infoBadge('ID', current.id, cs),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('상황: ${current.situation}', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(current.steps.length, (i) {
                        final step = current.steps[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cs.outline.withValues(alpha: 0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(8)),
                                    child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(step.content, style: TextStyle(fontSize: 14, color: cs.onSurface))),
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
                                    onPressed: () => _showEditDialog(context, provider, _selectedIndex, i, step),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.copy_outlined, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: step.content));
                                      _showSnack('복사됨!');
                                    },
                                  ),
                                ],
                              ),
                              if (step.note.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('메모: ${step.note}', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5), fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoBadge(String label, String value, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $value', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
    );
  }

  void _showEditDialog(BuildContext context, AppProvider provider, int scriptIdx, int stepIdx, dynamic step) {
    final cs = Theme.of(context).colorScheme;
    final contentCtrl = TextEditingController(text: step.content);
    final noteCtrl = TextEditingController(text: step.note);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('단계 수정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('단계 ${stepIdx + 1}: ${step.label}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 16),
            TextField(controller: contentCtrl, maxLines: 6, decoration: InputDecoration(labelText: '내용', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 12),
            TextField(controller: noteCtrl, decoration: InputDecoration(labelText: '메모 (선택)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () {
                provider.updateScriptStep(scriptIdx, stepIdx, content: contentCtrl.text, note: noteCtrl.text);
                Navigator.pop(ctx);
                _showSnack('수정됨!');
              },
              child: const Text('저장'),
            )),
          ],
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}