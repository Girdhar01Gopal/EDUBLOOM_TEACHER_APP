class SubjectResponse {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<SubjectData>? data;
  bool? showPopup;
  String? popupMessage;

  SubjectResponse({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  SubjectResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <SubjectData>[];
      (json['data'] as List).forEach((v) {
        data!.add(SubjectData.fromJson(v));
      });
    }
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['statusCode'] = statusCode;
    dataMap['isSuccess'] = isSuccess;
    dataMap['messages'] = messages;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    dataMap['showPopup'] = showPopup;
    dataMap['popupMessage'] = popupMessage;
    return dataMap;
  }
}

class SubjectData {
  int? id;
  int? classId;
  String? className;
  int? sectionId;       // ✅ NEW
  String? section;      // ✅ NEW
  String? session;      // ✅ NEW
  int? subjectId;
  String? subjectName;  // kept for old compat
  String? subject;      // ✅ NEW — API returns "subject" not "subjectName"
  String? descriptors;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;
  dynamic grade;

  SubjectData({
    this.id,
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.session,
    this.subjectId,
    this.subjectName,
    this.subject,
    this.descriptors,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.grade,
  });

  SubjectData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    classId = json['classId'];
    className = json['className'];
    sectionId = json['sectionId'];
    section = json['section']?.toString();
    session = json['session']?.toString();
    subjectId = json['subjectId'];
    subjectName = json['subjectName']?.toString();
    subject = json['subject']?.toString();
    descriptors = json['descriptors']?.toString();
    action = json['action']?.toString();
    createDate = json['createDate']?.toString();
    updateDate = json['updateDate']?.toString();
    createBy = json['createBy']?.toString();
    updateBy = json['updateBy']?.toString();
    schoolId = json['schoolId']?.toString();
    grade = json['grade'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'sectionId': sectionId,
      'section': section,
      'session': session,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subject': subject,
      'descriptors': descriptors,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'grade': grade,
    };
  }
}