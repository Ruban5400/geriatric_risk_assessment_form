// Converted to ChangeNotifier for use with the 'provider' package
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geriatric_risk_assessment_form/xtras/scan_qr_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- PLACEHOLDERS for external dependencies (Needed for compilation context) ---
class ApiEndPoints {
  static const authEndpoints = _AuthEndpoints();
}

class _AuthEndpoints {
  const _AuthEndpoints();
  final String loginEmail = "login";
}

class LoginController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Field needed for the SharedPreferences logic
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // The full login logic, now accepting BuildContext for UI interactions (dialogs/navigation)
  void loginWithEmails({
    required BuildContext
    context, // Added context to handle dialogs and navigation
    required String? name,
    required String? pswd,
    required String? unitselect,
    required String? axpapp,
    required String? baseurl,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Set up a simple loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator()),
    );

    var headers = {'Content-Type': 'application/json'};

    print("Initiating LIVE API call for user $name...");

    // -------------------------------------------------------------------------
    // --- START: Live Login Logic ---
    // -------------------------------------------------------------------------
    try {
      // Use the baseurl determined by the dropdown, if available.
      // Fallback to the ApiEndPoints.loginbaseUrl if baseurl is null, though it shouldn't be
      // if the dropdown validation works correctly.
      final String effectiveBaseUrl =
          'https://khr.kauveryhospital.com/khrmisscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/';
      var url = Uri.parse(
        effectiveBaseUrl + ApiEndPoints.authEndpoints.loginEmail,
      );

      Map body = {
        "_parameters": [
          {
            "login": {
              "axpapp":
                  "khrmis", // This hardcoded value might need to change based on 'axpapp' parameter
              "username": name,
              "password": pswd,
              "seed": "",
              "other": "Chrome",
              "trace": "true",
            },
          },
        ],
      };
      print("Response url Mock: ${url}");
      print("Response Body Mock: ${body}");

      // --- LIVE HTTP POST REQUEST ---
      http.Response response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );

      // Check mounted BEFORE using context after the AWAIT
      if (!context.mounted) return;

      // Close the loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> jobs = json['result'];

        if (jobs[0]['error'].toString() == "null") {
          final Map<String, dynamic> joby1 = jobs.first['result'];
          final String statusapi = joby1['status'];
          final String username = joby1['USERNAME'];
          final String nickname = joby1['NICKNAME'];

          final SharedPreferences prefs = await _prefs;
          await prefs.setString('token', statusapi);
          await prefs.setString('username', username);
          await prefs.setString('password', pswd!);
          await prefs.setString('session', unitselect!);
          await prefs.setString('axpapp', axpapp!);
          await prefs.setString('baseurl', baseurl!);
          await prefs.setString('nickname', nickname);

          // Check mounted BEFORE navigation
          if (!context.mounted) return;
          // Navigate after success
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (c) => const QRViewExample()),
          );
        } else if (jobs[0]['error']['status'] == 'Failed') {
          final Map<String, dynamic> joby = jobs.first['error'];
          final String jobTitle = joby['status'];
          final String jobTitle1 = joby['msg'];

          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (dialogContext) {
              return SimpleDialog(
                title: Text(jobTitle),
                contentPadding: const EdgeInsets.all(20),
                children: [Text(jobTitle1.toString())],
              );
            },
          );
        }
      } else {
        // Handle non-200 responses (e.g., 404, 500)
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (dialogContext) {
            return SimpleDialog(
              title: const Text('API Error'),
              contentPadding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Server responded with status code ${response.statusCode}.',
                ),
                Text(response.body),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Check mounted BEFORE using context after the AWAIT
      if (!context.mounted) return;

      // Ensure the loading dialog is closed if an error occurs
      Navigator.of(context, rootNavigator: true).pop();

      print("Login error: $error");
      showDialog(
        context: context,
        builder: (dialogContext) {
          return SimpleDialog(
            title: const Text('Connection Error'),
            contentPadding: const EdgeInsets.all(20),
            children: [Text(error.toString())],
          );
        },
      );
    }

    // -------------------------------------------------------------------------
    // --- END: Live Login Logic ---
    // -------------------------------------------------------------------------
  }

  // --- FIX APPLIED HERE: Using rootNavigator: true for navigation ---
  // LoginController
  Future<bool> getqrresponse({
    required String name,
    required String pswd,
    required String axpapp,
    required String baseurl,
    required String qrcodes,
    required String sessions,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    try {
      final url = Uri.parse(baseurl + 'getchoices');
      Map body = {
        "_parameters": [
          {
            "getchoices": {
              "name": "pdcinv",
              "axpapp": axpapp,
              "username": name,
              "password": pswd,
              "s": "",
              "sql":
                  "Select  ip.Ip_no,ip.uhid,ip.WARD_PATIENTNAME patname,cd.DOCTOR_NAME,cd.DOCTOR_SHRT Doctor_shortName,cw.WARD_NAME,cb.BED_NO,ip.attender_name  primary_care_taker,ip.CONTACT_NO primary_care_taker_no , case when ip.is_vip = 'T'  then 'VIP' else '' end is_vip from ip_admission ip join REGISTRATION r on r.uhid=ip.uhid join cm_ward cw on cw.CM_WARDID=ip.ward join cm_bed cb on cb.CM_BEDID=ip.BED_NO join cm_doctor cd on cd.cm_doctorid=ip.ATTENDING_PHYSICIAN join CM_SPECIALITY cs on cs.CM_SPECIALITYID=cd.SPECIALTY left join MG_PARTYHDR mp on mp.MG_PARTYHDRID=ip.COMPANY_name join cm_casetype cat on cat.cm_casetypeid=ip.case_type where  ip.ip_no ='" +
                  qrcodes! +
                  "' and ip.cancel='F'",
            },
          },
        ],
      };
      print('5400 -=-=-=-= url $url');
      print('5400 -=-=-=-= url $body');
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );
      print('5400 -=-=-=-= response ${jsonDecode(response.body)}');
      if (response.statusCode != 200) return false;
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> jobs = json['result'];

      if (jobs.isEmpty) return false;
      if (jobs[0]['error'].toString() != "null") return false;

      print('5400 -=-= ${jobs[0]['error']}');
      final Map<String, dynamic> joby1 = jobs.first['result'];
      print(joby1);
      final List<dynamic> joby2 = joby1['row'];

      final String ipNo = joby2[0]['ip_no'];
      final String uhid = joby2[0]['uhid'];
      final String patname = joby2[0]['patname'];
      final String doctorName = joby2[0]['doctor_shortname'];
      final String wardName = joby2[0]['ward_name'];
      final String bedNo = joby2[0]['bed_no'];
      final String primaryCareTakerNo = joby2[0]['primary_care_taker_no'];
      final SharedPreferences prefs = await _prefs;
      await prefs.setString('ip_no', ipNo);
      await prefs.setString('uhid', uhid);
      await prefs.setString('patname', patname);
      await prefs.setString('doctor_name', doctorName);
      await prefs.setString('ward_name', wardName);
      await prefs.setString('bed_no', bedNo);
      await prefs.setString('primary_care_taker_no', primaryCareTakerNo);
      print('5400 -=-=-=-= true');
      return true;
    } catch (err) {
      // optional: log error
      print('5400 -=-=-=-= $err');
      print('5400 -=-=-=-= false');
      return false;
    }
  }
}

