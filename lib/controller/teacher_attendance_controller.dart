import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart' as session_model;
import '../models/teacher_attendance.dart';

class TeacherAttendanceController extends GetxController {
  static const String statusPresent = "PRESENT";
  static const String statusAbsent = "ABSENT";
  static const String statusHold = "HOLD";

  // ========= UI FLAGS =========
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isViewLoading = false.obs;
  final isViewSaving = false.obs;

  // ========= STORAGE =========
  String schoolId = "";
  String token = "";

  // ========= SESSION =========
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ========= DATE =========
  final selectedDate = DateTime.now().obs;
  String get displayDate => _formatDateUI(selectedDate.value);

  // ========= TEACHERS LIST =========
  final teacherUsers = <TeacherUser>[].obs;

  // =========================================================
  // PER-TEACHER DATA — plain maps (no RxMap issues)
  // mapVersion.value++ triggers all Obx that depend on it
  // =========================================================
  final Map<int, String> _statusMap = {};
  final Map<int, String> _inOutMap = {};    // "IN" or "OUT"
  final Map<int, DateTime> _inTimeMap = {}; // user-picked check-in time
  final Map<int, DateTime> _outTimeMap = {};// user-picked check-out time

  /// Increment to force Obx widgets to rebuild after map changes
  final mapVersion = 0.obs;
  void _bump() => mapVersion.value++;

  // ========= APIs =========
  final String viewApi =
      "https://playschool.edubloom.in/api/TeacherApp/ViewTeacherAttendanceApp";
  final String saveApi =
      "https://playschool.edubloom.in/api/TeacherApp/SaveTeacherAttendenceApp";
  final String sessionApiBase =
      "https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/";

  // ========= INIT =========
  @override
  void onInit() async {
    super.onInit();
    schoolId =
        (await PrefManager().readValue(key: PrefConst.schollId) ?? "").toString();
    token =
        (await PrefManager().readValue(key: PrefConst.token) ?? "").toString();

    if (schoolId.trim().isEmpty) {
      _showError("SchoolId not found. Please login again.");
      return;
    }
    await fetchSessions();
  }

  // =========================================================
  // FORMATTERS
  // =========================================================
  String _formatDateApi(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }

  /// "yyyy-MM-dd HH:mm:ss"
  String _formatDateTimeApi(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')} "
        "${d.hour.toString().padLeft(2, '0')}:"
        "${d.minute.toString().padLeft(2, '0')}:"
        "${d.second.toString().padLeft(2, '0')}";
  }

