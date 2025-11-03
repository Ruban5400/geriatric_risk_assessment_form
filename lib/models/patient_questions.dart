class PatientQuestions {
  final String question;
  final List<String> options;
  final bool isMultiSelect; // <-- NEW FIELD

  const PatientQuestions(this.question, this.options, {this.isMultiSelect = false});
}

class PatientQuestionScore {
  const PatientQuestionScore(this.question, this.optionsWithScore);

  final String question;
  final List<Map<String, int>> optionsWithScore;
}
