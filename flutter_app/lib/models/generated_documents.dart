class FAQItem {
  String id;
  String category;
  String question;
  String answer;
  String channel;
  bool isEdited;
  DateTime? lastEditedAt;
  String? originalAnswer;

  FAQItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.channel = '전체',
    this.isEdited = false,
    this.lastEditedAt,
    this.originalAnswer,
  });

  void updateAnswer(String newAnswer) {
    originalAnswer ??= answer;
    answer = newAnswer;
    isEdited = true;
    lastEditedAt = DateTime.now();
  }

  void resetToOriginal() {
    if (originalAnswer != null) {
      answer = originalAnswer!;
      isEdited = false;
      lastEditedAt = null;
      originalAnswer = null;
    }
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'category': category, 'question': question, 'answer': answer,
    'channel': channel, 'isEdited': isEdited,
    'lastEditedAt': lastEditedAt?.toIso8601String(),
    'originalAnswer': originalAnswer,
  };

  factory FAQItem.fromMap(Map<String, dynamic> map) => FAQItem(
    id: map['id'] ?? '', category: map['category'] ?? '',
    question: map['question'] ?? '', answer: map['answer'] ?? '',
    channel: map['channel'] ?? '전체', isEdited: map['isEdited'] ?? false,
    lastEditedAt: map['lastEditedAt'] != null ? DateTime.tryParse(map['lastEditedAt']) : null,
    originalAnswer: map['originalAnswer'],
  );
}

class QAEvaluationSheet {
  final String title;
  final List<QACriteria> criteria;
  final List<String> grades;

  QAEvaluationSheet({required this.title, required this.criteria, required this.grades});
}

class QACriteria {
  final String name;
  final String description;
  final List<String> scoreGuide;

  QACriteria({required this.name, required this.description, required this.scoreGuide});
}

class QAEvaluationRecord {
  final String id;
  final DateTime date;
  final String agentName;
  final Map<String, int> scores; // criteriaName -> score(1-5)
  final String? notes;

  QAEvaluationRecord({
    required this.id, required this.date, required this.agentName,
    required this.scores, this.notes,
  });

  int get totalScore => scores.values.fold(0, (a, b) => a + b);
  int get maxScore => scores.length * 5;
  double get percentage => maxScore > 0 ? totalScore / maxScore * 100 : 0;

  String get grade {
    final total = totalScore;
    if (total >= 22) return '우수';
    if (total >= 18) return '양호';
    if (total >= 14) return '개선필요';
    return '집중코칭';
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'date': date.toIso8601String(), 'agentName': agentName,
    'scores': scores, 'notes': notes,
  };

  factory QAEvaluationRecord.fromMap(Map<String, dynamic> map) => QAEvaluationRecord(
    id: map['id'] ?? '', date: DateTime.parse(map['date']),
    agentName: map['agentName'] ?? '',
    scores: Map<String, int>.from(map['scores'] ?? {}),
    notes: map['notes'],
  );
}

class ConsultationScript {
  final String id;
  String scenarioName;
  String channel;
  String situation;
  List<ScriptStep> steps;
  bool isEdited;

  ConsultationScript({
    required this.id, required this.scenarioName, required this.channel,
    required this.situation, required this.steps, this.isEdited = false,
  });
}

class ScriptStep {
  String label;
  String content;
  String note;

  ScriptStep({required this.label, required this.content, this.note = ''});
}

class OperationDesign {
  String overview;
  String systemArchitecture;
  String ivrDesign;
  String workflowDesign;
  String agentSchedule;
  String channelOperations;
  String slaKpi;
  String escalationRules;
  String vocProcess;
  String budget;
  Map<String, bool> editedSections;

  OperationDesign({
    required this.overview, required this.systemArchitecture,
    required this.ivrDesign, required this.workflowDesign,
    required this.agentSchedule, required this.channelOperations,
    required this.slaKpi, required this.escalationRules,
    required this.vocProcess, required this.budget,
    Map<String, bool>? editedSections,
  }) : editedSections = editedSections ?? {};

  String getSection(String key) {
    switch (key) {
      case 'overview': return overview;
      case 'systemArchitecture': return systemArchitecture;
      case 'ivrDesign': return ivrDesign;
      case 'workflowDesign': return workflowDesign;
      case 'agentSchedule': return agentSchedule;
      case 'channelOperations': return channelOperations;
      case 'slaKpi': return slaKpi;
      case 'escalationRules': return escalationRules;
      case 'vocProcess': return vocProcess;
      case 'budget': return budget;
      default: return '';
    }
  }

  void updateSection(String key, String value) {
    switch (key) {
      case 'overview': overview = value; break;
      case 'systemArchitecture': systemArchitecture = value; break;
      case 'ivrDesign': ivrDesign = value; break;
      case 'workflowDesign': workflowDesign = value; break;
      case 'agentSchedule': agentSchedule = value; break;
      case 'channelOperations': channelOperations = value; break;
      case 'slaKpi': slaKpi = value; break;
      case 'escalationRules': escalationRules = value; break;
      case 'vocProcess': vocProcess = value; break;
      case 'budget': budget = value; break;
    }
    editedSections[key] = true;
  }
}

