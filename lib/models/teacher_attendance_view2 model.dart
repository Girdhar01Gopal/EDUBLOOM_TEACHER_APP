// ============================================================
//  teacher_attendance_view2 model.dart
// ============================================================

class ViewTeacherAttendanceResponse {
  final List<ViewTeacherAttendanceItem> listData;

  ViewTeacherAttendanceResponse({required this.listData});

  factory ViewTeacherAttendanceResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['listData'];
    return ViewTeacherAttendanceResponse(
      listData: raw is List
          ? raw
          .whereType<Map<String, dynamic>>()
          .map(ViewTeacherAttendanceItem.fromJson)
          .toList()
          : <ViewTeacherAttendanceItem>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'listData': listData.map((e) => e.toJson()).toList(),
  };
}

class ViewTeacherAttendanceItem {
  final String? teacherReg;
  final String? name;
  final int? months;
  final String? gender;
  final String? session;
  final DateTime? dob;
  final String? inTime;
  final String? outTime;
  final String? inAddress;
  final String? outAddress;

  /// Day-wise attendance status (1..31)
  final Map<int, String?> days;

  /// Per-day inTime / outTime (populated during merge in controller)
  final Map<int, String?> dayInTimes;
  final Map<int, String?> dayOutTimes;

  ViewTeacherAttendanceItem({
    this.teacherReg,
    this.name,
    this.months,
    this.gender,
    this.session,
    this.dob,
    this.inTime,
    this.outTime,
    this.inAddress,
    this.outAddress,
    required this.days,
    Map<int, String?>? dayInTimes,
    Map<int, String?>? dayOutTimes,
  })  : dayInTimes = dayInTimes ?? {},
        dayOutTimes = dayOutTimes ?? {};

  factory ViewTeacherAttendanceItem.fromJson(Map<String, dynamic> json) {
    final Map<int, String?> dayMap = {};
    for (int i = 1; i <= 31; i++) {
      final key = 'day$i';
      dayMap[i] = json.containsKey(key) ? _asString(json[key]) : null;
    }

    return ViewTeacherAttendanceItem(
      teacherReg: _asString(json['teacherReg']),
      name: _asString(json['name']),
      months: _asInt(json['months']),
      gender: _asString(json['gender']),
      session: _asString(json['session']),
      dob: _asDate(json['dob']),
      inTime: _asString(json['inTime']),
      outTime: _asString(json['outTime']),
      inAddress: _asString(json['inAddress']),
      outAddress: _asString(json['outAddress']),
      days: dayMap,
      // dayInTimes / dayOutTimes filled during merge — empty on raw parse
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'teacherReg': teacherReg,
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
      data['day$i'] = days[i];
    }
    return data;
  }

  /// Used by controller to create merged copies
  ViewTeacherAttendanceItem copyWith({
    Map<int, String?>? days,
    Map<int, String?>? dayInTimes,
    Map<int, String?>? dayOutTimes,
  }) {
    return ViewTeacherAttendanceItem(
      teacherReg: teacherReg,
      name: name,
      months: months,
      gender: gender,
      session: session,
      dob: dob,
      inTime: inTime,
      outTime: outTime,
      inAddress: inAddress,
      outAddress: outAddress,
      days: days ?? Map.from(this.days),
      dayInTimes: dayInTimes ?? Map.from(this.dayInTimes),
      dayOutTimes: dayOutTimes ?? Map.from(this.dayOutTimes),
    );
  }

  // ── Helpers for UI ──────────────────────────────────────────────────────
  String? dayStatus(int day) => days[day];
  String? dayIn(int day) => dayInTimes[day];
  String? dayOut(int day) => dayOutTimes[day];

  bool isPresent(int day) =>
      (days[day] ?? '').toLowerCase().trim() == 'present';
  bool isAbsent(int day) =>
      (days[day] ?? '').toLowerCase().trim() == 'absent';
  bool isHoliday(int day) =>
      (days[day] ?? '').toLowerCase().trim() == 'holiday';

  int get presentCount =>
      days.values.where((v) => (v ?? '').toLowerCase().trim() == 'present').length;
  int get absentCount =>
      days.values.where((v) => (v ?? '').toLowerCase().trim() == 'absent').length;
  int get holidayCount =>
      days.values.where((v) => (v ?? '').toLowerCase().trim() == 'holiday').length;
}

// ── Safe parsers ────────────────────────────────────────────────────────────
String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}