class activitystudent {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<Data>? data;
  bool? showPopup;
  Null? popupMessage;

  activitystudent(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  activitystudent.fromJson(Map<String, dynamic> json) {
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
  int? activityId;
  String? activity;
  String? fromTime;
  String? toTime;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;
  int? studentId;
  String? studentName;
  String? startTime;
  String? endTime;
  String? session;

  Data(
      {this.activityId,
      this.activity,
      this.fromTime,
      this.toTime,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId,
      this.studentId,
      this.studentName,
      this.startTime,
      this.endTime,
      this.session});

  Data.fromJson(Map<String, dynamic> json) {
    activityId = json['activityId'];
    activity = json['activity'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
    studentId = json['studentId'];
    studentName = json['studentName'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    session = json['session'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activityId'] = this.activityId;
    data['activity'] = this.activity;
    data['fromTime'] = this.fromTime;
    data['toTime'] = this.toTime;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    data['studentId'] = this.studentId;
    data['studentName'] = this.studentName;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['session'] = this.session;
    return data;
  }
}