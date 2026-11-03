import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/stafftypemodel.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart'; // ✅ common top snackbar

class Stafftypecontroller extends GetxController {
  // ========= Form =========
  final formKey = GlobalKey<FormState>();
  final designationC = TextEditingController();

  // ========= Loaders =========
  final isPageLoading = false.obs; // top linear progress for add tab
  final isSaving = false.obs; // save/update loader
  final isListLoading = false.obs; // list fetch loader

  // ========= Data =========
  final RxList<StaffType> designationList = <StaffType>[].obs;

  // ========= School =========
  String schoolId = "";

  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static const _months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("School not found. Please login again.");
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

      final url = Uri.parse('${AppUrl.base_url}api/StaffApp/ViewStaffTypeApp/$schoolId');

      final res = await http.get(url, headers: _jsonHeaders);

      if (res.statusCode == 200) {
        final parsed = StaffTypeResponse.fromJson(jsonDecode(res.body));
        designationList.assignAll(parsed.listData ?? []);

        // if your dropdown needs names only:
        // designationNames.assignAll(parsed.listData.map((e) => e.staffType).toList());
      } else {
        debugPrint("GET failed: ${res.statusCode}\n${res.body}");
        AppSnackbar.error(AppSnackbar.friendlyMessage(null, statusCode: res.statusCode));
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
      AppSnackbar.error(AppSnackbar.friendlyMessage(e));
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
    bool closeDialog = false, // edit dialog band karna (snackbar se pehle)
  }) async {
    // Get.back() snackbar ko band kar deta hai, isliye dialog pehle band hota hai
    void closeDialogIfNeeded() {
      if (closeDialog && (Get.isDialogOpen ?? false)) Get.back();
    }

    try {
      isSaving(true);

      final url = Uri.parse('${AppUrl.base_url}api/StaffApp/PostStaffTypeApp');

      final payload = {
        "staffTypeId": tdId, // 0 => add, >0 => update (as you requested)
        "staffType": designation,
        "action": "1", // ✅ always 1
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
        final msg = (jsonData["messages"] ?? "").toString().trim();

        closeDialogIfNeeded();

        if (ok) {
          AppSnackbar.success(msg.isEmpty ? "Saved" : msg);

          // clear add form only when adding new
          if (tdId == 0) designationC.clear();

          // refresh list
          await fetchDesignations();
        } else {
          // readable server message; technical text AppSnackbar khud generic bana deta hai
          AppSnackbar.error(msg.isEmpty ? "Save failed" : msg, title: "Failed");
        }
      } else {
        debugPrint("POST failed (${res.statusCode}): ${res.body}");
        closeDialogIfNeeded();
        AppSnackbar.error(AppSnackbar.friendlyMessage(null, statusCode: res.statusCode));
      }
    } catch (e) {
      debugPrint("Save error: $e");
      closeDialogIfNeeded();
      AppSnackbar.error(AppSnackbar.friendlyMessage(e));
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
  void openEditDialog(StaffType row) {
    final editC = TextEditingController(text: row.staffType);

    Get.dialog(
      AlertDialog(
        title: const Text("Edit Staff Type"),
        content: TextField(
          controller: editC,
          decoration: const InputDecoration(
            hintText: "Enter Type",
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
                  AppSnackbar.error("Staff Type is required", title: "Validation");
                  return;
                }
                await saveDesignation(
                  tdId: row.staffTypeId,
                  designation: v,
                  closeDialog: true,
                );
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

  /// API ki date string ko seedha format karta hai
  String formatDateStr(String? s) => formatDate(s != null ? DateTime.tryParse(s) : null);

  String _m(int m) => (m < 1 || m > 12) ? "NA" : _months[m - 1];

  void resetForm() {
    designationC.clear();
  }
}