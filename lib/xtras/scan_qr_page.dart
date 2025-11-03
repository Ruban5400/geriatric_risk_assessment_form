// lib/xtras/qr_view_with_patient.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geriatric_risk_assessment_form/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/patient_info.dart'; // your PatientProvider path
import '../xtras/login_screen.dart';

// Keep AppColors defined somewhere in your project; replace if needed
class AppColors {
  static const Color primaryColor = Color(0xFFD291BC);
  static const Color secondaryColor = Color(0xFF957DAD);
}

class DoubleClickExitApp extends StatefulWidget {
  final Widget child;
  const DoubleClickExitApp({super.key, required this.child});
  @override
  _DoubleClickExitAppState createState() => _DoubleClickExitAppState();
}

class _DoubleClickExitAppState extends State<DoubleClickExitApp> {
  bool _isBackPressed = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isBackPressed) {
          SystemNavigator.pop();
          return true;
        } else {
          _isBackPressed = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.primaryColor,
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );
          Timer(const Duration(seconds: 2), () {
            _isBackPressed = false;
          });
          return false;
        }
      },
      child: widget.child,
    );
  }
}

// ---------- QRViewExample with patient form (always visible) ----------
class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isLoading = false;

  late String password, username, nickname, sessions, axpapp, baseurl;

  bool isDataLoaded = false;

  // Form
  final GlobalKey<FormState> _patientFormKey = GlobalKey<FormState>();
  late final TextEditingController _patientNameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _genderCtrl;
  late final TextEditingController _ipCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _comorbidityCtrl;
  late final TextEditingController _diagnosisCtrl;

  @override
  void initState() {
    super.initState();
    _patientNameCtrl = TextEditingController();
    _ageCtrl = TextEditingController();
    _genderCtrl = TextEditingController();
    _ipCtrl = TextEditingController();
    _mobileCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _educationCtrl = TextEditingController();
    _comorbidityCtrl = TextEditingController();
    _diagnosisCtrl = TextEditingController();

    _loadCounter();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPatientPrefs());
  }

  Future<void> _loadPatientPrefs() async {
    final prefs = await _prefs;
    _patientNameCtrl.text = prefs.getString('patient_name') ?? '';
    _ageCtrl.text = prefs.getString('patient_age') ?? '';
    _genderCtrl.text = prefs.getString('patient_gender') ?? '';
    _ipCtrl.text = prefs.getString('ip_no') ?? '';
    _mobileCtrl.text = prefs.getString('caretaker_mobile') ?? '';
    _addressCtrl.text = prefs.getString('patient_address') ?? '';
    _educationCtrl.text = prefs.getString('patient_education') ?? '';
    _comorbidityCtrl.text = prefs.getString('patient_comorbidity') ?? '';
    _diagnosisCtrl.text = prefs.getString('patient_diagnosis') ?? '';
  }

  // --- Data Loading (login user) ---
  _loadCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        password = (prefs.getString('password') ?? 'mock_pw');
        username = (prefs.getString('username') ?? '12345');
        sessions = (prefs.getString('session') ?? 'KTN');
        baseurl = (prefs.getString('baseurl') ?? 'mock_base_url');
        axpapp = (prefs.getString('axpapp') ?? 'mock_axpapp');
        nickname = (prefs.getString('nickname') ?? 'Nursing User');
        isDataLoaded = true;
      });
    }
  }

  // --- Logout Logic ---
  void _decrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (c) => const LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  // Save patient details to provider + prefs
  Future<void> _savePatientDetailsToProvider() async {

    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    final String name = _patientNameCtrl.text.trim();
    final String age = _ageCtrl.text.trim();
    final String gender = _genderCtrl.text.trim();
    final String ip = _ipCtrl.text.trim();
    final String mobile = _mobileCtrl.text.trim();
    final String address = _addressCtrl.text.trim();
    final String education = _educationCtrl.text.trim();
    final String comorbidity = _comorbidityCtrl.text.trim();
    final String diagnosis = _diagnosisCtrl.text.trim();

    patientProvider.setPatientDetails(
      patientName: name,
      age: age,
      gender: gender,
      ipNo: ip,
      mobileNo: mobile,
      address: address,
      education: education,
      comorbidity: comorbidity,
      diagnosis: diagnosis,
      unit: sessions,
      userName: nickname,
      empId: username
    );

    final prefs = await _prefs;
    await prefs.setString('patient_name', name);
    await prefs.setString('patient_age', age);
    await prefs.setString('patient_gender', gender);
    await prefs.setString('ip_no', ip);
    await prefs.setString('caretaker_mobile', mobile);
    await prefs.setString('patient_address', address);
    await prefs.setString('patient_education', education);
    await prefs.setString('patient_comorbidity', comorbidity);
    await prefs.setString('patient_diagnosis', diagnosis);

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (ctx) =>  Home()));

  }

  Widget _buildPatientForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 5,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _patientFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Patient Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const Divider(),
              _buildTextField(controller: _patientNameCtrl, label: 'Patient Name', validator: (v) => v!.trim().isEmpty ? 'Enter name' : null),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _ageCtrl, label: 'Age', keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(controller: _genderCtrl, label: 'Gender', hint: 'M/F')),
                ],
              ),
              const SizedBox(height: 10),
              _buildTextField(controller: _ipCtrl, label: 'IP Number'),
              const SizedBox(height: 10),
              _buildTextField(controller: _mobileCtrl, label: 'Mobile Number', keyboardType: TextInputType.phone),
              const SizedBox(height: 10),
              _buildTextField(controller: _addressCtrl, label: 'Address', maxLines: 2),
              const SizedBox(height: 10),
              _buildTextField(controller: _educationCtrl, label: 'Education'),
              const SizedBox(height: 10),
              _buildTextField(controller: _comorbidityCtrl, label: 'Comorbidity', maxLines: 2),
              const SizedBox(height: 10),
              _buildTextField(controller: _diagnosisCtrl, label: 'Diagnosis', maxLines: 2),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _patientFormKey.currentState?.reset();
                      _patientNameCtrl.clear();
                      _ageCtrl.clear();
                      _genderCtrl.clear();
                      _ipCtrl.clear();
                      _mobileCtrl.clear();
                      _addressCtrl.clear();
                      _educationCtrl.clear();
                      _comorbidityCtrl.clear();
                      _diagnosisCtrl.clear();
                    },
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 173, 23, 143)),
                    onPressed: _savePatientDetailsToProvider,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Text('Save Patient', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetailsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, _) {
        return Card(
          elevation: 5,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('User Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Divider(),
                _infoRow('Username', nickname),
                _infoRow('Employee Id', username),
                _infoRow('Unit', sessions),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isNotEmpty ? value : '-', style: const TextStyle())),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color.fromARGB(255, 245, 245, 245),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color.fromARGB(255, 173, 23, 143))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    const breakpoint = 700.0;
    final isLargeScreen = screenWidth > breakpoint;

    final patientForm = _buildPatientForm(context);
    final detailsSection = _buildUserDetailsCard(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 23, 143),
        title: const Text(
          'Geriatric Fall Risk Assessment Form',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _decrementCounter,
          ),
        ],
      ),
      body: DoubleClickExitApp(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: isLargeScreen
                ? Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 3, child: patientForm),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: detailsSection),
                ],
              ),
            )
                : Column(
              children: <Widget>[
                patientForm,
                const SizedBox(height: 12),
                detailsSection,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _patientNameCtrl.dispose();
    _ageCtrl.dispose();
    _genderCtrl.dispose();
    _ipCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _educationCtrl.dispose();
    _comorbidityCtrl.dispose();
    _diagnosisCtrl.dispose();
    super.dispose();
  }
}
