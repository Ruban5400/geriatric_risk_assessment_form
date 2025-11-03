import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/questions.dart';         // questions list
import '../data/questions_score.dart';   // scored questions list
import '../providers/patient_history.dart';      // AnswersProvider
import '../providers/assessment_score.dart';     // AssessmentScoreProvider
import '../providers/patient_info.dart';         // PatientProvider
import '../models/patient_questions.dart';       // PatientQuestions / PatientQuestionScore

class ViewDetails extends StatelessWidget {
  final int score;
  final int maxScore;

  const ViewDetails({
    Key? key,
    required this.score,
    required this.maxScore,
  }) : super(key: key);

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isNotEmpty ? value : '-', style: const TextStyle())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final answersProvider = Provider.of<AnswersProvider>(context);
    final scoreProvider = Provider.of<AssessmentScoreProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 173, 23, 143),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== PATIENT INFO CARD =====
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Patient Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const Divider(),
                          _infoRow('Name', patientProvider.patientName),
                          _infoRow('Age', patientProvider.age),
                          _infoRow('Gender', patientProvider.gender),
                          _infoRow('IP No.', patientProvider.ipNo),
                          _infoRow('Unit', patientProvider.unit),
                          _infoRow('Mobile No.', patientProvider.mobileNo),
                          _infoRow('Address', patientProvider.address),
                          _infoRow('Education', patientProvider.education),
                          _infoRow('Comorbidity', patientProvider.comorbidity),
                          _infoRow('Diagnosis', patientProvider.diagnosis),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _infoRow('Assessed by', patientProvider.userName)),
                              const SizedBox(width: 12),
                              Expanded(child: _infoRow('Emp ID', patientProvider.empId)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ===== HEADER: SCORE SUMMARY =====
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Score', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('$score / $maxScore', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 173, 23, 143)),
                            onPressed: () {
                              // optional: export/share
                            },
                            child: const Text('Save / Share'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== QUESTIONS & ANSWERS SECTION =====
                  const Text('Questions & Answers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    itemBuilder: (ctx, qIndex) {
                      final PatientQuestions q = questions[qIndex];
                      final dynamic selected = answersProvider.getAnswer(q.question);
                      final bool isMulti = q.isMultiSelect;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Column(
                                children: q.options.map((opt) {
                                  final bool selectedState = isMulti
                                      ? (selected is List && selected.contains(opt))
                                      : (selected is String && selected == opt);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: selectedState ? colorScheme.primaryContainer : Colors.grey.shade300,
                                        width: selectedState ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        isMulti
                                            ? (selectedState ? Icons.check_box : Icons.check_box_outline_blank)
                                            : (selectedState ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                                        color: selectedState ? const Color.fromARGB(255, 173, 23, 143) : Colors.grey.shade600,
                                      ),
                                      title: Text(opt,
                                          style: TextStyle(
                                            fontWeight: selectedState ? FontWeight.w600 : FontWeight.normal,
                                            color: selectedState ? const Color.fromARGB(255, 173, 23, 143) : null,
                                          )),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ===== SCORED ITEMS (POMA) =====
                  const Text('Scored Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: question_score.length,
                    itemBuilder: (ctx, idx) {
                      final PatientQuestionScore sq = question_score[idx];
                      final int? selectedScore = scoreProvider.getScore(sq.question);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sq.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Column(
                                children: sq.optionsWithScore.map((optMap) {
                                  final String optText = optMap.keys.first;
                                  final int optScore = optMap.values.first;
                                  final bool isSelected = (selectedScore != null && selectedScore == optScore);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected ? colorScheme.primaryContainer : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: ListTile(
                                      leading: Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                        color: isSelected ? const Color.fromARGB(255, 173, 23, 143) : Colors.grey.shade600,
                                      ),
                                      title: Text(optText,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            color: isSelected ? const Color.fromARGB(255, 173, 23, 143) : null,
                                          )),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: colorScheme.primaryContainer),
                                        ),
                                        child: Text(optScore.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (selectedScore != null) ...[
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: colorScheme.primaryContainer)),
                                    child: Text('Selected score: $selectedScore', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}