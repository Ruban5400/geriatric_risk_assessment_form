import 'package:flutter/material.dart';
import '../data/questions.dart'; // Assuming you import question_score list

class AssessmentScoreProvider with ChangeNotifier {
  // Key: Question Text (String), Value: Score (int)
  final Map<String, int> _selectedScores = {};

  int get totalScore => _selectedScores.values.fold(0, (sum, score) => sum + score);

  int? getScore(String question) => _selectedScores[question];

  void setAnswerScore(String question, int score) {
    _selectedScores[question] = score;
    notifyListeners();
  }

  void clearAll() {
    _selectedScores.clear();
    notifyListeners();
  }

  /// Add this getter — returns an immutable copy of the current score map.
  Map<String,int> get selectedScoresSnapshot => Map<String,int>.from(_selectedScores);

}
