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
import '../utils/app_snackbar.dart';

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
      } else {
        debugPrint("❌ fetchSessions Status ${response.statusCode}");
        debugPrint("❌ fetchSessions Body ${response.body}");
        AppSnackbar.apiError(
          'Failed to load sessions => ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, s) {
      debugPrint("❌ fetchSessions error => $e");
      AppSnackbar.apiError(e, stackTrace: s);
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
      AppSnackbar.error("Please select all fields");
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
        final rawList = parsed.listData ?? <ListData>[];

        // ✅ API ek student ki multiple rows bhejti hai (har din ki alag).
        // studentId se group karke saare dayN ek hi object me merge karo.
        final Map<int, ListData> merged = {};
        final List<ListData> noIdRows = [];

        for (final row in rawList) {
          final id = row.studentId;
          if (id == null) {
            noIdRows.add(row);
            continue;
          }

          if (!merged.containsKey(id)) {
            merged[id] = row;
            continue;
          }

          final base = merged[id]!;
          base.studentName ??= row.studentName;
          base.className ??= row.className;
          base.classId ??= row.classId;
          base.sectionId ??= row.sectionId;
          base.sectionName ??= row.sectionName;
          base.months ??= row.months;
          base.sex ??= row.sex;
          base.session ??= row.session;
          base.dob ??= row.dob;
          base.adate ??= row.adate;
          base.day1 ??= row.day1;
          base.day2 ??= row.day2;
          base.day3 ??= row.day3;
          base.day4 ??= row.day4;
          base.day5 ??= row.day5;
          base.day6 ??= row.day6;
          base.day7 ??= row.day7;
          base.day8 ??= row.day8;
          base.day9 ??= row.day9;
          base.day10 ??= row.day10;
          base.day11 ??= row.day11;
          base.day12 ??= row.day12;
          base.day13 ??= row.day13;
          base.day14 ??= row.day14;
          base.day15 ??= row.day15;
          base.day16 ??= row.day16;
          base.day17 ??= row.day17;
          base.day18 ??= row.day18;
          base.day19 ??= row.day19;
          base.day20 ??= row.day20;
          base.day21 ??= row.day21;
          base.day22 ??= row.day22;
          base.day23 ??= row.day23;
          base.day24 ??= row.day24;
          base.day25 ??= row.day25;
          base.day26 ??= row.day26;
          base.day27 ??= row.day27;
          base.day28 ??= row.day28;
          base.day29 ??= row.day29;
          base.day30 ??= row.day30;
          base.day31 ??= row.day31;

          // attendanceDateWise maps ko bhi merge karo
          if (row.attendanceDateWise != null) {
            base.attendanceDateWise = {
              ...?base.attendanceDateWise,
              ...row.attendanceDateWise!,
            };
          }
        }

        students.value = [...merged.values, ...noIdRows];
      } else {
        debugPrint("❌ searchAttendance Status ${res.statusCode}");
        debugPrint("❌ searchAttendance Body ${res.body}");
        AppSnackbar.apiError(
          'Failed to load attendance => ${res.body}',
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      debugPrint("❌ searchAttendance error => $e");
      AppSnackbar.apiError(e, stackTrace: s);
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