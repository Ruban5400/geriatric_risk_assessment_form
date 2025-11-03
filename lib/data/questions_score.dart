import '../models/patient_questions.dart';

const question_score = [
  PatientQuestionScore('Sitting Balance', [
    {'Leans or slides in chair': 0},
    {'Steady': 1},
  ]),
  PatientQuestionScore('Arises', [
    {'Unable without help': 0},
    {'Able, uses arms': 1},
    {'Able without using arms': 2},
  ]),
  PatientQuestionScore('Attempts to Rise', [
    {'Unable without help': 0},
    {'Able, requires > 1 attempt': 1},
    {'Able in 1 attempt': 2},
  ]),
  PatientQuestionScore('Immediate Standing Balance (first 5 seconds)', [
    {'Unsteady (sway/stagger/feet move)': 0},
    {'Steady, with support': 1},
    {'Steady without support': 2},
  ]),
  PatientQuestionScore('Standing Balance', [
    {'Unsteady': 0},
    {'Steady, stance > 4 inch BOS & requires support': 1},
    {'Narrow stance, without support': 2},
  ]),
  PatientQuestionScore('Sternal Nudge (feet close together)', [
    {'Begins to fall': 0},
    {'Staggers, grabs, catches self': 1},
    {'Steady': 2},
  ]),
  PatientQuestionScore('Eyes Closed (feet close together)', [
    {'Unsteady': 0},
    {'Steady': 1},
  ]),
  PatientQuestionScore('Turning 360° (steps)', [
    {'Discontinuous steps': 0},
    {'Continuous steps': 1},
  ]),
  PatientQuestionScore('Turning 360° (stability)', [
    {'Unsteady (staggers, grabs)': 0},
    {'Steady': 1},
  ]),
  PatientQuestionScore('Sitting Down', [
    {'Unsafe (misjudges distance, falls)': 0},
    {'Uses arms, or not smooth motion': 1},
    {'Safe, smooth motion': 2},
  ]),
  PatientQuestionScore('Gait Initiation (immediate after told “go”)', [
    {'Any hesitancy, multiple attempts to start': 0},
    {'No hesitancy': 1},
  ]),
  PatientQuestionScore('Step Length', [
    {'R swing foot passes L stance leg': 1},
    {'L swing foot passes R': 1},
  ]),
  PatientQuestionScore('Foot Clearance', [
    {'R foot completely clears floor': 1},
    {'L foot completely clears floor': 1},
  ]),
  PatientQuestionScore('Step Symmetry', [
    {'R & L step length unequal': 0},
    {'R & L step length equal': 1},
  ]),
  PatientQuestionScore('Step Continuity', [
    {'Stop/discontinuity between steps': 0},
    {'Steps appear continuous': 1},
  ]),
  PatientQuestionScore('Path (excursion)', [
    {'Marked deviation': 0},
    {'Mild/moderate deviation or use of aid': 1},
    {'Straight without device': 2},
  ]),
  PatientQuestionScore('Trunk', [
    {'Marked sway or uses device': 0},
    {'No sway but knee/trunk flexion or spread arms while walking': 1},
    {'None of the above deviations': 2},
  ]),
  PatientQuestionScore('Base of Support', [
    {'Heels apart': 0},
    {'Heels close while walking': 1},
  ]),
];
