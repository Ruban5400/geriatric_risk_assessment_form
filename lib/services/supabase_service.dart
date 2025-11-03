// lib/services/supabase_service.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/patient_history.dart';      // AnswersProvider
import '../providers/assessment_score.dart';     // AssessmentScoreProvider
import '../providers/patient_info.dart';         // PatientProvider

final _supabase = Supabase.instance.client;

/// Single-row upload: stores patient details + QA array in `qa` jsonb column.
Future<bool> uploadAssessmentSingleRow({
  required BuildContext context,
  required int maxScore,
  Map<String, dynamic>? extraMetadata,
}) async {
  try {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final answersProvider = Provider.of<AnswersProvider>(context, listen: false);
    final scoreProvider = Provider.of<AssessmentScoreProvider>(context, listen: false);

    final Map<String, dynamic> answersMap = answersProvider.answers; // questionText -> String | List<String>
    final Map<String, int> scoresMap = scoreProvider.selectedScoresSnapshot; // questionId/text -> score

    // Build qa array
    final List<Map<String, dynamic>> qa = [];

    answersMap.forEach((questionKey, answerValue) {
      // Use stable id if available; fallback to questionKey (text)
      final String questionId = questionKey; // replace with id if you added one

      final bool isMulti = answerValue is List;
      final selectedAnswer = !isMulti && answerValue != null ? answerValue.toString() : null;
      final selectedAnswers = isMulti ? List.from(answerValue) : null;
      final int? ansScore = scoresMap[questionId] ?? scoresMap[questionKey];

      qa.add({
        'question_id': questionId,
        'question_text': questionKey,
        'question_type': isMulti ? 'multi' : (ansScore != null ? 'scored' : 'single'),
        'selected_answer': selectedAnswer,
        'selected_answers': selectedAnswers,
        'answer_score': ansScore,
      });
    });

    // Ensure scored-only items are included even if not present in answersMap
    scoresMap.forEach((qKey, qScore) {
      if (!answersMap.containsKey(qKey)) {
        qa.add({
          'question_id': qKey,
          'question_text': qKey,
          'question_type': 'scored',
          'selected_answer': null,
          'selected_answers': null,
          'answer_score': qScore,
        });
      }
    });

    final Map<String, dynamic> row = {
      'user_name': patientProvider.userName,
      'user_empid': patientProvider.empId,
      'patient_name': patientProvider.patientName,
      'patient_age': patientProvider.age,
      'patient_gender': patientProvider.gender,
      'ip_no': patientProvider.ipNo,
      'unit': patientProvider.unit,
      'mobile_no': patientProvider.mobileNo,
      'address': patientProvider.address,
      'education': patientProvider.education,
      'comorbidity': patientProvider.comorbidity,
      'diagnosis': patientProvider.diagnosis,

      'qa': qa, // Supabase client will serialize List/Map to jsonb
      'total_score': scoreProvider.totalScore,
      'max_score': maxScore,
      'metadata': extraMetadata ?? {'uploaded_from': 'flutter_app'},
    };

    final inserted = await _supabase.from('geriatric_fall_risk_assessment_form').insert(row).select().single();
    debugPrint('Inserted assessment id: ${inserted?['id']}');
    return inserted != null;
  } catch (e, st) {
    debugPrint('uploadAssessmentSingleRow error: $e\n$st');
    return false;
  }
}


// for reading the values from supabase
// final res = await Supabase.instance.client
//     .from('assessments')
// .select()
//     .order('created_at', ascending: false)
//     .limit(1)
//     .single();
//
// final List<dynamic> qa = res['qa'] as List<dynamic>;
// for (final item in qa) {
// final Map<String, dynamic> q = Map<String, dynamic>.from(item);
// print('Question: ${q['question_text']}, selected: ${q['selected_answer'] ?? q['selected_answers']}, score: ${q['answer_score']}');
// }
