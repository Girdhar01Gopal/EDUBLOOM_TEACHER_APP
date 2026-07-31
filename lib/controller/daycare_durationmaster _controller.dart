import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/daycare_durationmaster_model.dart';

class DayCareDurationController extends GetxController {
  final TextEditingController dayCareDurationController = TextEditingController();

  final isPosting = false.obs;
  final isLoading = false.obs;

  final dayCareDurations = <DayCareDurationModel>[].obs;
  final searchText = "".obs;

  String schoolId = "";
  String session = "";

  // ✅ POST API (used for both Add and Update, id = 0 for add, id != 0 for update)
  final String postUrl =
      "https://playschool.edubloom.in/api/FeeMasterApp/AddDaycareDuration";

  // ✅ GET API — schoolId gets appended dynamically at the end
  final String getBaseUrl =
      "https://playschool.edubloom.in/api/FeeMasterApp/ViewDaycareDuration/";

  // ✅ Toggle Active/Inactive API
  final String toggleActiveInactiveBaseUrl =
      "https://playschool.edubloom.in/api/FeeMasterApp/DaycareDurationActiveandInactive";

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    await fetchDayCareDurations();
  }

  @override
  void onClose() {
    dayCareDurationController.dispose();
    super.onClose();
  }

  Future<void> saveDayCareDuration() async {
    final dayCareDurationValue = dayCareDurationController.text.trim();

    if (dayCareDurationValue.isEmpty) {
      Get.snackbar("Validation", "Please enter Day Care Duration");
      return;
    }
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    final now = DateTime.now().toIso8601String();

    // ✅ Body matches AddDaycareDuration API contract
    final body = {
      "id": 0,
      "daycareDurations": dayCareDurationValue,
      "action": "1",
      "schoolId": schoolId,
      "createDate": now,
      "createBy": "Admin",
    };

    try {
      isPosting(true);

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonRes = jsonDecode(res.body);
        final msg = (jsonRes["messages"] ?? "").toString();
        final ok = jsonRes["isSuccess"] == true;

        if (ok) {
          Get.snackbar("Success", msg.isEmpty ? "Day Care Duration added" : msg);
          dayCareDurationController.clear();
          await fetchDayCareDurations(showLoader: false);
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Not saved" : msg);
        }
      } else {
        Get.snackbar("Error", "API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Save failed: $e");
    } finally {
      isPosting(false);
    }
  }

  Future<void> updateDayCareDuration({
    required int dayCareDurationId,
    required String dayCareDuration,
  }) async {
    final dayCareDurationValue = dayCareDuration.trim();

    if (dayCareDurationValue.isEmpty) {
      Get.snackbar("Validation", "Day Care Duration cannot be empty");
      return;
    }
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    // existing record ki original createDate/createBy preserve karo
    final existing =
    dayCareDurations.firstWhereOrNull((e) => e.id == dayCareDurationId);

    final now = DateTime.now().toIso8601String();

    final body = {
      "id": dayCareDurationId,
      "daycareDurations": dayCareDurationValue,
      "action": "1",
      "schoolId": existing?.schoolId ?? schoolId,
      "createDate": existing?.createDate.toIso8601String() ?? now,
      "createBy": existing?.createBy ?? "Admin",
      "updateDate": now,
      "updateBy": "Admin",
    };

    try {
      isPosting(true);

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonRes = jsonDecode(res.body);
        final msg = (jsonRes["messages"] ?? "").toString();
        final ok = jsonRes["isSuccess"] == true;

        if (ok) {
          Get.back();
          Get.snackbar("Success", msg.isEmpty ? "Updated" : msg);
          await fetchDayCareDurations(showLoader: false);
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Update failed" : msg);
        }
      } else {
        Get.snackbar("Error", "Update API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isPosting(false);
    }
  }

  // ✅ Toggle Active/Inactive
  Future<void> toggleActiveInactive({required int dayCareDurationId}) async {
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    final url =
        "$toggleActiveInactiveBaseUrl?SchoolId=$schoolId&sId=$dayCareDurationId";

    try {
      isPosting(true);

      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        // ✅ response List ya Map dono handle karo
        final decoded = jsonDecode(res.body);

        Map<String, dynamic> jsonRes;
        if (decoded is List && decoded.isNotEmpty) {
          jsonRes = decoded.first as Map<String, dynamic>;
        } else if (decoded is Map<String, dynamic>) {
          jsonRes = decoded;
        } else {
          jsonRes = {};
        }

        final msg = (jsonRes["messages"] ?? "").toString();

        Get.snackbar("Success", msg.isEmpty ? "Status updated" : msg);
        await fetchDayCareDurations(showLoader: false);
      } else {
        Get.snackbar("Error", "Status update API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Status update failed: $e");
    } finally {
      isPosting(false);
    }
  }

  Future<void> fetchDayCareDurations({bool showLoader = true}) async {
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    // ✅ schoolId dynamically appended, e.g. .../ViewDaycareDuration/GRAUM001
    final url = "$getBaseUrl$schoolId";

    try {
      if (showLoader) isLoading(true);

      final res = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        // ✅ handles the { "listData": [...], "currentSession": null } wrapper
        final list = DayCareDurationModel.fromJsonList(jsonRes);
        dayCareDurations.assignAll(list);
      } else {
        Get.snackbar("Error", "Fetch failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch failed: $e");
    } finally {
      if (showLoader) isLoading(false);
    }
  }

  List<DayCareDurationModel> get filteredList {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return dayCareDurations;

    return dayCareDurations.where((e) {
      return e.dayCareDuration.toLowerCase().contains(q) ||
          e.id.toString().contains(q);
    }).toList();
  }
}