  String _formatDateUI(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year}";
  }

  String fmtTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  String _normalizeStatus(String? status) {
    if (status == null) return statusPresent;
    final s = status.trim().toUpperCase();
    if (s == statusAbsent || s == "A") return statusAbsent;
    if (s == statusHold || s == "HOLIDAY" || s == "H") return statusHold;
    return statusPresent;
  }

  // =========================================================
  // DATE PICKER
  // =========================================================
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) selectedDate.value = picked;
  }

  Map<String, String> _headers() {
    final h = <String, String>{"Content-Type": "application/json"};
    if (token.trim().isNotEmpty) h["Authorization"] = "Bearer $token";
    return h;
  }

  bool _sessionMissing() =>
      selectedSession.value == null ||
          (selectedSession.value!.session ?? "").trim().isEmpty;

  // =========================================================
  // SESSIONS
  // =========================================================
  Future<void> fetchSessions() async {
    try {
      isPageLoading(true);
      final response = await http.get(
        Uri.parse("$sessionApiBase$schoolId"),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        _showError("Session API failed: ${response.statusCode}");
        return;
      }
      final jsonData = jsonDecode(response.body);
      sessionList.clear();
      if (jsonData is Map && jsonData['currentSession'] != null) {
        final cs = jsonData['currentSession'];
        final obj = session_model.sListDdata(
          sessionId: cs['currentSessionId'],
          session: cs['currentSession'],
          action: cs['action'],
          schoolId: cs['schoolId'],
        );
        sessionList.add(obj);
        selectedSession.value = obj;
      }
      if (sessionList.isEmpty) _showInfo("No session found");
    } catch (e) {
      _showError("Failed to load sessions: $e");
    } finally {
      isPageLoading(false);
    }
  }

  void setSession(session_model.sListDdata? s) => selectedSession.value = s;

  // =========================================================
  // PER-TEACHER GETTERS & SETTERS
  // =========================================================
  String statusForUser(int userId, String? rawStatus) =>
      _statusMap[userId] ?? _normalizeStatus(rawStatus);

  void setStatusForUser(int userId, String status) {
    _statusMap[userId] = _normalizeStatus(status);
    _bump();
  }

  String inOutForUser(int userId) => _inOutMap[userId] ?? "IN";

  void setInOutForUser(int userId, String val) {
    _inOutMap[userId] = val;
    _bump();
  }

  /// Returns the EXACT user-selected check-in time (null = not yet selected)
  DateTime? inTimeForUser(int userId) => _inTimeMap[userId];

  /// Returns the EXACT user-selected check-out time (null = not yet selected)
  DateTime? outTimeForUser(int userId) => _outTimeMap[userId];

  // =========================================================
  // TIME PICKERS — stores EXACT selected time in plain map
  // =========================================================
  Future<void> pickInTimeForUser(int userId) async {
    final existing = _inTimeMap[userId];
    final initial = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : TimeOfDay.now();

    final picked =
    await showTimePicker(context: Get.context!, initialTime: initial);
    if (picked == null) return; // cancelled — keep old value unchanged

    // Use selectedDate for date part, user-picked HH:mm for time part
    final d = selectedDate.value;
    _inTimeMap[userId] =
        DateTime(d.year, d.month, d.day, picked.hour, picked.minute, 0);
    _bump(); // triggers Obx rebuild in view
  }

  Future<void> pickOutTimeForUser(int userId) async {
    final existing = _outTimeMap[userId];
    final initial = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : TimeOfDay.now();

    final picked =
    await showTimePicker(context: Get.context!, initialTime: initial);
    if (picked == null) return; // cancelled — keep old value unchanged

    final d = selectedDate.value;
    _outTimeMap[userId] =
        DateTime(d.year, d.month, d.day, picked.hour, picked.minute, 0);
    _bump();
  }

  // =========================================================
  // ORANGE BUTTON
  // =========================================================
  Future<void> loadAttendanceFromAddTab() async {
    if (_sessionMissing()) {
      _showError("Please select a session first");
      return;
    }
    try {
      isSaving(true);
      await fetchTeacherAttendanceList();
    } catch (e) {
      _showError("Error loading attendance: $e");
    } finally {
      isSaving(false);
    }
  }

  Future<void> refreshListTab() async {
    if (_sessionMissing()) {
      _showError("Select session first");
      return;
    }
    await fetchTeacherAttendanceList();
  }

  // =========================================================
  // VIEW API
  // =========================================================
  Future<void> fetchTeacherAttendanceList() async {
    try {
      isViewLoading(true);

      final res = await http.post(
        Uri.parse(viewApi),
        headers: _headers(),
        body: jsonEncode({
          "date": _formatDateApi(selectedDate.value),
          "session": selectedSession.value!.session,
          "schoolId": schoolId,
        }),
      );

      if (res.statusCode != 200) {
        _showError("Failed to load: ${res.statusCode}");
        return;
      }

      final parsed = TeacherListResponse.fromJson(jsonDecode(res.body));
      teacherUsers.assignAll(parsed.listData);

      // Reset all per-teacher maps
      _statusMap.clear();
      _inOutMap.clear();
      _inTimeMap.clear();
      _outTimeMap.clear();

      for (final t in teacherUsers) {
        final id = t.userId;
        if (id == null) continue;
        _statusMap[id] = _normalizeStatus(t.status);
        _inOutMap[id] = "IN";
        // inTime & outTime = null → user must tap to select
      }

      _bump();

      if (teacherUsers.isEmpty) {
        _showInfo("No teachers found for selected date/session");
      } else {
        _showSuccess("${teacherUsers.length} teacher(s) loaded successfully");
      }
    } catch (e) {
      _showError("Error loading list: $e");
    } finally {
      isViewLoading(false);
    }
  }

  // =========================================================
  // SAVE — GREEN BUTTON
  // Sends EXACT user-selected inTime & outTime for each teacher
  // =========================================================
  Future<void> saveAttendanceFromView() async {
    if (_sessionMissing()) {
      _showError("Session missing. Please select a session first.");
      return;
    }
    if (teacherUsers.isEmpty) {
      _showError("No data to save. Click 'Manage Attendance' first.");
      return;
    }

    try {
      isViewSaving(true);

      int ok = 0;
      int fail = 0;
      String? firstFailReason;

      for (final t in teacherUsers) {
        final int? userId = t.userId;
        final String teacherReg =
        (t.additionalDetail?.registrationNo ?? "").trim();

        if (userId == null || teacherReg.isEmpty) {
          fail++;
          firstFailReason ??= "Missing teacher ID or registration number";
          continue;
        }

        // ✅ Read EXACT user-selected times from plain maps
        final DateTime? inTime = _inTimeMap[userId];
        final DateTime? outTime = _outTimeMap[userId];

        // ✅ Format only if user has actually selected that time
        final String? inTimeStr =
        inTime != null ? _formatDateTimeApi(inTime) : null;
        final String? outTimeStr =
        outTime != null ? _formatDateTimeApi(outTime) : null;

        final body = {
          "tadid": 0,
          "teacherReg": teacherReg,
          "status": _statusMap[userId] ?? _normalizeStatus(t.status),
          "months": selectedDate.value.month,
          "session": selectedSession.value!.session,
          "day": selectedDate.value.day.toString(),
          "adate": _formatDateApi(selectedDate.value),
          "userAttendance": "admin",
          "schoolId": schoolId,
          "inTime": inTimeStr,   // exact selected check-in time or null
          "outTime": outTimeStr, // exact selected check-out time or null
          "inOut": _inOutMap[userId] ?? "IN",
          "inAddress": "",
          "outAddress": "",
        };

        try {
          final res = await http.post(
            Uri.parse(saveApi),
            headers: _headers(),
            body: jsonEncode(body),
          );

          if (res.statusCode != 200) {
            fail++;
            firstFailReason ??= "HTTP ${res.statusCode}";
            continue;
          }

          final Map<String, dynamic> json = jsonDecode(res.body);
          final bool isSuccess =
              (json["isSuccess"] == true) || (json["statusCode"] == 200);

          if (isSuccess) {
            ok++;
          } else {
            fail++;
            firstFailReason ??= json["messages"]?.toString() ?? "Unknown error";
          }
        } catch (e) {
          fail++;
          firstFailReason ??= "Request error: $e";
        }
      }

      // ✅ One final snackbar only
      if (fail == 0) {
        _showSuccess("Attendance saved successfully for $ok teacher(s)");
      } else if (ok > 0) {
        Get.snackbar(
          "Partially Saved",
          "Saved: $ok  |  Failed: $fail\n${firstFailReason ?? ""}",
          backgroundColor: Colors.orange.shade800,
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
          borderRadius: 10,
        );
      } else {
        _showError("\n${firstFailReason ?? "Please try again."}");
      }
    } catch (e) {
      _showError("Unexpected error: $e");
    } finally {
      isViewSaving(false);
    }
  }

  // =========================================================
  // SNACKBARS — green/white success, red error, blue info
  // =========================================================
  void _showSuccess(String msg) {
    Get.snackbar(
      "Success",
      msg,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  void _showError(String msg) {
    Get.snackbar(
      "",
      msg,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      //icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  void _showInfo(String msg) {
    Get.snackbar(
      "Info",
      msg,
      backgroundColor: Colors.blue.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }
}