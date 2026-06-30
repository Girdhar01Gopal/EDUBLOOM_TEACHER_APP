import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/descriptors_model.dart';
import '../models/session_model.dart';
import '../res/app_url.dart';

class DescriptorsController extends GetxController {
  final TextEditingController descriptorsController = TextEditingController();

  final RxBool isPosting = false.obs;
  final RxBool isListLoading = false.obs;

  final RxList<SubjectProgressItem> descriptorsList =
      <SubjectProgressItem>[].obs;
  final RxList<SubjectProgressItem> filteredList =
      <SubjectProgressItem>[].obs;

  String schoolId = "";
  String session = "";

  // =========================================================
  // Lifecycle
  // =========================================================
  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await _fetchCurrentSession();
    await fetchDescriptors();
  }

  @override
  void onClose() {
    descriptorsController.dispose();
    super.onClose();
  }

  // =========================================================
  // GET: Current Session from ViewSessionApp
  // =========================================================
  Future<void> _fetchCurrentSession() async {
    try {
      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.view_session}$schoolId',
      );

      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final sessionModel = SessionModel.fromJson(decoded);
        session =
            sessionModel.currentSession?.session?.toString().trim() ?? "";
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    }
  }

  // =========================================================
  // GET: View Descriptors
  // ✅ URL: api/Result/ViewDescriptors/$schoolId/$session
  // =========================================================
  Future<void> fetchDescriptors() async {
    try {
      isListLoading(true);

      if (session.trim().isEmpty) {
        await _fetchCurrentSession();
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/Result/ViewDescriptors/$schoolId/$session',
      );

      final res = await http.get(url, headers: _headers);

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final parsed = SubjectProgressResponse.fromJson(decoded);
        descriptorsList.assignAll(parsed.listData);
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
  // Search
  // =========================================================
  void searchDescriptor(String value) {
    if (value.trim().isEmpty) {
      filteredList.assignAll(descriptorsList);
      return;
    }
    filteredList.assignAll(
      descriptorsList
          .where((item) => (item.descriptors ?? "")
          .toLowerCase()
          .contains(value.toLowerCase()))
          .toList(),
    );
  }

  // =========================================================
  // POST: Add Descriptor
  // ✅ URL: api/Result/PostDescriptors
  // ✅ Body: subjectProgressId, descriptors, createBy, action, schoolId, session
  // =========================================================
  Future<void> addDescriptor() async {
    final String text = descriptorsController.text.trim();

    if (text.isEmpty) {
      Get.snackbar("Validation", "Descriptors cannot be empty");
      return;
    }

    try {
      isPosting(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/Result/PostDescriptors',
      );

      final Map<String, dynamic> body = {
        "subjectProgressId": 0,
        "descriptors": text,
        "createBy": "admin",
        "action": "1",
        "schoolId": schoolId,
        "session": session,
      };

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      final Map<String, dynamic> decoded =
      res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (decoded["isSuccess"] == true) {
          descriptorsController.clear();
          await fetchDescriptors();
          Get.snackbar(
              "Success", decoded["messages"] ?? "Descriptor saved successfully.");
        } else {
          Get.snackbar(
              "Error", decoded["messages"] ?? "Unable to save descriptor.");
        }
      } else {
        Get.snackbar(
          "Error",
          decoded["messages"] ?? "Failed to save (${res.statusCode})",
        );
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
  void openEditDescriptorDialog(SubjectProgressItem item) {
    final TextEditingController editController =
    TextEditingController(text: item.descriptors ?? "");

    Get.defaultDialog(
      title: "Edit Descriptors",
      radius: 8,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: "Enter Descriptors",
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
                final String updatedText =
                editController.text.trim();
                if (updatedText.isEmpty) {
                  Get.snackbar(
                      "Validation", "Descriptors cannot be empty");
                  return;
                }
                await updateDescriptor(item, updatedText);
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
  // POST: Update Descriptor
  // ✅ Same API: PostDescriptors, subjectProgressId > 0 = update
  // =========================================================
  Future<void> updateDescriptor(
      SubjectProgressItem item,
      String updatedText,
      ) async {
    try {
      isPosting(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/Result/PostDescriptors',
      );

      final Map<String, dynamic> body = {
        "subjectProgressId": item.subjectProgressId ?? 0,
        "descriptors": updatedText,
        "createBy":
        (item.createBy != null && item.createBy!.isNotEmpty)
            ? item.createBy
            : "admin",
        "action":
        (item.action != null && item.action!.isNotEmpty)
            ? item.action
            : "1",
        "schoolId":
        (item.schoolId != null && item.schoolId!.isNotEmpty)
            ? item.schoolId
            : schoolId,
        "session":
        (item.session != null && item.session!.isNotEmpty)
            ? item.session
            : session,
      };

      final res = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      final Map<String, dynamic> decoded =
      res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (decoded["isSuccess"] == true) {
          Get.back();
          await fetchDescriptors();
          Get.snackbar("Success",
              decoded["messages"] ?? "Descriptor updated successfully.");
        } else {
          Get.snackbar(
              "Error", decoded["messages"] ?? "Unable to update descriptor.");
        }
      } else {
        Get.snackbar(
          "Error",
          decoded["messages"] ?? "Failed to update (${res.statusCode})",
        );
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
    await _fetchCurrentSession();
    await fetchDescriptors();
  }

  DateTime? parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  void _clearLists() {
    descriptorsList.clear();
    filteredList.clear();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}