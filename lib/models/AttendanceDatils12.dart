class AttendanceDatils12 {
  List<AttendanceDatils12Data>? listData;

  AttendanceDatils12({this.listData});

  AttendanceDatils12.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <AttendanceDatils12Data>[];
      json['listData'].forEach((v) {
        listData!.add(AttendanceDatils12Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (listData != null) {
      data['listData'] = listData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AttendanceDatils12Data {
  int? sadid;
  int? studentId;
  String? studentName;
  String? session;
  String? userAttandance;
  String? createDate;
  String? updateDate;
  String? action;
  int? months;
  dynamic days;
  String? adate;
  String? schoolId;
  String? fromTime;
  String? toTime;
  String? status;
  String? totalHour;

  AttendanceDatils12Data({
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

  AttendanceDatils12Data.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = {};
    data['sadid'] = sadid;
    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['session'] = session;
    data['userAttandance'] = userAttandance;
    data['createDate'] = createDate;
    data['updateDate'] = updateDate;
    data['action'] = action;
    data['months'] = months;
    data['days'] = days;
    data['adate'] = adate;
    data['schoolId'] = schoolId;
    data['fromTime'] = fromTime;
    data['toTime'] = toTime;
    data['status'] = status;
    data['totalHour'] = totalHour;
    return data;
  }
}