import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/session_model.dart' as session_model;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/ViewGirlsBoysReportmodel.dart';

class ViewGirlsBoysReportController extends GetxController {
  // Session dropdown
  final RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  final Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);

  // ✅ Gender dropdown (UPDATED)
  final RxList<String> genderList = <String>['Boy', 'Girl', 'Other'].obs;
  final RxString selectedGender = ''.obs;

  // Report list
  final RxList<ViewGirlBoyModelReport> reportList =
      <ViewGirlBoyModelReport>[].obs;

  // Loading flags
  final RxBool isPageLoading = false.obs; // dropdown load
  final RxBool isSubmitting = false.obs; // submit press

  String token = "";
  String schoolId = "";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    await fetchSessions();

    // ✅ Default gender set
    if (selectedGender.value.isEmpty) {
      selectedGender.value = "Boy";
    }
  }

  Future<void> fetchSessions() async {
    final apiUrl =
        'https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/$schoolId';

    try {
      isPageLoading(true);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );

          sessionList.add(cs);

          // ✅ default select current session
          selectedSession.value = cs;
        }
      } else {
        Get.snackbar('Error', 'Session API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isPageLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata? s) =>
      selectedSession.value = s;

  Future<void> fetchStudents() async {
    if (selectedSession.value == null) {
      Get.snackbar("Missing", "Select Session");
      return;
    }
    if (selectedGender.value.isEmpty) {
      Get.snackbar("Missing", "Select Gender");
      return;
    }

    final session = selectedSession.value!.session ?? '';
    final gender = selectedGender.value;

    if (session.isEmpty) {
      Get.snackbar("Missing", "Session is empty");
      return;
    }

    // ✅ IMPORTANT: schoolId has space -> URL encode required
    final encodedSchoolId = Uri.encodeComponent(schoolId);

    final url =
        'https://playschool.edubloom.in/api/ReportApp/SearchGirlsBoysReportApp/$session/$gender/$encodedSchoolId';

    try {
      isSubmitting(true);
      reportList.clear();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token', // if needed
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          reportList.assignAll(
            data
                .map((e) => ViewGirlBoyModelReport.fromJson(
                e as Map<String, dynamic>))
                .toList(),
          );
        } else {
          Get.snackbar("Error", "Unexpected response format");
        }
      } else {
        Get.snackbar('Error', 'Report API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Report API error: $e');
    } finally {
      isSubmitting(false);
    }
  }
}