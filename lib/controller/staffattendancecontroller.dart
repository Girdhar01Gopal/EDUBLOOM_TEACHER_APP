import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart' as session_model;
import '../models/teacher_attendance.dart';

class Staffattendancecontroller extends GetxController {
  static const String statusPresent = "PRESENT";
  static const String statusAbsent  = "ABSENT";
  static const String statusHold    = "HOLD";

  // ========= UI FLAGS =========
  final isPageLoading = false.obs;
  final isSaving      = false.obs;
  final isViewLoading = false.obs;
  final isViewSaving  = false.obs;

  // ========= CHECK-IN / CHECK-OUT (background GPS logic) =========
  final isChecking      = false.obs;
  final checkInTime     = Rxn<DateTime>();
  final checkOutTime    = Rxn<DateTime>();
  final checkInLat      = RxnDouble();
  final checkInLng      = RxnDouble();
  final checkOutLat     = RxnDouble();
  final checkOutLng     = RxnDouble();
  final checkInAddress  = "".obs;
  final checkOutAddress = "".obs;
  final isCheckInFlag   = false.obs;

  bool get isCheckedIn  => checkInTime.value != null && checkOutTime.value == null;
  bool get isCheckedOut => checkInTime.value != null && checkOutTime.value != null;

  // ========= STORAGE =========
  String schoolId = "";
  String token    = "";

  // ========= SESSION =========
  final sessionList     = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ========= DATE =========
  final selectedDate = DateTime.now().obs;
  String get displayDate => _formatDateUI(selectedDate.value);

  // ========= STAFF LIST =========
  final teacherUsers = <TeacherUser>[].obs;

  // =========================================================
  // PER-STAFF DATA MAPS
  // =========================================================
  final Map<int, String>   _statusMap  = {};
  final Map<int, String>   _inOutMap   = {};
  final Map<int, DateTime> _inTimeMap  = {};
  final Map<int, DateTime> _outTimeMap = {};

  final mapVersion = 0.obs;
  void _bump() => mapVersion.value++;

  // ========= APIs =========
  final String viewApi =
      "https://playschool.edubloom.in/api/StaffApp/ViewStaffAttendanceApp";
  final String saveApi =
      "https://playschool.edubloom.in/api/StaffApp/SaveStaffAttendenceApp";
  final String sessionApiBase =
      "https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/";

  // ========= INIT =========
  @override
  void onInit() async {
    super.onInit();
    schoolId = (await PrefManager().readValue(key: PrefConst.schollId) ?? "").toString();
    token    = (await PrefManager().readValue(key: PrefConst.token)    ?? "").toString();
    if (schoolId.trim().isEmpty) {
      _showError("SchoolId not found. Please login again.");
      return;
    }
    await _loadCheckInState();
    await fetchSessions();
  }

