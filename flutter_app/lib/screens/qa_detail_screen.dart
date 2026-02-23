import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/generated_documents.dart';
import '../services/export_service.dart';

class QADetailScreen extends StatefulWidget {
  const QADetailScreen({super.key});

  @override
  State<QADetailScreen> createState() => _QADetailScreenState();
}

class _QADetailScreenState extends State<QADetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final qa = provider.qaSheet;
        if (qa == null) return Scaffold(body: Center(child: Text('생성된 문서가 없습니다.', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.4)))));

        return Scaffold(
          appBar: AppBar(
            title: const Text('QA 평가'),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
                onSelected: (val) {
                  if (val == 'copy_sheet') {
                    final text = DocumentExportService.exportQASheetAsText(qa);
                    Clipboard.setData(ClipboardData(text: text));
                    _showSnack('QA 평가 시트가 복사되었습니다');
                  } else if (val == 'copy_records') {
                    final names = qa.criteria.map((c) => c.name).toList();
                    final text = DocumentExportService.exportQARecordsAsCSV(provider.qaRecords, names);
                    Clipboard.setData(ClipboardData(text: text));
                    _showSnack('평가 기록이 CSV로 복사되었습니다');
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'copy_sheet', child: Row(children: [Icon(Icons.content_copy, size: 16), SizedBox(width: 8), Text('평가 시트 복사')])),
                  if (provider.qaRecords.isNotEmpty)
                    const PopupMenuItem(value: 'copy_records', child: Row(children: [Icon(Icons.table_chart, size: 16), SizedBox(width: 8), Text('평가 기록 CSV 복사')])),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: '평가 기준'), Tab(text: '평가 기록')],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildCriteriaTab(qa, cs),
              _buildRecordsTab(provider, qa, cs),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showNewEvaluationDialog(provider, qa, cs),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('새 평가'),
          ),
        );
      },
    );
  }

  Widget _buildCriteriaTab(QAEvaluationSheet qa, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(qa.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
            const SizedBox(height: 4),
            Text('매주 금요일 15:00~16:00 상호 모니터링', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
          ]),
        ),
        const SizedBox(height: 16),
        Text('평가 항목 (각 5점 만점)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 10),
        ...qa.criteria.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: cs.outlineVariant)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                leading: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Center(child: Text('${i + 1}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.primary))),
                ),
                title: Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                subtitle: Text(c.description, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
                children: [
                  ...c.scoreGuide.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 6, height: 6, margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.4), shape: BoxShape.circle)),
                      Expanded(child: Text(g, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5), height: 1.5))),
                    ]),
                  )),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text('등급 기준', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: cs.outlineVariant)),
          child: Column(
            children: qa.grades.asMap().entries.map((e) {
              final colors = [const Color(0xFF10B981), cs.primary, const Color(0xFFF59E0B), const Color(0xFFEF4444)];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[e.key], shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Text(e.value, style: TextStyle(fontSize: 13, color: cs.onSurface)),
                ]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsTab(AppProvider provider, QAEvaluationSheet qa, ColorScheme cs) {
    final records = provider.qaRecords;

    if (records.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.grading_rounded, size: 64, color: cs.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text('아직 평가 기록이 없습니다', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.4))),
          const SizedBox(height: 8),
          Text('아래 "새 평가" 버튼을 눌러 시작하세요', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.3))),
        ]),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
      children: [
        // Summary stats
        if (records.length >= 2) ...[
          _buildRecordsSummary(records, cs),
          const SizedBox(height: 16),
        ],
        Text('평가 이력 (${records.length}건)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 10),
        ...records.map((r) => _buildRecordCard(r, qa, cs)),
      ],
    );
  }

  Widget _buildRecordsSummary(List<QAEvaluationRecord> records, ColorScheme cs) {
    final avgScore = records.map((r) => r.percentage).reduce((a, b) => a + b) / records.length;
    final latestGrade = records.first.grade;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withValues(alpha: 0.08), cs.primary.withValues(alpha: 0.02)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        Expanded(child: Column(children: [
          Text('평균 점수', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text('${avgScore.toStringAsFixed(1)}%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: cs.primary)),
        ])),
        Container(width: 1, height: 40, color: cs.outlineVariant),
        Expanded(child: Column(children: [
          Text('최근 등급', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text(latestGrade, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _gradeColor(latestGrade, cs))),
        ])),
        Container(width: 1, height: 40, color: cs.outlineVariant),
        Expanded(child: Column(children: [
          Text('총 평가', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
          const SizedBox(height: 4),
          Text('${records.length}건', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ])),
      ]),
    );
  }

  Widget _buildRecordCard(QAEvaluationRecord record, QAEvaluationSheet qa, ColorScheme cs) {
    final gradeColor = _gradeColor(record.grade, cs);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: cs.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: gradeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(record.grade, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gradeColor)),
            ),
            const SizedBox(width: 8),
            Text(record.agentName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
            const Spacer(),
            Text(record.date.toString().substring(0, 10), style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.4))),
          ]),
          const SizedBox(height: 10),
          // Score bars
          ...record.scores.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              SizedBox(width: 70, child: Text(e.key, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: e.value / 5,
                    backgroundColor: cs.outlineVariant,
                    color: e.value >= 4 ? const Color(0xFF10B981) : (e.value >= 3 ? cs.primary : const Color(0xFFF59E0B)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text('${e.value}/5', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.5))),
            ]),
          )),
          const SizedBox(height: 6),
          Row(children: [
            Text('총점: ${record.totalScore}/${record.maxScore}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(width: 8),
            Text('(${record.percentage.toStringAsFixed(0)}%)', style: TextStyle(fontSize: 12, color: cs.primary, fontWeight: FontWeight.w600)),
          ]),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(6)),
              child: Text(record.notes!, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4)),
            ),
          ],
        ],
      ),
    );
  }

  void _showNewEvaluationDialog(AppProvider provider, QAEvaluationSheet qa, ColorScheme cs) {
    final agentCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final scores = <String, int>{};
    for (final c in qa.criteria) {
      scores[c.name] = 3;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final totalScore = scores.values.fold(0, (a, b) => a + b);
            final maxScore = scores.length * 5;
            final pct = maxScore > 0 ? totalScore / maxScore * 100 : 0.0;
            String grade = '집중코칭';
            if (totalScore >= 22) grade = '우수';
            else if (totalScore >= 18) grade = '양호';
            else if (totalScore >= 14) grade = '개선필요';

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (ctx, scrollCtrl) {
                return Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 20),
                  child: ListView(
                    controller: scrollCtrl,
                    children: [
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)))),
                      const SizedBox(height: 16),
                      Text('새 QA 평가', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: agentCtrl,
                        decoration: InputDecoration(labelText: '상담원 이름', prefixIcon: const Icon(Icons.person_rounded, size: 18),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      const SizedBox(height: 20),
                      // Score sliders
                      ...qa.criteria.map((c) {
                        final score = scores[c.name] ?? 3;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: cs.surfaceContainerHighest.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(10)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Text(c.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: score >= 4 ? const Color(0xFF10B981).withValues(alpha: 0.1) : (score >= 3 ? cs.primary.withValues(alpha: 0.1) : const Color(0xFFF59E0B).withValues(alpha: 0.1)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('$score점', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                                  color: score >= 4 ? const Color(0xFF10B981) : (score >= 3 ? cs.primary : const Color(0xFFF59E0B)))),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Text(c.description, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.4))),
                            Slider(
                              value: score.toDouble(), min: 1, max: 5, divisions: 4,
                              activeColor: cs.primary,
                              onChanged: (v) => setSheetState(() => scores[c.name] = v.round()),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text('1점', style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.3))),
                              Text('5점', style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.3))),
                            ]),
                          ]),
                        );
                      }),
                      // Total preview
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [cs.primary.withValues(alpha: 0.08), cs.primary.withValues(alpha: 0.02)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('합계: $totalScore/$maxScore', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
                            Text('${pct.toStringAsFixed(0)}%', style: TextStyle(fontSize: 13, color: cs.primary)),
                          ])),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: _gradeColor(grade, cs).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: Text(grade, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _gradeColor(grade, cs))),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: notesCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(labelText: '메모 (선택)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(width: double.infinity, child: ElevatedButton(
                        onPressed: () {
                          if (agentCtrl.text.isEmpty) {
                            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('상담원 이름을 입력해 주세요'), behavior: SnackBarBehavior.floating));
                            return;
                          }
                          final record = QAEvaluationRecord(
                            id: 'QA-${DateTime.now().millisecondsSinceEpoch}',
                            date: DateTime.now(),
                            agentName: agentCtrl.text,
                            scores: Map.from(scores),
                            notes: notesCtrl.text.isEmpty ? null : notesCtrl.text,
                          );
                          provider.addQARecord(record);
                          Navigator.pop(ctx);
                          _tabController.animateTo(1);
                          _showSnack('평가가 저장되었습니다 (${record.grade})');
                        },
                        child: const Text('평가 저장'),
                      )),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Color _gradeColor(String grade, ColorScheme cs) {
    switch (grade) {
      case '우수': return const Color(0xFF10B981);
      case '양호': return cs.primary;
      case '개선필요': return const Color(0xFFF59E0B);
      default: return const Color(0xFFEF4444);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}
