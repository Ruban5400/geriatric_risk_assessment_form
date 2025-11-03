import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login.dart';


class ApiEndPoints {
  static const String loginbaseUrl = "https://khr.kauveryhospital.com/";
  static const authEndpoints = _AuthEndpoints();
}

class _AuthEndpoints {
  const _AuthEndpoints();
  final String loginEmail = "login";
}
class AppColors {
  static const Color primaryColor = Color(
    0xFFD291BC,
  ); // Used in previous design thread
  static const Color secondaryColor = Color(0xFF957DAD);
  static const Color backgroundColor = Color(0xFFE0BBE4);
}

class CustomButton extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color forgroundColor;
  final double width;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.forgroundColor,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: forgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: Size(width, 50), // Fixed height for a good button
      ),
      child: Text(title, style: const TextStyle(fontSize: 16)),
    );
  }
}

// Error messages used in your validators
const String kEmailNullError = "Please enter your Employee ID";
const String kInvalidEmailError = "Employee ID is too short";
const String kPasswordNullError = "Please enter your password";
const String kShortPasswordError = "Password is too short";

// --- 2. SIGN IN FORM CONTENT (Integrated Logic) ---

class _SignInFormContent extends StatefulWidget {
  const _SignInFormContent({Key? key}) : super(key: key);
  @override
  State<_SignInFormContent> createState() => _SignInFormContentState();
}

class _SignInFormContentState extends State<_SignInFormContent> {
  // Removed Get.put initialization. Controller is now accessed via Provider.

