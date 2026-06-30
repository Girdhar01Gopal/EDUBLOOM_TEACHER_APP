class StaffTypeResponse {
  final List<StaffType> listData;
  final dynamic currentSession;

  const StaffTypeResponse({
    required this.listData,
    this.currentSession,
  });

  factory StaffTypeResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['listData'];
    return StaffTypeResponse(
      listData: (rawList is List)
          ? rawList
              .whereType<Map<String, dynamic>>()
              .map(StaffType.fromJson)
              .toList()
          : <StaffType>[],
      currentSession: json['currentSession'],
    );
  }

  Map<String, dynamic> toJson() => {
        'listData': listData.map((e) => e.toJson()).toList(),
        'currentSession': currentSession,
      };
}

class StaffType {
  final int staffTypeId;
  final String staffType;
  final String? action;
  final String? createDate;
  final String? updateDate;
  final String? schoolId;
  final String? createBy;

  const StaffType({
    required this.staffTypeId,
    required this.staffType,
    this.action,
    this.createDate,
    this.updateDate,
    this.schoolId,
    this.createBy,
  });

  factory StaffType.fromJson(Map<String, dynamic> json) {
    return StaffType(
      staffTypeId: (json['staffTypeId'] is int)
          ? json['staffTypeId'] as int
          : int.tryParse('${json['staffTypeId']}') ?? 0,
      staffType: (json['staffType'] ?? '').toString(),
      action: json['action']?.toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      schoolId: json['schoolId']?.toString(),
      createBy: json['createBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'staffTypeId': staffTypeId,
        'staffType': staffType,
        'action': action,
        'createDate': createDate,
        'updateDate': updateDate,
        'schoolId': schoolId,
        'createBy': createBy,
      };
}
