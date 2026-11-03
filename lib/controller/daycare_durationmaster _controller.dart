import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/daycare_durationmaster_model.dart';
import '../utils/app_snackbar.dart';

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
      AppSnackbar.error("Please enter Day Care Duration", title: "Validation");
      return;
    }
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
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
          // Fixed success text (server text is never shown directly)
          AppSnackbar.success("Day Care Duration added successfully");
          dayCareDurationController.clear();
          await fetchDayCareDurations(showLoader: false);
        } else {
          // Short clean server message is shown; technical text becomes
          // "Something went wrong" automatically.
          AppSnackbar.error(msg.isEmpty ? "Not saved" : msg, title: "Failed");
        }
      } else {
        AppSnackbar.apiError("API failed: ${res.statusCode}",
            statusCode: res.statusCode);
      }
    } catch (e, s) {
      // User sees "Something went wrong", real error prints in console.
      AppSnackbar.apiError(e, stackTrace: s);
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
      AppSnackbar.error("Day Care Duration cannot be empty",
          title: "Validation");
      return;
    }
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
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
          // Fixed success text (server text is never shown directly)
          AppSnackbar.success("Day Care Duration updated successfully");
          await fetchDayCareDurations(showLoader: false);
        } else {
          AppSnackbar.error(msg.isEmpty ? "Update failed" : msg,
              title: "Failed");
        }
      } else {
        AppSnackbar.apiError("Update API failed: ${res.statusCode}",
            statusCode: res.statusCode);
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }

  // ✅ Toggle Active/Inactive
  Future<void> toggleActiveInactive({required int dayCareDurationId}) async {
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
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

        // Short clean server message is shown; otherwise a fixed text.
        // Technical text becomes "Something went wrong" automatically.
        AppSnackbar.success(msg.isEmpty || msg.length > 140
            ? "Status updated successfully"
            : msg);
        await fetchDayCareDurations(showLoader: false);
      } else {
        AppSnackbar.apiError("Status update API failed: ${res.statusCode}",
            statusCode: res.statusCode);
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPosting(false);
    }
  }

  Future<void> fetchDayCareDurations({bool showLoader = true}) async {
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
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
        AppSnackbar.apiError("Fetch failed: ${res.statusCode}",
            statusCode: res.statusCode);
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
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