int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

/// A school holiday, backed by api/CalendarApp/AddHoliday and
/// api/CalendarApp/GetHoliday/{schoolId}.
class Holiday {
  final int hdId;
  final DateTime dateHoliday;
  final String occasion;
  final int? action; // 1 = active, 0 = inactive
  final String? session;
  final String? schoolId;
  final String? createBy;
  final String? updateBy;
  final DateTime? createDate;
  final DateTime? updateDate;

  Holiday({
    this.hdId = 0,
    required this.dateHoliday,
    required this.occasion,
    this.action,
    this.session,
    this.schoolId,
    this.createBy,
    this.updateBy,
    this.createDate,
    this.updateDate,
  });

  bool get isActive => action != 0;

  /// Date only (no time part) — the key used to match calendar cells.
  DateTime get day => DateTime(dateHoliday.year, dateHoliday.month, dateHoliday.day);

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      hdId: _asInt(json['hdId']) ?? 0,
      dateHoliday: _asDate(json['dateHoliday']) ?? DateTime.now(),
      occasion: json['occasion']?.toString() ?? '',
      action: _asInt(json['action']),
      session: json['session']?.toString(),
      schoolId: json['schoolId']?.toString(),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      createDate: _asDate(json['createDate']),
      updateDate: _asDate(json['updateDate']),
    );
  }

  Map<String, dynamic> toJson() {
    final now = DateTime.now().toUtc().toIso8601String();
    // Send the picked calendar day at midnight with no timezone shift, so
    // the server stores the same date the admin tapped.
    final d = day;
    final date = "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}T00:00:00";
    return {
      'hdId': hdId,
      'dateHoliday': date,
      'occasion': occasion,
      'createBy': createBy ?? '',
      'updateBy': updateBy ?? '',
      'updateDate': now,
      'createDate': (createDate?.toUtc().toIso8601String()) ?? now,
      'action': action ?? 1,
      'session': session ?? '',
      'schoolId': schoolId ?? '',
    };
  }

  /// Response shape: { "data": { "holidayList": [ ... ] } }
  static List<Holiday> listFromJson(dynamic decoded) {
    dynamic list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map) {
      final data = decoded['data'];
      list = data is Map ? data['holidayList'] : (data ?? decoded['listData']);
    }
    if (list is! List) return <Holiday>[];
    return list
        .whereType<Map>()
        .map((e) => Holiday.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}
