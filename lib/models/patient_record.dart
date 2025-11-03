
import 'dart:convert';

class PatientRecord {
  final String patientName;
  final String age;
  final String gender;
  final String ipNo;
  final String mobileNo;
  final String unit;
  final String userName;
  final String empId;
  final String doctorName;

  // Answers map: question -> String | List<String>
  final Map<String, dynamic> answers;
  // optional timestamp
  final DateTime createdAt;

  PatientRecord({
    required this.patientName,
    required this.age,
    required this.gender,
    required this.ipNo,
    required this.mobileNo,
    required this.unit,
    required this.userName,
    required this.empId,
    required this.doctorName,
    required this.answers,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'patientName': patientName,
    'age': age,
    'gender': gender,
    'ipNo': ipNo,
    'mobileNo': mobileNo,
    'unit': unit,
    'userName': userName,
    'empId': empId,
    'doctorName': doctorName,
    'answers': answers,
    'createdAt': createdAt.toIso8601String(),
  };

  factory PatientRecord.fromJson(Map<String, dynamic> map) {
    return PatientRecord(
      patientName: map['patientName'] ?? '',
      age: map['age'] ?? '',
      gender: map['gender'] ?? '',
      ipNo: map['ipNo'] ?? '',
      mobileNo: map['mobileNo'] ?? '',
      unit: map['unit'] ?? '',
      userName: map['userName'] ?? '',
      empId: map['empId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      answers:
      Map<String, dynamic>.from(map['answers'] ?? <String, dynamic>{}),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // helper if you want to store as a JSON string in prefs
  String encode() => jsonEncode(toJson());
  static PatientRecord decode(String jsonStr) =>
      PatientRecord.fromJson(jsonDecode(jsonStr));
}
