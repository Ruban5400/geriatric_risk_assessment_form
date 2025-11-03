import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 1. IMPORT kIsWeb
import 'package:geriatric_risk_assessment_form/providers/assessment_score.dart';
import 'package:geriatric_risk_assessment_form/providers/patient_info.dart';
import 'package:geriatric_risk_assessment_form/xtras/login.dart';
import 'package:geriatric_risk_assessment_form/xtras/login_screen.dart';
import 'package:geriatric_risk_assessment_form/xtras/scan_qr_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/patient_history.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // --- START FIX: Conditional execution for non-web platforms ---
  if (!kIsWeb)
  {
    // This code only runs on Android/iOS/Desktop.

    // 2. Wrap HttpOverrides.global
    HttpOverrides.global = MyHttpOverrides();

    // 3. Wrap SecurityContext setup
    try {
      ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
      SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
    } catch (e) {
      // Handle or log the error, especially if the asset path is wrong
      print("Error setting trusted certificates: $e");
    }
  }

  const supabaseUrl =
      'http://supabasekong-uggsw0oswso0o4w4wkogos0g.72.60.206.230.sslip.io';
  const supabaseAnonKey =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJzdXBhYmFzZSIsImlhdCI6MTc2MDUwODQ4MCwiZXhwIjo0OTE2MTgyMDgwLCJyb2xlIjoiYW5vbiJ9.wrF1MVhHEBLuU_7UYG1E3eYQtGGqKV6I4XIOFQUWViw';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  // --- END FIX ---
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  Widget initialWidget = const LoginPage();
  // Determine the correct starting widget based on the token status
  if (token == 'Success') {
    initialWidget = const QRViewExample();
  } else {
    initialWidget = const LoginPage();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginController()),
        ChangeNotifierProvider(create: (_) => AnswersProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentScoreProvider()),
      ],
      child: GeriatricApp(initialWidget: initialWidget),
    ),
  );
}

final supabase = Supabase.instance.client;

class GeriatricApp extends StatelessWidget {
  final Widget initialWidget;

  const GeriatricApp({super.key, required this.initialWidget});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Geriatric Assessment',
      theme: ThemeData(
        // Kauvery color
        colorSchemeSeed: const Color.fromARGB(255, 173, 23, 143),
        useMaterial3: true,
      ),
      home: initialWidget,
    );
  }
}

// This class is still fine as it is only accessed inside the conditional block
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}