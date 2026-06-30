class SubjectProgressResponse {
  List<SubjectProgressItem> listData;
  String? currentSession;

  SubjectProgressResponse({
    required this.listData,
    this.currentSession,
  });

  factory SubjectProgressResponse.fromJson(Map<String, dynamic> json) {
    return SubjectProgressResponse(
      listData: json['listData'] != null
          ? (json['listData'] as List)
          .map((e) => SubjectProgressItem.fromJson(e))
          .toList()
          : <SubjectProgressItem>[],
      currentSession: json['currentSession']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'listData': listData.map((e) => e.toJson()).toList(),
    'currentSession': currentSession,
  };
}

class SubjectProgressItem {
  int? subjectProgressId;
  String? descriptors;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;
  String? session;

  SubjectProgressItem({
    this.subjectProgressId,
    this.descriptors,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.session,
  });

  factory SubjectProgressItem.fromJson(Map<String, dynamic> json) {
    return SubjectProgressItem(
      subjectProgressId: json['subjectProgressId'] as int?,
      descriptors: json['descriptors']?.toString(),
      action: json['action']?.toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      schoolId: json['schoolId']?.toString(),
      session: json['session']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'subjectProgressId': subjectProgressId,
    'descriptors': descriptors,
    'action': action,
    'createDate': createDate,
    'updateDate': updateDate,
    'createBy': createBy,
    'updateBy': updateBy,
    'schoolId': schoolId,
    'session': session,
  };
}