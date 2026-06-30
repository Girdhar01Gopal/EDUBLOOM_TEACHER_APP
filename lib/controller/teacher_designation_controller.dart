import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/designation model.dart';
import '../res/app_url.dart';


class TeacherDesignationController extends GetxController {
  // ========= Form =========
  final formKey = GlobalKey<FormState>();
  final designationC = TextEditingController();

  // ========= Loaders =========
  final isPageLoading = false.obs; // top linear progress for add tab
  final isSaving = false.obs;      // save/update loader
  final isListLoading = false.obs; // list fetch loader

  // ========= Data =========
  final designationList = <DesignationModel>[].obs;

  // ========= School =========
  String schoolId = "";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await fetchDesignations();
  }

  @override
  void onClose() {
    designationC.dispose();
    super.onClose();
  }

  // =========================
  // ✅ GET: View Designations
  // =========================
  Future<void> fetchDesignations() async {
    try {
      isListLoading(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ViewDesignationApp/$schoolId',
      );

      final res = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      if (res.statusCode == 200) {
        final parsed = DesignationResponse.fromJson(jsonDecode(res.body));
        designationList.assignAll(parsed.listData);
      } else {
        Get.snackbar("Error", "GET failed: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // =========================
  // ✅ POST: Add / Update
  // =========================
  Future<void> saveDesignation({
    int tdId = 0,
    required String designation,
    String createBy = "",
    String updateBy = "string",
  }) async {
    try {
      isSaving(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/PostTeacherDesignationApp',
      );

      final payload = {
        "tdId": tdId,                 // 0 => add, >0 => update (as you requested)
        "designation": designation,
        "action": "1",                // ✅ always 1
        "schoolId": schoolId,
        "createBy": createBy,
        "updateBy": updateBy,
      };

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      Map<String, dynamic>? jsonData;
      try {
        jsonData = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        jsonData = null;
      }

      if (res.statusCode == 200 && jsonData != null) {
        final ok = jsonData["isSuccess"] == true;
        final msg = (jsonData["messages"] ?? "").toString();

        if (ok) {
          Get.snackbar("Success", msg.isEmpty ? "Saved" : msg);

          // clear add form only when adding new
          if (tdId == 0) designationC.clear();

          // refresh list
          await fetchDesignations();
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Save failed" : msg);
        }
      } else {
        Get.snackbar("Error", "POST failed (${res.statusCode})\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Save error: $e");
    } finally {
      isSaving(false);
    }
  }

  // ✅ Add button handler (uses form validation)
  Future<void> onAddPressed() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final text = designationC.text.trim();
    await saveDesignation(tdId: 0, designation: text);
  }

  // ✅ Edit dialog -> hits same POST API with tdId
  void openEditDialog(DesignationModel row) {
    final editC = TextEditingController(text: row.designation);

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Designation"),
        content: TextField(
          controller: editC,
          decoration: const InputDecoration(
            hintText: "Enter designation",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          Obx(() {
            return ElevatedButton(
              onPressed: isSaving.value
                  ? null
                  : () async {
                final v = editC.text.trim();
                if (v.isEmpty) {
                  Get.snackbar("Validation", "Designation is required");
                  return;
                }
                await saveDesignation(tdId: row.tdId, designation: v);
                Get.back();
              },
              child: isSaving.value
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("Update"),
            );
          }),
        ],
      ),
      barrierDismissible: true,
    );
  }

  String? requiredValidator(String? v, String label) {
    if (v == null || v.trim().isEmpty) return "$label is required";
    return null;
  }

  // Date formatter for table
  String formatDate(DateTime? d) {
    if (d == null) return "-";
    final dd = d.day.toString().padLeft(2, '0');
    final mm = _m(d.month);
    final yy = d.year.toString();
    return "$dd-$mm-$yy";
  }

  String _m(int m) {
    const mm = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    if (m < 1 || m > 12) return "NA";
    return mm[m - 1];
  }

  void resetForm() {
    designationC.clear();
  }
}