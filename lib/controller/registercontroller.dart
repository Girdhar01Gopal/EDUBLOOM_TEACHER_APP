/*import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:playschool_admin/infrastructures/routes/page_constants.dart';
import 'package:playschool_admin/infrastructures/utils/local_storage/local_storage.dart';
import 'package:playschool_admin/infrastructures/utils/local_storage/pref_const.dart';
import 'package:playschool_admin/models/registermodel.dart';
import 'package:playschool_admin/res/app_url.dart';

class RegisterController extends GetxController {
  // Controllers for form fields
  TextEditingController schoolNameController = TextEditingController();
  TextEditingController schoolAddressController = TextEditingController();
  TextEditingController schoolContactController = TextEditingController();
  TextEditingController contactpersonname = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController districtcontroller = TextEditingController();
  TextEditingController schoolEmailController = TextEditingController();
  //TextEditingController pincodeController = TextEditingController();

  // Registration logic
  void registerSchool() {
    String schoolName = schoolNameController.text;
    String schoolAddress = schoolAddressController.text;
    String schoolContact = schoolContactController.text;
    String schoolEmail = schoolEmailController.text;

    // Add your registration logic here, like sending data to an API

    // Example print statement for debugging
    print('School Registered: $schoolName, $schoolAddress, $schoolContact, $schoolEmail');
  }

@override
 void onInit() {
    super.onInit();
    schoolContactController.text = Get.arguments['mobile'] ?? '';
  }
Future<void> register({
  required String schoolName,
  required String schoolAddress,
  required String schoolContact,
  required String schoolEmail,
  required String contactPersonName,
  required String city,
  required String state,
  required String district,
}) async {
  try {
    final uri = Uri.parse(
      "${AppUrl.base_url}api/SchoolApp/RegistrationApp",
    );

    final request = https.MultipartRequest('POST', uri);

    /// ✅ FORM-DATA fields
    request.fields.addAll({
      "Users": contactPersonName,
      "SchoolName": schoolName,
      "Email": schoolEmail,
      "Address": schoolAddress,
      "Phone": schoolContact,
      "City": city,
      "State": state,
      "Distec": district,
      "Action:": "1",
      "CurrentSession": "2026-27",
    });

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    debugPrint("Status: ${response.statusCode}");
    debugPrint("Body: $responseBody");

    if (response.statusCode != 200) {
      Get.snackbar("Error", "Server error ${response.statusCode}");
      return;
    }

    final decoded = jsonDecode(responseBody);
    final model = registermodel.fromJson(decoded);

    if ( model.data!.isEmpty) {
      Get.snackbar(
        "Error",
        model.messages?.toString() ?? "Registration failed",
      );
      return;
    }

    final user = model.data!.first;
    final result = await sendEdubloomUidPwdTemplate(
  apiKey: "910f3186-32a8-11ef-b1d4-02c8a5e042bd",
  phoneNumberId: "391229450729619",
  toNumber: schoolContact.toString(),
  schoolName: schoolName.toString(),
  userName: "${user.users}",
  password: "${user.password}",
  mobileNo: schoolContact.toString(),
);

if (result.ok) {
  print("Sent ✅ wamid=${result.wamid}, status=${result.status}");
} else {
  print("Failed ❌ ${result.errorMessage}");
  print("Raw: ${result.raw}");
}


    /// ✅ SAVE RESPONSE DATA
    await PrefManager().writeValue(
        key: PrefConst.isLoggedIn, value: "Yes");

    await PrefManager().writeValue(
        key: PrefConst.schollId, value: user.sclInfoId ?? "");

    await PrefManager().writeValue(
        key: PrefConst.schoolname, value: user.schoolName ?? "");

    await PrefManager().writeValue(
        key: PrefConst.Name, value: user.users ?? "");

    await PrefManager().writeValue(
        key: PrefConst.schoollogo, value: user.logoWithName ?? "");

    await PrefManager().writeValue(
        key: PrefConst.session, value: user.currentSession ?? "");

    Get.snackbar("Success", "School registered successfully");
    Get.offAllNamed(RouteName.dashboard_screen);

  } catch (e, s) {
    debugPrint("Register error: $e");
    debugPrintStack(stackTrace: s);
    Get.snackbar("Error", "Something went wrong");
  }
}


/// Converts "7351195961" -> "917351195961" (default India),
/// keeps "917351195961" as-is, strips spaces/+.
String normalizeToE164Digits(String input, {String defaultCountryCode = "91"}) {
  var digits = input.replaceAll(RegExp(r'[^0-9]'), '');

  // If user gave 10-digit Indian number, prefix with 91
  if (digits.length == 10 && defaultCountryCode.isNotEmpty) {
    digits = '$defaultCountryCode$digits';
  }

  return digits;
}

Future<WhatsAppSendResult> sendEdubloomUidPwdTemplate({
  required String apiKey, // Pinbot API key
  required String phoneNumberId, // the /v3/{phoneNumberId}/messages id
  required String toNumber, // "7351195961" or "917351195961"
  required String schoolName, // {{1}}
  required String userName,   // {{2}}
  required String password,   // {{3}} (not recommended)
  required String mobileNo,   // {{4}}
  String languageCode = "en",
  String imageLink =
      "https://whatsappdata.s3.ap-south-1.amazonaws.com/userMedia/c5c1cb0bebd56ae38817b251ad72bedb/edubllomusername.jpeg",
}) async {
  final to = normalizeToE164Digits(toNumber);

  final uri = Uri.parse("https://partnersv1.pinbot.ai/v3/$phoneNumberId/messages");

  final payload = {
    "messaging_product": "whatsapp",
    "to": to,
    "type": "template",
    "template": {
      "name": "edubloomuidpwd",
      "language": {"code": languageCode},
      "components": [
        {
          "type": "header",
          "parameters": [
            {
              "type": "image",
              "image": {"link": imageLink}
            }
          ]
        },
        {
          "type": "body",
          "parameters": [
            {"type": "text", "text": schoolName},
            {"type": "text", "text": userName},
            {"type": "text", "text": password},
            {"type": "text", "text": mobileNo},
          ]
        }
      ]
    }
  };
  print("Payload: ${jsonEncode(payload)}");

  try {
    final res = await https
        .post(
          uri,
          headers: {
            "apikey": "$apiKey",
            "Content-Type": "application/json",
          },
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 25));

    final Map<String, dynamic> json = jsonDecode(res.body);

    // Pinbot/Meta error format
    if (res.statusCode >= 400 || json["error"] != null) {
      final err = json["error"];
      final msg = err is Map ? (err["message"]?.toString() ?? "Unknown error") : "Unknown error";
      return WhatsAppSendResult(ok: false, raw: json, errorMessage: msg);
    }

    // Success format
    final messages = (json["messages"] as List?) ?? [];
    final wamid = messages.isNotEmpty ? messages.first["id"]?.toString() : null;
    final status = messages.isNotEmpty ? messages.first["message_status"]?.toString() : null;

    return WhatsAppSendResult(ok: true, wamid: wamid, status: status, raw: json);
  } catch (e) {
    return WhatsAppSendResult(ok: false, errorMessage: e.toString());
  }
}

  @override
  void onClose() {
    schoolNameController.dispose();
    schoolAddressController.dispose();
    schoolContactController.dispose();
    schoolEmailController.dispose();
    super.onClose();
  }
}

class WhatsAppSendResult {
  final bool ok;
  final String? wamid;
  final String? status;
  final Map<String, dynamic>? raw;
  final String? errorMessage;

  WhatsAppSendResult({
    required this.ok,
    this.wamid,
    this.status,
    this.raw,
    this.errorMessage,
  });
}*/


