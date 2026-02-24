import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/business_profile.dart';
import '../models/generated_documents.dart';
import '../services/document_generator_service.dart';

class AppProvider extends ChangeNotifier {
  BusinessProfile _profile = BusinessProfile();
  List<FAQItem> _faqs = [];
  QAEvaluationSheet? _qaSheet;
  List<ConsultationScript> _scripts = [];
  OperationDesign? _operationDesign;
  List<QAEvaluationRecord> _qaRecords = [];
  List<ActionItem> _actionItems = [];
  bool _isGenerated = false;
  bool _isGenerating = false;
  bool _profileCompleted = false;
  bool _isDarkMode = false;
  String _currentPlan = 'free';
  int _aiGenerateCount = 0;
  BusinessProfile get profile => _profile;
  List<FAQItem> get faqs => _faqs;
  QAEvaluationSheet? get qaSheet => _qaSheet;
  List<ConsultationScript> get scripts => _scripts;
  OperationDesign? get operationDesign => _operationDesign;
  List<QAEvaluationRecord> get qaRecords => _qaRecords;
  List<ActionItem> get actionItems => _actionItems;
  bool get isGenerated => _isGenerated;
  bool get isGenerating => _isGenerating;
  bool get profileCompleted => _profileCompleted;
  bool get isDarkMode => _isDarkMode;
  String get currentPlan => _currentPlan;
  int get aiGenerateCount => _aiGenerateCount;

  // 플랜별 기능 체크
  bool get canDownload => _currentPlan != 'free';
  bool get canExportCSV => _currentPlan != 'free';
  bool get canUseQA => _currentPlan == 'pro' || _currentPlan == 'business';
  bool get canUseIVR => _currentPlan == 'pro' || _currentPlan == 'business';
  bool get canUseTeam => _currentPlan == 'business';
  bool get isUnlimitedAI => _currentPlan == 'pro' || _currentPlan == 'business';

  int get aiGenerateLimit {
    switch (_currentPlan) {
      case 'basic': return 30;
      case 'pro': case 'business': return 999999;
      default: return 3;
    }
  }

  bool get canGenerate => _aiGenerateCount < aiGenerateLimit;

  String get requiredPlanForDownload => 'Basic';
  String get requiredPlanForQA => 'Pro';
  String get requiredPlanForIVR => 'Pro';
  String get requiredPlanForTeam => 'Business';

  void updatePlan(String planId) {
    _currentPlan = planId;
    notifyListeners();
    _saveSettings();
  }

  void incrementAICount() {
    _aiGenerateCount++;
    notifyListeners();
    _saveSettings();
  }

  // Completion progress (0.0 ~ 1.0)
  double get completionProgress {
    if (_actionItems.isEmpty) return 0.0;
    final done = _actionItems.where((a) => a.isCompleted).length;
    return done / _actionItems.length;
  }

  int get completedActionCount => _actionItems.where((a) => a.isCompleted).length;

