class NotificationModel {
  List<ListData>? listData;

  NotificationModel({this.listData});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <ListData>[];
      json['listData'].forEach((v) {
        listData!.add(new ListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData != null) {
      data['listData'] = this.listData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListData {
  int? notificationId;
  String? title;
  String? message;
  String? notificationFile;
  String? createDate;
  String? updateDate;
  String? action;
  String? session;
  String? createBy;
  String? updateBy;
  String? schoolId;
  int? classId;
  int? sectionId;
  Null? type;
  Null? admissionNo;
  Null? teacherReg;
  Null? status;

  ListData(
      {this.notificationId,
      this.title,
      this.message,
      this.notificationFile,
      this.createDate,
      this.updateDate,
      this.action,
      this.session,
      this.createBy,
      this.updateBy,
      this.schoolId,
      this.classId,
      this.sectionId,
      this.type,
      this.admissionNo,
      this.teacherReg,
      this.status});

  ListData.fromJson(Map<String, dynamic> json) {
    notificationId = json['notificationId'];
    title = json['title'];
    message = json['message'];
    notificationFile = json['notificationFile'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    action = json['action'];
    session = json['session'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    type = json['type'];
    admissionNo = json['admissionNo'];
    teacherReg = json['teacherReg'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notificationId'] = this.notificationId;
    data['title'] = this.title;
    data['message'] = this.message;
    data['notificationFile'] = this.notificationFile;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['action'] = this.action;
    data['session'] = this.session;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['type'] = this.type;
    data['admissionNo'] = this.admissionNo;
    data['teacherReg'] = this.teacherReg;
    data['status'] = this.status;
    return data;
  }
}
