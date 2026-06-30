import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/foundational_skills_model.dart';
import '../models/session_model.dart';
import '../res/app_url.dart';

class FoundationalSkillsController extends GetxController {
  // ========= Text Controllers =========
  final TextEditingController foundationalSkillsController =
  TextEditingController();

  // ========= Loaders =========
  final RxBool isPosting = false.obs;
  final RxBool isListLoading = false.obs;

  // ========= Data =========
  final RxList<FoundationalSkillItem> foundationalSkillsList =
      <FoundationalSkillItem>[].obs;
  final RxList<FoundationalSkillItem> filteredList =
      <FoundationalSkillItem>[].obs;

  // ========= School & Session =========
  String schoolId = "";
  String session = ""; // ✅ fetched directly from ViewSessionApp API

  // ========= Lifecycle =========
  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    // ✅ First fetch session, then load list
    await _fetchCurrentSession();
    await fetchFoundationalSkills();
  }

  @override
  void onClose() {
    foundationalSkillsController.dispose();
    super.onClose();
  }

  // =========================================================
  // GET: Fetch Current Session from ViewSessionApp
  // =========================================================
  Future<void> _fetchCurrentSession() async {
    try {
      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.view_session}$schoolId',
      );

      final res = await http.get(url, headers: _headers);

      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        Get.snackbar("Error",
            "Session API unexpected response (${res.statusCode})");
        return;
      }

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final sessionModel = SessionModel.fromJson(decoded);

        // ✅ currentSession se session string lo
        session =
            sessionModel.currentSession?.session?.toString().trim() ?? "";

        if (session.isEmpty) {
          Get.snackbar("Error",
              "No active session found. Please set a session first.");
        }
      } else {
        Get.snackbar("Error",
            "Failed to fetch session (${res.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Session fetch error: $e");
    }
  }

  // =========================================================
  // GET: Fetch Foundational Skills
  // =========================================================
  Future<void> fetchFoundationalSkills() async {
    try {
      isListLoading(true);

      if (session.trim().isEmpty) {
        // ✅ Try fetching session once more before giving up
        await _fetchCurrentSession();
        if (session.trim().isEmpty) {
          Get.snackbar("Error", "Session not found. Please login again.");
          return;
        }
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/Result/ViewFoundationalSkills/$schoolId/$session',
      );

      final res = await http.get(url, headers: _headers);

      final contentType = res.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        _clearLists();
        Get.snackbar(
            "Error", "Unexpected server response (${res.statusCode})");
        return;
      }

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = FoundationalSkillsResponse.fromJson(decoded);
        foundationalSkillsList.assignAll(parsed.listData);
        filteredList.assignAll(parsed.listData);
      } else {
        _clearLists();
        Get.snackbar("Error", "Failed to load data (${res.statusCode})");
      }
    } catch (e) {
      _clearLists();
      Get.snackbar("Error", "Fetch error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // =========================================================
  // Search / Filter
  // =========================================================
  void searchFoundationalSkill(String value) {
    if (value.trim().isEmpty) {
      filteredList.assignAll(foundationalSkillsList);
      return;
    }
    filteredList.assignAll(
      foundationalSkillsList
          .where((item) => item.foundationalSkills
          .toLowerCase()
          .contains(value.toLowerCase()))
          .toList(),
    );
  }

  // =========================================================
  // POST: Add Foundational Skill
  // =========================================================
  Future<void> addFoundationalSkill() async {
    final text = foundationalSkillsController.text.trim();

    if (text.isEmpty) {
      Get.snackbar("Validation", "Foundational Skills cannot be empty");
      return;
    }

    if (session.trim().isEmpty) {
      Get.snackbar("Error", "Session not found. Please login again.");
      return;
    }

    try {
      isPosting(true);

      final url = Uri.parse(
          '${AppUrl.base_url}api/Result/PostFoundationalSkills');

      final body = {
        "id": 0,
        "foundationalSkills": text,
        "action": "1",
        "createDate": DateTime.now().toUtc().toIso8601String(),
        "updateDate": DateTime.now().toUtc().toIso8601String(),
        "createBy": "admin",
        "updateBy": "admin",
        "schoolId": schoolId,
        "session": session,
      };

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (!_isJson(res)) {
        Get.snackbar("Error", "Server error (${res.statusCode})");
        return;
      }

      final decoded = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (decoded["isSuccess"] == true) {
          foundationalSkillsController.clear();
          await fetchFoundationalSkills();
          Get.snackbar("Success", decoded["messages"] ?? "Added successfully");
        } else {
          Get.snackbar("Error", decoded["messages"] ?? "Something went wrong");
        }
      } else if (res.statusCode == 409) {
        Get.snackbar("Duplicate",
            decoded["messages"] ?? "Skill already exists for this school.");
      } else {
        Get.snackbar("Error",
            decoded["messages"] ?? "POST failed (${res.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Add failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // =========================================================
  // Edit Dialog
  // =========================================================
  void openEditFoundationalSkillDialog(FoundationalSkillItem item) {
    final TextEditingController editController =
    TextEditingController(text: item.foundationalSkills);

    Get.defaultDialog(
      title: "Edit Foundational Skills",
      radius: 8,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: "Enter Foundational Skills",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPosting.value
                  ? null
                  : () async {
                final updatedText = editController.text.trim();
                if (updatedText.isEmpty) {
                  Get.snackbar(
                      "Validation", "Field cannot be empty");
                  return;
                }
                await updateFoundationalSkill(item, updatedText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
              ),
              child: isPosting.value
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Text("Update",
                  style: TextStyle(color: Colors.white)),
            ),
          )),
        ],
      ),
    );
  }

  // =========================================================
  // POST: Update Foundational Skill
  // =========================================================
  Future<void> updateFoundationalSkill(
      FoundationalSkillItem item,
      String updatedText,
      ) async {
    try {
      isPosting(true);

      final url = Uri.parse(
          '${AppUrl.base_url}api/Result/PostFoundationalSkills');

      final body = {
        "id": item.id,
        "foundationalSkills": updatedText,
        "action": item.action.isEmpty ? "1" : item.action,
        "createDate": item.createDate.toUtc().toIso8601String(),
        "updateDate": DateTime.now().toUtc().toIso8601String(),
        "createBy": item.createBy.isNotEmpty ? item.createBy : "admin",
        "updateBy": "admin",
        "schoolId": item.schoolId.isNotEmpty ? item.schoolId : schoolId,
        "session": (item.session != null && item.session!.isNotEmpty)
            ? item.session
            : session,
      };

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (!_isJson(res)) {
        Get.snackbar("Error", "Server error (${res.statusCode})");
        return;
      }

      final decoded = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (decoded["isSuccess"] == true) {
          Get.back();
          await fetchFoundationalSkills();
          Get.snackbar(
              "Success", decoded["messages"] ?? "Updated successfully");
        } else {
          Get.snackbar("Error", decoded["messages"] ?? "Something went wrong");
        }
      } else if (res.statusCode == 409) {
        Get.snackbar("Duplicate",
            decoded["messages"] ?? "Skill already exists for this school.");
      } else {
        Get.snackbar("Error",
            decoded["messages"] ?? "Update failed (${res.statusCode})");
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // =========================================================
  // Helpers
  // =========================================================
  Future<void> refreshList() async {
    await _fetchCurrentSession(); // ✅ session bhi refresh hoga
    await fetchFoundationalSkills();
  }

  void resetForm() => foundationalSkillsController.clear();

  void _clearLists() {
    foundationalSkillsList.clear();
    filteredList.clear();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  bool _isJson(http.Response res) {
    final ct = res.headers['content-type'] ?? '';
    return ct.contains('application/json');
  }
}