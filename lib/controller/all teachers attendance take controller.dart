import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart' as session_model;
import '../models/teacher_attendance.dart';

class TeacherAttendanceController2 extends GetxController {
  static const String statusPresent = "PRESENT";
  static const String statusAbsent = "ABSENT";
  // Internal marker only. NOTE: the backend's "HD" means Holiday, not half day.
  static const String statusHalfDay = "HALFDAY";

  // ========= UI FLAGS =========
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isViewLoading = false.obs;
  final isViewSaving = false.obs;

  // Per-teacher saving flag — sirf jis teacher ka Save button dabaya usi
  // ke liye spinner/disable dikhana hai, baaki rows untouched rahe.
  final savingUserIds = <int>{}.obs;
  bool isSavingUser(int userId) => savingUserIds.contains(userId);

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
  final Map<int, String> _inOutMap = {}; // "IN" or "OUT"
  final Map<int, DateTime> _inTimeMap = {}; // user-picked check-in time
  final Map<int, DateTime> _outTimeMap = {}; // user-picked check-out time

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
    schoolId = (await PrefManager().readValue(key: PrefConst.schollId) ?? "")
        .toString();
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
    if (s.isEmpty) return statusPresent;
    if (s == statusAbsent || s == "A" || s.contains("ABS")) {
      return statusAbsent;
    }
    if (s == statusHalfDay || s.contains("HALF")) {
      return statusHalfDay;
    }
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
      lastDate: DateTime.now(),
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
  // LOCAL PERSISTENCE FOR IN/OUT TIME (per teacher, per date)
  // =========================================================
  // Ye keys selectedDate ke hisaab se scoped hain — isliye alag-alag din ka
  // data alag-alag key me rehta hai aur kabhi mix nahi hota. Purpose: agar
  // admin present laga ke ya out-time deke app band kar de / screen se
  // hat ke wapas aaye (shaam ko), to in/out time RAM (map) khaali hone par
  // bhi yahin se wapas mil jaaye — In/Out button pe "--:--" nahi, purana
  // time hi dikhega.
  String _inTimeKey(int teacherId) =>
      "teacher_att_intime_${teacherId}_${_formatDateApi(selectedDate.value)}";
  String _outTimeKey(int teacherId) =>
      "teacher_att_outtime_${teacherId}_${_formatDateApi(selectedDate.value)}";

  Future<void> _persistInTime(int teacherId, DateTime time) async {
    await PrefManager().writeValue(
      key: _inTimeKey(teacherId),
      value: _formatDateTimeApi(time),
    );
  }

  Future<void> _persistOutTime(int teacherId, DateTime time) async {
    await PrefManager().writeValue(
      key: _outTimeKey(teacherId),
      value: _formatDateTimeApi(time),
    );
  }

  Future<DateTime?> _readPersistedTime(String key) async {
    final v = await PrefManager().readValue(key: key);
    if (v == null || v.toString().trim().isEmpty) return null;
    return DateTime.tryParse(v.toString());
  }

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
  // NOTE: Status/time change karne par auto-save NAHI hota — sirf local
  // state (map) update hota hai. Save ya to per-row "Save" button
  // (saveAttendanceForUser) se hota hai, ya niche wale bulk "Save
  // Attendance" (saveAttendanceFromView) button se — dono available hain.
  String statusForUser(int userId, String? rawStatus) =>
      _statusMap[userId] ?? _normalizeStatus(rawStatus);

  void setStatusForUser(int userId, String status) {
    final normalized = _normalizeStatus(status);
    _statusMap[userId] = normalized;

    if (normalized == statusAbsent) {
      // Absent => no in/out time at all. Clear anything set earlier (also
      // the locally persisted copy) so it can't be saved for an absent day.
      _inTimeMap.remove(userId);
      _outTimeMap.remove(userId);
      _inOutMap.remove(userId);
      unawaited(PrefManager().writeValue(key: _inTimeKey(userId), value: ""));
      unawaited(PrefManager().writeValue(key: _outTimeKey(userId), value: ""));
    }
    // Present / Half Day: In and Out stay empty until picked by hand.

    _bump();
  }

  /// In/Out times are only meaningful for Present and Half Day.
  bool hasInOutTime(int userId, String? rawStatus) =>
      statusForUser(userId, rawStatus) != statusAbsent;

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
  // TIME PICKERS — stores EXACT selected time in plain map (no auto-save)
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
    final inTime =
    DateTime(d.year, d.month, d.day, picked.hour, picked.minute, 0);
    _inTimeMap[userId] = inTime;
    _inOutMap[userId] = "IN";
    _bump(); // triggers Obx rebuild in view

    // Local persist turant, taaki app kill hone par bhi ye value bachi rahe.
    // Server-save yahan se nahi hota — Save button dabane par hi hoga.
    await _persistInTime(userId, inTime);
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
    final outTime =
    DateTime(d.year, d.month, d.day, picked.hour, picked.minute, 0);
    _outTimeMap[userId] = outTime;
    _inOutMap[userId] = "OUT";
    _bump();

    await _persistOutTime(userId, outTime);
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

