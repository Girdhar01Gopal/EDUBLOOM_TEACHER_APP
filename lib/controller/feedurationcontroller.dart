import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/feedurationmodel.dart';
import '../models/session_model.dart';      // ✅ ADD THIS IMPORT
import '../res/app_url.dart';               // ✅ ADD THIS IMPORT

class FeeDurationController extends GetxController {
  final TextEditingController feesDurationController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;

  final Rxn<FeeDurationMaster> feeDurationMaster = Rxn<FeeDurationMaster>();

  // ✅ CHANGE 1: hardcoded string hatao, dynamic list banao
  final RxString session = ''.obs;
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  String? schoolId;

  final String postUrl =
      "https://playschool.edubloom.in/api/FeeMasterApp/PostFeeDurationsApp";
  final String viewBaseUrl =
      "https://playschool.edubloom.in/api/FeeMasterApp/ViewFeesDurationApp/";

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    if (schoolId == null || schoolId!.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    // ✅ CHANGE 2: fetchSessionList pehle call karo
    await fetchSessionList();
    await fetchFeeDurations();
  }

  // ✅ CHANGE 3: yeh naya method add karo, baaki sab same
  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final url = Uri.parse(
        "${AppUrl.base_url}${AppUrl.view_session}$schoolId",
      );
      final res = await http.get(
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

        // current session ko default select karo
        final current = model.currentSession?.session?.trim();
        if (current != null && current.isNotEmpty) {
          session.value = current;
        } else if (sessionList.isNotEmpty) {
          session.value = sessionList.first;
        }
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    } finally {
      isSessionLoading(false);
    }
  }

  @override
  void onClose() {
    feesDurationController.dispose();
    super.onClose();
  }

  // ══════════════════════════════════════════════
  // BAAKI SAB EXACT SAME — EK BHI LINE NAHI BADI
  // ══════════════════════════════════════════════

  Future<void> fetchFeeDurations() async {
    try {
      isLoading(true);

      final url = Uri.parse("$viewBaseUrl${Uri.encodeComponent(schoolId!)}");
      final res =
      await http.get(url, headers: {"Content-Type": "application/json"});

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(res.body);
        final parsed = FeeDurationMaster.fromJson(jsonMap);
        feeDurationMaster.value = parsed;

        final apiSession = parsed.currentSession?.toString().trim();
        if (apiSession != null && apiSession.isNotEmpty) {
          session.value = apiSession;
        }
      } else {
        Get.snackbar("Error", "View API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch failed: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> addFeeDuration() async {
    final duration = feesDurationController.text.trim();

    if (duration.isEmpty) {
      Get.snackbar("Validation", "Fee Duration cannot be empty");
      return;
    }

    try {
      isPosting(true);

      final url = Uri.parse(postUrl);

      final body = {
        "feesDurationId": 0,
        "feesDuration": duration,
        "action": "1",
        "schoolId": schoolId,
        "session": session.value,
        "createBy": "",
        "updateBy": ""
      };

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonMap = jsonDecode(res.body);
      final apiRes = ApiResponseModel.fromJson(jsonMap);

      if (apiRes.isSuccess == true) {
        Get.snackbar(
          "Success",
          apiRes.messages.isEmpty ? "Saved" : apiRes.messages,
        );
        feesDurationController.clear();
        await fetchFeeDurations();
      } else {
        Get.snackbar(
          "Failed",
          apiRes.messages.isEmpty ? "Not saved" : apiRes.messages,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Add failed: $e");
    } finally {
      isPosting(false);
    }
  }

  void openEditFeeDurationDialog(dynamic item) {
    final TextEditingController editCtrl =
    TextEditingController(text: item.feesDuration.toString());

    Get.defaultDialog(
      title: "Edit Fee Duration",
      content: Column(
        children: [
          TextField(
            controller: editCtrl,
            decoration: const InputDecoration(
              hintText: "Enter Fee Duration",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPosting.value
                    ? null
                    : () async {
                  final newDuration = editCtrl.text.trim();

                  if (newDuration.isEmpty) {
                    Get.snackbar(
                        "Validation", "Fee Duration cannot be empty");
                    return;
                  }

                  await updateFeeDuration(
                    feesDurationId: item.feesDurationId,
                    feesDuration: newDuration,
                  );
                },
                child: isPosting.value
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Update"),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> updateFeeDuration({
    required int feesDurationId,
    required String feesDuration,
  }) async {
    try {
      isPosting(true);

      final url = Uri.parse(postUrl);

      final body = {
        "feesDurationId": feesDurationId,
        "feesDuration": feesDuration,
        "action": "2",
        "schoolId": schoolId,
        "session": session.value,
        "createBy": "",
        "updateBy": ""
      };

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonMap = jsonDecode(res.body);
      final apiRes = ApiResponseModel.fromJson(jsonMap);

      if (apiRes.isSuccess == true) {
        Get.back();
        Get.snackbar(
          "Success",
          apiRes.messages.isEmpty ? "Updated" : apiRes.messages,
        );
        await fetchFeeDurations();
      } else {
        Get.snackbar(
          "Failed",
          apiRes.messages.isEmpty ? "Not updated" : apiRes.messages,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isPosting(false);
    }
  }
}