import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/registermodel.dart';
import '../models/session_model.dart';
import '../res/app_url.dart';

class RegisterController extends GetxController {
  // Controllers for form fields
  TextEditingController schoolNameController = TextEditingController();
  TextEditingController schoolAddressController = TextEditingController();
  TextEditingController schoolContactController = TextEditingController();
  TextEditingController contactpersonname = TextEditingController();
  TextEditingController citycontroller = TextEditingController();
  TextEditingController statecontroller = TextEditingController();
  TextEditingController districtcontroller = TextEditingController();
  TextEditingController schoolEmailController = TextEditingController();
  //TextEditingController pincodeController = TextEditingController();

  final RxString currentSession = ''.obs;
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  // Registration logic
  void registerSchool() {
    String schoolName = schoolNameController.text;
    String schoolAddress = schoolAddressController.text;
    String schoolContact = schoolContactController.text;
    String schoolEmail = schoolEmailController.text;

    // Add your registration logic here, like sending data to an API

    // Example print statement for debugging
    print('School Registered: $schoolName, $schoolAddress, $schoolContact, $schoolEmail');
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    schoolContactController.text = Get.arguments['mobile'] ?? '';
    await fetchSessionList();
  }

  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final url = Uri.parse(
        "${AppUrl.base_url}${AppUrl.view_session}0",
      );
      final res = await https.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final model = SessionModel.fromJson(data);
        final list = model.listData ?? [];

