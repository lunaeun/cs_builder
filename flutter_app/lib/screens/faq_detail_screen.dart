import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/upgrade_dialog.dart';

class FAQDetailScreen extends StatefulWidget {
  const FAQDetailScreen({super.key});

  @override
  State<FAQDetailScreen> createState() => _FAQDetailScreenState();
}

class _FAQDetailScreenState extends State<FAQDetailScreen> {
  String _selectedCategory = '전체';
  String _searchQuery = '';
  bool _showSearch = false;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        final allFaqs = provider.faqs;
        final categories = ['전체', ...{...allFaqs.map((f) => f.category)}];
        var filtered = _selectedCategory == '전체' ? allFaqs : allFaqs.where((f) => f.category == _selectedCategory).toList();
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          filtered = filtered.where((f) => f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q)).toList();
        }
        final brand = provider.profile.brandName.isEmpty ? provider.profile.companyName : provider.profile.brandName;

        return Scaffold(
          appBar: AppBar(
            title: _showSearch
                ? TextField(
                    controller: _searchCtrl, autofocus: true,
                    decoration: InputDecoration(hintText: 'Search FAQs...', border: InputBorder.none, filled: false, hintStyle: TextStyle(color: cs.onSurface.withValues(alpha: 0.3))),
                    style: TextStyle(fontSize: 15, color: cs.onSurface),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  )
                : Row(children: [
                    const Text('FAQ'),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(6)),
                      child: Text('${allFaqs.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ]),
            actions: [
              IconButton(
                icon: Icon(_showSearch ? Icons.close_rounded : Icons.search_rounded, size: 20),
                onPressed: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) { _searchCtrl.clear(); _searchQuery = ''; } }),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.ios_share_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.6)),
                onSelected: (val) {
                  if (val == 'copy_text') { UpgradeDialog.show(context, feature: 'FAQ 내보내기', requiredPlan: 'Basic'); }
                  else if (val == 'copy_channeltalk') { UpgradeDialog.show(context, feature: 'ChannelTalk 연동', requiredPlan: 'Pro'); }
                  else if (val == 'copy_csv') { UpgradeDialog.show(context, feature: 'CSV 내보내기', requiredPlan: 'Basic'); }
                },
                itemBuilder: (_) => [
                  _popupItem('copy_text', Icons.text_snippet_rounded, '전체 텍스트'),
                  _popupItem('copy_channeltalk', Icons.chat_rounded, '채널톡 ALF 형식'),
                  _popupItem('copy_csv', Icons.table_chart_rounded, 'CSV 형식'),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Category chips
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final cat = categories.elementAt(i);
                    final isSelected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected ? AppTheme.primaryGradient : null,
                          color: isSelected ? null : cs.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? Colors.transparent : cs.outlineVariant.withValues(alpha: 0.4)),
                          boxShadow: isSelected ? [BoxShadow(color: cs.primary.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))] : [],
                        ),
                        child: Text(cat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : cs.onSurface.withValues(alpha: 0.5))),
                      ),
                    );
                  },
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text('${filtered.length} results found', style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.35))),
                ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.search_off_rounded, size: 48, color: cs.onSurface.withValues(alpha: 0.15)),
                        const SizedBox(height: 8),
                        Text('No results', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.3))),
                      ]))
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: filtered.length,
                        onReorder: (oldIdx, newIdx) {
                          if (_selectedCategory != '전체' || _searchQuery.isNotEmpty) return;
                          provider.reorderFAQs(oldIdx, newIdx);
                        },
                        itemBuilder: (_, i) {
                          final faq = filtered[i];
                          final realIndex = allFaqs.indexOf(faq);
                          return _buildFAQCard(faq, realIndex, provider, cs, key: ValueKey(faq.id));
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFAQCard(dynamic faq, int realIndex, AppProvider provider, ColorScheme cs, {required Key key}) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: faq.isEdited ? cs.primary.withValues(alpha: 0.3) : cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [cs.primary.withValues(alpha: 0.12), cs.primary.withValues(alpha: 0.04)]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(child: Text(faq.id.replaceAll('FAQ-', ''), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: cs.primary))),
          ),
          title: Text(faq.question, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface, height: 1.4)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (faq.isEdited) Container(
              width: 6, height: 6,
              decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.3)),
          ]),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _badge(faq.category, AppTheme.success, AppTheme.successLight),
                    if (faq.channel != '전체') ...[const SizedBox(width: 6), _badge(faq.channel, cs.primary, cs.primary.withValues(alpha: 0.08))],
                    const Spacer(),
                    _actionBtn(Icons.edit_rounded, '편집', cs.primary, () => _showEditDialog(realIndex, faq, provider, cs)),
                    _actionBtn(Icons.content_copy_rounded, '복사', cs.onSurface.withValues(alpha: 0.4), () {
                      Clipboard.setData(ClipboardData(text: 'Q: ${faq.question}\nA: ${faq.answer}'));
                      _showSnack('FAQ copied');
                    }),
                    if (faq.isEdited)
                      _actionBtn(Icons.undo_rounded, 'Revert', AppTheme.warning, () => provider.resetFAQ(realIndex)),
                  ]),
                  const SizedBox(height: 10),
                  SelectableText(faq.answer, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.6), height: 1.7)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.w600)),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }

  PopupMenuItem<String> _popupItem(String value, IconData icon, String label) {
    return PopupMenuItem(value: value, child: Row(children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)]));
  }

  void _showEditDialog(int index, dynamic faq, AppProvider provider, ColorScheme cs) {
    final answerCtrl = TextEditingController(text: faq.answer);
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('FAQ 답변 수정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
            const SizedBox(height: 6),
            Text(faq.question, style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.4))),
            const SizedBox(height: 16),
            TextField(controller: answerCtrl, maxLines: 8, decoration: InputDecoration(hintText: '답변을 수정하세요', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(14)),
                child: ElevatedButton(
                  onPressed: () { provider.updateFAQ(index, answer: answerCtrl.text); Navigator.pop(ctx); _showSnack('FAQ updated'); },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                  child: const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)));
  }
}