enum DocumentStatus { pending, generating, generated, error }

class GeneratedDocument {
  final String type;
  final String title;
  final String subtitle;
  final String iconName;
  DocumentStatus status;
  String? content;

  GeneratedDocument({
    required this.type, required this.title, required this.subtitle,
    required this.iconName, this.status = DocumentStatus.pending, this.content,
  });
}

/// Checklist action items for dashboard
class ActionItem {
  final String id;
  final String title;
  final String description;
  final String documentType;
  final String actionLabel;
  bool isCompleted;

  ActionItem({
    required this.id, required this.title, required this.description,
    required this.documentType, required this.actionLabel, this.isCompleted = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'description': description,
    'documentType': documentType, 'actionLabel': actionLabel,
    'isCompleted': isCompleted,
  };

  factory ActionItem.fromMap(Map<String, dynamic> map) => ActionItem(
    id: map['id'] ?? '', title: map['title'] ?? '',
    description: map['description'] ?? '', documentType: map['documentType'] ?? '',
    actionLabel: map['actionLabel'] ?? '', isCompleted: map['isCompleted'] ?? false,
  );
}

/// Industry preset for quick onboarding
class IndustryPreset {
  final String industry;
  final bool phone;
  final bool channelTalk;
  final bool email;
  final bool sns;
  final bool board;
  final bool kakao;
  final bool naver;
  final bool instaDm;
  final int recommendedAgents;
  final int recommendedBudget;
  final int estimatedDailyCalls;

  const IndustryPreset({
    required this.industry, this.phone = true, this.channelTalk = true,
    this.email = false, this.sns = true, this.board = true,
    this.kakao = true, this.naver = false, this.instaDm = false,
    this.recommendedAgents = 1, this.recommendedBudget = 500000,
    this.estimatedDailyCalls = 50,
  });

  static const Map<String, IndustryPreset> presets = {
    '자동차/튜닝': IndustryPreset(
      industry: '자동차/튜닝', phone: true, channelTalk: true, email: false,
      sns: true, board: true, kakao: true, instaDm: true,
      recommendedAgents: 2, recommendedBudget: 700000, estimatedDailyCalls: 40,
    ),
    '음식/외식': IndustryPreset(
      industry: '음식/외식', phone: true, channelTalk: false, email: false,
      sns: true, board: false, kakao: true, instaDm: true,
      recommendedAgents: 1, recommendedBudget: 300000, estimatedDailyCalls: 30,
    ),
    '뷰티/미용': IndustryPreset(
      industry: '뷰티/미용', phone: true, channelTalk: true, email: false,
      sns: true, board: false, kakao: true, naver: true, instaDm: true,
      recommendedAgents: 1, recommendedBudget: 400000, estimatedDailyCalls: 25,
    ),
    'IT/전자': IndustryPreset(
      industry: 'IT/전자', phone: true, channelTalk: true, email: true,
      sns: false, board: true, kakao: false,
      recommendedAgents: 2, recommendedBudget: 800000, estimatedDailyCalls: 60,
    ),
    '패션/의류': IndustryPreset(
      industry: '패션/의류', phone: false, channelTalk: true, email: false,
      sns: true, board: true, kakao: true, instaDm: true,
      recommendedAgents: 1, recommendedBudget: 400000, estimatedDailyCalls: 35,
    ),
    '건강/의료': IndustryPreset(
      industry: '건강/의료', phone: true, channelTalk: true, email: true,
      sns: true, board: false, kakao: true, naver: true,
      recommendedAgents: 2, recommendedBudget: 600000, estimatedDailyCalls: 45,
    ),
    '교육/학습': IndustryPreset(
      industry: '교육/학습', phone: true, channelTalk: true, email: true,
      sns: true, board: true, kakao: true,
      recommendedAgents: 2, recommendedBudget: 500000, estimatedDailyCalls: 40,
    ),
    '인테리어/가구': IndustryPreset(
      industry: '인테리어/가구', phone: true, channelTalk: true, email: false,
      sns: true, board: true, kakao: true, instaDm: true,
      recommendedAgents: 1, recommendedBudget: 500000, estimatedDailyCalls: 30,
    ),
    '반려동물': IndustryPreset(
      industry: '반려동물', phone: true, channelTalk: true, email: false,
      sns: true, board: false, kakao: true, instaDm: true,
      recommendedAgents: 1, recommendedBudget: 400000, estimatedDailyCalls: 30,
    ),
    '스포츠/레저': IndustryPreset(
      industry: '스포츠/레저', phone: true, channelTalk: false, email: false,
      sns: true, board: true, kakao: true, instaDm: true,
      recommendedAgents: 1, recommendedBudget: 400000, estimatedDailyCalls: 25,
    ),
  };
}
