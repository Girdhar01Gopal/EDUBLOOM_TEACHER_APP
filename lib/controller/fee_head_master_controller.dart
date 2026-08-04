import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/AddFeeHeadMasterModel.dart';
import '../res/app_url.dart';

import '../models/session_model.dart' as session_model;
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/fee_type_model.dart';
import '../models/feedurationmodel.dart';

class AddFeeHeadController extends GetxController {
  // ================= DROPDOWNS =================
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  final classList = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final feeTypeList = <fData>[].obs;
  final selectedFeeType = Rx<fData?>(null);

  final feeDurationList = <FeeDurationItem>[].obs;
  // ✅ CHANGED: single -> multi select list
  final selectedFeeDurations = <FeeDurationItem>[].obs;

  final sectionList = <ListDatta>[].obs;
  final selectedSection = Rx<ListDatta?>(null);

  // ================= INPUT =================
  final amountController = TextEditingController();

  // ================= LOADERS =================
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isListLoading = false.obs;

  // ================= VIEW LIST =================
  final feeHeadList = <AddFeeHeadMasterData>[].obs;

  String schoolId = "";

  // ================= API URLS =================
  String get _sessionUrl => '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
  String get _classUrl => '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
  String get _sectionUrl => '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';
  String get _feeTypeUrl => '${AppUrl.base_url}api/FeeMasterApp/ViewFeeTypeApp/$schoolId';
  String get _feeDurationUrl => '${AppUrl.base_url}api/FeeMasterApp/ViewFeesDurationApp/$schoolId';

  final String postAddFeesHeadUrl =
      'https://playschool.edubloom.in/api/MasterApp/PostAddFeesHeadApp';

  String getAllFeeHeadUrl({required String session}) =>
      'https://playschool.edubloom.in/api/MasterApp/GetAllFeeHeadAppAsync?schoolId=${Uri.encodeComponent(schoolId)}&session=${Uri.encodeComponent(session)}';

  // ✅ helper to show 800 instead of 800.00 in UI
  String normalizeAmount(String? v) {
    if (v == null) return "0";
    final s = v.trim();
    if (s.isEmpty) return "0";

    if (s.contains('.')) {
      final parts = s.split('.');
      if (parts.length == 2 && RegExp(r'^0+$').hasMatch(parts[1])) {
        return parts[0]; // "800.00" -> "800"
      }
    }
    return s;
  }

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    if (schoolId.isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await loadAllDropdowns();
    await fetchFeeHeadList();
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  Future<void> loadAllDropdowns() async {
    try {
      isPageLoading(true);
      await Future.wait([
        fetchSessions(),
        fetchClasses(),
        fetchFeeTypes(),
        fetchFeeDurations(),
        fetchSections(),
      ]);
    } finally {
      isPageLoading(false);
    }
  }

  // ================= FETCH APIs =================
  Future<void> fetchSessions() async {
    final res = await http.get(Uri.parse(_sessionUrl));
    if (res.statusCode != 200) return;

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
    }

    final list = jsonData['listData'];
    if (list is List) {
      for (final e in list) {
        try {
          final item = session_model.sListDdata.fromJson(e);
          if (!sessionList.any((x) => x.sessionId == item.sessionId)) {
            sessionList.add(item);
          }
        } catch (_) {}
      }
    }
  }

  Future<void> fetchClasses() async {
    final res = await http.get(Uri.parse(_classUrl));
    if (res.statusCode != 200) return;

    final parsed = ClassItem.fromJson(jsonDecode(res.body));
    classList.assignAll(parsed.listData?.where((e) => e.action == "1").toList() ?? []);
    selectedClass.value = null;
  }

  Future<void> fetchFeeTypes() async {
    final res = await http.get(Uri.parse(_feeTypeUrl));
    if (res.statusCode != 200) return;

    final parsed = FeeTypeModel.fromJson(jsonDecode(res.body));
    feeTypeList.assignAll(parsed.listData ?? []);
    selectedFeeType.value = null;
  }

  Future<void> fetchFeeDurations() async {
    final res = await http.get(Uri.parse(_feeDurationUrl));
    if (res.statusCode != 200) return;

    final parsed = FeeDurationMaster.fromJson(jsonDecode(res.body));
    feeDurationList.assignAll(parsed.listData);
    // ✅ CHANGED: clear multi-select list instead of single value
    selectedFeeDurations.clear();
  }

  Future<void> fetchSections() async {
    final res = await http.get(Uri.parse(_sectionUrl));
    if (res.statusCode != 200) return;

    final list = jsonDecode(res.body)['listData'] ?? [];
    sectionList.assignAll((list as List).map<ListDatta>((e) => ListDatta.fromJson(e)).toList());
    selectedSection.value = null;
  }

