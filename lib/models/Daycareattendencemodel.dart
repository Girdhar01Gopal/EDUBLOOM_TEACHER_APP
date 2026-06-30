class daycareattendance {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<dListData>? data;

  daycareattendance({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
  });

  daycareattendance.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];

    if (json['data'] != null) {
      data = <dListData>[];
      json['data'].forEach((v) {
        data!.add(dListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['statusCode'] = statusCode;
    dataMap['isSuccess'] = isSuccess;
    dataMap['messages'] = messages;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class dListData {
  int? studentID;
  String? studentName;
  String? action;
  String? fromTime;
  String? toTime;

  dListData({
    this.studentID,
    this.studentName,
    this.action,
    this.fromTime,
    this.toTime,
  });

  dListData.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    studentName = json['studentName'];
    action = json['action'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['studentID'] = studentID;
    dataMap['studentName'] = studentName;
    dataMap['action'] = action;
    dataMap['fromTime'] = fromTime;
    dataMap['toTime'] = toTime;
    return dataMap;
  }
}
