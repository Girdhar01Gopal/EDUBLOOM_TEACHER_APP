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
import '../models/viewdaycareattendencemodel.dart';
import '../res/app_url.dart';

class Viewdaycareattendancecontroller extends GetxController {
  // dropdown list
  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null);

  var listDataa = <vListData>[].obs;
  

  // months (UI dropdown)
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

  // actual API student attendance data
  RxList<ListData> students = <ListData>[].obs;

  var isLoading = false.obs;
  var schoolId = "";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    fetchSessions();
  }

Future<void> fetchSessions() async {
  final String apiUrl = '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

  try {
    isLoading(true);

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);

      // Clear old list
      sessionList.clear();

      // Read CURRENT SESSION only  
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
  // 🔥 API CALL FOR VIEW ATTENDANCE with new API endpoint
  Future<void> searchAttendance() async {
    if (selectedSession.value == null || selectedMonth.value == null) {
      Get.snackbar("Error", "Please select all fields");
      return;
    }

    try {
      isLoading(true);

      final url = Uri.parse('${AppUrl.base_url}api/StudentApp/ViewDaycareStudentAttendenceApp');

      final body = {
        "session": selectedSession.value!.session,
        "month": selectedMonth.value!['id'], // Pass the selected month ID
        "schoolId": schoolId,
      };

      print("📤 Sending Body => $body");

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("📥 Response => ${res.body}");

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

  // Set selected month based on user selection
  void setSelectedMonth(String monthName) {
    selectedMonth.value =
        months.firstWhere((m) => m['name'] == monthName, orElse: () => months[0]);
  }
}
