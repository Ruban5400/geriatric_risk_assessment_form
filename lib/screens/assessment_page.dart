import 'package:flutter/material.dart';
import 'package:geriatric_risk_assessment_form/widgets/speedometer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/questions_score.dart';
import '../providers/assessment_score.dart';
import '../models/patient_questions.dart';
import '../providers/patient_history.dart';
import '../providers/patient_info.dart';
import '../services/supabase_service.dart';
import '../widgets/score_question_block.dart';
import '../widgets/score_with_guidelines.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the provider for real-time score updates
    final scoreProvider = Provider.of<AssessmentScoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'POMA Assessment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 173, 23, 143),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        actions: [
          if (scoreProvider.totalScore != 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  'Total Score: ${scoreProvider.totalScore}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            tooltip: 'Clear all scores',
            onPressed: () {
              // ... (Dialog logic for clearing scores)
              scoreProvider.clearAll();
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: const SafeArea(child: ScoreFormWrapper()),
      floatingActionButton: const ScoreSubmitButton(),
    );
  }
}

// --- FormWrapper and SubmitButton remain the same logic, but renamed for context ---

class ScoreFormWrapper extends StatelessWidget {
  const ScoreFormWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    const double maxWidth = 700.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth > maxWidth ? maxWidth : screenWidth * 0.9,
        child: ListView.builder(
          itemCount: question_score.length, // Use the score list
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          itemBuilder: (context, index) => ScoreQuestionBlock(index: index),
        ),
      ),
    );
  }
}

class ScoreSubmitButton extends StatelessWidget {
  const ScoreSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreProvider = Provider.of<AssessmentScoreProvider>(
      context,
      listen: false,
    );

    return FloatingActionButton.extended(
      icon: const Icon(Icons.send, color: Colors.white),
      label: const Text(
        'Submit Assessment',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color.fromARGB(255, 173, 23, 143),
      onPressed: () async {
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(const SnackBar(content: Text('Uploading...')));
        final ok = await uploadAssessmentSingleRow(
          context: context,
          maxScore: 26,
        );
        scaffold.hideCurrentSnackBar();
        final snackBar = SnackBar(
          content: Text(
            ok ? 'Uploaded' : 'Upload failed',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
          behavior: SnackBarBehavior
              .floating, // optional: makes it float above bottom
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);

        final totalScore = scoreProvider.totalScore;

        if (ok) {
          // ✅ 1. Clear Provider state
          final questionProvider = Provider.of<AnswersProvider>(
            context,
            listen: false,
          );
          final scoreProvider = Provider.of<AssessmentScoreProvider>(
            context,
            listen: false,
          );
          final patientProvider = Provider.of<PatientProvider>(
            context,
            listen: false,
          );
          questionProvider.clearAll();
          scoreProvider.clearAll();
          patientProvider
              .resetAll(); // Same — define to clear all stored patient data

          // ✅ 2. Keep only the login-related SharedPreferences
          final prefs = await SharedPreferences.getInstance();

          // Get the keys we want to preserve
          final keepKeys = {
            'token',
            'username',
            'password',
            'session',
            'axpapp',
            'baseurl',
            'nickname',
          };

          // Collect values before clearing
          final preserved = <String, String?>{};
          for (final key in keepKeys) {
            preserved[key] = prefs.getString(key);
          }

          // Clear all prefs
          await prefs.clear();

          // Restore only preserved keys
          for (final entry in preserved.entries) {
            if (entry.value != null) {
              await prefs.setString(entry.key, entry.value!);
            }
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) =>
                ScoreWithGuidelinesPage(score: totalScore, maxScore: 26),
          ),
        );
      },
    );
  }
}
