class HomeworkModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<Data>? data;
  bool? showPopup;
  Null? popupMessage;

  HomeworkModel(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  HomeworkModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['isSuccess'] = this.isSuccess;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['showPopup'] = this.showPopup;
    data['popupMessage'] = this.popupMessage;
    return data;
  }
}

class Data {
  int? homeworkId;
  int? subjectId;
  String? subjectName;
  int? classId;
  int? sectionId;
  String? className;
  String? sectionName;
  String? session;
  String? remarks;
  String? homeworkFile;
  String? action;
  String? createDate;
  Null? updateDate;
  String? createBy;
  Null? updateBy;
  String? schoolId;

  Data(
      {this.homeworkId,
      this.subjectId,
      this.subjectName,
      this.classId,
      this.sectionId,
      this.className,
      this.sectionName,
      this.session,
      this.remarks,
      this.homeworkFile,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId});

  Data.fromJson(Map<String, dynamic> json) {
    homeworkId = json['homeworkId'];
    subjectId = json['subjectId'];
    subjectName = json['subjectName'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    className = json['className'];
    sectionName = json['sectionName'];
    session = json['session'];
    remarks = json['remarks'];
    homeworkFile = json['homeworkFile'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['homeworkId'] = this.homeworkId;
    data['subjectId'] = this.subjectId;
    data['subjectName'] = this.subjectName;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['className'] = this.className;
    data['sectionName'] = this.sectionName;
    data['session'] = this.session;
    data['remarks'] = this.remarks;
    data['homeworkFile'] = this.homeworkFile;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}