  // ================= VIEW LIST API =================
  Future<void> fetchFeeHeadList() async {
    final session = selectedSession.value?.session;
    if (session == null || session.isEmpty) return;

    try {
      isListLoading(true);

      final res = await http.get(
        Uri.parse(getAllFeeHeadUrl(session: session)),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode != 200) {
        Get.snackbar("Error", "List API failed: ${res.statusCode}");
        return;
      }

      final parsed = AddFeeHeadMasterModel.fromJson(jsonDecode(res.body));
      if (parsed.isSuccess != true) {
        feeHeadList.clear();
        Get.snackbar("Failed", parsed.messages);
        return;
      }

      feeHeadList.assignAll(parsed.data);
    } catch (e) {
      Get.snackbar("Error", "Fetch list error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // ================= TOGGLE HELPER FOR MULTI-SELECT =================
  // ✅ NEW: used by the picker UI to add/remove an item from selection
  void toggleFeeDuration(FeeDurationItem item, bool selected) {
    if (selected) {
      if (!selectedFeeDurations.any((e) => e.feesDurationId == item.feesDurationId)) {
        selectedFeeDurations.add(item);
      }
    } else {
      selectedFeeDurations.removeWhere((e) => e.feesDurationId == item.feesDurationId);
    }
  }

  bool isFeeDurationSelected(FeeDurationItem item) {
    return selectedFeeDurations.any((e) => e.feesDurationId == item.feesDurationId);
  }

  // ================= SAVE (POST) =================
  // ✅ CHANGED: loops over every selected duration and posts one fee head per duration
  Future<void> saveFeeHead() async {
    if (selectedSession.value == null ||
        selectedClass.value == null ||
        selectedFeeType.value == null ||
        selectedFeeDurations.isEmpty ||
        selectedSection.value == null) {
      Get.snackbar("Validation", "All fields are required");
      return;
    }

    final amount = amountController.text.trim();
    if (amount.isEmpty) {
      Get.snackbar("Validation", "Enter amount");
      return;
    }

    final int? classId = selectedClass.value!.classId;
    final int? sectionId = selectedSection.value!.sectionId;
    final int? feeTypeId = selectedFeeType.value!.feeTypeId;

    if (classId == null || sectionId == null || feeTypeId == null) {
      Get.snackbar("Validation", "Invalid selection (IDs missing)");
      return;
    }

    // Validate every selected duration has a valid id
    final durationIds = selectedFeeDurations
        .map((d) => d.feesDurationId)
        .whereType<int>()
        .toList();

    if (durationIds.isEmpty) {
      Get.snackbar("Validation", "Invalid fee duration selection");
      return;
    }

    try {
      isSaving(true);

      int successCount = 0;
      int failCount = 0;

      for (final durationId in durationIds) {
        final body = {
          "feeHeadId": 0,
          "session": selectedSession.value!.session,
          "classId": classId,
          "sectionId": sectionId,
          "feesDurationId": durationId,
          "feeTypeID": feeTypeId,
          "amount": amount, // ✅ STRING
          "action": "1",
          "schoolID": schoolId,
          "createBy": "String",
        };

        final ok = await _postFeeHeadOnce(body: body);
        if (ok) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (successCount > 0) {
        Get.snackbar(
          "Success",
          failCount == 0
              ? "Fee Head saved for $successCount duration(s)"
              : "Saved for $successCount duration(s), failed for $failCount",
        );
        amountController.clear();
        selectedClass.value = null;
        selectedFeeType.value = null;
        selectedFeeDurations.clear();
        selectedSection.value = null;
        await fetchFeeHeadList();
      } else {
        Get.snackbar("Failed", "Could not save fee head");
      }
    } finally {
      isSaving(false);
    }
  }

  // ================= COMMON POST HANDLER (single call, used in a loop) =================
  Future<bool> _postFeeHeadOnce({required Map<String, dynamic> body}) async {
    try {
      final jsonBody = jsonEncode(body);
      debugPrint("POST BODY => $jsonBody"); // ✅ proof: amount is string

      final res = await http.post(
        Uri.parse(postAddFeesHeadUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');

      if (res.statusCode != 200) {
        return false;
      }

      final jsonRes = jsonDecode(res.body);
      final msg = (jsonRes['messages'] ?? '').toString();
      final data = (jsonRes['data'] ?? '').toString();
      final isSuccess = jsonRes['isSuccess'] == true;

      return isSuccess || data.toUpperCase() == "SUCCESS" || msg.toLowerCase().contains("success");
    } catch (e) {
      debugPrint("Post error: $e");
      return false;
    }
  }

  void openEditDialog(BuildContext context, dynamic feeHeadItem) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Fee Head'),
          content: Text('Edit dialog for: ${feeHeadItem.feeType ?? ''}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}