import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/patient_history.dart';
import '../models/patient_questions.dart';
import '../data/questions.dart';

class QuestionBlock extends StatelessWidget {
  final int index;
  const QuestionBlock({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final PatientQuestions q = questions[index];
    final provider = Provider.of<AnswersProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    final bool isCheckbox = q.isMultiSelect;
    final dynamic currentSelection = provider.getAnswer(q.question);

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
              q.question, // Added index back for clarity
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Divider(height: 20, thickness: 1.5),

            // Options Column
            Column(
              children: q.options.map((opt) {
                // Determine selection state based on type
                final bool isSelected;
                if (isCheckbox) {
                  // Safe check for list containment
                  isSelected = (currentSelection is List<String>)
                      ? currentSelection.contains(opt)
                      : false;
                } else {
                  // Single string comparison
                  isSelected = currentSelection == opt;
                }

                return InkWell(
                  onTap: () {
                    // Provider handles the logic for both types
                    Provider.of<AnswersProvider>(
                      context,
                      listen: false,
                    ).setAnswer(q.question, opt);
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
                          Icon(
                            isSelected
                                ? (isCheckbox
                                      ? Icons.check_box
                                      : Icons.radio_button_checked)
                                : (isCheckbox
                                      ? Icons.check_box_outline_blank
                                      : Icons.radio_button_unchecked),
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
                                opt,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isSelected
                                      ? Color.fromARGB(255, 173, 23, 143)
                                      : colorScheme.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
