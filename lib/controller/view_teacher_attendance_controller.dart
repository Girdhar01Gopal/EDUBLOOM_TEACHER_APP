// ============================================================
//  view_teacher_attendance_controller.dart
// ============================================================
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/teacher_attendance_view2 model.dart';
import '../utils/app_snackbar.dart';

class ViewTeacherAttendanceController extends GetxController {
  // ── Credentials ───────────────────────────────────────────────────────────
  String schoolId = "";
  String token = "";
  String session = "";
  String userId = "";
  String roleName = "";
  // ── UI flag ───────────────────────────────────────────────────────────────
  final isLoading = false.obs;

  // ── Month picker ──────────────────────────────────────────────────────────
  final months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final selectedMonth = "January".obs;
  final selectedYear = DateTime.now().year.obs;

  // ── Data ──────────────────────────────────────────────────────────────────
  final reportList = <ViewTeacherAttendanceItem>[].obs;

  // ── API ───────────────────────────────────────────────────────────────────
  final String _api =
      "https://playschool.edubloom.in/api/TeacherApp/ViewTeacherAttendanceDetailsApp";

  int get monthIndex => months.indexOf(selectedMonth.value) + 1;
  int get daysInSelectedMonth =>
      DateTime(selectedYear.value, monthIndex + 1, 0).day;

  // ── Init ──────────────────────────────────────────────────────────────────
  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? "";
    roleName = await PrefManager().readValue(key: PrefConst.RName) ?? "";

    // Raw "SchoolId not found" jaisa text nahi — friendly line.
    if (schoolId.trim().isEmpty ||
        session.trim().isEmpty ||
        userId.trim().isEmpty) {
      AppSnackbar.error('Your session information is missing. Please login again.');
      return;
    }
    if (roleName.toLowerCase().trim() == "schoolstaff") {
      reportList.clear();
      return;
    }

    selectedMonth.value = months[DateTime.now().month - 1];
    await fetchReport();
  }

  void setMonth(String? m) {
    if (m == null) return;
    selectedMonth.value = m;
    reportList.clear();
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    if (isLoading.value) return;

    try {
      isLoading(true);

      final headers = <String, String>{
        "Content-Type": "application/json",
        "Accept": "application/json",
      };
      if (token.trim().isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      final requestBody = jsonEncode({
        "month": monthIndex,
        "schoolId": schoolId,
        "session": session,
        "userId": int.tryParse(userId) ?? 0,
        "roleName": roleName, // ✅ NEW
      });

      final res = await http.post(
        Uri.parse(_api),
        headers: headers,
        body: requestBody,
      );
      debugPrint("API response: ${res.statusCode} ${res.body}");
      debugPrint("Request body: $requestBody");

      if (res.statusCode != 200) {
        // Raw API body / status code user ko nahi dikhana.
        AppSnackbar.error(
          AppSnackbar.friendlyMessage(null, statusCode: res.statusCode),
        );
        return;
      }

      final decoded = jsonDecode(res.body);

      List<ViewTeacherAttendanceItem> rawList = [];

      if (decoded is Map<String, dynamic>) {
        rawList = ViewTeacherAttendanceResponse.fromJson(decoded).listData;
      } else if (decoded is List) {
        rawList = decoded
            .whereType<Map<String, dynamic>>()
            .map(ViewTeacherAttendanceItem.fromJson)
            .toList();
      }

      reportList.assignAll(_mergeByReg(rawList));

      if (reportList.isEmpty) {
        // AppSnackbar me sirf success/error style hain, isliye info bhi
        // usi card me "Info" title ke saath dikhta hai.
        AppSnackbar.success('No attendance data found', title: 'Info');
      }
    } catch (e) {
      // Raw "Fetch error: $e" nahi — friendly line.
      AppSnackbar.error(AppSnackbar.friendlyMessage(e));
    } finally {
      isLoading(false);
    }
  }

  List<ViewTeacherAttendanceItem> _mergeByReg(
      List<ViewTeacherAttendanceItem> raw,
      ) {
    // key = "teacherReg_name"
    final Map<String, ViewTeacherAttendanceItem> firstItem = {};
    final Map<String, Map<int, String?>> statusAcc = {};
    final Map<String, Map<int, String?>> inTimeAcc = {};
    final Map<String, Map<int, String?>> outTimeAcc = {};
    final Map<String, Map<int, String?>> inAddrAcc = {};
    final Map<String, Map<int, String?>> outAddrAcc = {};

    for (final item in raw) {
      final key =
          '${(item.teacherReg ?? "").trim()}_'
          '${(item.name ?? "").trim().toLowerCase()}';

      // First record for this teacher — initialise accumulators
      if (!firstItem.containsKey(key)) {
        firstItem[key] = item;
        statusAcc[key] = {};
        inTimeAcc[key] = {};
        outTimeAcc[key] = {};
        inAddrAcc[key] = {};
        outAddrAcc[key] = {};
      }

      final String? thisInTime = item.inTime;
      final String? thisOutTime = item.outTime;
      final String? thisInAddr = item.inAddress;
      final String? thisOutAddr = item.outAddress;

      for (int d = 1; d <= 31; d++) {
        final status = item.dayStatus(d);
        if (status != null && status.trim().isNotEmpty) {
          if (!statusAcc[key]!.containsKey(d)) {
            statusAcc[key]![d] = status.trim();
            inTimeAcc[key]![d] = item.dayIn(d) ?? thisInTime;
            outTimeAcc[key]![d] = item.dayOut(d) ?? thisOutTime;
            inAddrAcc[key]![d] = thisInAddr;
            outAddrAcc[key]![d] = thisOutAddr;
          }
        }
      }
    }

    // Beete hue working day (aaj ko chhodkar) jo mark nahi hua = Absent
    final daysInMonth = daysInSelectedMonth;
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    for (final k in firstItem.keys) {
      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(selectedYear.value, monthIndex, d);
        if (date.weekday != DateTime.sunday &&
            date.isBefore(todayDateOnly) &&
            !statusAcc[k]!.containsKey(d)) {
          statusAcc[k]![d] = "Absent";
        }
      }
    }

    // Build one merged item per teacher
    return firstItem.entries.map((e) {
      final k = e.key;
      return e.value.copyWith(
        days: statusAcc[k]!,
        dayInTimes: inTimeAcc[k]!,
        dayOutTimes: outTimeAcc[k]!,
        dayInAddresses: inAddrAcc[k]!,
        dayOutAddresses: outAddrAcc[k]!,
      );
    }).toList();
  }
}