class Attendetail11 {
  int? statusCode;
  bool? isSuccess;
  List<String>? messages;
  List<Attendetail11Data>? data;
  bool? showPopup;
  String? popupMessage;

  Attendetail11({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  Attendetail11.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'] != null ? List<String>.from(json['messages']) : null;

    if (json['data'] != null) {
      data = <Attendetail11Data>[];
      json['data'].forEach((v) {
        data!.add(Attendetail11Data.fromJson(v));
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

class Attendetail11Data {
  int? sadid;
  int? studentId;
  String? studentName;
  String? session;
  String? userAttandance;
  String? createDate;
  String? updateDate;
  String? action;
  int? months;
  String? days;
  String? adate;
  String? schoolId;
  String? fromTime;
  String? toTime;
  String? status;
  String? totalHour;

  Attendetail11Data({
    this.sadid,
    this.studentId,
    this.studentName,
    this.session,
    this.userAttandance,
    this.createDate,
    this.updateDate,
    this.action,
    this.months,
    this.days,
    this.adate,
    this.schoolId,
    this.fromTime,
    this.toTime,
    this.status,
    this.totalHour,
  });

  Attendetail11Data.fromJson(Map<String, dynamic> json) {
    sadid = json['sadid'];
    studentId = json['studentId'];
    studentName = json['studentName'];
    session = json['session'];
    userAttandance = json['userAttandance'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    action = json['action'];
    months = json['months'];
    days = json['days'];
    adate = json['adate'];
    schoolId = json['schoolId'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
    status = json['status'];
    totalHour = json['totalHour'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['sadid'] = sadid;
    dataMap['studentId'] = studentId;
    dataMap['studentName'] = studentName;
    dataMap['session'] = session;
    dataMap['userAttandance'] = userAttandance;
    dataMap['createDate'] = createDate;
    dataMap['updateDate'] = updateDate;
    dataMap['action'] = action;
    dataMap['months'] = months;
    dataMap['days'] = days;
    dataMap['adate'] = adate;
    dataMap['schoolId'] = schoolId;
    dataMap['fromTime'] = fromTime;
    dataMap['toTime'] = toTime;
    dataMap['status'] = status;
    dataMap['totalHour'] = totalHour;
    return dataMap;
  }
}