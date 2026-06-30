// ============================================================
//  view_staff_attendance_controller.dart
// ============================================================
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/view staff attendance details.dart';

class ViewStaffAttendanceController extends GetxController {
  // ── School ─────────────────────────────────────────────────────────────────
  String schoolId = "";
  String token = "";
  String session = "";

  // ── UI ──────────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final errorMessage = "".obs;

  // ── Month dropdown ──────────────────────────────────────────────────────────
  final months = const [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  final selectedMonth = "January".obs;
  final selectedYear = DateTime.now().year.obs;

  // ── Report data (merged) ────────────────────────────────────────────────────
  final reportList = <StaffAttendanceView>[].obs;

  // ── API ─────────────────────────────────────────────────────────────────────
  final String detailsApi =
      "https://playschool.edubloom.in/api/StaffApp/ViewStaffAttendanceDetailsApp";

  int get monthIndex => months.indexOf(selectedMonth.value) + 1;
  int get daysInSelectedMonth => _daysInMonth(selectedYear.value, monthIndex);

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    if (session.trim().isEmpty) {
      Get.snackbar("Error", "Session not found");
      return;
    }

    selectedMonth.value = months[DateTime.now().month - 1];
  }

  void setMonth(String? m) {
    if (m == null) return;
    selectedMonth.value = m;
    reportList.clear();
  }

  // ── Fetch + merge ───────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    if (isLoading.value) return;

    try {
      isLoading(true);
      errorMessage.value = "";

      final body = {
        "month": monthIndex,
        "schoolId": schoolId,
        "session": session,
      };

      final headers = <String, String>{
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      if (token.trim().isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }

      final res = await http.post(
        Uri.parse(detailsApi),
        headers: headers,
        body: jsonEncode(body),
      );

      print("Request Body: ${jsonEncode(body)}");
      print("API Response: ${res.statusCode} - ${res.body}");

      if (res.statusCode != 200) {
        final msg = res.body.length > 250
            ? "${res.body.substring(0, 250)}..."
            : res.body;
        errorMessage.value = "API failed: ${res.statusCode}\n$msg";
        return;
      }

      final decoded = jsonDecode(res.body);
      List<StaffAttendanceView> rawList = [];

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('listData')) {
          rawList = (decoded['listData'] as List)
              .map((e) => StaffAttendanceView.fromJson(
              Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      } else if (decoded is List) {
        rawList = decoded
            .map((e) => StaffAttendanceView.fromJson(
            Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      print("Raw staff rows: ${rawList.length}");

      // ── Merge duplicate staffReg + name records ─────────────────────────
      final merged = _mergeByReg(rawList);
      reportList.assignAll(merged);

      print("Merged staff cards: ${reportList.length}");

      if (reportList.isEmpty) {
        errorMessage.value = "No data found";
      }
    } catch (e) {
      errorMessage.value = "Fetch error: $e";
    } finally {
      isLoading(false);
    }
  }

  // ── Merge records with same staffReg + name ─────────────────────────────────
  /// Each raw record may cover only some days + carries its own inTime/outTime.
  /// We merge all records into one item, assigning each day's in/out from
  /// whichever raw record contained that day's attendance.
  List<StaffAttendanceView> _mergeByReg(List<StaffAttendanceView> raw) {
    final Map<String, StaffAttendanceView> map = {};

    for (final item in raw) {
      final key =
          '${item.staffReg.trim()}_${item.name.trim().toLowerCase()}';

      if (!map.containsKey(key)) {
        // First record: build initial per-day in/out maps
        final inT = <int, String?>{};
        final outT = <int, String?>{};

        for (int d = 1; d <= 31; d++) {
          final status = item.attendanceDays['day$d'];
          if (status != null && status.isNotEmpty) {
            inT[d] = item.inTime;
            outT[d] = item.outTime;
          }
        }

        map[key] = item.copyWith(dayInTimes: inT, dayOutTimes: outT);
      } else {
        // Subsequent record: merge days + per-day times
        final existing = map[key]!;
        final newDays = Map<String, String?>.from(existing.attendanceDays);
        final newInT = Map<int, String?>.from(existing.dayInTimes);
        final newOutT = Map<int, String?>.from(existing.dayOutTimes);

        for (int d = 1; d <= 31; d++) {
          final status = item.attendanceDays['day$d'];
          if (status != null && status.isNotEmpty) {
            newDays['day$d'] = status;
            newInT[d] = item.inTime;
            newOutT[d] = item.outTime;
          }
        }

        map[key] = existing.copyWith(
          attendanceDays: newDays,
          dayInTimes: newInT,
          dayOutTimes: newOutT,
        );
      }
    }

    return map.values.toList();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
}