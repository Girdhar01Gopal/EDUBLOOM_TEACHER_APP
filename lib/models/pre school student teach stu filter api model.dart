// ClassTeacher Filter Model
class ClassTeacherFilterModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<ClassTeacherFilterData>? data;
  bool? showPopup;
  String? popupMessage;

  ClassTeacherFilterModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory ClassTeacherFilterModel.fromJson(Map<String, dynamic> json) {
    return ClassTeacherFilterModel(
      statusCode: json['statusCode'],
      isSuccess: json['isSuccess'],
      messages: json['messages'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => ClassTeacherFilterData.fromJson(e))
          .toList()
          : [],
      showPopup: json['showPopup'],
      popupMessage: json['popupMessage'],
    );
  }
}

class ClassTeacherFilterData {
  int? classId;
  String? className;
  String? studentClassId;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;
  int? sqno;

  ClassTeacherFilterData({
    this.classId,
    this.className,
    this.studentClassId,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.sqno,
  });

  factory ClassTeacherFilterData.fromJson(Map<String, dynamic> json) {
    return ClassTeacherFilterData(
      classId: json['classId'],
      className: json['class'],
      studentClassId: json['studentClassId']?.toString(),
      action: json['action'],
      createDate: json['createDate'],
      updateDate: json['updateDate'],
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
      sqno: json['sqno'],
    );
  }
}