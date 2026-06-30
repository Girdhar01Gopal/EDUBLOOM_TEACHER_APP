// ============================================================
//  view_teacher_attendance_controller.dart
// ============================================================
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/teacher_attendance_view2 model.dart';

class ViewTeacherAttendanceController extends GetxController {
  // ── Credentials ───────────────────────────────────────────────────────────
  String schoolId = "";
  String token    = "";
  String session  = "";

  // ── UI flag ───────────────────────────────────────────────────────────────
  final isLoading = false.obs;

  // ── Month picker ──────────────────────────────────────────────────────────
  final months = const [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December",
  ];

  final selectedMonth = "January".obs;
  final selectedYear  = DateTime.now().year.obs;

  // ── Data ──────────────────────────────────────────────────────────────────
  final reportList = <ViewTeacherAttendanceItem>[].obs;

  // ── API ───────────────────────────────────────────────────────────────────
  final String _api =
      "https://playschool.edubloom.in/api/TeacherApp/ViewTeacherAttendanceDetailsApp";

  int get monthIndex        => months.indexOf(selectedMonth.value) + 1;
  int get daysInSelectedMonth =>
      DateTime(selectedYear.value, monthIndex + 1, 0).day;

  // ── Init ──────────────────────────────────────────────────────────────────
  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token    = await PrefManager().readValue(key: PrefConst.token)    ?? "";
    session  = await PrefManager().readValue(key: PrefConst.session)  ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }
    if (session.trim().isEmpty) {
      Get.snackbar("Error", "Session not found");
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
        "Accept"       : "application/json",
      };
      if (token.trim().isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      final res = await http.post(
        Uri.parse(_api),
        headers: headers,
        body: jsonEncode({
          "month"   : monthIndex,
          "schoolId": schoolId,
          "session" : session,
        }),
      );

      if (res.statusCode != 200) {
        final msg = res.body.length > 250
            ? "${res.body.substring(0, 250)}…"
            : res.body;
        Get.snackbar("Error", "API failed: ${res.statusCode}\n$msg");
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
        Get.snackbar("Info", "No attendance data found");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch error: $e");
    } finally {
      isLoading(false);
    }
  }

  // ── Merge ─────────────────────────────────────────────────────────────────
  /// The API sends multiple records per teacher — one per "batch save".
  /// Each record has its OWN inTime / outTime and covers specific days.
  ///
  /// Goal: for every day that has a status, store the inTime/outTime from
  ///       THE SAME record that provided that day's status.
  ///
  /// Example from real API response:
  ///   Record-A  inTime:"11:21"  outTime:"11:56"  → day1,day2,day3,day6,day15
  ///   Record-B  inTime:"10:35"  outTime:"10:36"  → day28
  ///   Record-C  inTime:"12:06"  outTime:null     → day19
  ///
  /// Result after merge:
  ///   day1  → in:11:21  out:11:56
  ///   day28 → in:10:35  out:10:36   ← exact time user saved for that day
  ///   day19 → in:12:06  out:null
  List<ViewTeacherAttendanceItem> _mergeByReg(
      List<ViewTeacherAttendanceItem> raw) {

    // key = "teacherReg_name"
    final Map<String, ViewTeacherAttendanceItem>  firstItem  = {};
    final Map<String, Map<int, String?>>          statusAcc  = {};
    final Map<String, Map<int, String?>>          inTimeAcc  = {};
    final Map<String, Map<int, String?>>          outTimeAcc = {};

    for (final item in raw) {
      final key =
          '${(item.teacherReg ?? "").trim()}_'
          '${(item.name ?? "").trim().toLowerCase()}';

      // First record for this teacher — initialise accumulators
      if (!firstItem.containsKey(key)) {
        firstItem [key] = item;
        statusAcc [key] = {};
        inTimeAcc [key] = {};
        outTimeAcc[key] = {};
      }

      // THIS record's check-in / check-out time (may be null if not saved)
      final String? thisInTime  = item.inTime;
      final String? thisOutTime = item.outTime;

      // Walk every possible day; if THIS record has a status → record its time
      for (int d = 1; d <= 31; d++) {
        final status = item.dayStatus(d);
        if (status != null && status.trim().isNotEmpty) {
          statusAcc [key]![d] = status.trim();
          inTimeAcc [key]![d] = thisInTime;   // ✅ time from THIS record only
          outTimeAcc[key]![d] = thisOutTime;  // ✅ time from THIS record only
        }
      }
    }

    // Build one merged item per teacher
    return firstItem.entries.map((e) {
      final k = e.key;
      return e.value.copyWith(
        days       : statusAcc [k]!,
        dayInTimes : inTimeAcc [k]!,
        dayOutTimes: outTimeAcc[k]!,
      );
    }).toList();
  }
}