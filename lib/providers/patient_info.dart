// lib/providers/patient_info.dart
import 'package:flutter/material.dart';

class PatientProvider with ChangeNotifier {
  String patientName = '';
  String age = '';
  String gender = '';
  String ipNo = '';
  String mobileNo = '';
  String address = '';
  String education = '';
  String comorbidity = '';
  String diagnosis = '';
  String userName = '';
  String empId = '';
  String unit = '';
  String doctorName = '';

  void setPatientDetails({
    String? patientName,
    String? age,
    String? gender,
    String? ipNo,
    String? mobileNo,
    String? address,
    String? education,
    String? comorbidity,
    String? diagnosis,
    String? userName,
    String? empId,
    String? unit,
    String? doctorName,
  }) {
    if (patientName != null) this.patientName = patientName;
    if (age != null) this.age = age;
    if (gender != null) this.gender = gender;
    if (ipNo != null) this.ipNo = ipNo;
    if (mobileNo != null) this.mobileNo = mobileNo;
    if (address != null) this.address = address;
    if (education != null) this.education = education;
    if (comorbidity != null) this.comorbidity = comorbidity;
    if (diagnosis != null) this.diagnosis = diagnosis;
    if (userName != null) this.userName = userName;
    if (empId != null) this.empId = empId;
    if (unit != null) this.unit = unit;
    if (doctorName != null) this.doctorName = doctorName;
    notifyListeners();
  }

  void clear() {
    patientName = '';
    age = '';
    gender = '';
    ipNo = '';
    mobileNo = '';
    address = '';
    education = '';
    comorbidity = '';
    diagnosis = '';
    userName = '';
    empId = '';
    unit = '';
    doctorName = '';
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_name': patientName,
      'patient_age': age,
      'patient_gender': gender,
      'ip_no': ipNo,
      'caretaker_mobile': mobileNo,
      'patient_address': address,
      'patient_education': education,
      'patient_comorbidity': comorbidity,
      'patient_diagnosis': diagnosis,
      'user_name': userName,
      'emp_id': empId,
      'unit': unit,
      'doctor_name': doctorName,
    };
  }

  void resetAll() {
    patientName = '';
    age = '';
    gender = '';
    unit = '';
    mobileNo = '';
    address = '';
    education = '';
    comorbidity = '';
    diagnosis = '';
    notifyListeners();
  }

}
