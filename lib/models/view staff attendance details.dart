// ============================================================
//  view staff attendance details.dart
// ============================================================

class StaffAttendanceView {
  final String staffReg;
  final String name;
  final int months;
  final String gender;
  final String session;
  final DateTime? dob;
  final String? inTime;
  final String? outTime;
  final String? inAddress;
  final String? outAddress;

  /// Day-wise attendance status  (key = "day1".."day31")
  final Map<String, String?> attendanceDays;

  /// Per-day in/out times — filled during merge in controller
  final Map<int, String?> dayInTimes;
  final Map<int, String?> dayOutTimes;
  final Map<int, String?> dayInAddresses;
  final Map<int, String?> dayOutAddresses;

  StaffAttendanceView({
    required this.staffReg,
    required this.name,
    required this.months,
    required this.gender,
    required this.session,
    this.dob,
    this.inTime,
    this.outTime,
    this.inAddress,
    this.outAddress,
    required this.attendanceDays,
    Map<int, String?>? dayInTimes,
    Map<int, String?>? dayOutTimes,
    Map<int, String?>? dayInAddresses,    // ✅ NEW
    Map<int, String?>? dayOutAddresses,   // ✅ NEW
  })  : dayInTimes = dayInTimes ?? {},
        dayOutTimes = dayOutTimes ?? {},
        dayInAddresses = dayInAddresses ?? {},
        dayOutAddresses = dayOutAddresses ?? {};

  // ── FROM JSON ──────────────────────────────────────────────────────────────
  factory StaffAttendanceView.fromJson(Map<String, dynamic> json) {
    final Map<String, String?> days = {};
    final Map<int, String?> inTimes = {};
    final Map<int, String?> outTimes = {};
    final Map<int, String?> inAddrs = {};    // ✅ NEW
    final Map<int, String?> outAddrs = {};   // ✅ NEW


    for (int i = 1; i <= 31; i++) {
      final key = 'day$i';
      final v = json[key]?.toString();
      days[key] = (v == null || v.trim().isEmpty) ? null : v.trim();

      // ✅ NEW: actual in/out time read karo JSON se
      inTimes[i] = _clean(json['day${i}InTime']);
      outTimes[i] = _clean(json['day${i}OutTime']);
      inAddrs[i] = _clean(json['day${i}InAddress']);    // ✅ NEW
      outAddrs[i] = _clean(json['day${i}OutAddress']);  // ✅ NEW
    }

    return StaffAttendanceView(
      staffReg: json['staffReg']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      months: json['months'] is int
          ? json['months']
          : int.tryParse(json['months']?.toString() ?? '0') ?? 0,
      gender: json['gender']?.toString() ?? '',
      session: json['session']?.toString() ?? '',
      dob: json['dob'] != null
          ? DateTime.tryParse(json['dob'].toString())
          : null,
      inTime: _clean(json['inTime']),
      outTime: _clean(json['outTime']),
      inAddress: _clean(json['inAddress']),
      outAddress: _clean(json['outAddress']),
      attendanceDays: days,
      dayInTimes: inTimes,   // ✅ NEW
      dayOutTimes: outTimes,
      dayInAddresses: inAddrs,     // ✅ NEW
      dayOutAddresses: outAddrs,   // ✅ NEW// ✅ NEW
    );
  }

  // ── TO JSON ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'staffReg': staffReg,
      'name': name,
      'months': months,
      'gender': gender,
      'session': session,
      'dob': dob?.toIso8601String(),
      'inTime': inTime,
      'outTime': outTime,
      'inAddress': inAddress,
      'outAddress': outAddress,
    };
    for (int i = 1; i <= 31; i++) {
      data['day$i'] = attendanceDays['day$i'];
    }
    return data;
  }

  // ── copyWith — used by controller merge ───────────────────────────────────
  StaffAttendanceView copyWith({
    Map<String, String?>? attendanceDays,
    Map<int, String?>? dayInTimes,
    Map<int, String?>? dayOutTimes,
    Map<int, String?>? dayInAddresses,    // ✅ NEW
    Map<int, String?>? dayOutAddresses,   // ✅ NEW
  }) {
    return StaffAttendanceView(
      staffReg: staffReg,
      name: name,
      months: months,
      gender: gender,
      session: session,
      dob: dob,
      inTime: inTime,
      outTime: outTime,
      inAddress: inAddress,
      outAddress: outAddress,
      attendanceDays: attendanceDays ?? Map.from(this.attendanceDays),
      dayInTimes: dayInTimes ?? Map.from(this.dayInTimes),
      dayOutTimes: dayOutTimes ?? Map.from(this.dayOutTimes),
      dayInAddresses: dayInAddresses ?? Map.from(this.dayInAddresses),     // ✅ NEW
      dayOutAddresses: dayOutAddresses ?? Map.from(this.dayOutAddresses),  // ✅ NEW
    );
  }

  // ── Helpers for UI ─────────────────────────────────────────────────────────
  String attendanceStatus(int day) {
    if (day < 1 || day > 31) return "";
    return attendanceDays['day$day'] ?? "";
  }

  String? dayIn(int day) => dayInTimes[day];
  String? dayOut(int day) => dayOutTimes[day];
  String? dayInAddress(int day) => dayInAddresses[day];
  String? dayOutAddress(int day) => dayOutAddresses[day];

  void setAttendance(int day, String? value) {
    if (day < 1 || day > 31) return;
    attendanceDays['day$day'] = value;
  }

  // ✅ UPDATED: full word aur short code (P / A / H) dono count honge
  int get presentCount => attendanceDays.values.where((v) {
    final s = (v ?? '').toLowerCase().trim();
    return s == 'present' || s == 'p';
  }).length;

  int get absentCount => attendanceDays.values.where((v) {
    final s = (v ?? '').toLowerCase().trim();
    return s == 'absent' || s == 'a';
  }).length;

  int get holidayCount => attendanceDays.values.where((v) {
    final s = (v ?? '').toLowerCase().trim();
    return s == 'holiday' || s == 'hold' || s == 'h';
  }).length;
}

// ── Safe string helper ────────────────────────────────────────────────────────
String? _clean(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}