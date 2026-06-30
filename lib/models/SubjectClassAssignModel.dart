class SubjectClassAssignModel {
  int? statusCode;
  bool? isSuccess;
  List<String>? messages;
  List<SubjectClassAssignData>? data;
  bool? showPopup;
  String? popupMessage;

  SubjectClassAssignModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  SubjectClassAssignModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];

    if (json['messages'] != null) {
      messages = List<String>.from(json['messages']);
    }

    if (json['data'] != null) {
      data = <SubjectClassAssignData>[];
      json['data'].forEach((v) {
        data!.add(SubjectClassAssignData.fromJson(v));
      });
    }

    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['isSuccess'] = isSuccess;
    data['messages'] = messages;

    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }

    data['showPopup'] = showPopup;
    data['popupMessage'] = popupMessage;

    return data;
  }
}

class SubjectClassAssignData {
  int? id;
  int? classId;
  String? className;
  int? subjectId;
  String? subjectName;
  int? sectionId;
  String? sectionName;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  SubjectClassAssignData({
    this.id,
    this.classId,
    this.className,
    this.subjectId,
    this.subjectName,
    this.sectionId,
    this.sectionName,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
  });

  SubjectClassAssignData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    classId = json['classId'];
    className = json['className'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['classId'] = classId;
    data['className'] = className;
    data['subjectId'] = subjectId;
    data['subjectName'] = subjectName;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['action'] = action;
    data['createDate'] = createDate;
    data['updateDate'] = updateDate;
    data['createBy'] = createBy;
    data['updateBy'] = updateBy;
    data['schoolId'] = schoolId;
    return data;
  }
}