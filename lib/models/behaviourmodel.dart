class behaviouractivity {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<beData>? data;
  bool? showPopup;
  Null? popupMessage;

  behaviouractivity(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  behaviouractivity.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <beData>[];
      json['data'].forEach((v) {
        data!.add(new beData.fromJson(v));
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

class beData {
  int? behaviourId;
  String? behaviour;
  String? fromTime;
  String? toTime;
  String? action;
  String? createDate;
  Null? updateDate;
  String? createBy;
  Null? updateBy;
  String? schoolId;
  int? studentId;
  String? studentName;
  String? admissionNo;
  String? startTime;
  String? endTime;

  beData(
      {this.behaviourId,
      this.behaviour,
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
      this.admissionNo,
      this.startTime,
      this.endTime});

  beData.fromJson(Map<String, dynamic> json) {
    behaviourId = json['behaviourId'];
    behaviour = json['behaviour'];
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
    admissionNo = json['admissionNo'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['behaviourId'] = this.behaviourId;
    data['behaviour'] = this.behaviour;
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
    data['admissionNo'] = this.admissionNo;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    return data;
  }
}