  var selectedSalutation;
  final _emailFormFieldKey = GlobalKey<FormFieldState>();
  final _passwordFormFieldKey = GlobalKey<FormFieldState>();
  String? email, password, axpapp, baseurl;
  late FocusNode passwordFocusNode;
  String paswordFieldSuffixText = "Show";
  var newBase64;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    passwordFocusNode.dispose();
    super.dispose();
  }

  // Your MD5 Hashing Logic
  generateMd5(String data) {
    newBase64 = md5.convert(utf8.encode(data)).toString();
    return newBase64;
  }

  // Your Email/Employee ID Field
  TextFormField emailFormField() {
    // Access controller using Provider.of here, or in the build method.
    // We access it in the build method for simplicity.
    final controller = Provider.of<LoginController>(context, listen: false);

    return TextFormField(
      key: _emailFormFieldKey,
      controller: controller.emailController,
      onSaved: (newEmail) {
        setState(() {
          email = newEmail;
        });
      },
      onChanged: (newEmail) {
        _emailFormFieldKey.currentState!.validate();
      },
      onFieldSubmitted: (newEmail) {
        passwordFocusNode.requestFocus();
      },
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.grey.shade800),
      decoration: InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        labelText: "Employee Id",
        hintText: 'Employee Id',
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
      ),
      validator: (newEmail) {
        if (newEmail!.isEmpty) {
          return kEmailNullError;
        } else if (newEmail.length < 5) {
          return kInvalidEmailError;
        }
        return null;
      },
    );
  }

  // Your Password Field
  TextFormField passwordFormField() {
    // Access controller using Provider.of here, or in the build method.
    final controller = Provider.of<LoginController>(context, listen: false);

    return TextFormField(
      key: _passwordFormFieldKey,
      controller: controller.passwordController,
      focusNode: passwordFocusNode,
      onSaved: (newPassword) {
        generateMd5(newPassword!);
        setState(() {
          password = newBase64;
        });
      },
      onChanged: (newPassword) {
        _passwordFormFieldKey.currentState!.validate();
      },
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      style: TextStyle(color: Colors.grey.shade800),
      decoration: InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        labelText: "Password",
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        hintText: "Enter your password",
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        suffixIcon: TextButton(
          child: Text(
            paswordFieldSuffixText,
            style: const TextStyle(color: AppColors.primaryColor),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
              paswordFieldSuffixText = (paswordFieldSuffixText == "Show")
                  ? "Hide"
                  : "Show";
            });
          },
        ),
      ),
      validator: (newPassword) {
        if (newPassword!.isEmpty) {
          return kPasswordNullError;
        } else if (newPassword.length < 2) {
          return kShortPasswordError;
        }
        return null;
      },
    );
  }

  // Your Dropdown Field
  Widget dropdownFormField() {
    return DropdownButtonFormField<String>(
      hint: const Text('Select unit', style: TextStyle(color: Colors.grey)),
      value: selectedSalutation,
      validator: (value) => value == null ? 'Field required' : null,
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),

      decoration: InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        labelText: "Unit",
        labelStyle: const TextStyle(color: AppColors.primaryColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
      ),

      items: const [
        DropdownMenuItem(value: 'KTN', child: Text("KTN-Tennur")),
        DropdownMenuItem(value: 'KCN', child: Text("KCN-Cantonment")),
        DropdownMenuItem(value: 'KHC', child: Text("KHC-Heartcity")),
        DropdownMenuItem(value: 'KSM', child: Text("KSM-Salem")),
        DropdownMenuItem(value: 'KCH', child: Text("KCH-Chennai")),
        DropdownMenuItem(value: 'KTV', child: Text("KTV-Tirunelveli")),
        DropdownMenuItem(value: 'KHO', child: Text("KHO-Hosur")),
      ],

      onChanged: (newValue) {
        setState(() {
          selectedSalutation = newValue;
          if (selectedSalutation == 'KTN') {
            axpapp = "hmsktn";
            baseurl =
                "https://hmsktn06.kauverykonnect.com/hmsktnscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/";
          } else if (selectedSalutation == 'KHC') {
            axpapp = "hmsheartcity";
            baseurl =
                "https://telemedicinescripts.kauveryhospital.com/hmsheartcityscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/";
          } else if (selectedSalutation == 'KCN') {
            axpapp = "hmsspeciality";
            baseurl =
                "https://telemedicinescripts.kauverykonnect.com/hmsspecialityscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/";
          } else if (selectedSalutation == 'KSM') {
            axpapp = "hmsksm";
            baseurl =
                "https://hmsksm.kauverykonnect.com/hmsksmscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/";
          } else if (selectedSalutation == 'KCH') {
            axpapp = "hmskch";
            baseurl =
                "https://chennaihms.kauverykonnect.com/hmskchscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/";
          } else if (selectedSalutation == 'KTV') {
            axpapp = "hmsktv";
            baseurl =
                "https://hmsapiktv.kauverykonnect.com/hmsktvscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/";
          } else if (selectedSalutation == 'KHO') {
            axpapp = "hmshosur";
            baseurl =
                "https://hmskho.kauveryhospital.com/hmshosurscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/";
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access the controller using Provider.of, setting listen: false as we only call methods
    // We assume the controller is provided higher up in the widget tree.
    final controller = Provider.of<LoginController>(context, listen: false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Text(
            "Login",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.03),

        Form(
          key: controller.formKey,
          child: Column(
            children: [
              emailFormField(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              passwordFormField(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              dropdownFormField(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),

              CustomButton(
                title: "Login",
                backgroundColor: const Color.fromARGB(255, 173, 23, 143),
                forgroundColor: Colors.white,
                width: double.infinity,
                onPressed: () async {
                  if (controller.formKey.currentState!.validate()) {
                    controller.formKey.currentState!.save();

                    // Pass context to the controller's login method for UI interactions
                    controller.loginWithEmails(
                      context: context,
                      name: email,
                      pswd: password,
                      unitselect: selectedSalutation,
                      axpapp: axpapp,
                      baseurl: baseurl,
                    );
                  }
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ],
          ),
        ),
      ],
    );
  }
}

// --- 3. MAIN LOGIN PAGE (Responsive Wrapper) ---

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxLoginCardWidth = 950.0;
    const double maxLoginCardHeight = 500.0;
    final bool isLargeScreen = screenWidth > 800;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Full Background Image
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  maxWidth: isLargeScreen
                      ? maxLoginCardWidth * 0.6
                      : screenWidth * 0.8,
                  maxHeight: maxLoginCardHeight,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: isLargeScreen
                    ? Padding(
                        padding: const EdgeInsets.all(40.0),
                        child:
                            const _SignInFormContent(), // _SignInFormContent now uses Provider
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(40.0),
                        child:
                            const _SignInFormContent(), // _SignInFormContent now uses Provider
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
