class mealactivity {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<MData>? data;
  bool? showPopup;
  Null? popupMessage;

  mealactivity(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  mealactivity.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <MData>[];
      json['data'].forEach((v) {
        data!.add(new MData.fromJson(v));
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

class MData {
  int? mealId;
  String? meal;
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

  MData(
      {this.mealId,
      this.meal,
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

  MData.fromJson(Map<String, dynamic> json) {
    mealId = json['mealId'];
    meal = json['meal'];
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
    data['mealId'] = this.mealId;
    data['meal'] = this.meal;
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