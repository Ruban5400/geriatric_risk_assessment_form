// lib/providers/patient_history.dart

import 'package:flutter/material.dart';
import '../data/questions.dart';
import '../models/patient_questions.dart';

class AnswersProvider with ChangeNotifier {
  // Stores answers: String (Radio) OR List<String> (Checkbox)
  final Map<String, dynamic> _answers = {};

  Map<String, dynamic> get answers => _answers;

  dynamic getAnswer(String question) => _answers[question];

  bool get allAnswered {
    // Check if every question has an entry in the answers map
    return questions.every((q) {
      final answer = _answers[q.question];

      if (q.isMultiSelect) {
        // Multi-select is considered answered if the key exists and the value is a list (even if the list is empty)
        return answer is List<String>;
      } else {
        // Single-select is considered answered if the value is a non-empty string
        return answer is String && answer.isNotEmpty;
      }
    });
  }

  void setAnswer(String question, String option) {
    // Find the question model to check its type
    final q = questions.firstWhere((model) => model.question == question);

    if (q.isMultiSelect) {
      // --- CHECKBOX LOGIC (Toggle Item in List) ---
      List<String> currentSelections = List.from(_answers[question] ?? []);

      if (currentSelections.contains(option)) {
        currentSelections.remove(option);
      } else {
        currentSelections.add(option);
      }

      // Save the list back. If the list is empty, it's still considered initialized/answered.
      _answers[question] = currentSelections;
    } else {
      // --- RADIO BUTTON LOGIC (Overwrite Single String) ---
      // If the user taps the same option, treat it as unselecting it
      if (_answers[question] == option) {
        _answers.remove(question); // Remove the answer to allow re-selection
      } else {
        _answers[question] = option;
      }
    }
    notifyListeners();
  }

  void clearAll() {
    _answers.clear();
    notifyListeners();
  }
}