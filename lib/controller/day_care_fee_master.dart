import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../res/app_url.dart';

import '../models/session_model.dart' as session_model;
import '../models/fee_type_model.dart';

// ✅ Use YOUR model file name here (the one we created)
// If your class name is MasterDaycareFeeModel, import that file and use it below.
// import '../models/master_daycare_fee_model.dart';

class DayCareFeeMasterController extends GetxController {
  // ========= Session Dropdown =========
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ========= Fee Type Dropdown =========
  final feeTypeList = <fData>[].obs;
  final selectedFeeType = Rx<fData?>(null);

  // ========= Amount =========
  final amountController = TextEditingController();

  // ========= Loaders =========
  final isPageLoading = false.obs; // for add tab top progress
  final isSaving = false.obs;

  final isListLoading = false.obs; // for view tab list fetch

  // ========= View List =========
  final daycareFeeList = <DaycareFeeRow>[].obs;

  String schoolId = "";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await Future.wait([
      fetchSessions(),
      fetchFeeTypes(),
    ]);

    // load list initially (after current session loaded)
    await fetchDaycareFees();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  // ✅ SESSION API
  Future<void> fetchSessions() async {
    try {
      isPageLoading(true);

      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);

        sessionList.clear();
        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );

          sessionList.add(cs);
          selectedSession.value = cs; // auto select
        } else {
          selectedSession.value = null;
        }
      } else {
        Get.snackbar("Error", "Session API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Session error: $e");
    } finally {
      isPageLoading(false);
    }
  }

  // ✅ FEE TYPE API
  Future<void> fetchFeeTypes() async {
    try {
      isPageLoading(true);

      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/FeeMasterApp/ViewFeeTypeApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed = FeeTypeModel.fromJson(jsonDecode(res.body));
        feeTypeList.assignAll(parsed.listData ?? []);
        selectedFeeType.value = null;
      } else {
        Get.snackbar("Error", "Fee Type API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fee Type error: $e");
    } finally {
      isPageLoading(false);
    }
  }

  // ✅ GET ALL DAYCARE FEES (actually POST with body)
  Future<void> fetchDaycareFees() async {
    final session = selectedSession.value?.session;
    if (session == null || session.isEmpty) return;

    try {
      isListLoading(true);

      final url = Uri.parse('${AppUrl.base_url}api/FeeMasterApp/GetAllDaycareFeeAsyncApp');

      final body = {
        "schoolId": schoolId,
        "currentSession": session,
      };

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body) as Map<String, dynamic>;

        final ok = jsonData["isSuccess"] == true;
        if (!ok) {
          daycareFeeList.clear();
          Get.snackbar("Failed", (jsonData["messages"] ?? "Fetch failed").toString());
          return;
        }

        final data = (jsonData["data"] is List) ? (jsonData["data"] as List) : [];
        daycareFeeList.assignAll(data.map((e) => DaycareFeeRow.fromJson(e)).toList());
      } else {
        Get.snackbar("Error", "List API failed: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch list error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // ✅ POST: Add/Update Daycare Fee (same API)
  Future<void> saveDayCareFee() async {
    final session = selectedSession.value?.session;
    final feeTypeId = selectedFeeType.value?.feeTypeId;
    final amountText = amountController.text.trim();

    // ⚠️ you hardcoded before; keep same until you add head dropdown
    const int daycareHeadId = 6;

    if (session == null || session.isEmpty) {
      Get.snackbar("Validation", "Select Session");
      return;
    }
    if (feeTypeId == null) {
      Get.snackbar("Validation", "Select Fee Type");
      return;
    }
    if (amountText.isEmpty) {
      Get.snackbar("Validation", "Enter Amount");
      return;
    }

    final amountInt = int.tryParse(amountText);
    if (amountInt == null || amountInt <= 0) {
      Get.snackbar("Validation", "Enter valid amount");
      return;
    }

    try {
      isSaving(true);

      final url = Uri.parse('${AppUrl.base_url}api/FeeMasterApp/PostDaycareAddFeeApp');
      final nowIso = DateTime.now().toUtc().toIso8601String();

      final payload = {
        "daycareHeadId": daycareHeadId,
        "feeTypeId": feeTypeId,
        "amount": amountInt.toString(),
        "session": session,
        "schoolId": schoolId,
        "createBy": "Admin",
        "createDate": nowIso,
        "action": "1",
        "updateBy": "Admin",
        "updateDate": nowIso,
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
          Get.snackbar("Success", msg.isEmpty ? "Daycare fee saved" : msg);

          amountController.clear();
          selectedFeeType.value = null;

          // refresh view list
          await fetchDaycareFees();
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Save failed" : msg);
        }
      } else {
        Get.snackbar("Error", "API failed (${res.statusCode})\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Save error: $e");
    } finally {
      isSaving(false);
    }
  }

  // ✅ EDIT DIALOG (uses same POST API)
  void openEditDialog(BuildContext context, DaycareFeeRow row) {
    final txt = TextEditingController(text: row.amount ?? "");
    Get.dialog(
      AlertDialog(
        title: Text("Edit Amount", style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: txt,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Amount",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          Obx(() {
            return ElevatedButton(
              onPressed: isSaving.value
                  ? null
                  : () async {
                final newAmount = txt.text.trim();
                final val = int.tryParse(newAmount);
                if (val == null || val <= 0) {
                  Get.snackbar("Validation", "Enter valid amount");
                  return;
                }

                // IMPORTANT: your POST payload doesn't include id.
                // If backend needs id for update, then API is broken.
                // We'll send same payload + keep feeTypeId/session from row.
                await saveDayCareFeeByRow(row: row, newAmount: val.toString());
                Get.back();
              },
              child: isSaving.value
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Update"),
            );
          }),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> saveDayCareFeeByRow({
    required DaycareFeeRow row,
    required String newAmount,
  }) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();

    // ⚠️ still hardcoded due to missing head id in row response
    const int daycareHeadId = 6;

    try {
      isSaving(true);

      final url = Uri.parse('${AppUrl.base_url}api/FeeMasterApp/PostDaycareAddFeeApp');

      final payload = {
        "daycareHeadId": daycareHeadId,
        "feeTypeId": row.feeTypeId ?? 0,
        "amount": newAmount,
        "session": row.session ?? (selectedSession.value?.session ?? ""),
        "schoolId": schoolId,
        "createBy": "Admin",
        "createDate": nowIso,
        "action": row.action ?? "1",
        "updateBy": "Admin",
        "updateDate": nowIso,

        // If backend supports id-based update, add it here.
        // "id": row.id,
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
          Get.snackbar("Success", msg.isEmpty ? "Updated" : msg);
          await fetchDaycareFees();
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Update failed" : msg);
        }
      } else {
        Get.snackbar("Error", "Update API failed (${res.statusCode})\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Update error: $e");
    } finally {
      isSaving(false);
    }
  }

  // ========= helpers =========
  String formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return "-";
    try {
      final d = DateTime.parse(iso);
      return "${d.day.toString().padLeft(2, '0')}-${_m(d.month)}-${d.year}";
    } catch (_) {
      return iso;
    }
  }

  String _m(int m) {
    const mm = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    if (m < 1 || m > 12) return "NA";
    return mm[m - 1];
  }
}

// ✅ Minimal row model for View list (keeps your response fields)
class DaycareFeeRow {
  final int? id;
  final int? feeTypeId;
  final String? feeTypeName;
  final String? amount;
  final String? session;
  final String? createDate;
  final String? updateDate;
  final String? action;

  DaycareFeeRow({
    this.id,
    this.feeTypeId,
    this.feeTypeName,
    this.amount,
    this.session,
    this.createDate,
    this.updateDate,
    this.action,
  });

  factory DaycareFeeRow.fromJson(Map<String, dynamic> json) {
    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return DaycareFeeRow(
      id: _asInt(json['id']),
      feeTypeId: _asInt(json['feeTypeId']),
      feeTypeName: json['feeTypeName']?.toString(),
      amount: json['amount']?.toString(),
      session: json['session']?.toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      action: json['action']?.toString(),
    );
  }
}