  // =========================================================
  // FORMATTERS
  // =========================================================
  String _formatDateApi(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')}";

  String _formatDateTimeApi(DateTime d) =>
      "${_formatDateApi(d)} "
          "${d.hour.toString().padLeft(2, '0')}:"
          "${d.minute.toString().padLeft(2, '0')}:"
          "${d.second.toString().padLeft(2, '0')}";

  String _formatDateUI(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}";

  String fmtTime(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";

  String _normalizeStatus(String? status) {
    if (status == null) return statusPresent;
    final s = status.trim().toUpperCase();
    if (s == statusAbsent || s == "A") return statusAbsent;
    if (s == statusHold   || s == "HOLIDAY" || s == "H") return statusHold;
    return statusPresent;
  }

  // =========================================================
  // CHECK-IN STATE PERSISTENCE
  // =========================================================
  DateTime? _readDateTimePref(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Future<void> _loadCheckInState() async {
    await _loadCheckInFlag();
    final inTimeRaw  = await PrefManager().readValue(key: PrefConst.staffCheckinTime)
        ?? await PrefManager().readValue(key: PrefConst.checkinTime);
    final outTimeRaw = await PrefManager().readValue(key: PrefConst.staffCheckoutTime)
        ?? await PrefManager().readValue(key: PrefConst.checkoutTime);
    checkInTime.value  = _readDateTimePref(inTimeRaw);
    checkOutTime.value = _readDateTimePref(outTimeRaw);
    if (checkInTime.value != null && checkOutTime.value == null) isCheckInFlag.value = true;
    if (checkOutTime.value != null) isCheckInFlag.value = false;
  }

  Future<void> _loadCheckInFlag() async {
    final v = await PrefManager().readValue(key: PrefConst.staffCheckinFlag)
        ?? await PrefManager().readValue(key: PrefConst.checkin);
    if (v == null) { isCheckInFlag.value = false; return; }
    if (v is bool) { isCheckInFlag.value = v;     return; }
    final s = v.toString().trim();
    isCheckInFlag.value = s == "1" || s.toLowerCase() == "true";
  }

  Future<void> _saveCheckInFlag(bool value) async {
    isCheckInFlag.value = value;
    await PrefManager().writeValue(key: PrefConst.staffCheckinFlag, value: value ? 1 : 0);
  }

  Future<void> _saveCheckInTime(DateTime? value) async {
    checkInTime.value = value;
    await PrefManager().writeValue(key: PrefConst.staffCheckinTime, value: value?.toIso8601String());
  }

  Future<void> _saveCheckOutTime(DateTime? value) async {
    checkOutTime.value = value;
    await PrefManager().writeValue(key: PrefConst.staffCheckoutTime, value: value?.toIso8601String());
  }

  Future<void> resetCheckInOut() async {
    await _saveCheckInTime(null);
    await _saveCheckOutTime(null);
    checkInLat.value  = null;
    checkInLng.value  = null;
    checkOutLat.value = null;
    checkOutLng.value = null;
    checkInAddress.value  = "";
    checkOutAddress.value = "";
    await _saveCheckInFlag(false);
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

  Map<String, String> _headers() => {
    "Content-Type": "application/json",
    if (token.trim().isNotEmpty) "Authorization": "Bearer $token",
  };

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
          session:   cs['currentSession'],
          action:    cs['action'],
          schoolId:  cs['schoolId'],
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
  // PER-STAFF GETTERS & SETTERS
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

  DateTime? inTimeForUser(int userId)  => _inTimeMap[userId];
  DateTime? outTimeForUser(int userId) => _outTimeMap[userId];

  // =========================================================
  // PER-STAFF TIME PICKERS
  // =========================================================
  Future<void> pickInTimeForUser(int userId) async {
    final existing = _inTimeMap[userId];
    final initial  = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : TimeOfDay.now();
    final picked = await showTimePicker(context: Get.context!, initialTime: initial);
    if (picked == null) return;
    final d = selectedDate.value;
    _inTimeMap[userId] = DateTime(d.year, d.month, d.day, picked.hour, picked.minute, 0);
    _bump();
  }

  Future<void> pickOutTimeForUser(int userId) async {
    final existing = _outTimeMap[userId];
    final initial  = existing != null
        ? TimeOfDay(hour: existing.hour, minute: existing.minute)
        : TimeOfDay.now();
    final picked = await showTimePicker(context: Get.context!, initialTime: initial);
    if (picked == null) return;
    final d = selectedDate.value;
    _outTimeMap[userId] = DateTime(d.year, d.month, d.day, picked.hour, picked.minute, 0);
    _bump();
  }

  // =========================================================
  // GPS CHECK-IN / CHECK-OUT
  // =========================================================
  Future<Position?> _getPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) { Get.snackbar("Location", "Please enable Location services"); return null; }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      Get.snackbar("Location", "Location permission denied");
      return null;
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return "Address not found";
      final p = placemarks.first;
      final parts = <String>[
        if ((p.name               ?? "").trim().isNotEmpty) p.name!.trim(),
        if ((p.street             ?? "").trim().isNotEmpty) p.street!.trim(),
        if ((p.subLocality        ?? "").trim().isNotEmpty) p.subLocality!.trim(),
        if ((p.locality           ?? "").trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? "").trim().isNotEmpty) p.administrativeArea!.trim(),
        if ((p.postalCode         ?? "").trim().isNotEmpty) p.postalCode!.trim(),
      ];
      return parts.isEmpty ? "Address not found" : parts.join(", ");
    } catch (_) {
      return "Address not available";
    }
  }

  Future<void> doCheckIn() async {
    if (_sessionMissing()) { Get.snackbar("Validation", "Select session first"); return; }
    if (isCheckedIn)  { Get.snackbar("Info", "Already checked in");  return; }
    if (isCheckedOut) { Get.snackbar("Info", "Already checked out"); return; }
    try {
      isChecking(true);
      final pos = await _getPosition();
      if (pos == null) return;
      final now = DateTime.now();
      await _saveCheckOutTime(null);
      await _saveCheckInTime(now);
      checkInLat.value = pos.latitude;
      checkInLng.value = pos.longitude;
      final addr = await _reverseGeocode(pos.latitude, pos.longitude);
      checkInAddress.value = addr;
      await _saveCheckInFlag(true);
      Get.snackbar("Success", "Checked in at ${fmtTime(now)}\n$addr",
          duration: const Duration(seconds: 6));
    } catch (e) {
      Get.snackbar("Error", "Check-in failed: $e");
    } finally {
      isChecking(false);
    }
  }

