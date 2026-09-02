import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart' as session_model;
import '../models/teacher_attendance.dart';

class TeacherAttendanceController extends GetxController {
  static const String statusPresent = "PRESENT";
  static const String statusAbsent = "ABSENT";
  static const String statusHold = "HOLIDAY";

  // ========= UI FLAGS =========
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isViewLoading = false.obs;
  final isViewSaving = false.obs;

  // ========= CHECK-IN / CHECK-OUT FLAGS =========
  // flag: 0 = not checked in yet today, 1 = checked in (button shows "Check Out")
  final isCheckedIn = false.obs;
  // flag1: 1 = already checked out today -> button hidden until next day (midnight)
  final isCheckedOutToday = false.obs;
  // loading indicator while a check-in/check-out save (incl. location fetch) is in flight
  final isCheckInOutSaving = false.obs;

  // ========= GLOBAL IN/OUT TIME (shown in the header card) =========
  // Jab bhi "Check In"/"Check Out" dabaya jaata hai, poori list ke saare
  // present teachers ke liye same "now" time stamp hota hai — isliye ek hi
  // global time header card me dikhane ke liye kaafi hai.
  final todayInTime = Rx<DateTime?>(null);
  final todayOutTime = Rx<DateTime?>(null);

  // ========= MIDNIGHT ROLLOVER TIMER =========
  // App foreground/alive rehte hue har raat 12 baje automatically:
  // 1) agar aaj (jo din abhi khatam hua) check-in nahi hua tha (Sunday
  //    chhodkar), to us din ko turant Absent mark karke API se save kar
  //    deta hai.
  // 2) Check-in/Check-out flags reload kar deta hai taaki naye din ka
  //    cycle turant "Check In" se shuru ho jaaye — app restart ka wait
  //    nahi karna padta.
  // NOTE: Mobile app background me 24x7 nahi chal sakta, isliye jab tak
  // app kill/force-close nahi hoti tab tak hi ye timer chalega. App band
  // hone ke baad bhi missed din agli baar app khulne par
  // _autoMarkAbsentForMissedDays() (neeche) se cover ho jaate hain.
  // Guaranteed midnight-exact marking ke liye backend pe daily cron job
  // hona chahiye.
  Timer? _midnightTimer;

  // ========= STORAGE =========
  String schoolId = "";
  String token = "";
  String userId = "";
  String roleId = "";

  // ========= SESSION =========
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // ========= DATE =========
  // Locked to today only — no past/future selection anymore.
  final selectedDate = Rx<DateTime>(DateTime.now());
  String get displayDate => _formatDateUI(selectedDate.value);

  // Long format for the header card, e.g. "02 September 2026"
  String get displayDateLong => _formatDateLong(selectedDate.value);

  // ========= TEACHERS LIST =========
  final teacherUsers = <TeacherUser>[].obs;

  // ========= PER-TEACHER DATA (Persistent Maps) =========
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
      "https://playschool.edubloom.in/api/TeacherApp/TeacherAttendanceGetUserIdApp";
  final String saveApi =
      "https://playschool.edubloom.in/api/TeacherApp/SaveTeacherAttendenceApp";
  final String sessionApiBase =
      "https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/";

  // Kitne purane din tak "auto-absent" check karna hai jab app khule.
  static const int _autoAbsentLookbackDays = 14;

