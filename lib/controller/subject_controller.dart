import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/subject_model.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

class SubjectController extends GetxController {
  final TextEditingController subject = TextEditingController();

  var schoolId;
  final isLoading = false.obs;

  final subjectdata = SubjectModel().obs;

  // ✅ NEW: search box state (used by the search bar under the AppBar)
  final searchQuery = ''.obs;

  void updateSearchQuery(String value) {
    searchQuery.value = value;
  }

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    if (schoolId == null || schoolId.toString().trim().isEmpty) {
      AppSnackbar.error("SchoolId not found");
      return;
    }

    await fetchsubjectdata();
  }

  @override
  void onClose() {
    subject.dispose();
    super.onClose();
  }

  // =========================
  // ADD SUBJECT (POST)
  // =========================
  Future<void> postSubject(BuildContext context) async {
    final name = subject.text.trim();
    if (name.isEmpty) {
      AppSnackbar.error("Enter subject name", title: "Validation");
      return;
    }

    final url = Uri.parse("${AppUrl.base_url}${AppUrl.post_subject}");
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({
      "subjectId": 0,
      "subject": name,
      "action": "1",
      "schoolId": schoolId,
    });

    try {
      isLoading(true);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Clear input
        subject.clear();

        // Refresh list
        await fetchsubjectdata();

        // Snackbar
        AppSnackbar.success("Subject added successfully!");
      } else {
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "Subject Add Failed | Status: ${response.statusCode}\n${response.body}",
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading(false);
    }
  }

  // =========================
  // OPEN EDIT DIALOG
  // =========================
  Future<void> openEditSubjectDialog(BuildContext context, dynamic subjectItem) async {
    final TextEditingController editCtrl = TextEditingController(
      text: (subjectItem.subject ?? "").toString(),
    );

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Subject"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editCtrl,
              decoration: InputDecoration(
                labelText: "Subject Name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => isLoading.value
                ? const LinearProgressIndicator()
                : const SizedBox.shrink()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink.shade600),
            onPressed: () async {
              final newName = editCtrl.text.trim();
              if (newName.isEmpty) {
                AppSnackbar.error("Subject name required", title: "Validation");
                return;
              }

              await updateSubject(
                context: context,
                subjectId: subjectItem.subjectId,
                subjectName: newName,
              );
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // =========================
  // UPDATE SUBJECT (POST)
  // =========================
  Future<void> updateSubject({
    required BuildContext context,
    required dynamic subjectId,
    required String subjectName,
  }) async {
    final url = Uri.parse("${AppUrl.base_url}${AppUrl.post_subject}");
    final headers = {'Content-Type': 'application/json'};

    // ✅ action "2" assumed for update (change to "1" if backend uses upsert)
    final body = jsonEncode({
      "subjectId": subjectId,
      "subject": subjectName,
      "action": "2",
      "schoolId": schoolId,
    });

    try {
      isLoading(true);

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Close dialog
        Get.back();

        AppSnackbar.success("Subject updated successfully");

        // Refresh list
        await fetchsubjectdata();
      } else {
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "Update Failed | Status: ${response.statusCode}\n${response.body}",
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading(false);
    }
  }

  // =========================
  // FETCH SUBJECT LIST (GET)
  // =========================
  Future<void> fetchsubjectdata() async {
    try {
      isLoading(true);

      final url = Uri.parse('${AppUrl.base_url}${AppUrl.view_subject}$schoolId');

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        subjectdata.value = SubjectModel.fromJson(data);
      } else {
        AppSnackbar.apiError(
          "Fetch Failed | Status: ${response.statusCode}\n${response.body}",
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading(false);
    }
  }
}