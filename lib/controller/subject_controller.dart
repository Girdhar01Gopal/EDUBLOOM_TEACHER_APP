import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/subject_model.dart';
import '../res/app_url.dart';

class SubjectController extends GetxController {
  final TextEditingController subject = TextEditingController();

  var schoolId;
  final isLoading = false.obs;

  final subjectdata = SubjectModel().obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    if (schoolId == null || schoolId.toString().trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
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
      Get.snackbar("Validation", "Enter subject name");
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Subject added successfully!",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        Get.snackbar(
          "Subject Add Failed",
          "Status: ${response.statusCode}\n${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Post error: $e");
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
                Get.snackbar("Validation", "Subject name required");
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

        Get.snackbar(
          "Success",
          "Subject updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh list
        await fetchsubjectdata();
      } else {
        Get.snackbar(
          "Update Failed",
          "Status: ${response.statusCode}\n${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Update error: $e");
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
        Get.snackbar(
          "Fetch Failed",
          "Status: ${response.statusCode}\n${response.body}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch error: $e");
    } finally {
      isLoading(false);
    }
  }
}