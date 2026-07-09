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
  static const String statusAbsent = "ABSENT";
  static const String statusHold = "HOLD";

  // ========= UI FLAGS =========
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isViewLoading = false.obs;
  final isViewSaving = false.obs;

  final requestTabIndex = RxnInt();

  // ========= CHECK-IN / CHECK-OUT =========
  final isChecking = false.obs;

  final checkInTime = Rxn<DateTime>();
  final checkOutTime = Rxn<DateTime>();

  final checkInLat = RxnDouble();
  final checkInAddress = "".obs;
  final checkOutAddress = "".obs;

  final checkInLng = RxnDouble();
  final checkOutLat = RxnDouble();
  final checkOutLng = RxnDouble();

  final isCheckInFlag = false.obs;

  bool get isCheckedIn => checkInTime.value != null && checkOutTime.value == null;
  bool get isCheckedOut => checkInTime.value != null && checkOutTime.value != null;

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

  // ========= STATUS MAP =========
  final statusByUserId = <int, String>{}.obs;

  // ========= PER-USER IN/OUT TIME =========
  final mapVersion = 0.obs;

  final _inOutByUser = <int, String>{};
  final _inTimeByUser = <int, DateTime>{};
  final _outTimeByUser = <int, DateTime>{};

  String inOutForUser(int userId) => _inOutByUser[userId] ?? "IN";

  void setInOutForUser(int userId, String v) {
    _inOutByUser[userId] = v;
    mapVersion.value++;
  }

  DateTime? inTimeForUser(int userId) => _inTimeByUser[userId];
  DateTime? outTimeForUser(int userId) => _outTimeByUser[userId];

  Future<void> pickInTimeForUser(int userId) async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(_inTimeByUser[userId] ?? DateTime.now()),
    );
    if (picked == null) return;
    final now = DateTime.now();
    _inTimeByUser[userId] = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    mapVersion.value++;
  }

  Future<void> pickOutTimeForUser(int userId) async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.fromDateTime(_outTimeByUser[userId] ?? DateTime.now()),
    );
    if (picked == null) return;
    final now = DateTime.now();
    _outTimeByUser[userId] = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
    mapVersion.value++;
  }

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

    schoolId = (await PrefManager().readValue(key: PrefConst.schollId) ?? "").toString();
    token = (await PrefManager().readValue(key: PrefConst.token) ?? "").toString();

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await _loadCheckInFlag();
    await fetchSessions();
  }

  Future<void> _loadCheckInFlag() async {
    final v = await PrefManager().readValue(key: PrefConst.checkin);
    if (v == null) {
      isCheckInFlag.value = false;
      return;
    }
    if (v is bool) {
      isCheckInFlag.value = v;
      return;
    }
    final s = v.toString().trim();
    isCheckInFlag.value = s == "1" || s.toLowerCase() == "true";
  }

  Future<void> _saveCheckInFlag(bool value) async {
    isCheckInFlag.value = value;
    await PrefManager().writeValue(key: PrefConst.checkin, value: value ? 1 : 0);
  }

  String _adateNoonLocal(DateTime d) {
    final localNoon = DateTime(d.year, d.month, d.day, 12, 0, 0);
    return localNoon.toIso8601String();
  }

  String _formatDateApi(DateTime d) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return "$yyyy-$mm-$dd";
  }

  String _formatDateTimeApi(DateTime d) {
    final date = _formatDateApi(d);
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    final ss = d.second.toString().padLeft(2, '0');
    return "$date $hh:$min:$ss";
  }

  String _formatDateUI(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return "$dd/$mm/$yy";
  }

  String _normalizeStatus(String? status) {
    if (status == null) return statusPresent;
    final s = status.trim().toUpperCase();
    if (s == statusAbsent) return statusAbsent;
    if (s == statusHold || s == "HOLIDAY") return statusHold;
    if (s == statusPresent) return statusPresent;
    if (s == "P" || s == "A" || s == "H") {
      return s == "A"
          ? statusAbsent
          : (s == "H" ? statusHold : statusPresent);
    }
    return statusPresent;
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> resetCheckInOut() async {
    checkInTime.value = null;
    checkOutTime.value = null;
    checkInLat.value = null;
    checkInLng.value = null;
    checkOutLat.value = null;
    checkOutLng.value = null;
    checkInAddress.value = "";
    checkOutAddress.value = "";
    await _saveCheckInFlag(false);
  }

  // =========================================================
  // HEADERS
  // =========================================================
  Map<String, String> _headers() {
    final h = <String, String>{
      "Content-Type": "application/json",
    };
    if (token.trim().isNotEmpty) {
      h["Authorization"] = "Bearer $token";
    }
    return h;
  }

  // =========================================================
  // SESSIONS
  // =========================================================
  Future<void> fetchSessions() async {
    final apiUrl = "$sessionApiBase$schoolId";

    try {
      isPageLoading(true);

      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode != 200) {
        Get.snackbar("Error", "Session API failed: ${response.statusCode}");
        return;
      }

      final jsonData = jsonDecode(response.body);
      sessionList.clear();

      if (jsonData is Map && jsonData['currentSession'] != null) {
        final cs = jsonData['currentSession'];

        final sessionObj = session_model.sListDdata(
          sessionId: cs['currentSessionId'],
          session: cs['currentSession'],
          action: cs['action'],
          schoolId: cs['schoolId'],
        );

        sessionList.add(sessionObj);
        selectedSession.value = sessionObj;
      }

      if (sessionList.isEmpty) {
        Get.snackbar("Info", "No session found");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load sessions: $e");
    } finally {
      isPageLoading(false);
    }
  }

  void setSession(session_model.sListDdata? s) {
    selectedSession.value = s;
  }

  bool _sessionMissing() {
    return selectedSession.value == null ||
        (selectedSession.value!.session ?? "").trim().isEmpty;
  }

  // =========================================================
  // CHECK-IN / CHECK-OUT
  // =========================================================
  Future<Position?> _getPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      Get.snackbar("Location", "Please enable Location services");
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Get.snackbar("Location", "Location permission denied");
      return null;
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 12),
    );
  }

  String fmtTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return "Address not found";

      final p = placemarks.first;

      final parts = <String>[
        if ((p.name ?? "").trim().isNotEmpty) p.name!.trim(),
        if ((p.street ?? "").trim().isNotEmpty) p.street!.trim(),
        if ((p.subLocality ?? "").trim().isNotEmpty) p.subLocality!.trim(),
        if ((p.locality ?? "").trim().isNotEmpty) p.locality!.trim(),
        if ((p.administrativeArea ?? "").trim().isNotEmpty) p.administrativeArea!.trim(),
        if ((p.postalCode ?? "").trim().isNotEmpty) p.postalCode!.trim(),
      ];

      return parts.isEmpty ? "Address not found" : parts.join(", ");
    } catch (_) {
      return "Address not available";
    }
  }

  Future<void> doCheckIn() async {
    if (_sessionMissing()) {
      Get.snackbar("Validation", "Select session first");
      return;
    }

    if (isCheckedIn) {
      Get.snackbar("Info", "Already checked in");
      return;
    }
    if (isCheckedOut) {
      Get.snackbar("Info", "Already checked out");
      return;
    }

    try {
      isChecking(true);

      final pos = await _getPosition();
      if (pos == null) return;

      final now = DateTime.now();
      final lat = pos.latitude;
      final lng = pos.longitude;

      checkInTime.value = now;
      checkInLat.value = lat;
      checkInLng.value = lng;

      final addr = await _reverseGeocode(lat, lng);
      checkInAddress.value = addr;

      await _saveCheckInFlag(true);

      Get.snackbar(
        "Success",
        "Checked in at ${fmtTime(now)}\n$addr",
        duration: const Duration(seconds: 6),
      );
    } catch (e) {
      Get.snackbar("Error", "Check-in failed: $e");
    } finally {
      isChecking(false);
    }
  }

  Future<void> doCheckOut() async {
    if (_sessionMissing()) {
      Get.snackbar("Validation", "Select session first");
      return;
    }
    if (checkOutTime.value != null) {
      Get.snackbar("Info", "Already checked out");
      return;
    }

    try {
      isChecking(true);

      final pos = await _getPosition();
      if (pos == null) return;

      final now = DateTime.now();
      final lat = pos.latitude;
      final lng = pos.longitude;

      checkOutTime.value = now;
      checkOutLat.value = lat;
      checkOutLng.value = lng;

      final addr = await _reverseGeocode(lat, lng);
      checkOutAddress.value = addr;

      await _saveCheckInFlag(false);

      Get.snackbar(
        "Success",
        "Checked out at ${fmtTime(now)}\n$addr",
        duration: const Duration(seconds: 6),
      );
    } catch (e) {
      Get.snackbar("Error", "Check-out failed: $e");
    } finally {
      isChecking(false);
    }
  }

  // =========================================================
  // ORANGE BUTTON
  // =========================================================
  Future<void> loadAttendanceFromAddTab() async {
    if (_sessionMissing()) {
      Get.snackbar("Error", "Please select session");
      return;
    }

    if (checkInTime.value == null) {
      Get.snackbar("Required", "Please check-in before managing attendance");
      return;
    }

    try {
      isSaving(true);
      await fetchTeacherAttendanceList();
      requestTabIndex.value = 1;
    } catch (e) {
      Get.snackbar("Error", "Error: $e");
    } finally {
      isSaving(false);
    }
  }

  Future<void> refreshListTab() async {
    if (_sessionMissing()) {
      Get.snackbar("Error", "Select session first");
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

      final body = {
        "date": _formatDateApi(selectedDate.value),
        "session": selectedSession.value!.session,
        "schoolId": schoolId,
      };

      final res = await http.post(
        Uri.parse(viewApi),
        headers: _headers(),
        body: jsonEncode(body),
      );

      if (res.statusCode != 200) {
        Get.snackbar("Error", "View API failed: ${res.statusCode}\n${res.body}");
        return;
      }

      final decoded = jsonDecode(res.body);
      final parsed = TeacherListResponse.fromJson(decoded);

      teacherUsers.assignAll(parsed.listData);

      statusByUserId.clear();
      for (final t in teacherUsers) {
        final id = t.userId;
        if (id == null) continue;
        statusByUserId[id] = _normalizeStatus(t.status);
      }

      if (teacherUsers.isEmpty) {
        Get.snackbar("Info", "No teachers found");
      } else {
        Get.snackbar("Success", "Loaded (${teacherUsers.length})");
      }
    } catch (e) {
      Get.snackbar("Error", "View API error: $e");
    } finally {
      isViewLoading(false);
    }
  }

  // =========================================================
  // STATUS HELPERS
  // =========================================================
  // NOTE: single-argument version — matches view's call: controller.statusForUser(t)
  String statusForUser(TeacherUser t) {
    final id = t.userId;
    if (id == null) return _normalizeStatus(t.status);
    return statusByUserId[id] ?? _normalizeStatus(t.status);
  }

  void setStatusForUser(int userId, String status) {
    statusByUserId[userId] = _normalizeStatus(status);
  }

  // =========================================================
  // SAVE (GREEN BUTTON)
  // =========================================================
  Future<void> saveAttendanceFromView() async {
    if (_sessionMissing()) {
      Get.snackbar("Error", "Session missing. Select session first.");
      return;
    }

    if (teacherUsers.isEmpty) {
      Get.snackbar("Error", "No data");
      return;
    }

    if (checkInTime.value == null) {
      Get.snackbar("Required", "Please check-in before saving attendance");
      return;
    }

    try {
      isViewSaving(true);

      final int months = selectedDate.value.month;
      final String dayStr = selectedDate.value.day.toString();
      final String adate = _formatDateApi(selectedDate.value);
      const String userAttendance = "admin";

      int ok = 0;
      int fail = 0;
      String? firstFailReason;

      for (final t in teacherUsers) {
        final int? userId = t.userId;
        final String teacherReg = (t.additionalDetail?.registrationNo ?? "").trim();

        if (userId == null || teacherReg.isEmpty) {
          fail++;
          firstFailReason ??= "Missing teacherReg/userId";
          continue;
        }

        final String status = statusByUserId[userId] ?? _normalizeStatus(t.status);

        final body = {
          "tadid": 0,
          "teacherReg": teacherReg,
          "status": status,
          "months": months,
          "session": selectedSession.value!.session,
          "day": dayStr,
          "adate": adate,
          "userAttendance": userAttendance,
          "schoolId": schoolId,
          "inTime": checkInTime.value == null ? null : _formatDateTimeApi(checkInTime.value!),
          "outTime": checkOutTime.value == null ? null : _formatDateTimeApi(checkOutTime.value!),
          "inAddress": checkInAddress.value,
          "outAddress": checkOutAddress.value,
        };

        final res = await http.post(
          Uri.parse(saveApi),
          headers: _headers(),
          body: jsonEncode(body),
        );

        if (res.statusCode != 200) {
          fail++;
          firstFailReason ??= "HTTP ${res.statusCode}: ${res.body}";
          continue;
        }

        final Map<String, dynamic> jsonRes = jsonDecode(res.body);
        final bool isSuccess =
            (jsonRes["isSuccess"] == true) || (jsonRes["statusCode"] == 200);

        if (isSuccess) {
          ok++;
        } else {
          fail++;
          firstFailReason ??= "Fail: ${jsonRes["messages"] ?? res.body}";
        }
      }

      if (fail == 0) {
        Get.snackbar("Success", "Attendance saved successfully ($ok)");
      } else {
        Get.snackbar(
          "Warning",
          "Saved: $ok | Failed: $fail\n${firstFailReason ?? ""}",
          duration: const Duration(seconds: 7),
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Save API error: $e");
    } finally {
      isViewSaving(false);
    }
  }
}