// not moving to Home apge after scan
// import 'dart:convert';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:geriatric_risk_assessment_form/xtras/scan_qr_page.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../screens/home.dart';
// import 'login_screen.dart';
//
// class LoginController extends ChangeNotifier {
//   final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//
//   // Field needed for the SharedPreferences logic
//   final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//
//   // The full login logic, now accepting BuildContext for UI interactions (dialogs/navigation)
//   void loginWithEmails({
//     required BuildContext context, // Added context to handle dialogs and navigation
//     required String? name,
//     required String? pswd,
//     required String? unitselect,
//     required String? axpapp,
//     required String? baseurl,
//   }) async {
//     if (!formKey.currentState!.validate()) {
//       return;
//     }
//
//     // Set up a simple loading indicator
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
//     );
//
//     var headers = {'Content-Type': 'application/json'};
//
//     print("Initiating LIVE API call for user $name...");
//
//     // -------------------------------------------------------------------------
//     // --- START: Live Login Logic ---
//     // -------------------------------------------------------------------------
//     try {
//       // Use the baseurl determined by the dropdown, if available.
//       // Fallback to the ApiEndPoints.loginbaseUrl if baseurl is null, though it shouldn't be
//       // if the dropdown validation works correctly.
//       final String effectiveBaseUrl = 'https://khr.kauveryhospital.com/khrmisscripts/ASBMenuRest.dll/datasnap/rest/TASBMenuREST/';
//       var url = Uri.parse(effectiveBaseUrl + ApiEndPoints.authEndpoints.loginEmail);
//
//       Map body = {
//         "_parameters": [
//           {
//             "login": {
//               "axpapp": "khrmis", // This hardcoded value might need to change based on 'axpapp' parameter
//               "username": name,
//               "password": pswd,
//               "seed": "",
//               "other": "Chrome",
//               "trace": "true"
//             }
//           }
//         ]
//       };
//       print("Response url Mock: ${url}");
//       print("Response Body Mock: ${body}");
//
//       // --- LIVE HTTP POST REQUEST ---
//       http.Response response = await http.post(url, body: jsonEncode(body), headers: headers);
//
//       // Close the loading dialog
//       Navigator.of(context, rootNavigator: true).pop();
//
//       print("Response Status: ${response.statusCode}");
//       print("Response Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//         final List<dynamic> jobs = json['result'];
//
//         if (jobs[0]['error'].toString() == "null") {
//           final Map<String, dynamic> joby1 = jobs.first['result'];
//           final String statusapi = joby1['status'];
//           final String username = joby1['USERNAME'];
//           final String nickname = joby1['NICKNAME'];
//
//           final SharedPreferences prefs = await _prefs;
//           await prefs.setString('token', statusapi);
//           await prefs.setString('username', username);
//           await prefs.setString('password', pswd!);
//           await prefs.setString('session', unitselect!);
//           await prefs.setString('axpapp', axpapp!);
//           await prefs.setString('baseurl', baseurl!);
//           await prefs.setString('nickname', nickname);
//
//           // Show success dialog
//           // showDialog(
//           //     context: context,
//           //     builder: (dialogContext) {
//           //       return SimpleDialog(
//           //         title: Text(statusapi),
//           //         contentPadding: const EdgeInsets.all(20),
//           //         children: [Text(statusapi.toString())],
//           //       );
//           //     });
//
//           // Navigate after success
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (c) => const QRViewExample()),
//           );
//
//         } else if (jobs[0]['error']['status'] == 'Failed') {
//           final Map<String, dynamic> joby = jobs.first['error'];
//           final String jobTitle = joby['status'];
//           final String jobTitle1 = joby['msg'];
//
//           showDialog(
//               context: context,
//               builder: (dialogContext) {
//                 return SimpleDialog(
//                   title: Text(jobTitle),
//                   contentPadding: const EdgeInsets.all(20),
//                   children: [Text(jobTitle1.toString())],
//                 );
//               });
//         }
//       } else {
//         // Handle non-200 responses (e.g., 404, 500)
//         showDialog(
//             context: context,
//             builder: (dialogContext) {
//               return SimpleDialog(
//                 title: const Text('API Error'),
//                 contentPadding: const EdgeInsets.all(20),
//                 children: [
//                   Text('Server responded with status code ${response.statusCode}.'),
//                   Text(response.body)
//                 ],
//               );
//             });
//       }
//     }
//     catch (error) {
//       // Ensure the loading dialog is closed if an error occurs
//       Navigator.of(context, rootNavigator: true).pop();
//
//       print("Login error: $error");
//       showDialog(
//           context: context,
//           builder: (dialogContext) {
//             return SimpleDialog(
//               title: const Text('Connection Error'),
//               contentPadding: const EdgeInsets.all(20),
//               children: [Text(error.toString())],
//             );
//           });
//     }
//
//
//     // -------------------------------------------------------------------------
//     // --- END: Live Login Logic ---
//     // -------------------------------------------------------------------------
//   }
//   void getqrresponse({required BuildContext context, required name, required pswd,required axpapp,required baseurl, String? qrcodes, required sessions}) async {
//     var headers = {'Content-Type': 'application/json'};
//     try {
//       var url = Uri.parse(baseurl + 'getchoices');
//       print("--------------->"+baseurl + 'getchoices');
//       Map body =
//       {
//         "_parameters": [
//           {
//             "getchoices":
//             {
//               "name": "pdcinv",
//               "axpapp": axpapp,
//               "username": name,
//               "password": pswd,
//               "s": "",
//               "sql":
//               "Select  ip.Ip_no,ip.uhid,ip.WARD_PATIENTNAME patname,cd.DOCTOR_NAME,cd.DOCTOR_SHRT Doctor_shortName,cw.WARD_NAME,cb.BED_NO,ip.attender_name  primary_care_taker,ip.CONTACT_NO primary_care_taker_no , case when ip.is_vip = 'T'  then 'VIP' else '' end is_vip from ip_admission ip join REGISTRATION r on r.uhid=ip.uhid join cm_ward cw on cw.CM_WARDID=ip.ward join cm_bed cb on cb.CM_BEDID=ip.BED_NO join cm_doctor cd on cd.cm_doctorid=ip.ATTENDING_PHYSICIAN join CM_SPECIALITY cs on cs.CM_SPECIALITYID=cd.SPECIALTY left join MG_PARTYHDR mp on mp.MG_PARTYHDRID=ip.COMPANY_name join cm_casetype cat on cat.cm_casetypeid=ip.case_type where  ip.ip_no ='" +
//                   qrcodes! +
//                   "' and ip.cancel='F'"
//             }
//           }
//         ]
//       };
//       http.Response response = await http.post(url, body: jsonEncode(body), headers: headers);
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> json = jsonDecode(response.body);
//
//         final List<dynamic> jobs = json['result'];
//
//         print('Ruby -=-= $json');
//
//         if (jobs[0]['error'].toString() == "null") {
//
//           final Map<String, dynamic> joby1 = jobs.first['result'];
//           print(joby1);
//           final List<dynamic> joby2 = joby1['row'];
//
//           final String ipNo = joby2[0]['ip_no'];
//           final String uhid = joby2[0]['uhid'];
//           final String patname = joby2[0]['patname'];
//           final String doctorName = joby2[0]['doctor_shortname'];
//           final String wardName = joby2[0]['ward_name'];
//           final String bedNo = joby2[0]['bed_no'];
//           final String primaryCareTakerNo = joby2[0]['primary_care_taker_no'];
//           final SharedPreferences prefs = await _prefs;
//           await prefs.setString('ip_no', ipNo);
//           await prefs.setString('uhid', uhid);
//           await prefs.setString('patname', patname);
//           await prefs.setString('doctor_name', doctorName);
//           await prefs.setString('ward_name', wardName);
//           await prefs.setString('bed_no', bedNo);
//           await prefs.setString('primary_care_taker_no', primaryCareTakerNo);
//           print('5400 -=-= REached enf');
//
//           //
//           // Navigate after success
//           Navigator.of(context).push(
//             MaterialPageRoute(builder: (c) => const Home()),
//           );
//           print('5400 -=-= REached after end');
//         }
//         // else  if (jobs[0]['error']['status'] == 'Failed') {
//         //   final Map<String, dynamic> joby = jobs.first['error'];
//         //   final String jobTitle = joby['msg'];
//         //   final String job11=joby['status'];
//         //   showDialog(
//         //       context: Get.context!,
//         //       builder: (context) {
//         //         return
//         //           SimpleDialog(
//         //             title: Text(job11),
//         //             contentPadding: const EdgeInsets.all(20),
//         //             children: [
//         //               Text(jobTitle.toString())
//         //             ],
//         //           );
//         //       });
//         // }
//       }
//     }
//     catch (error) {
//       Navigator.pop(context);
//
//       // showDialog(
//       //     context: Get.context!,
//       //     builder: (context) {
//       //       return SimpleDialog(
//       //         // title: const Text('Unit Mismatch'),
//       //         contentPadding: const EdgeInsets.all(20),
//       //         children: [Text('No data available for this Unit')],
//       //       );
//       //     });
//     }
//   }
//
// }
