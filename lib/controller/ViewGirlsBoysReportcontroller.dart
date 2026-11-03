import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/session_model.dart' as session_model;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/ViewGirlsBoysReportmodel.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

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
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          'Session API failed: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isPageLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata? s) =>
      selectedSession.value = s;

  Future<void> fetchStudents() async {
    if (selectedSession.value == null) {
      AppSnackbar.error("Select Session", title: "Missing");
      return;
    }
    if (selectedGender.value.isEmpty) {
      AppSnackbar.error("Select Gender", title: "Missing");
      return;
    }

    final session = selectedSession.value!.session ?? '';
    final gender = selectedGender.value;

    if (session.isEmpty) {
      AppSnackbar.error("Session is empty", title: "Missing");
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

          // ✅ Success / Info snackbar
          if (reportList.isEmpty) {
            AppSnackbar.error("No data found", title: "Info");
          } else {
            AppSnackbar.success("Data loaded successfully");
          }
        } else {
          AppSnackbar.apiError("Unexpected response format");
        }
      } else {
        AppSnackbar.apiError(
          'Report API failed: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isSubmitting(false);
    }
  }
}