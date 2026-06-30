class FoundationalSkillsResponse {
  List<FoundationalSkillItem> listData;
  dynamic currentSession;

  FoundationalSkillsResponse({
    required this.listData,
    this.currentSession,
  });

  factory FoundationalSkillsResponse.fromJson(Map<String, dynamic> json) {
    return FoundationalSkillsResponse(
      listData: json['listData'] != null
          ? (json['listData'] as List)
          .map((e) => FoundationalSkillItem.fromJson(e))
          .toList()
          : [],
      currentSession: json['currentSession'],
    );
  }

  Map<String, dynamic> toJson() => {
    'listData': listData.map((e) => e.toJson()).toList(),
    'currentSession': currentSession,
  };
}

class FoundationalSkillItem {
  int id;
  String foundationalSkills;
  String action;
  DateTime createDate;
  DateTime? updateDate;
  String createBy;
  String? updateBy;
  String schoolId;
  String? session;
  dynamic sqno;

  FoundationalSkillItem({
    required this.id,
    required this.foundationalSkills,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
    this.session,
    this.sqno,
  });

  factory FoundationalSkillItem.fromJson(Map<String, dynamic> json) {
    return FoundationalSkillItem(
      id: json['id'] ?? 0,
      foundationalSkills: json['foundationalSkills']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      createDate: json['createDate'] != null
          ? DateTime.parse(json['createDate'])
          : DateTime.now(),
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : null,
      createBy: json['createBy']?.toString() ?? '',
      updateBy: json['updateBy']?.toString(),
      schoolId: json['schoolId']?.toString() ?? '',
      session: json['session']?.toString(),
      sqno: json['sqno'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'foundationalSkills': foundationalSkills,
    'action': action,
    'createDate': createDate.toIso8601String(),
    'updateDate': updateDate?.toIso8601String(),
    'createBy': createBy,
    'updateBy': updateBy,
    'schoolId': schoolId,
    'session': session,
    'sqno': sqno,
  };
}