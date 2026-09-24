// ============================================================
// Attendance Timing Configuration Model
// API: GET /api/MasterApp/ViewAttendanceTiming/{schoolId}
// ============================================================
//
// Usage:
//   final res = await http.get(Uri.parse("$timingApiBase$schoolId"));
//   final config = AttendanceTimingResponse.fromJson(jsonDecode(res.body));
//   for (final t in config.listData) {
//     print(t.timingName);
//   }
//
// ============================================================

class AttendanceTimingResponse {
  final List<AttendanceTiming> listData;

  AttendanceTimingResponse({
    required this.listData,
  });

  factory AttendanceTimingResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['listData'];
    final List<AttendanceTiming> parsedList = [];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          parsedList.add(AttendanceTiming.fromJson(item));
        } else if (item is Map) {
          parsedList.add(
            AttendanceTiming.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return AttendanceTimingResponse(listData: parsedList);
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((e) => e.toJson()).toList(),
    };
  }
}

class AttendanceTiming {
  final int timingId;
  final String timingName;
  final String month;
  final String schoollStartTime;
  final String? schoollENdTime;
  final int relaxationTime;
  final String lateAfter;
  final String applicableStaff;
  final int action;
  final String schoolId;
  final String session;
  final String createBy;
  final DateTime? createdAt;
  final String? updateBy;

  AttendanceTiming({
    required this.timingId,
    required this.timingName,
    required this.month,
    required this.schoollStartTime,
    required this.schoollENdTime,
    required this.relaxationTime,
    required this.lateAfter,
    required this.applicableStaff,
    required this.action,
    required this.schoolId,
    required this.session,
    required this.createBy,
    required this.createdAt,
    required this.updateBy,
  });

  factory AttendanceTiming.fromJson(Map<String, dynamic> json) {
    return AttendanceTiming(
      timingId: _toInt(json['timingId']),
      timingName: _toStringSafe(json['timingName']),
      month: _toStringSafe(json['month']),
      schoollStartTime: _toStringSafe(json['schoollStartTime']),
      // FIX: schoollENdTime can be null in the API (e.g. not yet configured
      // for a given timing record) — keep it nullable, never crash on null.
      schoollENdTime: _toNullableString(json['schoollENdTime']),
      relaxationTime: _toInt(json['relaxationTime']),
      lateAfter: _toStringSafe(json['lateAfter']),
      // FIX: applicableStaff can be null (as seen in timingId 21) or an
      // empty string (as seen in timingId 22) — normalize both to "".
      applicableStaff: _toStringSafe(json['applicableStaff']),
      action: _toInt(json['action']),
      schoolId: _toStringSafe(json['schoolId']),
      session: _toStringSafe(json['session']),
      createBy: _toStringSafe(json['createBy']),
      createdAt: _toDateTime(json['createdAt']),
      updateBy: _toNullableString(json['updateBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timingId': timingId,
      'timingName': timingName,
      'month': month,
      'schoollStartTime': schoollStartTime,
      'schoollENdTime': schoollENdTime,
      'relaxationTime': relaxationTime,
      'lateAfter': lateAfter,
      'applicableStaff': applicableStaff,
      'action': action,
      'schoolId': schoolId,
      'session': session,
      'createBy': createBy,
      'createdAt': createdAt?.toIso8601String(),
      'updateBy': updateBy,
    };
  }

  /// True only when this timing record is currently enabled by admin.
  bool get isActive => action == 1;

  /// Splits the comma-separated `month` field into a clean list, e.g.
  /// "December,January,February" -> ["December", "January", "February"].
  /// Handles mixed case (e.g. "MARCH") by keeping original casing here —
  /// use monthMatches() below for a case-insensitive check.
  List<String> get monthList => month
      .split(',')
      .map((m) => m.trim())
      .where((m) => m.isNotEmpty)
      .toList();

  /// Case-insensitive check whether this timing record applies to the
  /// given month name (e.g. "September", "march", "MARCH" all match).
  bool monthMatches(String monthName) {
    final target = monthName.trim().toLowerCase();
    return monthList.any((m) => m.toLowerCase() == target);
  }

  /// Case-insensitive check whether this timing record applies to the
  /// given staff role. Treats an empty/null applicableStaff as "applies
  /// to everyone" since the API has sent both "" and null for that case.
  bool appliesToStaff(String staffRole) {
    final normalized = applicableStaff.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'all staff') return true;
    return normalized == staffRole.trim().toLowerCase();
  }

  // ---------------------------------------------------------
  // Safe JSON field parsers — never throw on unexpected types
  // ---------------------------------------------------------
  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static String _toStringSafe(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    return s.trim().isEmpty ? null : s;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

// ============================================================
// TIME PARSING HELPER
// ============================================================
// The API sends time in several inconsistent formats seen so far:
//   "10:00AM"   (no space before AM/PM)
//   "10:00 AM"  (space before AM/PM)
//   "10:10"     (24-hour style, no AM/PM at all)
//   "04:00 AM"  (zero-padded hour)
//
// This helper normalizes all of them into a simple (hour, minute) pair
// in 24-hour form, wrapped in TimeOfDayValue below (kept dependency-free
// from Flutter's TimeOfDay so this file can be used in pure Dart too).
// ============================================================

class TimeOfDayValue {
  final int hour; // 0-23
  final int minute; // 0-59

  const TimeOfDayValue({required this.hour, required this.minute});

  /// Total minutes since midnight — handy for duration comparisons.
  int get totalMinutes => hour * 60 + minute;

  @override
  String toString() =>
      "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";

  /// Parses flexible time strings such as "10:00AM", "10:00 AM", "10:10",
  /// "04:00 AM". Returns null if the string can't be parsed at all.
  static TimeOfDayValue? parse(String? raw) {
    if (raw == null) return null;
    var s = raw.trim().toUpperCase();
    if (s.isEmpty) return null;

    final isPM = s.contains('PM');
    final isAM = s.contains('AM');

    // Strip AM/PM markers (with or without a preceding space).
    s = s.replaceAll('AM', '').replaceAll('PM', '').trim();

    final parts = s.split(':');
    if (parts.length < 2) return null;

    int? hour = int.tryParse(parts[0].trim());
    int? minute = int.tryParse(parts[1].trim());
    if (hour == null || minute == null) return null;

    if (isPM && hour < 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    // Defensive clamp — malformed data should never produce an invalid
    // TimeOfDayValue that later breaks DateTime construction.
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDayValue(hour: hour, minute: minute);
  }
}