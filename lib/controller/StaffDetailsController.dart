import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/staffdetails_model.dart';
import '../res/app_url.dart';

class StaffDetailsController extends GetxController {
  var token = "";
  var schoolId = "";
  var session = "";

  var isLoading = false.obs;
  var staffDetail = Rxn<StaffDetail>();
  var staffData = Rxn<StaffData>();

  @override
  Future<void> onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";

    await fetchStaffDetails();
  }

  Future<void> fetchStaffDetails() async {
    try {
      isLoading(true);

      final uri = Uri.parse(
        '${AppUrl.base_url}api/StaffApp/GetStaffDetailsApp',
      );

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final body = {
        "schoolId": schoolId,
        "staffId": 0,
        "currentSession": session,
      };

      debugPrint("Staff API URL: $uri");
      debugPrint("Staff API BODY: ${jsonEncode(body)}");

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      debugPrint("Staff API STATUS: ${response.statusCode}");
      debugPrint("Staff API RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final result = StaffDetail.fromJson(jsonResponse);

        staffDetail.value = result;

        if (result.isSuccess == true && result.data != null) {
          staffData.value = result.data;
        } else {
          staffData.value = null;
          Get.snackbar(
            "Message",
            result.messages ?? "Staff details not found",
          );
        }
      } else {
        staffData.value = null;
        Get.snackbar(
          "Error",
          "Failed to fetch staff details (${response.statusCode})",
        );
      }
    } catch (e) {
      debugPrint("fetchStaffDetails Error: $e");
      staffData.value = null;
      Get.snackbar("Error", "Something went wrong");
    } finally {
      isLoading(false);
    }
  }

  String getFullImageUrl(String? path) {
    if (path == null || path.trim().isEmpty || path == "null") {
      return "";
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return '${AppUrl.base_url}${path.startsWith('/') ? path.substring(1) : path}';
  }

  String formatDate(String? date) {
    if (date == null || date.trim().isEmpty || date == "null") {
      return "-";
    }

    try {
      final parsedDate = DateTime.parse(date);
      return "${parsedDate.day.toString().padLeft(2, '0')}-"
          "${parsedDate.month.toString().padLeft(2, '0')}-"
          "${parsedDate.year}";
    } catch (e) {
      return date;
    }
  }

  String valueOrDash(dynamic value) {
    if (value == null) return "-";
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == "null") return "-";
    return text;
  }

  bool hasFile(String? path) {
    if (path == null) return false;
    final text = path.trim();
    return text.isNotEmpty && text.toLowerCase() != "null";
  }
}