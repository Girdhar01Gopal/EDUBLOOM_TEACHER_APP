import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/day_care_fee_master_model.dart';
import '../res/app_url.dart';

import '../models/session_model.dart' as session_model;
import '../models/fee_type_model.dart';
import '../models/daycare_durationmaster_model.dart';

class DayCareFeeMasterController extends GetxController {
  // ========= Session Dropdown =========
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ========= Fee Type Dropdown =========
  final feeTypeList = <fData>[].obs;
  final selectedFeeType = Rx<fData?>(null);

  // ========= Daycare Duration Dropdown (from API) =========
  final daycareDurationList = <DayCareDurationModel>[].obs;
  final selectedDaycareDuration = Rx<DayCareDurationModel?>(null);

  // ========= Daycare Month (STATIC, MULTI-SELECT) =========
  final monthList = <String>[
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  ];
  final selectedMonths = <String>[].obs;

  // ========= Amount =========
  final amountController = TextEditingController();

  // ========= Loaders =========
  final isPageLoading = false.obs;
  final isSaving = false.obs;

  final isListLoading = false.obs;

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
      fetchDaycareDurationDropdown(),
    ]);

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
          selectedSession.value = cs;
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

  // ✅ DAYCARE DURATION DROPDOWN API
  Future<void> fetchDaycareDurationDropdown() async {
    if (schoolId.trim().isEmpty) return;

    try {
      isPageLoading(true);

      final res = await http.get(
        Uri.parse(
          'https://playschool.edubloom.in/api/FeeMasterApp/DaycareDurationDropdwon/$schoolId',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        final list = DayCareDurationModel.fromJsonList(jsonData);
        daycareDurationList.assignAll(list);
      } else {
        Get.snackbar("Error", "Daycare Duration API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Daycare Duration error: $e");
    } finally {
      isPageLoading(false);
    }
  }

  // ✅ GET ALL DAYCARE FEES (POST with body)
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
        daycareFeeList.assignAll(
          data.map((e) => DaycareFeeRow.fromJson(e as Map<String, dynamic>)).toList(),
        );
      } else {
        Get.snackbar("Error", "List API failed: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch list error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // ✅ POST: Add Daycare Fee
  Future<void> saveDayCareFee() async {
    final session = selectedSession.value?.session;
    final amountText = amountController.text.trim();
    final duration = selectedDaycareDuration.value?.dayCareDuration;
    final months = selectedMonths;

    if (session == null || session.isEmpty) {
      Get.snackbar("Validation", "Select Session");
      return;
    }
    if (duration == null || duration.isEmpty) {
      Get.snackbar("Validation", "Select Daycare Duration");
      return;
    }
    if (months.isEmpty) {
      Get.snackbar("Validation", "Select at least one Daycare Month");
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
      final now = _nowIso();

      final payload = {
        "daycareHeadId": 0,
        "feeTypeId": 0,
        "feeType": "Daycare",
        "amount": amountInt.toString(),
        "session": session,
        "schoolId": schoolId,
        "createBy": "Admin",
        "createDate": now,
        "action": "1",
        "updateBy": "Admin",
        "updateDate": now,
        "daycareDurations": duration,
        "feeDuration": months.toList(),
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
          selectedDaycareDuration.value = null;
          selectedMonths.clear();

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

  // ✅ EDIT DIALOG — Amount + Daycare Duration + multi-select Month prefilled
  void openEditDialog(BuildContext context, DaycareFeeRow row) {
    final txt = TextEditingController(text: row.amount ?? "");
    final editDuration = Rx<DayCareDurationModel?>(
      daycareDurationList.firstWhereOrNull(
            (d) => d.dayCareDuration == row.daycareDurations,
      ),
    );
    final editMonths = <String>[...(row.feeDuration ?? [])].obs;

    Get.dialog(
      AlertDialog(
        title: Text("Edit Daycare Fee", style: TextStyle(fontWeight: FontWeight.w800)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: txt,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                return DropdownButtonFormField<DayCareDurationModel>(
                  value: editDuration.value,
                  isExpanded: true,
                  hint: const Text("Select Daycare Duration"),
                  items: daycareDurationList
                      .map((d) => DropdownMenuItem(
                    value: d,
                    child: Text(d.dayCareDuration, overflow: TextOverflow.ellipsis),
                  ))
                      .toList(),
                  onChanged: (v) => editDuration.value = v,
                  decoration: const InputDecoration(
                    labelText: "Daycare Duration",
                    border: OutlineInputBorder(),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Obx(() {
                return InkWell(
                  onTap: () async {
                    await _openMonthPickerDialog(editMonths);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Daycare Month",
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      editMonths.isEmpty ? "Select Month" : editMonths.join(", "),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ],
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
                if (editDuration.value == null) {
                  Get.snackbar("Validation", "Select Daycare Duration");
                  return;
                }
                if (editMonths.isEmpty) {
                  Get.snackbar("Validation", "Select at least one Month");
                  return;
                }

                await saveDayCareFeeByRow(
                  row: row,
                  newAmount: val.toString(),
                  newDuration: editDuration.value!.dayCareDuration,
                  newMonths: editMonths.toList(),
                );
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

  // small reusable month-picker dialog (checkbox list) used inside edit dialog
  Future<void> _openMonthPickerDialog(RxList<String> target) async {
    final temp = <String>[...target].obs;
    await Get.dialog(
      AlertDialog(
        title: const Text("Select Month(s)"),
        content: SizedBox(
          width: 300,
          child: SingleChildScrollView(
            child: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: monthList.map((m) {
                  final checked = temp.contains(m);
                  return CheckboxListTile(
                    dense: true,
                    value: checked,
                    title: Text(m),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (v) {
                      if (v == true) {
                        temp.add(m);
                      } else {
                        temp.remove(m);
                      }
                    },
                  );
                }).toList(),
              );
            }),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              target.assignAll(temp);
              Get.back();
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  // ✅ POST: Update Daycare Fee
  Future<void> saveDayCareFeeByRow({
    required DaycareFeeRow row,
    required String newAmount,
    required String newDuration,
    required List<String> newMonths,
  }) async {
    final now = _nowIso();

    // 🔵 DEBUG PRINTS — added to trace which row is being edited
    print("🔵 EDITING ROW → id=${row.id}, duration=${row.daycareDurations}, oldMonths=${row.feeDuration}");
    print("🔵 NEW VALUES → newDuration=$newDuration, newMonths=$newMonths");

    try {
      isSaving(true);

      final url = Uri.parse('${AppUrl.base_url}api/FeeMasterApp/PostDaycareAddFeeApp');

      final payload = {
        "id": row.id,
        "daycareHeadId": row.id ?? 0, // ✅ FIX: real row id bheja, pehle 0 tha isliye backend wrong record match/update kar raha tha
        "feeTypeId": row.feeTypeId ?? 0,
        "feeType": "Daycare", // ✅ FIX: added, was missing earlier so backend saved it as null
        "amount": newAmount,
        "session": row.session ?? (selectedSession.value?.session ?? ""),
        "schoolId": schoolId,
        "createBy": row.createBy ?? "Admin",
        "createDate": row.createDate ?? now,
        "action": row.action ?? "1",
        "updateBy": "Admin",
        "updateDate": now,
        "daycareDurations": newDuration,
        "feeDuration": newMonths,
      };

      // 🟡 DEBUG PRINT — exact payload jo backend ko jaa raha hai
      print("🟡 PAYLOAD SENDING → ${jsonEncode(payload)}");

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      // 🟢 DEBUG PRINT — backend se raw response
      print("🟢 UPDATE RESPONSE → ${res.body}");

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

  // ✅ full ISO UTC timestamp, e.g. "2026-07-29T10:52:31.135Z" — matches API contract
  String _nowIso() {
    return DateTime.now().toUtc().toIso8601String();
  }

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