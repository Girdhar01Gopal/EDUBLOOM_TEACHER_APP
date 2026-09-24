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

    // 🆕 Naya ViewNotificationApp (test server) response seedha
    // 'listData' key ke andar array deta hai (statusCode/isSuccess
    // wrapper ke bina). Purana 'data' wrapper bhi support kiya hai
    // taaki koi purani API kabhi use ho to na tute.
    final rawList = json['listData'] ?? json['data'];
    if (rawList != null) {
      data = <Data>[];
      (rawList as List).forEach((v) {
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

  String? updateDate;
  String? updateBy;

  String? action;
  String? notificationfile;
  String? schoolId;

  // 🆕 Naye ViewNotificationApp response ke extra fields — abhi UI me
  // use nahi ho rahe, future ke liye rakhe gaye hain.
  dynamic type;
  dynamic admissionNo;
  dynamic teacherReg;
  dynamic status;
  int? userId;
  String? roleName;

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
        this.schoolId,
        this.type,
        this.admissionNo,
        this.teacherReg,
        this.status,
        this.userId,
        this.roleName});

  Data.fromJson(Map<String, dynamic> json) {
    // 🆕 Naya API 'notificationId' / 'title' / 'notificationFile' bhejta
    // hai (camelCase), purana 'notificationID' / 'tittle' /
    // 'notificationfile' — dono support kiya hai.
    notificationID = json['notificationId'] ?? json['notificationID'];
    tittle = json['title'] ?? json['tittle'];
    message = json['message'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    // 🆕 Naya API className/sectionName nahi bhejta — ye null hi
    // rahenge jab tak controller classList/sectionList se fill na kare.
    className = json['className'];
    sectionName = json['sectionName'];
    session = json['session'];
    createDate = json['createDate'];
    createBy = json['createBy'];
    // .toString() safety-net kept intentionally in case backend ever sends
    // a non-string (e.g. int/DateTime-like) value for these fields again.
    updateDate = json['updateDate']?.toString();
    updateBy = json['updateBy']?.toString();
    action = json['action'];
    notificationfile = json['notificationFile'] ?? json['notificationfile'];
    schoolId = json['schoolId'];

    type = json['type'];
    admissionNo = json['admissionNo'];
    teacherReg = json['teacherReg'];
    status = json['status'];
    userId = json['userId'];
    roleName = json['roleName'];
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
    data['type'] = this.type;
    data['admissionNo'] = this.admissionNo;
    data['teacherReg'] = this.teacherReg;
    data['status'] = this.status;
    data['userId'] = this.userId;
    data['roleName'] = this.roleName;
    return data;
  }
}