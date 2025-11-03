import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/questions_score.dart';
import '../models/patient_questions.dart';
import '../providers/assessment_score.dart';

class ScoreQuestionBlock extends StatelessWidget {
  final int index;
  const ScoreQuestionBlock({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final PatientQuestionScore q = question_score[index];
    final scoreProvider = Provider.of<AssessmentScoreProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Get the score of the currently selected option for this question
    final int? currentScore = scoreProvider.getScore(q.question);

    // We also need to find the text of the selected option to visually highlight it.
    // This requires iterating through the options to find the one matching the current score.
    final String? selectedOptionText;
    if (currentScore != null) {
      // Find the option text that corresponds to the current score
      selectedOptionText = q.optionsWithScore
          .firstWhere(
            (optionMap) => optionMap.values.first == currentScore,
        orElse: () =>
        {}, // Handle case where score isn't found (shouldn't happen)
      )
          .keys
          .firstOrNull; // Get the option text
    } else {
      selectedOptionText = null;
    }

    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Title
            Text(
              q.question,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),

            // **********************************
            const Divider(height: 20, thickness: 1.5),

            // Options Column
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: q.optionsWithScore.map((optionMap) {
                      final optionText = optionMap.keys.first;
                      final optionScore = optionMap.values.first;

                      // Check if this option's text matches the currently selected option text
                      final bool isSelected = selectedOptionText == optionText;

                      return InkWell(
                        onTap: () {
                          // Update the score in the provider
                          scoreProvider.setAnswerScore(q.question, optionScore);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primaryContainer
                                  : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 2.0,
                            ),
                            child: Row(
                              children: [
                                // Radio Icon
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? Color.fromARGB(255, 173, 23, 143)
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 12),
                                // Option Text
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Text(
                                      optionText,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: isSelected
                                            ?  Color.fromARGB(255, 173, 23, 143)
                                            : colorScheme.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                                // *** SCORE REMOVED FROM HERE ***
                                // It's removed from the Row, achieving the requested separation.
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (currentScore != null)
                  Container(
                    margin: const EdgeInsets.only(left: 20.0),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 15.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:colorScheme.primaryContainer
                      ),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Text(
                      currentScore.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color:  Color.fromARGB(255, 173, 23, 143),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