  List<GeneratedDocument> get documents => [
    GeneratedDocument(type: 'faq', title: 'CS FAQ', subtitle: '${_faqs.length}개 항목 (업종 맞춤)', iconName: 'quiz',
      status: _faqs.isNotEmpty ? DocumentStatus.generated : (_isGenerating ? DocumentStatus.generating : DocumentStatus.pending)),
    GeneratedDocument(type: 'operation', title: '운영설계서', subtitle: '채널별 운영 가이드', iconName: 'architecture',
      status: _operationDesign != null ? DocumentStatus.generated : (_isGenerating ? DocumentStatus.generating : DocumentStatus.pending)),
    GeneratedDocument(type: 'qa', title: 'QA 평가 시트', subtitle: '상담 품질 관리${_qaRecords.isNotEmpty ? " (${_qaRecords.length}건 평가)" : ""}', iconName: 'grading',
      status: _qaSheet != null ? DocumentStatus.generated : (_isGenerating ? DocumentStatus.generating : DocumentStatus.pending)),
    GeneratedDocument(type: 'scripts', title: '상담 스크립트', subtitle: '${_scripts.length}개 시나리오', iconName: 'description',
      status: _scripts.isNotEmpty ? DocumentStatus.generated : (_isGenerating ? DocumentStatus.generating : DocumentStatus.pending)),
  ];

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _saveSettings();
  }

  void updateProfile(BusinessProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void setProfileCompleted(bool value) {
    _profileCompleted = value;
    notifyListeners();
  }

  // === FAQ editing ===
  void updateFAQ(int index, {String? question, String? answer}) {
    if (index < 0 || index >= _faqs.length) return;
    if (answer != null) _faqs[index].updateAnswer(answer);
    if (question != null) _faqs[index].question = question;
    notifyListeners();
    _saveToHive();
  }

  void resetFAQ(int index) {
    if (index < 0 || index >= _faqs.length) return;
    _faqs[index].resetToOriginal();
    notifyListeners();
    _saveToHive();
  }

  void reorderFAQs(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _faqs.removeAt(oldIndex);
    _faqs.insert(newIndex, item);
    // Renumber
    for (int i = 0; i < _faqs.length; i++) {
      _faqs[i].id = 'FAQ-${(i + 1).toString().padLeft(2, '0')}';
    }
    notifyListeners();
    _saveToHive();
  }

  // === Script editing ===
  void updateScriptStep(int scriptIdx, int stepIdx, {String? content, String? note}) {
    if (scriptIdx < 0 || scriptIdx >= _scripts.length) return;
    final script = _scripts[scriptIdx];
    if (stepIdx < 0 || stepIdx >= script.steps.length) return;
    if (content != null) script.steps[stepIdx].content = content;
    if (note != null) script.steps[stepIdx].note = note;
    script.isEdited = true;
    notifyListeners();
  }

  // === Operation Design editing ===
  void updateOperationSection(String key, String value) {
    _operationDesign?.updateSection(key, value);
    notifyListeners();
  }

  // === QA Evaluation ===
  void addQARecord(QAEvaluationRecord record) {
    _qaRecords.insert(0, record);
    notifyListeners();
    _saveQARecords();
  }

  // === Action Items ===
  void toggleActionItem(String id) {
    final idx = _actionItems.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      _actionItems[idx].isCompleted = !_actionItems[idx].isCompleted;
      notifyListeners();
      _saveActionItems();
    }
  }

  // === Document Generation ===
  Future<void> generateAllDocuments() async {
    _isGenerating = true;
    notifyListeners();

    if (_profile.agentRoles.isEmpty) {
      _profile.agentRoles = _profile.generateDefaultRoles();
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _faqs = DocumentGeneratorService.generateFAQ(_profile);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    _operationDesign = DocumentGeneratorService.generateOperationDesign(_profile);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _qaSheet = DocumentGeneratorService.generateQASheet(_profile);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _scripts = DocumentGeneratorService.generateScripts(_profile);
    notifyListeners();

    _actionItems = DocumentGeneratorService.generateActionItems(_profile);

    _isGenerating = false;
    _isGenerated = true;
    notifyListeners();
    await _saveToHive();
  }

  // === Persistence ===
  Future<void> _saveToHive() async {
    final box = await Hive.openBox('cs_builder');
    await box.put('profile', jsonEncode(_profile.toMap()));
    await box.put('isGenerated', _isGenerated);
    await box.put('profileCompleted', _profileCompleted);
    if (_faqs.isNotEmpty) {
      await box.put('faqs', jsonEncode(_faqs.map((f) => f.toMap()).toList()));
    }
  }

Future<void> _saveSettings() async {
    final box = await Hive.openBox('cs_builder');
    await box.put('isDarkMode', _isDarkMode);
    await box.put('currentPlan', _currentPlan);
    await box.put('aiGenerateCount', _aiGenerateCount);
  }
  Future<void> _saveQARecords() async {
    final box = await Hive.openBox('cs_builder');
    await box.put('qaRecords', jsonEncode(_qaRecords.map((r) => r.toMap()).toList()));
  }

  Future<void> _saveActionItems() async {
    final box = await Hive.openBox('cs_builder');
    await box.put('actionItems', jsonEncode(_actionItems.map((a) => a.toMap()).toList()));
  }

  Future<void> loadFromHive() async {
    final box = await Hive.openBox('cs_builder');
    final profileJson = box.get('profile');
    if (profileJson != null) {
      _profile = BusinessProfile.fromMap(jsonDecode(profileJson));
    }
    _profileCompleted = box.get('profileCompleted', defaultValue: false);
    _isDarkMode = box.get('isDarkMode', defaultValue: false);
    _currentPlan = box.get('currentPlan', defaultValue: 'free');
    _aiGenerateCount = box.get('aiGenerateCount', defaultValue: 0);
    // Load QA records
    final qaJson = box.get('qaRecords');
    if (qaJson != null) {
      final list = jsonDecode(qaJson) as List;
      _qaRecords = list.map((r) => QAEvaluationRecord.fromMap(r)).toList();
    }

    // Load action items
    final actJson = box.get('actionItems');
    if (actJson != null) {
      final list = jsonDecode(actJson) as List;
      _actionItems = list.map((a) => ActionItem.fromMap(a)).toList();
    }

    final wasGenerated = box.get('isGenerated', defaultValue: false);
    if (wasGenerated && _profile.isComplete) {
      // Try to load cached FAQs first
      final faqsJson = box.get('faqs');
      if (faqsJson != null) {
        final list = jsonDecode(faqsJson) as List;
        _faqs = list.map((f) => FAQItem.fromMap(f)).toList();
      }
      // Regenerate non-cached documents
      if (_profile.agentRoles.isEmpty) {
        _profile.agentRoles = _profile.generateDefaultRoles();
      }
      _operationDesign = DocumentGeneratorService.generateOperationDesign(_profile);
      _qaSheet = DocumentGeneratorService.generateQASheet(_profile);
      _scripts = DocumentGeneratorService.generateScripts(_profile);
      if (_faqs.isEmpty) {
        _faqs = DocumentGeneratorService.generateFAQ(_profile);
      }
      if (_actionItems.isEmpty) {
        _actionItems = DocumentGeneratorService.generateActionItems(_profile);
      }
      _isGenerated = true;
      notifyListeners();
    }
  }

  void resetAll() async {
    _profile = BusinessProfile();
    _faqs = [];
    _qaSheet = null;
    _scripts = [];
    _operationDesign = null;
    _qaRecords = [];
    _actionItems = [];
    _isGenerated = false;
    _isGenerating = false;
    _profileCompleted = false;
    final box = await Hive.openBox('cs_builder');
    await box.clear();
    notifyListeners();
  }
}
