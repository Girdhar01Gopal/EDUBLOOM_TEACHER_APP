import 'dart:convert';
import 'package:flutter/services.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/session_model.dart';
import '../res/app_url.dart';

class SessionController extends GetxController {
  final TextEditingController sessionController = TextEditingController();
  var tempSelectedSession = Rx<sListDdata?>(null);

  var schoolId;

  final sessionData = SessionModel().obs;
  var selectedSessionId = 0.obs;
  var isLoading = true.obs;

  @override
  void onInit() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    await fetchSessionData();
    super.onInit();
  }

  // ✅ Edit dialog
  void openEditSessionDialog(sListDdata session) {
    final TextEditingController editCtrl = TextEditingController(
      text: session.session?.toString() ?? "",
    );

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Session"),
        content: TextField(
          controller: editCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            // ✅ Strict YYYY-YY formatter (same logic, no other file dependency)
            TextInputFormatter.withFunction((oldValue, newValue) {
              String text = newValue.text.replaceAll(RegExp(r'[^0-9-]'), '');
              if (text.length > 7) return oldValue;

              if (text.length > 4 && !text.contains('-')) {
                text = '${text.substring(0, 4)}-${text.substring(4)}';
              }

              final okPartial = RegExp(r'^\d{0,4}(-\d{0,2})?$').hasMatch(text);
              if (!okPartial) return oldValue;

              return TextEditingValue(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            }),
          ],
          decoration: const InputDecoration(
            hintText: "e.g., 2025-26",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newVal = editCtrl.text.trim();

              // ✅ final strict validation
              if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(newVal)) {
                ShortMessage.toast(title: "Session must be like 2025-26");
                return;
              }

              await postSession(
                sessionId: session.sessionId ?? 0,
                sessionText: newVal,
              );

              Get.back();
              await fetchSessionData();
            },
            child: const Text("Save"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> updateCurrentSession(sListDdata session) async {
    final url = Uri.parse("${AppUrl.base_url}api/MasterApp/PostCurrentSessionApp");

    final payload = {
      "currentSessionId": session.sessionId,
      "currentSession": session.session,
      "action": "1",
      "createDate": DateTime.now().toIso8601String(),
      "updateDate": DateTime.now().toIso8601String(),
      "schoolId": session.schoolId
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      ShortMessage.toast(title: "Session updated successfully");

      selectedSessionId.value = session.sessionId ?? 0;

      await fetchSessionData();

      await PrefManager().writeValue(key: PrefConst.isLoggedIn, value: "No");
      Get.offAllNamed(RouteName.login_screen);
      ShortMessage.toast(title: "To apply session change, please login again");
    } else {
      ShortMessage.toast(title: "Failed to update session");
    }
  }

  // ✅ Add + Edit same API (sessionId 0=add, >0=edit)
  Future<void> postSession({int sessionId = 0, String? sessionText}) async {
    final url = Uri.parse("${AppUrl.base_url}${AppUrl.post_session}");

    final payload = {
      "sessionId": sessionId,
      "session": (sessionText ?? sessionController.text).trim(),
      "action": "1",
      "schoolId": schoolId
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      if (sessionId == 0) sessionController.clear();
      ShortMessage.toast(title: "Request was successful");
      Get.back();
    } else {
      ShortMessage.toast(title: "Request was Not successful");
      debugPrint("POST session failed: ${response.statusCode} | ${response.body}");
    }
  }

  Future<void> fetchSessionData() async {
    try {
      isLoading(true);

      final url = Uri.parse('${AppUrl.base_url}${AppUrl.view_session}$schoolId');

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        sessionData.value = SessionModel.fromJson(data);

        if (sessionData.value.currentSession?.sessionId != null) {
          selectedSessionId.value = sessionData.value.currentSession!.sessionId!;
        }
      } else {
        debugPrint("Fetch session failed: ${response.statusCode} | ${response.body}");
      }
    } finally {
      isLoading(false);
    }
  }

  // ✅ Toggle session status (active/inactive)
  Future<void> toggleSessionStatus(sListDdata session) async {
    // Toggle the action value (1 = active, 0 = inactive)
    session.action = (session.action == '1') ? '0' : '1';

    // Update session status on the server
    await updateSessionStatusOnServer(session);

    // Provide feedback to the user
    Get.snackbar(
      'Session Status Updated',
      session.action == '1' ? 'Session is now Active' : 'Session is now Inactive',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // Example method to update session status on the server
  Future<void> updateSessionStatusOnServer(sListDdata session) async {
    final url = Uri.parse("${AppUrl.base_url}/api/updateSessionStatus");

    final payload = {
      'sessionId': session.sessionId,
      'action': session.action,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      // Handle success response if needed
    } else {
      // Handle failure response if needed
    }
  }

  @override
  void onClose() {
    sessionController.dispose();
    super.onClose();
  }
}