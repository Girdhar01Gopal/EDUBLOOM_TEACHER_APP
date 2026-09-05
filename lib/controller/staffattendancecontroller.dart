import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart' as session_model;
import '../models/staff attend load model.dart';

class Staffattendancecontroller extends GetxController {
  static const String statusPresent = "PRESENT";
  static const String statusAbsent = "ABSENT";
  static const String statusHold = "HOLIDAY";

  // ========= UI FLAGS =========
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isViewLoading = false.obs;
  final isViewSaving = false.obs;

  // ========= CHECK-IN / CHECK-OUT FLAGS =========
  final isCheckedIn = false.obs;
  final isCheckedOutToday = false.obs;
  final isCheckInOutSaving = false.obs;

  // ========= GLOBAL IN/OUT TIME (header card) =========
  final todayInTime = Rx<DateTime?>(null);
  final todayOutTime = Rx<DateTime?>(null);

  // ========= MIDNIGHT ROLLOVER TIMER =========
  Timer? _midnightTimer;

  // ========= STORAGE =========
  String schoolId = "";
  String token = "";
  String userId = "";
  String roleName = "";

  // ========= SESSION =========
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ========= DATE (locked to today) =========
  final selectedDate = Rx<DateTime>(DateTime.now());
  String get displayDate => _formatDateUI(selectedDate.value);
  String get displayDateLong => _formatDateLong(selectedDate.value);

  // ========= STAFF LIST =========
  final teacherUsers = <StaffUser>[].obs; // naam wahi rakha taaki view me change min ho

  // ========= PER-STAFF DATA (Persistent Maps) =========
  final Map<int, String> _statusMap = {};
  final Map<int, String> _inOutMap = {};
  final Map<int, DateTime> _inTimeMap = {};
  final Map<int, DateTime> _outTimeMap = {};
  final Map<int, String> _inAddressMap = {};
  final Map<int, String> _outAddressMap = {};

  final mapVersion = 0.obs;
  void _bump() => mapVersion.value++;

  // ========= APIs =========
  final String viewApi =
      "https://playschool.edubloom.in/api/StaffApp/ViewStaffAttendanceApp";
  final String saveApi =
      "https://playschool.edubloom.in/api/StaffApp/SaveStaffAttendenceApp";
  final String sessionApiBase =
      "https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/";

  static const int _autoAbsentLookbackDays = 14;

  @override
  void onInit() async {
    super.onInit();
    schoolId =
        (await PrefManager().readValue(key: PrefConst.schollId) ?? "").toString();
    token = (await PrefManager().readValue(key: PrefConst.token) ?? "").toString();
    userId = (await PrefManager().readValue(key: PrefConst.Userid) ?? "").toString();
    roleName = (await PrefManager().readValue(key: PrefConst.RName) ?? "").toString();

    if (schoolId.trim().isEmpty) {
      _showError("SchoolId not found. Please login again.");
      return;
    }

    selectedDate.value = DateTime.now();

    await _loadCheckFlags();
    await fetchSessions();

    if (!_sessionMissing()) {
      await fetchStaffAttendanceList();
    } else {
      unawaited(_retrySessionLoadThenFetchList());
    }

    unawaited(_autoMarkAbsentForMissedDays());
    _scheduleMidnightRollover();
  }

  @override
  void onClose() {
    _midnightTimer?.cancel();
    super.onClose();
  }

