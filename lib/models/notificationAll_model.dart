class NotificationAllModel {
  int? statusCode;
  bool? isSuccess;
  Null? messages;
  List<Data>? data;

  NotificationAllModel(
      {this.statusCode, this.isSuccess, this.messages, this.data});

  NotificationAllModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['isSuccess'] = this.isSuccess;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? notificationID;
  String? tittle;
  String? message;
  int? classId;
  int? sectionId;
  String? className;
  String? sectionName;
  String? session;
  String? createDate;
  String? createBy;
  Null? updateDate;
  Null? updateBy;
  String? action;
  String? notificationfile;
  String? schoolId;

  Data(
      {this.notificationID,
      this.tittle,
      this.message,
      this.classId,
      this.sectionId,
      this.className,
      this.sectionName,
      this.session,
      this.createDate,
      this.createBy,
      this.updateDate,
      this.updateBy,
      this.action,
      this.notificationfile,
      this.schoolId});

  Data.fromJson(Map<String, dynamic> json) {
    notificationID = json['notificationID'];
    tittle = json['tittle'];
    message = json['message'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    className = json['className'];
    sectionName = json['sectionName'];
    session = json['session'];
    createDate = json['createDate'];
    createBy = json['createBy'];
    updateDate = json['updateDate'];
    updateBy = json['updateBy'];
    action = json['action'];
    notificationfile = json['notificationfile'];
    schoolId = json['schoolId'];
  }

  get subjectName => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notificationID'] = this.notificationID;
    data['tittle'] = this.tittle;
    data['message'] = this.message;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['className'] = this.className;
    data['sectionName'] = this.sectionName;
    data['session'] = this.session;
    data['createDate'] = this.createDate;
    data['createBy'] = this.createBy;
    data['updateDate'] = this.updateDate;
    data['updateBy'] = this.updateBy;
    data['action'] = this.action;
    data['notificationfile'] = this.notificationfile;
    data['schoolId'] = this.schoolId;
    return data;
  }
}
