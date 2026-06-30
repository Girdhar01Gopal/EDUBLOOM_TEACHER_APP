import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/class_list_model.dart';


class ClassController extends GetxController {
  final TextEditingController classID = TextEditingController();
  final TextEditingController clas = TextEditingController();

  final isLoading = false.obs;
  final isPosting = false.obs;

  String? schoolId;

  final classList = ClassListModel(listData: []).obs;

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    if (schoolId == null || schoolId!.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "SchoolId not found in storage",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    await fetchClasses();
  }

  String formatDDMMYYYY(DateTime? d) {
    if (d == null) return "-";
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return "$dd-$mm-$yyyy";
  }

  // =========================
  // POST CLASS
  // =========================
  Future<void> postClass({
    required String className,
  }) async {
    try {
      isPosting(true);

      final url = Uri.parse(
        "https://playschool.edubloom.in/api/MasterApp/PostClassApp",
      );

      final body = jsonEncode({
        "classId": "0",
        "class": className.trim(),
        "action": "1",
        "schoolId": schoolId,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        clearFields();
        await fetchClasses();

        Get.snackbar(
          "Success",
          "Class posted successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Post Failed",
          "Status: ${response.statusCode}\n${response.body}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Post error: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPosting(false);
    }
  }

  // =========================
  // FETCH CLASSES
  // =========================
  Future<void> fetchClasses() async {
    try {
      isLoading(true);

      if (schoolId == null || schoolId!.trim().isEmpty) {
        throw Exception("SchoolId is null or empty");
      }

      final encodedSchoolId = Uri.encodeComponent(schoolId!.trim());
      final url = Uri.parse(
        "https://playschool.edubloom.in/api/MasterApp/ViewClass/$encodedSchoolId",
      );

      final response = await http.get(
        url,
        headers: {
          "accept": "*/*",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          classList.value = ClassListModel.fromJson(decoded);
        } else {
          classList.value = ClassListModel(listData: []);
          Get.snackbar(
            "Error",
            "Invalid response format from API",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        classList.value = ClassListModel(listData: []);
        Get.snackbar(
          "Fetch Failed",
          "Status: ${response.statusCode}\n${response.body}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      classList.value = ClassListModel(listData: []);
      Get.snackbar(
        "Error",
        "Fetch error: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // =========================
  // OPEN EDIT DIALOG
  // =========================
  Future<void> openEditClassDialog(BuildContext context, ClassData item) async {
    final editCtrl = TextEditingController(text: item.className);

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Edit Class"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: editCtrl,
              decoration: InputDecoration(
                labelText: "Class Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
                  () => isPosting.value
                  ? const LinearProgressIndicator()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade600,
            ),
            onPressed: () async {
              final newName = editCtrl.text.trim();

              if (newName.isEmpty) {
                Get.snackbar(
                  "Validation",
                  "Class name required",
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              await updateClass(
                classId: item.classId,
                className: newName,
              );
            },
            child: const Text(
              "Update",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // =========================
  // UPDATE CLASS
  // =========================
  Future<void> updateClass({
    required int classId,
    required String className,
  }) async {
    try {
      isPosting(true);

      final url = Uri.parse(
        "https://playschool.edubloom.in/api/MasterApp/PostClassApp",
      );

      final body = jsonEncode({
        "classId": classId.toString(),
        "class": className.trim(),
        "action": "1",
        "schoolId": schoolId,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        Get.back();
        await fetchClasses();

        Get.snackbar(
          "Success",
          "Class updated successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Update Failed",
          "Status: ${response.statusCode}\n${response.body}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Update error: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isPosting(false);
    }
  }

  void clearFields() {
    classID.clear();
    clas.clear();
  }

  @override
  void onClose() {
    classID.dispose();
    clas.dispose();
    super.onClose();
  }
}