      // Purani (is date ke liye already set) values yaad rakho — taaki
      // dobara list load hone par (jaise shaam ko wapas aane par) already
      // diya hua status/in-time/out-time kho na jaaye. Priority order:
      // 1) Server se aayi fresh value (nested teacherAttendance object se)
      // 2) RAM me abhi tak ki value (isi session me pehle set hui thi)
      // 3) SharedPreferences me persisted value (app kill hone ke baad bhi)
      final Map<int, String> oldStatusMap = Map.of(_statusMap);
      final Map<int, String> oldInOutMap = Map.of(_inOutMap);
      final Map<int, DateTime> oldInTimeMap = Map.of(_inTimeMap);
      final Map<int, DateTime> oldOutTimeMap = Map.of(_outTimeMap);

      _statusMap.clear();
      _inOutMap.clear();
      _inTimeMap.clear();
      _outTimeMap.clear();

      DateTime? parseTime(String? val) {
        if (val == null || val.trim().isEmpty) return null;
        final d = DateTime.tryParse(val);
        if (d != null) return d;
        try {
          return DateTime.tryParse(
              "${_formatDateApi(selectedDate.value)} $val");
        } catch (_) {}
        return null;
      }

      for (final t in teacherUsers) {
        final id = t.userId;
        if (id == null) continue;

        // ---- STATUS: server value ho to wahi, warna purani local value ----
        final rawStatus = t.status ?? t.teacherAttendance?.attendanceStatus;
        _statusMap[id] = _normalizeStatus(
          (rawStatus != null && rawStatus.trim().isNotEmpty)
              ? rawStatus
              : oldStatusMap[id],
        );

        // ---- IN/OUT TIME ----
        // NOTE: TeacherUser model par top-level inTime/outTime getters
        // maujood nahi hain — isliye sirf nested teacherAttendance object
        // (aur uske andar ka "extra" map) se hi read kar rahe hain.
        final rawIn = t.teacherAttendance?.inTime ??
            t.teacherAttendance?.extra?['inTime']?.toString();
        final rawOut = t.teacherAttendance?.outTime ??
            t.teacherAttendance?.extra?['outTime']?.toString();

        final pIn = parseTime(rawIn);
        final pOut = parseTime(rawOut);

        final DateTime? persistedIn = pIn == null && oldInTimeMap[id] == null
            ? await _readPersistedTime(_inTimeKey(id))
            : null;
        final DateTime? persistedOut = pOut == null && oldOutTimeMap[id] == null
            ? await _readPersistedTime(_outTimeKey(id))
            : null;

        final DateTime? finalIn = pIn ?? oldInTimeMap[id] ?? persistedIn;
        final DateTime? finalOut = pOut ?? oldOutTimeMap[id] ?? persistedOut;

        if (finalIn != null) _inTimeMap[id] = finalIn;
        if (finalOut != null) _outTimeMap[id] = finalOut;

        _inOutMap[id] = (finalOut != null) ? "OUT" : (oldInOutMap[id] ?? "IN");
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
  // INDIVIDUAL / PARTICULAR TEACHER SAVE — Explicit per-row Save Button
  // =========================================================
  // Ye function SIRF ek particular teacher ka record save karta hai.
  // Isse baaki kisi bhi teacher ka data touch/reset nahi hota — bulk
  // "Save Attendance" (neeche wala green button) alag se maujood hai aur
  // waisa hi kaam karta hai jaisa pehle karta tha.
  TeacherUser? _findTeacher(int userId) {
    for (final t in teacherUsers) {
      if (t.userId == userId) return t;
    }
    return null;
  }

  String _safeNameForUser(TeacherUser t) {
    final n = "${t.firstName ?? ""} ${t.lastName ?? ""}".trim();
    return n.isEmpty ? "Teacher" : n;
  }

  static const _weekdays = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ];

  /// "09:00 AM" — the time format the save endpoint's body uses.
  String _formatTime12(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour < 12 ? "AM" : "PM";
    return "${h.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $period";
  }

  /// Internal status constant -> the text the save endpoint expects.
  String _statusLabel(String status) {
    if (status == statusAbsent) return "Absent";
    if (status == statusHalfDay) return "HalfDay";
    return "Present";
  }

  /// Body for SaveTeacherAttendenceApp, in the backend's updated format:
  /// status as text, weekday name in "day", ISO "adate", 12-hour times.
  Map<String, dynamic> _saveBody({
    required String teacherReg,
    required String status,
    required DateTime? inTime,
    required DateTime? outTime,
  }) {
    final d = selectedDate.value;
    final now = DateTime.now();
    final label = _statusLabel(status);
    return {
      "tadid": 0,
      "teacherReg": teacherReg,
      "status": label,
      "months": d.month,
      "session": selectedSession.value!.session,
      "day": _weekdays[d.weekday - 1],
      // Selected date at the current clock time, built as UTC so the date
      // part can't shift a day when converted.
      "adate":
      DateTime.utc(d.year, d.month, d.day, now.hour, now.minute, now.second)
          .toIso8601String(),
      "userAttendance": label,
      "schoolId": schoolId,
      "inTime": inTime != null ? _formatTime12(inTime) : null,
      "outTime": outTime != null ? _formatTime12(outTime) : null,
      "inAddress": "",
      "outAddress": "",
    };
  }

