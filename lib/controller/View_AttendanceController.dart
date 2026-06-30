import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/session_model.dart' as session_model;
import '../models/viewattendancemodel.dart';
import '../res/app_url.dart';

class ViewAttendanceController extends GetxController {
  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null);

  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);
  var session = ''.obs;

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rx<ListDatta?>(null);

  final months = [
    {'name': 'January', 'id': 1},
    {'name': 'February', 'id': 2},
    {'name': 'March', 'id': 3},
    {'name': 'April', 'id': 4},
    {'name': 'May', 'id': 5},
    {'name': 'June', 'id': 6},
    {'name': 'July', 'id': 7},
    {'name': 'August', 'id': 8},
    {'name': 'September', 'id': 9},
    {'name': 'October', 'id': 10},
    {'name': 'November', 'id': 11},
    {'name': 'December', 'id': 12},
  ];

  var selectedMonth = Rx<Map<String, dynamic>?>(null);

  RxList<ListData> students = <ListData>[].obs;

  var isLoading = false.obs;
  var schoolId = "";
  var token = "";

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    fetchSessions();
    fetchClasses();
    fetchSections();
  }

  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
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
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata session) {
    selectedSession.value = session;
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
      );
      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        listDataa.value =
            parsed.listData?.where((e) => e.action == "1").toList() ?? [];
        selectedClass.value = null;
      }
    } catch (e) {
      debugPrint("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSections() async {
    try {
      isLoading(true);
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId'),
      );
      if (res.statusCode == 200) {
        List jsonList = jsonDecode(res.body)['listData'] ?? [];
        sectionList.value =
            jsonList.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      }
    } catch (e) {
      debugPrint("Error fetching sections: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> searchAttendance() async {
    if (selectedSession.value == null ||
        selectedClass.value == null ||
        selectedSection.value == null ||
        selectedMonth.value == null) {
      Get.snackbar("Error", "Please select all fields");
      return;
    }
    try {
      isLoading(true);
      final url = Uri.parse(
          '${AppUrl.base_url}api/StudentApp/ViewStudentAttendanceDetailsApp');
      final body = {
        "session": selectedSession.value!.session,
        "classId": selectedClass.value!.classId,
        "sectionId": selectedSection.value!.sectionId,
        "month": selectedMonth.value!['id'],
        "schoolId": schoolId,
      };
      debugPrint("📤 Sending Body => $body");
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint("📥 Response => ${res.body}");
      if (res.statusCode == 200) {
        final parsed = viewattendence.fromJson(jsonDecode(res.body));
        students.value = parsed.listData ?? [];
      } else {
        Get.snackbar("Error", "Failed to load attendance");
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedMonth(String monthName) {
    selectedMonth.value = months.firstWhere(
          (m) => m['name'] == monthName,
      orElse: () => months[0],
    );
  }

  int getYearFromSession() {
    final sessionStr = selectedSession.value?.session ?? "";
    if (sessionStr.contains("-")) {
      final parts = sessionStr.split("-");
      final parsed = int.tryParse(parts[0]);
      if (parsed != null) return parsed;
    }
    return DateTime.now().year;
  }

  Future<bool> editAttendance({
    required int studentId,
    required String status,
    required int day,
  }) async {
    final monthId = selectedMonth.value?['id'] as int? ?? 1;
    final year = getYearFromSession();
    final dateStr =
        "$year-${monthId.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

    try {
      final url =
      Uri.parse('${AppUrl.base_url}api/StudentApp/SaveAttendenceApp');
      final body = {
        "studentId": studentId,
        "status": status,
        "months": monthId,
        "session": selectedSession.value?.session ?? "",
        "classId": selectedClass.value?.classId,
        "sectionId": selectedSection.value?.sectionId,
        "adate": dateStr,
        "schoolId": schoolId,
        "userAttendance": "Admin",
      };
      debugPrint("📤 editAttendance => ${jsonEncode(body)}");
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      debugPrint("📥 editAttendance => ${res.statusCode} | ${res.body}");
      return res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204;
    } catch (e) {
      debugPrint("⚠️ editAttendance error: $e");
      return false;
    }
  }
}