        sessionList.value = list
            .map((s) => s.session ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

        final current = model.currentSession?.session?.trim();
        if (current != null && current.isNotEmpty) {
          currentSession.value = current;
        } else if (sessionList.isNotEmpty) {
          currentSession.value = sessionList.first;
        }
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    } finally {
      isSessionLoading(false);
    }
  }



  Future<void> register({
    required String schoolName,
    required String schoolAddress,
    required String schoolContact,
    required String schoolEmail,
    required String contactPersonName,
    required String city,
    required String state,
    required String district,
  }) async {
    try {
      final uri = Uri.parse(
        "${AppUrl.base_url}api/SchoolApp/RegistrationApp",
      );

      final request = https.MultipartRequest('POST', uri);

      /// ✅ FORM-DATA fields
      request.fields.addAll({
        "Users": contactPersonName,
        "SchoolName": schoolName,
        "Email": schoolEmail,
        "Address": schoolAddress,
        "Phone": schoolContact,
        "City": city,
        "State": state,
        "Distec": district,
        "Action:": "1",
        "CurrentSession": currentSession.value,
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: $responseBody");

      if (response.statusCode != 200) {
        Get.snackbar("Error", "Server error ${response.statusCode}");
        return;
      }

      final decoded = jsonDecode(responseBody);
      final model = registermodel.fromJson(decoded);

      if ( model.data!.isEmpty) {
        Get.snackbar(
          "Error",
          model.messages?.toString() ?? "Registration failed",
        );
        return;
      }

      final user = model.data!.first;
      final result = await sendEdubloomUidPwdTemplate(
        apiKey: "910f3186-32a8-11ef-b1d4-02c8a5e042bd",
        phoneNumberId: "391229450729619",
        toNumber: schoolContact.toString(),
        schoolName: schoolName.toString(),
        userName: "${user.users}",
        password: "${user.password}",
        mobileNo: schoolContact.toString(),
      );

      if (result.ok) {
        print("Sent ✅ wamid=${result.wamid}, status=${result.status}");
      } else {
        print("Failed ❌ ${result.errorMessage}");
        print("Raw: ${result.raw}");
      }


      /// ✅ SAVE RESPONSE DATA
      await PrefManager().writeValue(
          key: PrefConst.isLoggedIn, value: "Yes");

      await PrefManager().writeValue(
          key: PrefConst.schollId, value: user.sclInfoId ?? "");

      await PrefManager().writeValue(
          key: PrefConst.schoolname, value: user.schoolName ?? "");

      await PrefManager().writeValue(
          key: PrefConst.Name, value: user.users ?? "");

      await PrefManager().writeValue(
          key: PrefConst.schoollogo, value: user.logoWithName ?? "");

      await PrefManager().writeValue(
          key: PrefConst.session, value: user.currentSession ?? "");

      Get.snackbar("Success", "School registered successfully");
      Get.offAllNamed(RouteName.dashboard_screen);

    } catch (e, s) {
      debugPrint("Register error: $e");
      debugPrintStack(stackTrace: s);
      Get.snackbar("Error", "Something went wrong");
    }
  }


  /// Converts "7351195961" -> "917351195961" (default India),
  /// keeps "917351195961" as-is, strips spaces/+.
  String normalizeToE164Digits(String input, {String defaultCountryCode = "91"}) {
    var digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    // If user gave 10-digit Indian number, prefix with 91
    if (digits.length == 10 && defaultCountryCode.isNotEmpty) {
      digits = '$defaultCountryCode$digits';
    }

    return digits;
  }

  Future<WhatsAppSendResult> sendEdubloomUidPwdTemplate({
    required String apiKey, // Pinbot API key
    required String phoneNumberId, // the /v3/{phoneNumberId}/messages id
    required String toNumber, // "7351195961" or "917351195961"
    required String schoolName, // {{1}}
    required String userName,   // {{2}}
    required String password,   // {{3}} (not recommended)
    required String mobileNo,   // {{4}}
    String languageCode = "en",
    String imageLink =
    "https://whatsappdata.s3.ap-south-1.amazonaws.com/userMedia/c5c1cb0bebd56ae38817b251ad72bedb/edubllomusername.jpeg",
  }) async {
    final to = normalizeToE164Digits(toNumber);

    final uri = Uri.parse("https://partnersv1.pinbot.ai/v3/$phoneNumberId/messages");

    final payload = {
      "messaging_product": "whatsapp",
      "to": to,
      "type": "template",
      "template": {
        "name": "edubloomuidpwd",
        "language": {"code": languageCode},
        "components": [
          {
            "type": "header",
            "parameters": [
              {
                "type": "image",
                "image": {"link": imageLink}
              }
            ]
          },
          {
            "type": "body",
            "parameters": [
              {"type": "text", "text": schoolName},
              {"type": "text", "text": userName},
              {"type": "text", "text": password},
              {"type": "text", "text": mobileNo},
            ]
          }
        ]
      }
    };
    print("Payload: ${jsonEncode(payload)}");

    try {
      final res = await https
          .post(
        uri,
        headers: {
          "apikey": "$apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 25));

      final Map<String, dynamic> json = jsonDecode(res.body);

      // Pinbot/Meta error format
      if (res.statusCode >= 400 || json["error"] != null) {
        final err = json["error"];
        final msg = err is Map ? (err["message"]?.toString() ?? "Unknown error") : "Unknown error";
        return WhatsAppSendResult(ok: false, raw: json, errorMessage: msg);
      }

      // Success format
      final messages = (json["messages"] as List?) ?? [];
      final wamid = messages.isNotEmpty ? messages.first["id"]?.toString() : null;
      final status = messages.isNotEmpty ? messages.first["message_status"]?.toString() : null;

      return WhatsAppSendResult(ok: true, wamid: wamid, status: status, raw: json);
    } catch (e) {
      return WhatsAppSendResult(ok: false, errorMessage: e.toString());
    }
  }

  @override
  void onClose() {
    schoolNameController.dispose();
    schoolAddressController.dispose();
    schoolContactController.dispose();
    schoolEmailController.dispose();
    super.onClose();
  }
}

class WhatsAppSendResult {
  final bool ok;
  final String? wamid;
  final String? status;
  final Map<String, dynamic>? raw;
  final String? errorMessage;

  WhatsAppSendResult({
    required this.ok,
    this.wamid,
    this.status,
    this.raw,
    this.errorMessage,
  });
}

