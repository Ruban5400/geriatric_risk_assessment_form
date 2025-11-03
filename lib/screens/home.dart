import 'package:flutter/material.dart';
import 'package:geriatric_risk_assessment_form/screens/assessment_page.dart';
import 'package:provider/provider.dart';
import '../data/questions.dart';
import '../providers/patient_history.dart';
import '../widgets/question_block.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Geriatric Assessment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 173, 23, 143),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            tooltip: 'Clear all answers',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear all answers?'),
                  content: const Text('This will remove all selected answers.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AnswersProvider>(
                          context,
                          listen: false,
                        ).clearAll();
                        Navigator.pop(ctx);
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: const SafeArea(child: FormWrapper()),
      floatingActionButton: const SubmitButton(),
    );
  }
}

// --------------------------------------------------------------------------

class FormWrapper extends StatelessWidget {
  const FormWrapper({super.key});


  @override
  Widget build(BuildContext context) {
    const double maxWidth = 700.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: screenWidth > maxWidth ? maxWidth : screenWidth * 0.9,
        child: ListView.builder(
          itemCount: questions.length,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
          itemBuilder: (context, index) => QuestionBlock(index: index),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      icon: const Icon(Icons.arrow_forward, color: Colors.white),
      label: const Text('Continue', style: TextStyle(color: Colors.white)),
      backgroundColor: Color.fromARGB(255, 173, 23, 143),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => AssessmentPage()),
        );
      },
    );
  }
}
