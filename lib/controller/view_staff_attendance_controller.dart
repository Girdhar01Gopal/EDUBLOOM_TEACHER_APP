// ============================================================
//  view_staff_attendance_controller.dart
// ============================================================
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/view staff attendance details.dart';
import '../utils/app_snackbar.dart';

class ViewStaffAttendanceController extends GetxController {
  // ── School / user context ────────────────────────────────────────────────
  String schoolId = "";
  String token = "";
  String session = "";

  String roleName = "SchoolStaff";
  int userId = 0;

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

    selectedMonth.value = months[DateTime.now().month - 1];

    final pref = PrefManager();
    schoolId = await pref.readValue(key: PrefConst.schollId) ?? "";
    token = await pref.readValue(key: PrefConst.token) ?? "";
    session = await pref.readValue(key: PrefConst.session) ?? "";

    // ✅ Sirf SchoolStaff login ho to uski apni id + role bhejo
    final loginRole = (await pref.readValue(key: PrefConst.RName) ?? "")
        .toString()
        .trim();
    if (loginRole.toLowerCase() == "schoolstaff") {
      roleName = "SchoolStaff";
      final userIdRaw = await pref.readValue(key: PrefConst.Userid);
      userId = int.tryParse(userIdRaw?.toString() ?? "") ?? 0;
    } else {
      // Teacher etc. ki id staff API ko kabhi nahi jayegi
      roleName = "SchoolStaff";
      userId = 0;
    }

    _validateContext();
  }

  // ── School / session check (snackbar me sirf friendly message) ─────────────
  bool _validateContext() {
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("School details not found. Please login again.");
      return false;
    }
    if (session.trim().isEmpty) {
      AppSnackbar.error("Session not found. Please login again.");
      return false;
    }
    return true;
  }

  void setMonth(String? m) {
    if (m == null) return;
    selectedMonth.value = m;
    reportList.clear();
  }

  // ── Fetch + merge ───────────────────────────────────────────────────────────
  Future<void> fetchReport() async {
    if (isLoading.value) return;
    if (!_validateContext()) return;

    try {
      isLoading(true);
      errorMessage.value = "";

      final headers = <String, String>{
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token.trim().isNotEmpty) "Authorization": "Bearer $token",
      };

      final body = {
        "month": monthIndex,
        "schoolId": schoolId,
        "session": session,
        "roleName": roleName, // ✅ hamesha "SchoolStaff"
        "userId": userId, // ✅ staff login = uski id, warna 0
      };

      // 🔍 Debug: check karo kya body ja rahi hai
      print("STAFF BODY => ${jsonEncode(body)}");

      final res = await http
          .post(
        Uri.parse(detailsApi),
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode != 200) {
        // ❌ Raw API text kabhi user ko nahi dikhega
        final msg = AppSnackbar.friendlyMessage(null,
            statusCode: res.statusCode);
        errorMessage.value = msg;
        AppSnackbar.error(msg);
        return;
      }

      final decoded = jsonDecode(res.body);
      Iterable? rows;

      if (decoded is Map<String, dynamic>) {
        final list = decoded['listData'];
        if (list is List) rows = list;
      } else if (decoded is List) {
        rows = decoded;
      }

      final rawList = (rows ?? const [])
          .map((e) => StaffAttendanceView.fromJson(
          Map<String, dynamic>.from(e as Map)))
          .toList();

      // ── Merge duplicate staffReg + name records ─────────────────────────
      reportList.assignAll(_mergeByReg(rawList));

      if (reportList.isEmpty) {
        errorMessage.value = "No data found";
      }
    } catch (e) {
      // ❌ Exception text user ko nahi dikhega, sirf friendly line
      final msg = AppSnackbar.friendlyMessage(e);
      errorMessage.value = msg;
      AppSnackbar.error(msg);
    } finally {
      isLoading(false);
    }
  }

  // ── Merge records with same staffReg + name ─────────────────────────────────
  List<StaffAttendanceView> _mergeByReg(List<StaffAttendanceView> raw) {
    final Map<String, StaffAttendanceView> map = {};

    for (final item in raw) {
      final key =
          '${item.staffReg.trim()}_${item.name.trim().toLowerCase()}';

      final existing = map[key];
      if (existing == null) {
        // ✅ First record already has correct dayInTimes/dayOutTimes from fromJson
        map[key] = item;
        continue;
      }

      // Subsequent record: merge days + per-day times
      final newDays = Map<String, String?>.from(existing.attendanceDays);
      final newInT = Map<int, String?>.from(existing.dayInTimes);
      final newOutT = Map<int, String?>.from(existing.dayOutTimes);
      final newInA = Map<int, String?>.from(existing.dayInAddresses);
      final newOutA = Map<int, String?>.from(existing.dayOutAddresses);

      for (int d = 1; d <= 31; d++) {
        final status = item.attendanceDays['day$d'];
        if (status != null && status.isNotEmpty) {
          newDays['day$d'] = status;
          newInT[d] = item.dayIn(d);
          newOutT[d] = item.dayOut(d);
          newInA[d] = item.dayInAddress(d);
          newOutA[d] = item.dayOutAddress(d);
        }
      }

      map[key] = existing.copyWith(
        attendanceDays: newDays,
        dayInTimes: newInT,
        dayOutTimes: newOutT,
        dayInAddresses: newInA,
        dayOutAddresses: newOutA,
      );
    }

    // ✅ Beete hue working day (aaj ko chhodkar) jo mark nahi hua = Absent
    final daysInMonth = daysInSelectedMonth;
    final year = selectedYear.value;
    final month = monthIndex;
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    return map.values.map((item) {
      Map<String, String?>? newDays;

      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(year, month, d);
        if (date.weekday == DateTime.sunday ||
            !date.isBefore(todayDateOnly)) {
          continue;
        }
        final s = item.attendanceDays['day$d'];
        if (s == null || s.trim().isEmpty) {
          newDays ??= Map<String, String?>.from(item.attendanceDays);
          newDays['day$d'] = "Absent";
        }
      }

      return newDays == null ? item : item.copyWith(attendanceDays: newDays);
    }).toList();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
}