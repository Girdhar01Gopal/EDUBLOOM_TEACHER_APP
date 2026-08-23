// Model for: api/TeacherApp/SectionTeacher
// Response example:
// {
//   "statusCode": 0,
//   "isSuccess": false,
//   "messages": null,
//   "data": [
//     {
//       "sectionId": 373,
//       "section": "A",
//       "action": null,
//       "createDate": null,
//       "updateDate": null,
//       "createBy": null,
//       "updateBy": null,
//       "schoolId": null
//     }
//   ],
//   "showPopup": false,
//   "popupMessage": null
// }

class SectionForAttendanceModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<SectionForAttendanceData>? data;
  bool? showPopup;
  String? popupMessage;

  SectionForAttendanceModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory SectionForAttendanceModel.fromJson(Map<String, dynamic> json) {
    return SectionForAttendanceModel(
      statusCode: json['statusCode'],
      isSuccess: json['isSuccess'],
      messages: json['messages'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => SectionForAttendanceData.fromJson(e))
          .toList()
          : [],
      showPopup: json['showPopup'],
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data?.map((e) => e.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class SectionForAttendanceData {
  int? sectionId;
  String? section;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  SectionForAttendanceData({
    this.sectionId,
    this.section,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
  });

  factory SectionForAttendanceData.fromJson(Map<String, dynamic> json) {
    return SectionForAttendanceData(
      sectionId: json['sectionId'],
      section: json['section'],
      action: json['action'],
      createDate: json['createDate'],
      updateDate: json['updateDate'],
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionId': sectionId,
      'section': section,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }
}