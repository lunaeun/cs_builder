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

  String? lastError;

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

  void clearError() {
    lastError = null;
    notifyListeners();
  }

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
    for (int i = 0; i < _faqs.length; i++) {
      _faqs[i].id = 'FAQ-${(i + 1).toString().padLeft(2, '0')}';
    }
    notifyListeners();
    _saveToHive();
  }

  void updateScriptStep(int scriptIdx, int stepIdx, {String? content, String? note}) {
    if (scriptIdx < 0 || scriptIdx >= _scripts.length) return;
    final script = _scripts[scriptIdx];
    if (stepIdx < 0 || stepIdx >= script.steps.length) return;
    if (content != null) script.steps[stepIdx].content = content;
    if (note != null) script.steps[stepIdx].note = note;
    script.isEdited = true;
    notifyListeners();
  }

  void updateOperationSection(String key, String value) {
    _operationDesign?.updateSection(key, value);
    notifyListeners();
  }

  void addQARecord(QAEvaluationRecord record) {
    _qaRecords.insert(0, record);
    notifyListeners();
    _saveQARecords();
  }

  void toggleActionItem(String id) {
    final idx = _actionItems.indexWhere((a) => a.id == id);
    if (idx >= 0) {
      _actionItems[idx].isCompleted = !_actionItems[idx].isCompleted;
      notifyListeners();
      _saveActionItems();
    }
  }

  Future<void> generateAllDocuments() async {
    _isGenerating = true;
    lastError = null;
    notifyListeners();

    try {
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
      lastError = null;
      notifyListeners();
      await _saveToHive();
    } catch (e) {
      _isGenerating = false;
      lastError = '문서 생성 중 오류가 발생했습니다. 다시 시도해 주세요.';
      notifyListeners();
    }
  }

  Future<Box> _openSecureBox() async {
    try {
      final keyBox = await Hive.openBox('keyBox');
      if (!keyBox.containsKey('encryptionKey')) {
        final key = Hive.generateSecureKey();
        await keyBox.put('encryptionKey', base64UrlEncode(key));
      }
      final encryptionKey = base64Url.decode(keyBox.get('encryptionKey'));
      return await Hive.openBox('cs_builder_secure',
          encryptionCipher: HiveAesCipher(encryptionKey));
    } catch (e) {
      return await Hive.openBox('cs_builder');
    }
  }

  Future<void> _saveToHive() async {
    try {
      final box = await _openSecureBox();
      await box.put('profile', jsonEncode(_profile.toMap()));
      await box.put('isGenerated', _isGenerated);
      await box.put('profileCompleted', _profileCompleted);
      if (_faqs.isNotEmpty) {
        await box.put('faqs', jsonEncode(_faqs.map((f) => f.toMap()).toList()));
      }
    } catch (e) {
      // 저장 실패는 조용히 무시
    }
  }

  Future<void> _saveSettings() async {
    try {
      final box = await _openSecureBox();
      await box.put('isDarkMode', _isDarkMode);
      await box.put('currentPlan', _currentPlan);
      await box.put('aiGenerateCount', _aiGenerateCount);
    } catch (e) {
      // 저장 실패 무시
    }
  }

  Future<void> _saveQARecords() async {
    try {
      final box = await _openSecureBox();
      await box.put('qaRecords', jsonEncode(_qaRecords.map((r) => r.toMap()).toList()));
    } catch (e) {
      // 저장 실패 무시
    }
  }

  Future<void> _saveActionItems() async {
    try {
      final box = await _openSecureBox();
      await box.put('actionItems', jsonEncode(_actionItems.map((a) => a.toMap()).toList()));
    } catch (e) {
      // 저장 실패 무시
    }
  }

  Future<void> loadFromHive() async {
    try {
      final box = await _openSecureBox();
      final profileJson = box.get('profile');
      if (profileJson != null) {
        _profile = BusinessProfile.fromMap(jsonDecode(profileJson));
      }
      _profileCompleted = box.get('profileCompleted', defaultValue: false);
      _isDarkMode = box.get('isDarkMode', defaultValue: false);
      _currentPlan = box.get('currentPlan', defaultValue: 'free');
      _aiGenerateCount = box.get('aiGenerateCount', defaultValue: 0);

      final qaJson = box.get('qaRecords');
      if (qaJson != null) {
        final list = jsonDecode(qaJson) as List;
        _qaRecords = list.map((r) => QAEvaluationRecord.fromMap(r)).toList();
      }

      final actJson = box.get('actionItems');
      if (actJson != null) {
        final list = jsonDecode(actJson) as List;
        _actionItems = list.map((a) => ActionItem.fromMap(a)).toList();
      }

      final wasGenerated = box.get('isGenerated', defaultValue: false);
      if (wasGenerated && _profile.isComplete) {
        final faqsJson = box.get('faqs');
        if (faqsJson != null) {
          final list = jsonDecode(faqsJson) as List;
          _faqs = list.map((f) => FAQItem.fromMap(f)).toList();
        }
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

      await _migrateFromOldBox();
    } catch (e) {
      lastError = '저장된 데이터를 불러오는 중 오류가 발생했습니다';
      notifyListeners();
    }
  }

  Future<void> _migrateFromOldBox() async {
    try {
      if (await Hive.boxExists('cs_builder')) {
        final oldBox = await Hive.openBox('cs_builder');
        if (oldBox.isNotEmpty && !_profileCompleted) {
          final oldProfile = oldBox.get('profile');
          if (oldProfile != null && _profile.companyName.isEmpty) {
            _profile = BusinessProfile.fromMap(jsonDecode(oldProfile));
            _profileCompleted = oldBox.get('profileCompleted', defaultValue: false);
            _isDarkMode = oldBox.get('isDarkMode', defaultValue: false);
            _currentPlan = oldBox.get('currentPlan', defaultValue: 'free');
            _aiGenerateCount = oldBox.get('aiGenerateCount', defaultValue: 0);
            await _saveToHive();
            await _saveSettings();
          }
          await oldBox.clear();
        }
        await oldBox.close();
      }
    } catch (e) {
      // 마이그레이션 실패는 무시
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
    lastError = null;
    try {
      final box = await _openSecureBox();
      await box.clear();
      if (await Hive.boxExists('cs_builder')) {
        final oldBox = await Hive.openBox('cs_builder');
        await oldBox.clear();
        await oldBox.close();
      }
    } catch (e) {
      // 정리 실패 무시
    }
    notifyListeners();
  }
}