  @override
  void onInit() async {
    super.onInit();
    schoolId = (await PrefManager().readValue(key: PrefConst.schollId) ?? "").toString();
    token = (await PrefManager().readValue(key: PrefConst.token) ?? "").toString();
    userId = (await PrefManager().readValue(key: PrefConst.Userid) ?? "").toString();
    roleId = (await PrefManager().readValue(key: PrefConst.roleId) ?? "").toString();

    if (schoolId.trim().isEmpty) {
      _showError("SchoolId not found. Please login again.");
      return;
    }

    // Always today — defensive reset in case something upstream changed it.
    selectedDate.value = DateTime.now();

    await _loadCheckFlags();
    await fetchSessions();

    // Session/date ab manual select nahi hote (hamesha current session + aaj ki
    // date), isliye "Manage Attendance" button ki zarurat nahi — list yahin
    // auto-load ho jaati hai. Baad me refresh icon / pull-to-refresh se reload
    // hoga.
    if (!_sessionMissing()) {
      await fetchTeacherAttendanceList();
    } else {
      // Session pehli baar load nahi ho paya (slow network / API glitch) —
      // thodi der baad automatically dobara try karo, user ko kuch karne
      // ki zaroorat nahi.
      unawaited(_retrySessionLoadThenFetchList());
    }

    // Best-effort: pichle kuch din me jo bhi din (Sunday chhodkar) check-in
    // nahi hua tha, unhe automatically Absent mark kar do. Ye sirf tabhi
    // chalega jab app khulegi — guaranteed midnight-exact marking ke liye
    // backend pe ek daily cron job hona chahiye.
    unawaited(_autoMarkAbsentForMissedDays());

    // App khuli rehte hue bhi har raat 12 baje automatically absent-marking
    // aur check-in/out cycle reset ho jaaye, iske liye midnight timer schedule
    // kar do.
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
      // Agli midnight ke liye phir se schedule kar do — jab tak app zinda hai.
      _scheduleMidnightRollover();
    });
  }

  Future<void> _handleMidnightRollover() async {
    debugPrint("[ATT-DEBUG] Midnight rollover triggered — resetting check-in/out cycle for new day");

    // Jo din abhi khatam hua, agar us din check-in nahi hua tha (Sunday
    // chhodkar), to use turant Absent mark karke server pe save kar do.
    final justEndedDay = DateTime.now().subtract(const Duration(minutes: 1));
    if (justEndedDay.weekday != DateTime.sunday) {
      final dateKey =
          "${justEndedDay.year.toString().padLeft(4, '0')}-${justEndedDay.month.toString().padLeft(2, '0')}-${justEndedDay.day.toString().padLeft(2, '0')}";
      final checkInKey = "teacher_att_checkin_${userId}_$dateKey";
      final autoAbsentDoneKey = "teacher_att_autoabsent_done_${userId}_$dateKey";

      final alreadyHandled =
          (await PrefManager().readValue(key: autoAbsentDoneKey))?.toString() == "1";
      if (!alreadyHandled) {
        final wasCheckedIn =
            (await PrefManager().readValue(key: checkInKey))?.toString() == "1";
        if (!wasCheckedIn) {
          debugPrint("[ATT-DEBUG] MIDNIGHT-AUTO-ABSENT: marking $dateKey as absent (no check-in found, not Sunday)");
          await _markDayAbsentOnServer(justEndedDay);
        }
        await PrefManager().writeValue(key: autoAbsentDoneKey, value: "1");
      }
    }

    // Naye din ke liye check-in/check-out cycle reset karo. Flags date-scoped
    // keys se automatically fresh aa jaate hain (naya din -> naya key -> not
    // set), bas RAM/Rx state ko reload karke UI turant "Check In" dikha do —
    // app restart ka wait nahi karna padta.
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

  // =========================================================
  // LOCATION
  // =========================================================
  /// Fetches the device's current position and reverse-geocodes it into a
  /// human-readable address string. Falls back to "lat, lng" if reverse
  /// geocoding fails, and returns "" (with an error snackbar) if location
  /// can't be obtained at all — the check-in/out still proceeds, just
  /// without an address in that case.
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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
              .toSet() // drop exact duplicate segments
              .toList();
          final addr = parts.join(", ");
          if (addr.trim().isNotEmpty) return addr;
        }
      } catch (_) {
        // reverse geocoding failed (e.g. no internet) — fall back below
      }

      return "${position.latitude}, ${position.longitude}";
    } catch (e) {
      _showError("Could not fetch location: $e");
      return "";
    }
  }

  // =========================================================
  // CHECK-IN / CHECK-OUT
  // =========================================================
  // Keys are scoped to today's real calendar date, so at midnight the date
  // string changes, the old keys simply stop matching, and both flags come
  // back as "not set" (0) automatically — no timer/reset job needed.
  String _todayDateKeyPart() {
    final d = DateTime.now();
    return "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String get _checkInPrefKey => "teacher_att_checkin_${userId}_${_todayDateKeyPart()}";
  String get _checkOutPrefKey => "teacher_att_checkout_${userId}_${_todayDateKeyPart()}";
  String get _globalInTimeKey => "teacher_att_global_intime_${userId}_${_todayDateKeyPart()}";
  String get _globalOutTimeKey => "teacher_att_global_outtime_${userId}_${_todayDateKeyPart()}";

  // ========= LOCAL PERSISTENT IN/OUT DATA (survives app kill) =========
  // Har teacher ke check-in/check-out time+address ko SharedPreferences me
  // bhi save karte hain (sirf RAM map pe depend nahi karte), taaki app kill
  // hone ke baad bhi ye data mile — server response pe bharosa na karna pade.
  String _inTimeKey(int teacherId) =>
      "teacher_att_intime_${teacherId}_${_todayDateKeyPart()}";
  String _inAddrKey(int teacherId) =>
      "teacher_att_inaddr_${teacherId}_${_todayDateKeyPart()}";
  String _outTimeKey(int teacherId) =>
      "teacher_att_outtime_${teacherId}_${_todayDateKeyPart()}";
  String _outAddrKey(int teacherId) =>
      "teacher_att_outaddr_${teacherId}_${_todayDateKeyPart()}";

  Future<void> _persistInData(int teacherId, DateTime time, String address) async {
    await PrefManager().writeValue(key: _inTimeKey(teacherId), value: _formatDateTimeApi(time));
    await PrefManager().writeValue(key: _inAddrKey(teacherId), value: address);
    debugPrint("[ATT-DEBUG] persisted IN for teacher=$teacherId time=${_formatDateTimeApi(time)} addr=$address");
  }

  Future<void> _persistOutData(int teacherId, DateTime time, String address) async {
    await PrefManager().writeValue(key: _outTimeKey(teacherId), value: _formatDateTimeApi(time));
    await PrefManager().writeValue(key: _outAddrKey(teacherId), value: address);
    debugPrint("[ATT-DEBUG] persisted OUT for teacher=$teacherId time=${_formatDateTimeApi(time)} addr=$address");
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
      final inVal = await PrefManager().readValue(key: _checkInPrefKey);
      final outVal = await PrefManager().readValue(key: _checkOutPrefKey);
      isCheckedIn.value = (inVal?.toString() ?? "0") == "1";
      isCheckedOutToday.value = (outVal?.toString() ?? "0") == "1";

      todayInTime.value = await _readPersistedTime(_globalInTimeKey);
      todayOutTime.value = await _readPersistedTime(_globalOutTimeKey);
    } catch (_) {
      isCheckedIn.value = false;
      isCheckedOutToday.value = false;
    }
  }

  Future<void> _persistFlag(String key, bool value) async {
    // NOTE: adjust method name if your PrefManager's write method is named differently
    await PrefManager().writeValue(key: key, value: value ? "1" : "0");
  }

  /// Single button handler for the whole list:
  /// - not checked in yet today  -> fetches current location, stamps "now"
  ///   as in-time + that address for every Present teacher, saves, sets
  ///   flag=1 ("Check Out" shows next)
  /// - checked in, not out yet   -> fetches current location, stamps "now"
  ///   as out-time + that address, saves, sets flag=0, flag1=1 (button
  ///   hides for the rest of the day)
  /// - already checked out today -> no-op (button should already be hidden)
  // Check-in ke baad kam se kam itni der tak check-out button ka tap
  // effective nahi hoga — accidental turant check-out rokne ke liye.
  static const int _minGapBeforeCheckOutMinutes = 30;

  // Synchronous (non-reactive) re-entrancy lock — Rx flags (isCheckInOutSaving)
  // UI rebuild ke baad hi update hote hain, isliye agar user button ko bahut
  // tezi se do baar taps kare (double-tap) to dono taps ek sath function me
  // ghus sakte hain isse pehle ki Rx flag "saving" dikhaye. Ye plain bool
  // turant (same microtask) set ho jaata hai, isliye doosra tap turant
  // reject ho jaata hai — koi race window nahi bachta.
  bool _handlingCheckInOut = false;

  Future<void> handleCheckInOut() async {
    if (_handlingCheckInOut) return; // ignore any overlapping tap immediately
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

      // ---- CHECK-OUT GUARD: Check-in aur Check-out ke beech kam se kam
      // 30 minute ka gap zaroori hai. ----
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

      // ---- DOUBLE CHECK-IN GUARD: agar abhi "Check In" hi hone waala hai
      // (isCheckedIn abhi false hai), to database/local flags ke stale hone
      // ki possibility ko khatam karne ke liye ek AAKHRI baar server se
      // taaza attendance record mangwa lo. Agar isi dauraan (doosre device
      // / doosri session se) already check-in ho chuka hai, to server
      // record turant reflect kar dega aur ye check-in yahin rok denge —
      // koi duplicate check-in save nahi hoga. ----
      if (!isCheckedIn.value) {
        isCheckInOutSaving(true);
        await fetchTeacherAttendanceList(); // isके andar hi _reconcileCheckFlagsFromServer() chalta hai
        if (isCheckedIn.value || isCheckedOutToday.value) {
          isCheckInOutSaving(false);
          _showInfo("Attendance for today is already marked. No action needed.");
          return;
        }
      }

      try {
        isCheckInOutSaving(true);
        final now = DateTime.now();
        final address = await _getCurrentAddress();

        if (!isCheckedIn.value) {
          // ---- CHECK IN: stamp "now" + current address for every present teacher ----
          for (final t in teacherUsers) {
            final id = t.userId;
            if (id == null) continue;
            if (statusForUser(id, t.status) != statusPresent) continue;
            _inTimeMap[id] = now;
            _inOutMap[id] = "IN";
            _inAddressMap[id] = address;
            await _persistInData(id, now, address);
          }
          _bump();

          todayInTime.value = now;
          await PrefManager().writeValue(key: _globalInTimeKey, value: _formatDateTimeApi(now));

          await saveAttendanceFromView();
          isCheckedIn.value = true;
          await _persistFlag(_checkInPrefKey, true);
        } else {
          // ---- CHECK OUT: stamp "now" + current address for every present teacher ----
          for (final t in teacherUsers) {
            final id = t.userId;
            if (id == null) continue;
            if (statusForUser(id, t.status) != statusPresent) continue;
            _outTimeMap[id] = now;
            _inOutMap[id] = "OUT";
            _outAddressMap[id] = address;
            await _persistOutData(id, now, address);
          }
          _bump();

          todayOutTime.value = now;
          await PrefManager().writeValue(key: _globalOutTimeKey, value: _formatDateTimeApi(now));

          await saveAttendanceFromView();
          isCheckedIn.value = false;
          isCheckedOutToday.value = true;
          await _persistFlag(_checkInPrefKey, false);
          await _persistFlag(_checkOutPrefKey, true);
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

  bool _sessionMissing() => selectedSession.value == null || (selectedSession.value!.session ?? "").trim().isEmpty;

  // =========================================================
  // SESSIONS
  // =========================================================
  Future<void> fetchSessions() async {
    try {
      isPageLoading(true);
      final response = await http.get(Uri.parse("$sessionApiBase$schoolId"), headers: {'Content-Type': 'application/json'});
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

  /// Agar session load nahi ho paya tha, to background me kuch retries
  /// (2s gap ke sath) karta hai — bina user ko error dikhaye. Jaise hi
  /// session mil jaata hai, list bhi turant fetch kar leta hai. Ye
  /// purely automatic hai, koi manual "select session" action nahi chahiye.
  Future<void> _retrySessionLoadThenFetchList() async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      await Future.delayed(const Duration(seconds: 2));
      if (!_sessionMissing()) break;
      debugPrint("[ATT-DEBUG] Session missing, retry #$attempt");
      await fetchSessions();
    }
    if (!_sessionMissing()) {
      await fetchTeacherAttendanceList();
    } else {
      debugPrint("[ATT-DEBUG] Session still missing after retries");
    }
  }

  /// Session hamesha automatic hi load hota hai (koi manual selection UI
  /// nahi hai) — isliye kahin bhi session ki zaroorat pade (refresh,
  /// check-in/out), agar wo missing mile to pehle ek baar fetchSessions()
  /// se dobara try karo, tabhi user ko error dikhao jab retry ke baad bhi
  /// na mile.
  Future<bool> _ensureSessionLoaded() async {
    if (!_sessionMissing()) return true;
    await fetchSessions();
    return !_sessionMissing();
  }

  // =========================================================
  // CURRENT TEACHER DISPLAY HELPERS (for header card UI only)
  // =========================================================
  // Logged-in userId se match karke teacher dhoondte hain; na mile to
  // list ka pehla record use karte hain. Ye sirf display ke liye hai,
  // ismein koi save/fetch logic nahi hai.
  TeacherUser? get _currentTeacher {
    if (teacherUsers.isEmpty) return null;
    final uid = int.tryParse(userId);
    if (uid != null) {
      for (final t in teacherUsers) {
        if (t.userId == uid) return t;
      }
    }
    return teacherUsers.first;
  }

  String get currentTeacherName {
    final t = _currentTeacher;
    if (t == null) return "-";
    final n = "${t.firstName ?? ""} ${t.lastName ?? ""}".trim();
    return n.isEmpty ? "-" : n;
  }

  String get currentTeacherId {
    final t = _currentTeacher;
    if (t == null) return "-";
    final reg = (t.registrationNo?.trim().isNotEmpty == true)
        ? t.registrationNo!.trim()
        : t.additionalDetail?.registrationNo?.trim();
    return (reg != null && reg.isNotEmpty) ? reg : "-";
  }

  // =========================================================
  // PER-TEACHER STATUS
  // =========================================================
  String statusForUser(int userId, String? rawStatus) => _statusMap[userId] ?? _normalizeStatus(rawStatus);

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
      await fetchTeacherAttendanceList();
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
    await fetchTeacherAttendanceList();
  }

  // =========================================================
  // VIEW & SAVE (The core logic to keep data persistent)
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
          "userId": int.tryParse(userId) ?? 0,
          "roleId": int.tryParse(roleId) ?? 0,
        }),
      );

      if (res.statusCode != 200) return;

      final parsed = TeacherListResponse.fromJson(jsonDecode(res.body));
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

      // Time parsing helper
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

        // Har field ke liye teeno jagah try karo: flat, nested, aur nested-extra.
        final rawStatus = t.status ?? t.teacherAttendance?.attendanceStatus;

        final rawIn = t.inTime ??
            t.teacherAttendance?.inTime ??
            t.teacherAttendance?.extra?['inTime']?.toString();

        final rawOut = t.outTime ??
            t.teacherAttendance?.outTime ??
            t.teacherAttendance?.extra?['outTime']?.toString();

        final rawInAddress = t.inAddress ??
            t.teacherAttendance?.extra?['inAddress']?.toString();

        final rawOutAddress = t.outAddress ??
            t.teacherAttendance?.extra?['outAddress']?.toString();

        debugPrint("[ATT-DEBUG] FETCH teacher=$id rawStatus=$rawStatus rawIn=$rawIn rawOut=$rawOut "
            "rawInAddr=$rawInAddress rawOutAddr=$rawOutAddress");

        // Status
        _statusMap[id] = _normalizeStatus(
          rawStatus.isNotEmptyOrNull ? rawStatus : oldStatusMap[id],
        );

        // Time — server value ho to wahi, warna purani local value, kabhi null nahi
        final pIn = parseTime(rawIn);
        final pOut = parseTime(rawOut);
        // Agar server aur RAM dono khaali hain, to local-persisted (SharedPreferences)
        // value se fallback lo — ye app-kill ke baad bhi zinda rehta hai.
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

        // Address — server value ho to wahi, warna purani local value, warna persisted value
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

        debugPrint("[ATT-DEBUG] FETCH-RESULT teacher=$id finalIn=${_inTimeMap[id]} finalOut=${_outTimeMap[id]} "
            "finalInAddr=${_inAddressMap[id]} finalOutAddr=${_outAddressMap[id]}");
      }
      _bump();

      // Server ko bhi source of truth maankar check-in/out flags reconcile
      // kar do — sirf local device flags par bharosa nahi karte.
      await _reconcileCheckFlagsFromServer();
    } catch (e) {
      _showError("Error loading: $e");
    } finally {
      isViewLoading(false);
    }
  }

  // =========================================================
  // RECONCILE CHECK-IN/OUT FLAGS WITH SERVER (single source of truth)
  // =========================================================
  /// Local device flags (isCheckedIn / isCheckedOutToday) sirf ek "cache"
  /// hain — asli source of truth server ka fetched inTime/outTime hai.
  /// Ye function har list-fetch ke baad current logged-in teacher ke
  /// server record ko check karta hai:
  /// - Agar server pe outTime already hai -> isCheckedOutToday = true,
  ///   isCheckedIn = false (cycle locked, button hidden) — chahe local
  ///   flag kuch bhi kahe (logout/login, reinstall, doosra device, kuch
  ///   bhi ho, ek din me sirf ek hi Check Out allow hota hai).
  /// - Warna agar server pe inTime hai (outTime nahi) -> isCheckedIn =
  ///   true ("Check Out" button dikhega, dobara "Check In" nahi ho sakta).
  /// - Agar server pe kuch bhi nahi hai -> local flags jaise the waise
  ///   hi rehne do (abhi tak koi check-in nahi hua).
  Future<void> _reconcileCheckFlagsFromServer() async {
    final uid = int.tryParse(userId);
    if (uid == null) return;

    final serverIn = _inTimeMap[uid];
    final serverOut = _outTimeMap[uid];

    if (serverOut != null) {
      if (!isCheckedOutToday.value) {
        isCheckedOutToday.value = true;
        await _persistFlag(_checkOutPrefKey, true);
      }
      if (isCheckedIn.value) {
        isCheckedIn.value = false;
        await _persistFlag(_checkInPrefKey, false);
      }
      todayOutTime.value = serverOut;
      await PrefManager().writeValue(key: _globalOutTimeKey, value: _formatDateTimeApi(serverOut));
      if (serverIn != null) {
        todayInTime.value = serverIn;
        await PrefManager().writeValue(key: _globalInTimeKey, value: _formatDateTimeApi(serverIn));
      }
    } else if (serverIn != null) {
      if (!isCheckedIn.value) {
        isCheckedIn.value = true;
        await _persistFlag(_checkInPrefKey, true);
      }
      todayInTime.value = serverIn;
      await PrefManager().writeValue(key: _globalInTimeKey, value: _formatDateTimeApi(serverIn));
    }
  }

  Future<void> saveAttendanceFromView() async {    if (_sessionMissing() || teacherUsers.isEmpty) return;

  // Yahi wo helper hai jo kabhi bhi khaali/null time nahi jaane dega —
  // agar RAM map me value nahi hai to seedha teacher ke apne record
  // (flat / nested / extra) se fallback le lega.
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

      // ---- IN TIME: local map -> local-persisted (SharedPreferences) -> flat -> nested -> extra -> kabhi null nahi ----
      final DateTime? inT = _inTimeMap[uId] ??
          await _readPersistedTime(_inTimeKey(uId)) ??
          _fallbackTime(
            t.inTime ??
                t.teacherAttendance?.inTime ??
                t.teacherAttendance?.extra?['inTime']?.toString(),
          );

      // ---- OUT TIME: same fallback chain ----
      final DateTime? outT = _outTimeMap[uId] ??
          await _readPersistedTime(_outTimeKey(uId)) ??
          _fallbackTime(
            t.outTime ??
                t.teacherAttendance?.outTime ??
                t.teacherAttendance?.extra?['outTime']?.toString(),
          );

      // ---- ADDRESS: same fallback chain ----
      final String inAddr = _inAddressMap[uId] ??
          (await _readPersistedAddr(_inAddrKey(uId))) ??
          t.inAddress ??
          t.teacherAttendance?.extra?['inAddress']?.toString() ??
          "";
      final String outAddr = _outAddressMap[uId] ??
          (await _readPersistedAddr(_outAddrKey(uId))) ??
          t.outAddress ??
          t.teacherAttendance?.extra?['outAddress']?.toString() ??
          "";

      debugPrint("[ATT-DEBUG] SAVE teacher=$uId inT=$inT outT=$outT inAddr=$inAddr outAddr=$outAddr "
          "(fromMap=${_inTimeMap[uId]}, fromServer=${t.inTime ?? t.teacherAttendance?.inTime})");

      final body = {
        "tadid": t.teacherAttendance?.attendanceId ?? 0,
        "teacherReg": reg,
        "status": _statusMap[uId] ?? _normalizeStatus(t.status),
        "months": selectedDate.value.month,
        "session": selectedSession.value!.session,
        "day": selectedDate.value.day.toString(),
        "adate": _formatDateApi(selectedDate.value),
        "userAttendance": "admin",
        "schoolId": schoolId,
        // inTime/outTime sirf tabhi bhejo jab koi real value ho —
        // kabhi bhi bare "null" nahi bhejenge jo backend me overwrite kar de.
        "inTime": inT != null ? _formatDateTimeApi(inT) : (t.inTime ?? t.teacherAttendance?.inTime ?? ""),
        "outTime": outT != null ? _formatDateTimeApi(outT) : "",
        "inOut": _inOutMap[uId] ?? "IN",
        "inAddress": inAddr,
        "outAddress": outAddr,
      };

      debugPrint("[ATT-DEBUG] SAVE-BODY teacher=$uId body=$body");

      final res = await http.post(Uri.parse(saveApi), headers: _headers(), body: jsonEncode(body));
      if (res.statusCode == 200) {
        final respBody = jsonDecode(res.body);
        debugPrint("[ATT-DEBUG] SAVE-RESPONSE teacher=$uId response=$respBody");
        if (respBody['isSuccess'] == true || respBody['statusCode'] == 200) {
          ok++;
        }
      } else {
        debugPrint("[ATT-DEBUG] SAVE-FAILED teacher=$uId statusCode=${res.statusCode} body=${res.body}");
      }
    }
    _showSuccess("Attendance updated for teacher");
    await fetchTeacherAttendanceList();
  } catch (e) {
    _showError("Save error: $e");
  } finally {
    isViewSaving(false);
  }
  }

  // =========================================================
  // AUTO-ABSENT FOR MISSED DAYS (Sunday chhodkar)
  // =========================================================
  /// App khulte hi pichle [_autoAbsentLookbackDays] din check karta hai.
  /// Jis din (Sunday chhodkar) us admin device se check-in nahi hua tha,
  /// us din ke liye — agar server pe pehle se koi status save nahi hai —
  /// har teacher ko "ABSENT" mark kar deta hai.
  ///
  /// NOTE: Ye best-effort client-side logic hai, kyunki mobile app
  /// background me 24x7 nahi chal sakta. Guaranteed midnight-exact marking
  /// ke liye backend pe daily cron job hona chahiye. Jab tak app zinda hai
  /// tab tak _scheduleMidnightRollover() (upar) bhi har raat 12 baje isi
  /// tarah ka check turant karta hai.
  Future<void> _autoMarkAbsentForMissedDays() async {
    if (_sessionMissing()) return;

    final today = DateTime.now();
    for (int i = 1; i <= _autoAbsentLookbackDays; i++) {
      final day = today.subtract(Duration(days: i));

      // Sunday (weekday == 7) ko chhod do — weekly off.
      if (day.weekday == DateTime.sunday) continue;

      final dateKey =
          "${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
      final checkInKey = "teacher_att_checkin_${userId}_$dateKey";
      final autoAbsentDoneKey = "teacher_att_autoabsent_done_${userId}_$dateKey";

      final alreadyHandled =
          (await PrefManager().readValue(key: autoAbsentDoneKey))?.toString() == "1";
      if (alreadyHandled) continue;

      final wasCheckedIn =
          (await PrefManager().readValue(key: checkInKey))?.toString() == "1";
      if (wasCheckedIn) {
        // Us din check-in ho chuka tha, absent mark karne ki zaroorat nahi.
        await PrefManager().writeValue(key: autoAbsentDoneKey, value: "1");
        continue;
      }

      debugPrint("[ATT-DEBUG] AUTO-ABSENT: marking $dateKey as absent (no check-in found, not Sunday)");
      await _markDayAbsentOnServer(day);
      await PrefManager().writeValue(key: autoAbsentDoneKey, value: "1");
    }
  }

  Future<void> _markDayAbsentOnServer(DateTime day) async {
    try {
      // Us din ki teacher list fetch karo taaki sahi registrationNo/tadid mile.
      final res = await http.post(
        Uri.parse(viewApi),
        headers: _headers(),
        body: jsonEncode({
          "date": _formatDateApi(day),
          "session": selectedSession.value!.session,
          "schoolId": schoolId,
          "userId": int.tryParse(userId) ?? 0,
          "roleId": int.tryParse(roleId) ?? 0,
        }),
      );
      if (res.statusCode != 200) return;

      final parsed = TeacherListResponse.fromJson(jsonDecode(res.body));
      for (final t in parsed.listData) {
        final reg = (t.registrationNo ?? t.additionalDetail?.registrationNo ?? "").trim();
        if (reg.isEmpty) continue;

        // Agar us din already koi status save hai (present/absent), to overwrite mat karo.
        final existingStatus = t.status ?? t.teacherAttendance?.attendanceStatus;
        if (existingStatus != null && existingStatus.trim().isNotEmpty) continue;

        final body = {
          "tadid": t.teacherAttendance?.attendanceId ?? 0,
          "teacherReg": reg,
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
        debugPrint("[ATT-DEBUG] AUTO-ABSENT save teacher=$reg date=${_formatDateApi(day)} statusCode=${saveRes.statusCode}");
      }
    } catch (e) {
      debugPrint("[ATT-DEBUG] AUTO-ABSENT error for ${_formatDateApi(day)}: $e");
    }
  }

  void _showSuccess(String msg) {
    Get.snackbar("Success", msg, backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  }

  void _showError(String msg) {
    Get.snackbar("Error", msg, backgroundColor: Colors.red, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  }

  void _showInfo(String msg) {
    Get.snackbar("Info", msg, backgroundColor: Colors.blue, colorText: Colors.white, snackPosition: SnackPosition.TOP);
  }
}

extension _NullableStringCheck on String? {
  bool get isNotEmptyOrNull => this != null && this!.trim().isNotEmpty;
}