

import '../models/patient_questions.dart';

const questions = [
  PatientQuestions('History of Falls', ['Yes', 'No']),
  PatientQuestions('Fear of Fall', ['Yes', 'No']),
  PatientQuestions('ADL (Activities of Daily Living)', [
    'Independent',
    'Partially Dependent',
    'Dependent',
  ]),
  PatientQuestions('Vision Impairment', ['Normal', 'Impaired']),
  PatientQuestions('Cognition', ['Normal (>6)', 'Impaired (<6)']),
  PatientQuestions('Incontinence', ['Present', 'Absent']),
  PatientQuestions('Cardiovascular Complications', ['Yes', 'No']),
  PatientQuestions('Poly Pharmacy', ['Yes (> 5 Drugs)', 'No']),
  PatientQuestions('Medications', [
    'Antihypertensive',
    'Antidepressant',
    'Sedative',
    'Anti-Psychotic',
    'BZD',
  ],isMultiSelect: true),
  PatientQuestions('Behavior Problem', ['Yes', 'No']),
  PatientQuestions('Environmental Risk', ['Present', 'Absent']),
  PatientQuestions('Nutrition', [
    'Risk of Malnutrition',
    'No Risk of Malnutrition',
  ]),
  // PatientQuestions('POMA', [
  //   'Normal (>25)',
  //   'Mild to Moderate (19-24)',
  //   'Severe (<19)',
  // ]),
  PatientQuestions('Recent Falls', [
    'None in last 12 months',
    'One or more between 3–12 months ago',
    'One or more in last 3 months',
    'One or more in last 3 months whilst inpatient/resident',
  ]),
  PatientQuestions('Medications taken', [
    'Not taking any',
    'Taking one',
    'Taking two',
    'Taking more than two',
  ]),
  PatientQuestions('Psychological Status', [
    'No issues',
    'Mildly affected',
    'Moderately affected',
    'Severely affected',
  ]),
  PatientQuestions('Cognitive Status (AMTS)', [
    '9–10 (Normal)',
    '7–8 (Mild impairment)',
    '5–6 (Moderate impairment)',
    '4 or less (Severe impairment)',
  ]),
  PatientQuestions('Automatic High Risk', [
    'Recent functional change',
    'Medications affecting stability',
    'Dizziness / postural hypotension',
  ]),
  PatientQuestions('Fall Risk', ['Present', 'Not Present']),
  PatientQuestions('FRAT', [
    'Low Risk (5-11)',
    'Medium Risk (12-15)',
    'High Risk (15-20)',
  ]),
];