  // =========================================================
  // MIDNIGHT ROLLOVER
  // =========================================================
  void _scheduleMidnightRollover() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);
    debugPrint("[ATT-DEBUG] Scheduling midnight rollover in $duration");
    _midnightTimer = Timer(duration, () async {
      await _handleMidnightRollover();
      _scheduleMidnightRollover();
    });
  }

  Future<void> _handleMidnightRollover() async {
    debugPrint("[ATT-DEBUG] Midnight rollover triggered — resetting check-in/out cycle for new day");

    final justEndedDay = DateTime.now().subtract(const Duration(minutes: 1));
    if (justEndedDay.weekday != DateTime.sunday) {
      final dateKey =
          "${justEndedDay.year.toString().padLeft(4, '0')}-${justEndedDay.month.toString().padLeft(2, '0')}-${justEndedDay.day.toString().padLeft(2, '0')}";
      final checkInKey = "staff_att_checkin_${userId}_$dateKey";
      final autoAbsentDoneKey = "staff_att_autoabsent_done_${userId}_$dateKey";

      final alreadyHandled =
          (await PrefManager().readValue(key: autoAbsentDoneKey))?.toString() == "1";
      if (!alreadyHandled) {
        final wasCheckedIn =
            (await PrefManager().readValue(key: checkInKey))?.toString() == "1";
        if (!wasCheckedIn) {
          debugPrint("[ATT-DEBUG] MIDNIGHT-AUTO-ABSENT: marking $dateKey as absent");
          await _markDayAbsentOnServer(justEndedDay);
        }
        await PrefManager().writeValue(key: autoAbsentDoneKey, value: "1");
      }
    }

    await _loadCheckFlags();
  }

  // =========================================================
  // FORMATTERS
  // =========================================================
  String _formatDateApi(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _formatDateTimeApi(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}:${d.second.toString().padLeft(2, '0')}";
  }

  String _formatDateUI(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  static const List<String> _monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December",
  ];

  String _formatDateLong(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')} ${_monthNames[d.month - 1]} ${d.year}";
  }

  String fmtTime(DateTime dt) {
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _normalizeStatus(String? status) {
    if (status == null) return statusPresent;
    final s = status.trim().toUpperCase();
    if (s.isEmpty) return statusPresent;
    if (s == statusAbsent || s == "A" || s.contains("ABS")) return statusAbsent;
    if (s == statusHold || s == "HOLIDAY" || s == "H" || s.contains("HOL")) return statusHold;
    return statusPresent;
  }

  /// Centralized success detector for the Save API.
  /// The backend is inconsistent: it sometimes sends isSuccess:false /
  /// statusCode:0 even when the save actually worked, but always sends
  /// data:"SUCCESS" and/or a "success" wording inside messages when it did.
  /// This checks all signals so we never show a red "failed" snackbar for
  /// a save that actually succeeded.
  bool _isSaveSuccessful(Map<String, dynamic> respBody) {
    final bool isSuccessFlag = respBody['isSuccess'] == true;
    final bool statusOk = respBody['statusCode'] == 200;
    final String dataStr = (respBody['data'] ?? "").toString().trim().toUpperCase();
    final String msgStr = (respBody['messages'] ?? "").toString().trim().toLowerCase();

    final bool dataSaysSuccess = dataStr == "SUCCESS";
    final bool msgSaysSuccess = msgStr.contains("success") && !msgStr.contains("fail");

    return isSuccessFlag || statusOk || dataSaysSuccess || msgSaysSuccess;
  }

  // =========================================================
  // LOCATION
  // =========================================================
  Future<String> _getCurrentAddress() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError("Please turn on location services to record your address");
        return "";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError("Location permission denied");
          return "";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError("Location permission permanently denied. Enable it from app settings.");
        return "";
      }

      // Medium accuracy + timeout => much faster fix than "high" with no limit.
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 6),
        );
      } on TimeoutException {
        // Fall back to last known position if a fresh fix takes too long.
        final last = await Geolocator.getLastKnownPosition();
        if (last == null) {
          _showError("Could not get your location quickly. Please try again.");
          return "";
        }
        position = last;
      }

      try {
        final placemarks = await geocoding.placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            p.name,
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
            p.country,
          ]
              .where((e) => e != null && e.trim().isNotEmpty)
              .map((e) => e!.trim())
              .toSet()
              .toList();
          final addr = parts.join(", ");
          if (addr.trim().isNotEmpty) return addr;
        }
      } catch (_) {}

      return "${position.latitude}, ${position.longitude}";
    } catch (e) {
      _showError("Could not fetch location: $e");
      return "";
    }
  }

  // =========================================================
  // CHECK-IN / CHECK-OUT
  // =========================================================
  String _todayDateKeyPart() {
    final d = DateTime.now();
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String get checkInPrefKey => "staff_att_checkin${userId}_${_todayDateKeyPart()}";
  String get checkOutPrefKey => "staff_att_checkout${userId}_${_todayDateKeyPart()}";
  String get globalInTimeKey => "staff_att_global_intime${userId}_${_todayDateKeyPart()}";
  String get globalOutTimeKey => "staff_att_global_outtime${userId}_${_todayDateKeyPart()}";

  String _inTimeKey(int staffId) =>
      "staff_att_intime_${staffId}_${_todayDateKeyPart()}";
  String _inAddrKey(int staffId) =>
      "staff_att_inaddr_${staffId}_${_todayDateKeyPart()}";
  String _outTimeKey(int staffId) =>
      "staff_att_outtime_${staffId}_${_todayDateKeyPart()}";
  String _outAddrKey(int staffId) =>
      "staff_att_outaddr_${staffId}_${_todayDateKeyPart()}";

  Future<void> _persistInData(int staffId, DateTime time, String address) async {
    await PrefManager().writeValue(key: _inTimeKey(staffId), value: _formatDateTimeApi(time));
    await PrefManager().writeValue(key: _inAddrKey(staffId), value: address);
    debugPrint("[ATT-DEBUG] persisted IN for staff=$staffId time=${_formatDateTimeApi(time)} addr=$address");
  }

  Future<void> _persistOutData(int staffId, DateTime time, String address) async {
    await PrefManager().writeValue(key: _outTimeKey(staffId), value: _formatDateTimeApi(time));
    await PrefManager().writeValue(key: _outAddrKey(staffId), value: address);
    debugPrint("[ATT-DEBUG] persisted OUT for staff=$staffId time=${_formatDateTimeApi(time)} addr=$address");
  }

  Future<DateTime?> _readPersistedTime(String key) async {
    final v = await PrefManager().readValue(key: key);
    if (v == null || v.toString().trim().isEmpty) return null;
    return DateTime.tryParse(v.toString());
  }

  Future<String?> _readPersistedAddr(String key) async {
    final v = await PrefManager().readValue(key: key);
    if (v == null || v.toString().trim().isEmpty) return null;
    return v.toString();
  }

  Future<void> _loadCheckFlags() async {
    try {
      final inVal = await PrefManager().readValue(key: checkInPrefKey);
      final outVal = await PrefManager().readValue(key: checkOutPrefKey);
      isCheckedIn.value = (inVal?.toString() ?? "0") == "1";
      isCheckedOutToday.value = (outVal?.toString() ?? "0") == "1";

      todayInTime.value = await _readPersistedTime(globalInTimeKey);
      todayOutTime.value = await _readPersistedTime(globalOutTimeKey);
    } catch (_) {
      isCheckedIn.value = false;
      isCheckedOutToday.value = false;
    }
  }

  Future<void> _persistFlag(String key, bool value) async {
    await PrefManager().writeValue(key: key, value: value ? "1" : "0");
  }

  static const int _minGapBeforeCheckOutMinutes = 30;

  bool _handlingCheckInOut = false;

  /// FAST PATH: only saves the logged-in user's own attendance record
  /// (no full staff-list save loop, no redundant re-fetch of the whole list).
  Future<void> handleCheckInOut() async {
    if (_handlingCheckInOut) return;
    _handlingCheckInOut = true;
    try {
      if (_sessionMissing()) {
        final loaded = await _ensureSessionLoaded();
        if (!loaded) {
          _showError("Could not load session. Please check your internet and try again.");
          return;
        }
      }
      if (isCheckedOutToday.value) return;

      if (teacherUsers.isEmpty) {
        _showError("Load the attendance list first");
        return;
      }

      if (isCheckedIn.value && todayInTime.value != null) {
        final elapsed = DateTime.now().difference(todayInTime.value!);
        if (elapsed < const Duration(minutes: _minGapBeforeCheckOutMinutes)) {
          final remaining = const Duration(minutes: _minGapBeforeCheckOutMinutes) - elapsed;
          final remainingMinutes = remaining.inSeconds <= 0
              ? 1
              : (remaining.inSeconds / 60).ceil();
          _showError(
            "You can check out after $remainingMinutes more minute${remainingMinutes == 1 ? '' : 's'} "
                "(minimum $_minGapBeforeCheckOutMinutes minutes after check-in).",
          );
          return;
        }
      }

      final currentStaff = teacherUsers.firstWhereOrNull(
            (t) => t.userId == int.tryParse(userId),
      );

      if (currentStaff == null) {
        _showError("Your attendance record not found in today's list.");
        return;
      }

      final id = currentStaff.userId!;

      try {
        isCheckInOutSaving(true);
        final now = DateTime.now();
        final address = await _getCurrentAddress();

        if (!isCheckedIn.value) {
          if (statusForUser(id, currentStaff.status) == statusPresent) {
            _inTimeMap[id] = now;
            _inOutMap[id] = "IN";
            _inAddressMap[id] = address;
            await _persistInData(id, now, address);
            _bump();
          }

          todayInTime.value = now;
          await PrefManager().writeValue(key: globalInTimeKey, value: _formatDateTimeApi(now));

          await _saveSingleStaffAttendance(currentStaff);

          isCheckedIn.value = true;
          await _persistFlag(checkInPrefKey, true);
        } else {
          if (statusForUser(id, currentStaff.status) == statusPresent) {
            _outTimeMap[id] = now;
            _inOutMap[id] = "OUT";
            _outAddressMap[id] = address;
            await _persistOutData(id, now, address);
            _bump();
          }

          todayOutTime.value = now;
          await PrefManager().writeValue(key: globalOutTimeKey, value: _formatDateTimeApi(now));

          await _saveSingleStaffAttendance(currentStaff);

          isCheckedIn.value = false;
          isCheckedOutToday.value = true;
          await _persistFlag(checkInPrefKey, false);
          await _persistFlag(checkOutPrefKey, true);
        }
      } finally {
        isCheckInOutSaving(false);
      }
    } finally {
      _handlingCheckInOut = false;
    }
  }

  Map<String, String> _headers() {
    final h = <String, String>{"Content-Type": "application/json"};
    if (token.trim().isNotEmpty) h["Authorization"] = "Bearer $token";
    return h;
  }

  bool _sessionMissing() =>
      selectedSession.value == null || (selectedSession.value!.session ?? "").trim().isEmpty;

  // =========================================================
  // SESSIONS
  // =========================================================
  Future<void> fetchSessions() async {
    try {
      isPageLoading(true);
      final response = await http.get(Uri.parse("$sessionApiBase$schoolId"),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode != 200) return;
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
    } catch (e) {
      _showError("Failed to load sessions: $e");
    } finally {
      isPageLoading(false);
    }
  }

  void setSession(session_model.sListDdata? s) => selectedSession.value = s;

  Future<void> _retrySessionLoadThenFetchList() async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_sessionMissing()) break;
      debugPrint("[ATT-DEBUG] Session missing, retry #$attempt");
      await fetchSessions();
    }
    if (!_sessionMissing()) {
      await fetchStaffAttendanceList();
    } else {
      debugPrint("[ATT-DEBUG] Session still missing after retries");
    }
  }

  Future<bool> _ensureSessionLoaded() async {
    if (!_sessionMissing()) return true;
    await fetchSessions();
    return !_sessionMissing();
  }

  // =========================================================
  // CURRENT STAFF DISPLAY HELPERS
  // =========================================================
  StaffUser? get _currentStaff {
    if (teacherUsers.isEmpty) return null;
    final uid = int.tryParse(userId);
    if (uid != null) {
      for (final t in teacherUsers) {
        if (t.userId == uid) return t;
      }
    }
    return teacherUsers.first;
  }

  String get currentStaffName {
    final t = _currentStaff;
    if (t == null) return "-";
    final n = "${t.firstName ?? ""} ${t.lastName ?? ""}".trim();
    return n.isEmpty ? "-" : n;
  }

  String get currentStaffId {
    final t = _currentStaff;
    if (t == null) return "-";
    final reg = (t.registrationNo?.trim().isNotEmpty == true)
        ? t.registrationNo!.trim()
        : t.additionalDetail?.registrationNo?.trim();
    return (reg != null && reg.isNotEmpty) ? reg : "-";
  }

  // =========================================================
  // PER-STAFF STATUS
  // =========================================================
  String statusForUser(int userId, String? rawStatus) =>
      _statusMap[userId] ?? _normalizeStatus(rawStatus);

  void setStatusForUser(int userId, String status) {
    _statusMap[userId] = _normalizeStatus(status);
    _bump();
  }

  Future<void> loadAttendanceFromAddTab() async {
    final loaded = await _ensureSessionLoaded();
    if (!loaded) {
      _showError("Could not load session. Please check your internet and try again.");
      return;
    }
    try {
      isSaving(true);
      await fetchStaffAttendanceList();
    } finally {
      isSaving(false);
    }
  }

  Future<void> refreshListTab() async {
    final loaded = await _ensureSessionLoaded();
    if (!loaded) {
      _showError("Could not load session. Please check your internet and try again.");
      return;
    }
    await fetchStaffAttendanceList();
  }

  // =========================================================
  // VIEW & SAVE
  // =========================================================
  Future<void> fetchStaffAttendanceList() async {
    try {
      isViewLoading(true);
      final res = await http.post(
        Uri.parse(viewApi),
        headers: _headers(),
        body: jsonEncode({
          "date": _formatDateApi(selectedDate.value),
          "session": selectedSession.value!.session,
          "schoolId": schoolId,
          "roleName": roleName,
          "userId": int.tryParse(userId) ?? 0,
        }),
      );

      if (res.statusCode != 200) return;

      final parsed = StaffListResponse.fromJson(jsonDecode(res.body));
      teacherUsers.assignAll(parsed.listData);

      final Map<int, String> oldStatusMap = Map.of(_statusMap);
      final Map<int, String> oldInOutMap = Map.of(_inOutMap);
      final Map<int, DateTime> oldInTimeMap = Map.of(_inTimeMap);
      final Map<int, DateTime> oldOutTimeMap = Map.of(_outTimeMap);
      final Map<int, String> oldInAddressMap = Map.of(_inAddressMap);
      final Map<int, String> oldOutAddressMap = Map.of(_outAddressMap);

      _statusMap.clear();
      _inOutMap.clear();
      _inTimeMap.clear();
      _outTimeMap.clear();
      _inAddressMap.clear();
      _outAddressMap.clear();

      DateTime? parseTime(String? val) {
        if (val == null || val.trim().isEmpty) return null;
        final d = DateTime.tryParse(val);
        if (d != null) return d;
        try {
          return DateTime.tryParse("${_formatDateApi(selectedDate.value)} $val");
        } catch (_) {}
        return null;
      }

      for (final t in teacherUsers) {
        final id = t.userId;
        if (id == null) continue;

        final rawStatus = t.status ?? t.staffAttendance?.attendanceStatus;

        final rawIn = t.inTime ??
            t.staffAttendance?.inTime ??
            t.staffAttendance?.extra?['inTime']?.toString();

        final rawOut = t.outTime ??
            t.staffAttendance?.outTime ??
            t.staffAttendance?.extra?['outTime']?.toString();

        final rawInAddress =
        t.staffAttendance?.extra?['inAddress']?.toString();
        final rawOutAddress =
        t.staffAttendance?.extra?['outAddress']?.toString();

        debugPrint("[ATT-DEBUG] FETCH staff=$id rawStatus=$rawStatus rawIn=$rawIn rawOut=$rawOut "
            "rawInAddr=$rawInAddress rawOutAddr=$rawOutAddress");

        _statusMap[id] = _normalizeStatus(
          rawStatus.isNotEmptyOrNull ? rawStatus : oldStatusMap[id],
        );

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

        final String? persistedInAddr = (rawInAddress == null || rawInAddress.trim().isEmpty) &&
            (oldInAddressMap[id] == null || oldInAddressMap[id]!.trim().isEmpty)
            ? await _readPersistedAddr(_inAddrKey(id))
            : null;
        final String? persistedOutAddr = (rawOutAddress == null || rawOutAddress.trim().isEmpty) &&
            (oldOutAddressMap[id] == null || oldOutAddressMap[id]!.trim().isEmpty)
            ? await _readPersistedAddr(_outAddrKey(id))
            : null;

        final String? finalInAddress =
        (rawInAddress != null && rawInAddress.trim().isNotEmpty)
            ? rawInAddress
            : (oldInAddressMap[id] ?? persistedInAddr);
        final String? finalOutAddress =
        (rawOutAddress != null && rawOutAddress.trim().isNotEmpty)
            ? rawOutAddress
            : (oldOutAddressMap[id] ?? persistedOutAddr);
        if (finalInAddress != null && finalInAddress.trim().isNotEmpty) {
          _inAddressMap[id] = finalInAddress;
        }
        if (finalOutAddress != null && finalOutAddress.trim().isNotEmpty) {
          _outAddressMap[id] = finalOutAddress;
        }

        _inOutMap[id] = (rawOut != null && rawOut.isNotEmpty)
            ? "OUT"
            : (oldInOutMap[id] ?? "IN");

        debugPrint("[ATT-DEBUG] FETCH-RESULT staff=$id finalIn=${_inTimeMap[id]} finalOut=${_outTimeMap[id]} "
            "finalInAddr=${_inAddressMap[id]} finalOutAddr=${_outAddressMap[id]}");
      }
      _bump();

      await _reconcileCheckFlagsFromServer();
    } catch (e) {
      _showError("Error loading: $e");
    } finally {
      isViewLoading(false);
    }
  }

  // =========================================================
  // RECONCILE CHECK-IN/OUT FLAGS WITH SERVER
  // =========================================================
  Future<void> _reconcileCheckFlagsFromServer() async {
    final uid = int.tryParse(userId);
    if (uid == null) return;

    final serverIn = _inTimeMap[uid];
    final serverOut = _outTimeMap[uid];

    if (serverOut != null) {
      if (!isCheckedOutToday.value) {
        isCheckedOutToday.value = true;
        await _persistFlag(checkOutPrefKey, true);
      }
      if (isCheckedIn.value) {
        isCheckedIn.value = false;
        await _persistFlag(checkInPrefKey, false);
      }
      todayOutTime.value = serverOut;
      await PrefManager().writeValue(key: globalOutTimeKey, value: _formatDateTimeApi(serverOut));
      if (serverIn != null) {
        todayInTime.value = serverIn;
        await PrefManager().writeValue(key: globalInTimeKey, value: _formatDateTimeApi(serverIn));
      }
    } else if (serverIn != null) {
      if (!isCheckedIn.value) {
        isCheckedIn.value = true;
        await _persistFlag(checkInPrefKey, true);
      }
      todayInTime.value = serverIn;
      await PrefManager().writeValue(key: globalInTimeKey, value: _formatDateTimeApi(serverIn));
    }
  }

  /// FAST PATH save: saves attendance for ONE staff member only.
  /// Used by handleCheckInOut() so check-in/out doesn't wait on the
  /// entire staff list being posted one-by-one.
  Future<void> _saveSingleStaffAttendance(StaffUser t) async {
    final int? uId = t.userId;
    final String reg =
    (t.registrationNo ?? t.additionalDetail?.registrationNo ?? "").trim();
    if (uId == null || reg.isEmpty) {
      _showError("Missing registration number for your record.");
      return;
    }

    DateTime? fallbackTime(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      final d = DateTime.tryParse(raw);
      if (d != null) return d;
      try {
        return DateTime.tryParse("${_formatDateApi(selectedDate.value)} $raw");
      } catch (_) {}
      return null;
    }

    final DateTime? inT = _inTimeMap[uId] ??
        await _readPersistedTime(_inTimeKey(uId)) ??
        fallbackTime(
          t.inTime ??
              t.staffAttendance?.inTime ??
              t.staffAttendance?.extra?['inTime']?.toString(),
        );

    final DateTime? outT = _outTimeMap[uId] ??
        await _readPersistedTime(_outTimeKey(uId)) ??
        fallbackTime(
          t.outTime ??
              t.staffAttendance?.outTime ??
              t.staffAttendance?.extra?['outTime']?.toString(),
        );

    final String inAddr = _inAddressMap[uId] ??
        (await _readPersistedAddr(_inAddrKey(uId))) ??
        t.staffAttendance?.extra?['inAddress']?.toString() ??
        "";
    final String outAddr = _outAddressMap[uId] ??
        (await _readPersistedAddr(_outAddrKey(uId))) ??
        t.staffAttendance?.extra?['outAddress']?.toString() ??
        "";

    final body = {
      "sadid": t.staffAttendance?.attendanceId ?? 0,
      "staffReg": reg,
      "status": _statusMap[uId] ?? _normalizeStatus(t.status),
      "months": selectedDate.value.month,
      "session": selectedSession.value!.session,
      "day": selectedDate.value.day.toString(),
      "adate": _formatDateApi(selectedDate.value),
      "userAttendance": "admin",
      "schoolId": schoolId,
      "inTime": inT != null ? _formatDateTimeApi(inT) : (t.inTime ?? t.staffAttendance?.inTime ?? ""),
      "outTime": outT != null ? _formatDateTimeApi(outT) : "",
      "inOut": _inOutMap[uId] ?? "IN",
      "inAddress": inAddr,
      "outAddress": outAddr,
    };

    debugPrint("[ATT-DEBUG] SINGLE-SAVE-BODY staff=$uId body=$body");

    try {
      isViewSaving(true);
      final res = await http.post(Uri.parse(saveApi), headers: _headers(), body: jsonEncode(body));
      if (res.statusCode == 200) {
        final respBody = jsonDecode(res.body) as Map<String, dynamic>;
        debugPrint("[ATT-DEBUG] SINGLE-SAVE-RESPONSE staff=$uId response=$respBody");
        if (_isSaveSuccessful(respBody)) {
          _showSuccess("Attendance updated");
        } else {
          _showError("Save failed: ${respBody['messages'] ?? 'Unknown error'}");
        }
      } else {
        debugPrint("[ATT-DEBUG] SINGLE-SAVE-FAILED staff=$uId statusCode=${res.statusCode} body=${res.body}");
        _showError("Save failed (${res.statusCode})");
      }
    } catch (e) {
      _showError("Save error: $e");
    } finally {
      isViewSaving(false);
    }
  }

  /// Full-list save — kept for other flows (e.g. admin bulk-editing the
  /// whole staff list from the Add/Edit tab). NOT used by handleCheckInOut()
  /// anymore since that only needs to save the current user's record.
  Future<void> saveAttendanceFromView() async {
    if (_sessionMissing() || teacherUsers.isEmpty) return;

    DateTime? _fallbackTime(String? raw) {
      if (raw == null || raw.trim().isEmpty) return null;
      final d = DateTime.tryParse(raw);
      if (d != null) return d;
      try {
        return DateTime.tryParse("${_formatDateApi(selectedDate.value)} $raw");
      } catch (_) {}
      return null;
    }

    try {
      isViewSaving(true);
      int ok = 0;
      for (final t in teacherUsers) {
        final int? uId = t.userId;
        final String reg =
        (t.registrationNo ?? t.additionalDetail?.registrationNo ?? "").trim();
        if (uId == null || reg.isEmpty) continue;

        final DateTime? inT = _inTimeMap[uId] ??
            await _readPersistedTime(_inTimeKey(uId)) ??
            _fallbackTime(
              t.inTime ??
                  t.staffAttendance?.inTime ??
                  t.staffAttendance?.extra?['inTime']?.toString(),
            );

        final DateTime? outT = _outTimeMap[uId] ??
            await _readPersistedTime(_outTimeKey(uId)) ??
            _fallbackTime(
              t.outTime ??
                  t.staffAttendance?.outTime ??
                  t.staffAttendance?.extra?['outTime']?.toString(),
            );

        final String inAddr = _inAddressMap[uId] ??
            (await _readPersistedAddr(_inAddrKey(uId))) ??
            t.staffAttendance?.extra?['inAddress']?.toString() ??
            "";
        final String outAddr = _outAddressMap[uId] ??
            (await _readPersistedAddr(_outAddrKey(uId))) ??
            t.staffAttendance?.extra?['outAddress']?.toString() ??
            "";

        debugPrint("[ATT-DEBUG] SAVE staff=$uId inT=$inT outT=$outT inAddr=$inAddr outAddr=$outAddr");

        final body = {
          "sadid": t.staffAttendance?.attendanceId ?? 0,
          "staffReg": reg,
          "status": _statusMap[uId] ?? _normalizeStatus(t.status),
          "months": selectedDate.value.month,
          "session": selectedSession.value!.session,
          "day": selectedDate.value.day.toString(),
          "adate": _formatDateApi(selectedDate.value),
          "userAttendance": "admin",
          "schoolId": schoolId,
          "inTime": inT != null ? _formatDateTimeApi(inT) : (t.inTime ?? t.staffAttendance?.inTime ?? ""),
          "outTime": outT != null ? _formatDateTimeApi(outT) : "",
          "inOut": _inOutMap[uId] ?? "IN",
          "inAddress": inAddr,
          "outAddress": outAddr,
        };

        debugPrint("[ATT-DEBUG] SAVE-BODY staff=$uId body=$body");

        final res = await http.post(Uri.parse(saveApi), headers: _headers(), body: jsonEncode(body));
        if (res.statusCode == 200) {
          final respBody = jsonDecode(res.body) as Map<String, dynamic>;
          debugPrint("[ATT-DEBUG] SAVE-RESPONSE staff=$uId response=$respBody");
          if (_isSaveSuccessful(respBody)) {
            ok++;
          }
        } else {
          debugPrint("[ATT-DEBUG] SAVE-FAILED staff=$uId statusCode=${res.statusCode} body=${res.body}");
        }
      }
      _showSuccess("Attendance updated for staff");
      await fetchStaffAttendanceList();
    } catch (e) {
      _showError("Save error: $e");
    } finally {
      isViewSaving(false);
    }
  }

  // =========================================================
  // AUTO-ABSENT FOR MISSED DAYS
  // =========================================================
  Future<void> _autoMarkAbsentForMissedDays() async {
    if (_sessionMissing()) return;

    final today = DateTime.now();
    for (int i = 1; i <= _autoAbsentLookbackDays; i++) {
      final day = today.subtract(Duration(days: i));

      if (day.weekday == DateTime.sunday) continue;

      final dateKey =
          "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
      final checkInKey = "staff_att_checkin_${userId}_$dateKey";
      final autoAbsentDoneKey = "staff_att_autoabsent_done_${userId}_$dateKey";

      final alreadyHandled =
          (await PrefManager().readValue(key: autoAbsentDoneKey))?.toString() == "1";
      if (alreadyHandled) continue;

      final wasCheckedIn =
          (await PrefManager().readValue(key: checkInKey))?.toString() == "1";
      if (wasCheckedIn) {
        await PrefManager().writeValue(key: autoAbsentDoneKey, value: "1");
        continue;
      }

      debugPrint("[ATT-DEBUG] AUTO-ABSENT: marking $dateKey as absent");
      await _markDayAbsentOnServer(day);
      await PrefManager().writeValue(key: autoAbsentDoneKey, value: "1");
    }
  }

  Future<void> _markDayAbsentOnServer(DateTime day) async {
    try {
      final res = await http.post(
        Uri.parse(viewApi),
        headers: _headers(),
        body: jsonEncode({
          "date": _formatDateApi(day),
          "session": selectedSession.value!.session,
          "schoolId": schoolId,
          "roleName": roleName,
          "userId": int.tryParse(userId) ?? 0,
        }),
      );
      if (res.statusCode != 200) return;

      final parsed = StaffListResponse.fromJson(jsonDecode(res.body));
      for (final t in parsed.listData) {
        final reg = (t.registrationNo ?? t.additionalDetail?.registrationNo ?? "").trim();
        if (reg.isEmpty) continue;

        final existingStatus = t.status ?? t.staffAttendance?.attendanceStatus;
        if (existingStatus != null && existingStatus.trim().isNotEmpty) continue;

        final body = {
          "sadid": t.staffAttendance?.attendanceId ?? 0,
          "staffReg": reg,
          "status": statusAbsent,
          "months": day.month,
          "session": selectedSession.value!.session,
          "day": day.day.toString(),
          "adate": _formatDateApi(day),
          "userAttendance": "admin",
          "schoolId": schoolId,
          "inTime": "",
          "outTime": "",
          "inOut": "OUT",
          "inAddress": "",
          "outAddress": "",
        };

        final saveRes = await http.post(Uri.parse(saveApi), headers: _headers(), body: jsonEncode(body));
        debugPrint("[ATT-DEBUG] AUTO-ABSENT save staff=$reg date=${_formatDateApi(day)} statusCode=${saveRes.statusCode}");
      }
    } catch (e) {
      debugPrint("[ATT-DEBUG] AUTO-ABSENT error for ${_formatDateApi(day)}: $e");
    }
  }

  void _showSuccess(String msg) {
    Get.snackbar("Success", msg,
        backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  }

  void _showError(String msg) {
    Get.snackbar("Error", msg,
        backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  }

  void _showInfo(String msg) {
    Get.snackbar("Info", msg,
        backgroundColor: Colors.blue, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  }
}

extension _NullableStringCheck on String? {
  bool get isNotEmptyOrNull => this != null && this!.trim().isNotEmpty;
}