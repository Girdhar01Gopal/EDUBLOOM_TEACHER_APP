class MapFoundationalSkillsResponse {
  final int? statusCode;
  final bool? isSuccess;
  final dynamic messages;
  final List<FoundationalSkillData> data;
  final bool? showPopup;
  final dynamic popupMessage;

  MapFoundationalSkillsResponse({
    this.statusCode,
    this.isSuccess,
    this.messages,
    required this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory MapFoundationalSkillsResponse.fromJson(Map<String, dynamic> json) {
    return MapFoundationalSkillsResponse(
      statusCode: json['statusCode'] is int
          ? json['statusCode']
          : int.tryParse(json['statusCode']?.toString() ?? ''),
      isSuccess: json['isSuccess'] == true,
      messages: json['messages'],
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FoundationalSkillData.fromJson(e as Map<String, dynamic>))
          .toList() ??
          <FoundationalSkillData>[],
      showPopup: json['showPopup'] == true,
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "isSuccess": isSuccess,
    "messages": messages,
    "data": data.map((e) => e.toJson()).toList(),
    "showPopup": showPopup,
    "popupMessage": popupMessage,
  };
}

class FoundationalSkillData {
  final int? id;
  final int? classId;
  final String? className;
  final int? sectionId;     // ✅ NEW
  final String? section;    // ✅ NEW
  final String? foundationalSkills;
  final String? action;
  final DateTime? createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;
  final String? level;
  final String? session;    // ✅ NEW

  FoundationalSkillData({
    this.id,
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.foundationalSkills,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.level,
    this.session,
  });

  factory FoundationalSkillData.fromJson(Map<String, dynamic> json) {
    return FoundationalSkillData(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      classId: json['classId'] is int
          ? json['classId']
          : int.tryParse(json['classId']?.toString() ?? ''),
      className: json['className']?.toString(),
      sectionId: json['sectionId'] is int
          ? json['sectionId']
          : int.tryParse(json['sectionId']?.toString() ?? ''),
      section: json['section']?.toString(),
      foundationalSkills: json['foundationalSkills']?.toString(),
      action: json['action']?.toString(),
      createDate: json['createDate'] != null &&
          json['createDate'].toString().trim().isNotEmpty
          ? DateTime.tryParse(json['createDate'].toString())
          : null,
      updateDate: json['updateDate'] != null &&
          json['updateDate'].toString().trim().isNotEmpty
          ? DateTime.tryParse(json['updateDate'].toString())
          : null,
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      schoolId: json['schoolId']?.toString(),
      level: json['level']?.toString(),
      session: json['session']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "classId": classId,
    "className": className,
    "sectionId": sectionId,
    "section": section,
    "foundationalSkills": foundationalSkills,
    "action": action,
    "createDate": createDate?.toIso8601String(),
    "updateDate": updateDate?.toIso8601String(),
    "createBy": createBy,
    "updateBy": updateBy,
    "schoolId": schoolId,
    "level": level,
    "session": session,
  };
}