  /// The save endpoint answers a good save with isSuccess:false and
  /// statusCode:0, but data:"SUCCESS" / messages:"Attendance saved
  /// successfully" — so the flag alone can't be trusted.
  bool _saveSucceeded(dynamic json) {
    if (json is! Map) return false;
    if (json["isSuccess"] == true || json["statusCode"] == 200) return true;
    if ((json["data"] ?? "").toString().toUpperCase() == "SUCCESS") return true;
    return (json["messages"] ?? "")
        .toString()
        .toLowerCase()
        .contains("saved successfully");
  }

  /// The backend ignores the "status" we send and derives Present / Late /
  /// Absent from inTime: no In time means the day is stored as Absent. So a
  /// Present or Half Day save without an In time would silently become Absent.
  String? _missingInTimeReason(int userId, String? rawStatus) {
    if (!hasInOutTime(userId, rawStatus)) return null;
    return _inTimeMap[userId] == null
        ? "Pick an In time first — without it the day is stored as Absent"
        : null;
  }

  Future<void> saveAttendanceForUser(int userId) async {
    if (_sessionMissing()) {
      _showError("Session missing. Please select a session first.");
      return;
    }

    final t = _findTeacher(userId);
    if (t == null) {
      _showError("Teacher not found");
      return;
    }

    final String teacherReg = (t.additionalDetail?.registrationNo ?? "").trim();
    if (teacherReg.isEmpty) {
      _showError("Missing registration number for this teacher");
      return;
    }

    final missingIn = _missingInTimeReason(userId, t.status);
    if (missingIn != null) {
      _showError(missingIn);
      return;
    }

    if (savingUserIds.contains(userId)) {
      return; // already saving, ignore double-tap
    }
    savingUserIds.add(userId);

    try {
      final bool timed = hasInOutTime(userId, t.status);
      final DateTime? inTime = timed ? _inTimeMap[userId] : null;
      final DateTime? outTime = timed ? _outTimeMap[userId] : null;

      final body = _saveBody(
        teacherReg: teacherReg,
        status: _statusMap[userId] ?? _normalizeStatus(t.status),
        inTime: inTime,
        outTime: outTime,
      );

      final res = await http.post(
        Uri.parse(saveApi),
        headers: _headers(),
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        _showError("Failed to save: HTTP ${res.statusCode}");
        return;
      }

      final json = jsonDecode(res.body);
      if (_saveSucceeded(json)) {
        _showSuccess("Attendance saved for ${_safeNameForUser(t)}");
      } else {
        _showError(json["messages"]?.toString() ?? "Failed to save attendance");
      }
    } catch (e) {
      _showError("Save error: $e");
    } finally {
      savingUserIds.remove(userId);
    }
  }

  // =========================================================
  // SAVE — GREEN BUTTON (bulk, sab teachers ke liye — SAME AS BEFORE)
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
      int skipped = 0; // Present / Half Day teachers nobody gave an In time
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

        // Present / Half Day with no In time = not marked: the backend would
        // store that day as Absent anyway, so send it explicitly as Absent.
        final bool unmarked = _missingInTimeReason(userId, t.status) != null;
        if (unmarked) skipped++;

        final bool timed = !unmarked && hasInOutTime(userId, t.status);
        final DateTime? inTime = timed ? _inTimeMap[userId] : null;
        final DateTime? outTime = timed ? _outTimeMap[userId] : null;

        final body = _saveBody(
          teacherReg: teacherReg,
          status: unmarked
              ? statusAbsent
              : (_statusMap[userId] ?? _normalizeStatus(t.status)),
          inTime: inTime,
          outTime: outTime,
        );
        final who = _safeNameForUser(t);

        try {
          final res = await http.post(
            Uri.parse(saveApi),
            headers: _headers(),
            body: jsonEncode(body),
          );
          debugPrint("Saving for $who: ${jsonEncode(body)}");
          debugPrint(saveApi);

          if (res.statusCode != 200) {
            fail++;
            firstFailReason ??= "$who: HTTP ${res.statusCode}";
            debugPrint(
                "Teacher save failed ($who): HTTP ${res.statusCode} ${res.body}");
            continue;
          }

          final Map<String, dynamic> json = jsonDecode(res.body);

          if (_saveSucceeded(json)) {
            ok++;
          } else {
            fail++;
            firstFailReason ??= "$who: ${json["messages"] ?? "Unknown error"}";
            debugPrint("Teacher save failed ($who): ${res.body}");
          }
        } catch (e) {
          fail++;
          firstFailReason ??= "$who: $e";
          debugPrint("Teacher save error ($who): $e");
        }
      }

      // One final snackbar only
      if (fail == 0 && ok == 0) {
        _showError(skipped > 0 ? "Nothing saved." : "Nothing to save.");
      } else if (fail == 0) {
        _showSuccess("Attendance saved for $ok teacher(s)"
            "${skipped > 0 ? ", $skipped unmarked saved as Absent" : ""}");
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
      "Error",
      msg,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
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