  Future<void> doCheckOut() async {
    if (_sessionMissing()) { Get.snackbar("Validation", "Select session first"); return; }
    if (checkOutTime.value != null) { Get.snackbar("Info", "Already checked out"); return; }
    try {
      isChecking(true);
      final pos = await _getPosition();
      if (pos == null) return;
      final now = DateTime.now();
      await _saveCheckOutTime(now);
      checkOutLat.value = pos.latitude;
      checkOutLng.value = pos.longitude;
      final addr = await _reverseGeocode(pos.latitude, pos.longitude);
      checkOutAddress.value = addr;
      await _saveCheckInFlag(false);
      Get.snackbar("Success", "Checked out at ${fmtTime(now)}\n$addr",
          duration: const Duration(seconds: 6));
    } catch (e) {
      Get.snackbar("Error", "Check-out failed: $e");
    } finally {
      isChecking(false);
    }
  }

  // =========================================================
  // ORANGE BUTTON — no check-in required (same as TeacherAttendanceController)
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
          "date":     _formatDateApi(selectedDate.value),
          "session":  selectedSession.value!.session,
          "schoolId": schoolId,
        }),
      );

      if (res.statusCode != 200) {
        _showError("View API failed: ${res.statusCode}\n${res.body}");
        return;
      }

      final parsed = TeacherListResponse.fromJson(jsonDecode(res.body));
      teacherUsers.assignAll(parsed.listData);

      _statusMap.clear();
      _inOutMap.clear();
      _inTimeMap.clear();
      _outTimeMap.clear();

      for (final t in teacherUsers) {
        final id = t.userId;
        if (id == null) continue;
        _statusMap[id] = _normalizeStatus(t.status);
        _inOutMap[id]  = "IN";
      }

      _bump();

      if (teacherUsers.isEmpty) {
        _showInfo("No staff found for selected date/session");
      } else {
        _showSuccess("${teacherUsers.length} staff loaded successfully");
      }
    } catch (e) {
      _showError("View API error: $e");
    } finally {
      isViewLoading(false);
    }
  }

  // =========================================================
  // SAVE — GREEN BUTTON
  // ✅ Status correctly saved: PRESENT / ABSENT / HOLD
  // ✅ Exact per-staff inTime / outTime from maps
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

      int    ok   = 0;
      int    fail = 0;
      String? firstFailReason;

      for (final t in teacherUsers) {
        final int?   userId   = t.userId;
        final String staffReg = (t.additionalDetail?.registrationNo ?? "").trim();

        if (userId == null || staffReg.isEmpty) {
          fail++;
          firstFailReason ??= "save attendance successfully";
          continue;
        }

        // ✅ Read exact user-selected times (null = not selected)
        final DateTime? inTime  = _inTimeMap[userId];
        final DateTime? outTime = _outTimeMap[userId];

        // ✅ Read status from map — correctly PRESENT / ABSENT / HOLD
        final String status = _statusMap[userId] ?? _normalizeStatus(t.status);

        final body = {
          "sadid":          0,
          "staffReg":       staffReg,
          "status":         status,
          "months":         selectedDate.value.month,
          "session":        selectedSession.value!.session,
          "day":            selectedDate.value.day.toString(),
          "adate":          _formatDateApi(selectedDate.value),
          "userAttendance": "admin",
          "schoolId":       schoolId,
          "inTime":         inTime  != null ? _formatDateTimeApi(inTime)  : null,
          "outTime":        outTime != null ? _formatDateTimeApi(outTime) : null,
          "inOut":          _inOutMap[userId] ?? "IN",
          "inAddress":      checkInAddress.value,
          "outAddress":     checkOutAddress.value,
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

          final Map<String, dynamic> jsonRes = jsonDecode(res.body);
          final bool isSuccess =
              (jsonRes["isSuccess"] == true) || (jsonRes["statusCode"] == 200);

          if (isSuccess) {
            ok++;
          } else {
            fail++;
            firstFailReason ??= jsonRes["messages"]?.toString() ?? "Unknown error";
          }
        } catch (e) {
          fail++;
          firstFailReason ??= "Request error: $e";
        }
      }

      if (fail == 0) {
        _showSuccess("Attendance saved successfully for $ok staff");
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
        _showError(firstFailReason ?? "Please try again.");
      }
    } catch (e) {
      _showError("Unexpected error: $e");
    } finally {
      isViewSaving(false);
    }
  }

  // =========================================================
  // SNACKBARS
  // =========================================================
  void _showSuccess(String msg) {
    Get.snackbar(
      "Success", msg,
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
      "", msg,
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
      "Info", msg,
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