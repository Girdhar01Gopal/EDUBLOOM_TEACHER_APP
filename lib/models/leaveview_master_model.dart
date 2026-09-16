class LeaveModel {
  final int id; // leaveId
  final String leave;
  final String action; // "1" = Active, "0" = Inactive
  final DateTime? createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;

  LeaveModel({
    required this.id,
    required this.leave,
    required this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
  });

  // ✅ Handles both POST response ("data": {...}) and GET list item shape
  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['leaveId'] is int
          ? json['leaveId']
          : int.tryParse(json['leaveId']?.toString() ?? '0') ?? 0,
      leave: json['leave']?.toString() ?? "",
      action: json['action']?.toString() ?? "1",
      createDate: _parseDate(json['createDate']),
      updateDate: _parseDate(json['updateDate']),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      schoolId: json['schoolId']?.toString(),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (str.isEmpty || str.toLowerCase() == 'null') return null;
    return DateTime.tryParse(str);
  }

  // ✅ Body for AddLeave / UpdateLeave POST call
  Map<String, dynamic> toJson() {
    return {
      "leaveId": id,
      "leave": leave,
      "action": action,
      "createDate": createDate?.toIso8601String(),
      "updateDate": updateDate?.toIso8601String(),
      "createBy": createBy,
      "updateBy": updateBy,
      "schoolId": schoolId,
    };
  }

  LeaveModel copyWith({
    int? id,
    String? leave,
    String? action,
    DateTime? createDate,
    DateTime? updateDate,
    String? createBy,
    String? updateBy,
    String? schoolId,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      leave: leave ?? this.leave,
      action: action ?? this.action,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      createBy: createBy ?? this.createBy,
      updateBy: updateBy ?? this.updateBy,
      schoolId: schoolId ?? this.schoolId,
    );
  }

  // ✅ Handles the { "listData": [...] } wrapper returned by ViewLeave API,
  // and also plain lists / single maps just in case.
  static List<LeaveModel> fromJsonList(dynamic jsonRes) {
    List rawList = [];

    if (jsonRes is Map<String, dynamic>) {
      if (jsonRes['listData'] is List) {
        rawList = jsonRes['listData'] as List;
      } else if (jsonRes['data'] is List) {
        rawList = jsonRes['data'] as List;
      } else if (jsonRes['data'] is Map<String, dynamic>) {
        rawList = [jsonRes['data']];
      }
    } else if (jsonRes is List) {
      rawList = jsonRes;
    }

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => LeaveModel.fromJson(e))
        .toList();
  }
}