class DaycareFeeRow {
  final int? id;
  final int? sadId;
  final int? studentId;
  final String? studentName;
  final String? fatherName;
  final int? feeTypeId;
  final String? feeTypeName;
  final String? totalHour;
  final String? amount;
  final String? session;
  final String? schoolId;
  final String? createBy;
  final String? createDate;
  final String? updateDate;
  final String? action;
  final String? daycareDurations;
  final List<String>? feeDuration;

  DaycareFeeRow({
    this.id,
    this.sadId,
    this.studentId,
    this.studentName,
    this.fatherName,
    this.feeTypeId,
    this.feeTypeName,
    this.totalHour,
    this.amount,
    this.session,
    this.schoolId,
    this.createBy,
    this.createDate,
    this.updateDate,
    this.action,
    this.daycareDurations,
    this.feeDuration,
  });

  factory DaycareFeeRow.fromJson(Map<String, dynamic> json) {
    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }


    List<String>? _asStringList(dynamic v) {
      if (v == null) return null;

      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }

      if (v is String) {
        final trimmed = v.trim();
        if (trimmed.isEmpty) return null;
        return trimmed.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      }

      return null;
    }

    return DaycareFeeRow(
      id: _asInt(json['id']),
      sadId: _asInt(json['sadId']),
      studentId: _asInt(json['studentId']),
      studentName: json['studentName']?.toString(),
      fatherName: json['fatherName']?.toString(),
      feeTypeId: _asInt(json['feeTypeId']),
      feeTypeName: json['feeTypeName']?.toString(),
      totalHour: json['totalHour']?.toString(),
      amount: json['amount']?.toString(),
      session: json['session']?.toString(),
      schoolId: json['schoolId']?.toString(),
      createBy: json['createBy']?.toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      action: json['action']?.toString(),
      daycareDurations: json['daycareDurations']?.toString(),
      feeDuration: _asStringList(json['feeDuration']),
    );
  }
}