import '../models/generated_documents.dart';

class DocumentExportService {
  // === FAQ Export ===
  static String exportFAQsAsText(List<FAQItem> faqs, String brandName) {
    final buf = StringBuffer();
    buf.writeln('$brandName CS FAQ (${faqs.length}개)');
    buf.writeln('${'=' * 50}\n');
    for (final faq in faqs) {
      buf.writeln('[${faq.id}] [${faq.category}]');
      buf.writeln('Q: ${faq.question}');
      buf.writeln('A: ${faq.answer}');
      buf.writeln('');
    }
    return buf.toString();
  }

  static String exportFAQsForChannelTalk(List<FAQItem> faqs) {
    final buf = StringBuffer();
    for (final faq in faqs) {
      buf.writeln('Q: ${faq.question}');
      buf.writeln('A: ${faq.answer}');
      buf.writeln('---');
    }
    return buf.toString();
  }

  static String exportFAQsAsCSV(List<FAQItem> faqs) {
    final buf = StringBuffer();
    buf.writeln('ID,카테고리,채널,질문,답변');
    for (final faq in faqs) {
      final q = faq.question.replaceAll('"', '""');
      final a = faq.answer.replaceAll('"', '""');
      buf.writeln('"${faq.id}","${faq.category}","${faq.channel}","$q","$a"');
    }
    return buf.toString();
  }

  // === Scripts Export ===
  static String exportScriptsAsText(List<ConsultationScript> scripts, String brandName) {
    final buf = StringBuffer();
    buf.writeln('$brandName 상담 스크립트 (${scripts.length}개 시나리오)');
    buf.writeln('${'=' * 50}\n');
    for (final s in scripts) {
      buf.writeln('[${ s.id}] ${s.scenarioName}');
      buf.writeln('채널: ${s.channel}');
      buf.writeln('상황: ${s.situation}');
      buf.writeln('');
      for (int i = 0; i < s.steps.length; i++) {
        buf.writeln('  ${i + 1}. [${s.steps[i].label}]');
        buf.writeln('     ${s.steps[i].content}');
        if (s.steps[i].note.isNotEmpty) buf.writeln('     * ${s.steps[i].note}');
      }
      buf.writeln('\n${'─' * 40}\n');
    }
    return buf.toString();
  }

  // === Operation Design Export ===
  static String exportOperationDesignAsText(OperationDesign op, String brandName) {
    final buf = StringBuffer();
    buf.writeln('$brandName 고객센터 운영설계서');
    buf.writeln('${'=' * 50}\n');
    final sections = [
      ['1. 개요', op.overview],
      ['2. 시스템 아키텍처', op.systemArchitecture],
      ['3. 채널별 운영 정책', op.channelOperations],
      ['4. IVR 설계', op.ivrDesign],
      ['5. 워크플로우 설계', op.workflowDesign],
      ['6. 상담원 운영', op.agentSchedule],
      ['7. SLA & KPI', op.slaKpi],
      ['8. 에스컬레이션', op.escalationRules],
      ['9. VOC 프로세스', op.vocProcess],
      ['10. 예산', op.budget],
    ];
    for (final s in sections) {
      buf.writeln('\n${'─' * 40}');
      buf.writeln(s[0]);
      buf.writeln('${'─' * 40}');
      buf.writeln(s[1]);
    }
    return buf.toString();
  }

  // === QA Sheet Export ===
  static String exportQASheetAsText(QAEvaluationSheet qa) {
    final buf = StringBuffer();
    buf.writeln(qa.title);
    buf.writeln('${'=' * 50}\n');
    buf.writeln('평가 항목 (각 5점 만점)\n');
    for (int i = 0; i < qa.criteria.length; i++) {
      final c = qa.criteria[i];
      buf.writeln('${i + 1}. ${c.name} (${c.description})');
      for (final g in c.scoreGuide) {
        buf.writeln('   $g');
      }
      buf.writeln('');
    }
    buf.writeln('등급 기준:');
    for (final g in qa.grades) {
      buf.writeln('  $g');
    }
    return buf.toString();
  }

  // === QA Evaluation Records Export ===
  static String exportQARecordsAsCSV(List<QAEvaluationRecord> records, List<String> criteriaNames) {
    final buf = StringBuffer();
    buf.write('날짜,상담원');
    for (final c in criteriaNames) {
      buf.write(',$c');
    }
    buf.writeln(',총점,등급,메모');
    for (final r in records) {
      buf.write('${r.date.toString().substring(0, 10)},${r.agentName}');
      for (final c in criteriaNames) {
        buf.write(',${r.scores[c] ?? 0}');
      }
      final notes = (r.notes ?? '').replaceAll('"', '""');
      buf.writeln(',${r.totalScore},${r.grade},"$notes"');
    }
    return buf.toString();
  }

  // === Full Export (All Documents) ===
  static String exportAllAsText({
    required String brandName,
    required List<FAQItem> faqs,
    required OperationDesign? op,
    required QAEvaluationSheet? qa,
    required List<ConsultationScript> scripts,
  }) {
    final buf = StringBuffer();
    buf.writeln('${'#' * 60}');
    buf.writeln('  $brandName CS/CX 운영 산출물 전체');
    buf.writeln('  생성일: ${DateTime.now().toString().substring(0, 16)}');
    buf.writeln('${'#' * 60}\n\n');

    if (faqs.isNotEmpty) {
      buf.writeln(exportFAQsAsText(faqs, brandName));
      buf.writeln('\n\n');
    }
    if (op != null) {
      buf.writeln(exportOperationDesignAsText(op, brandName));
      buf.writeln('\n\n');
    }
    if (qa != null) {
      buf.writeln(exportQASheetAsText(qa));
      buf.writeln('\n\n');
    }
    if (scripts.isNotEmpty) {
      buf.writeln(exportScriptsAsText(scripts, brandName));
    }
    return buf.toString();
  }
}
