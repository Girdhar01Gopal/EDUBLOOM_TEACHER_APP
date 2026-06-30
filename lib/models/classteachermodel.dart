class classteachermodel {
  int? statusCode;
  bool? isSuccess;
  Null? messages;
  List<Data>? data;
  bool? showPopup;
  Null? popupMessage;

  classteachermodel(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  classteachermodel.fromJson(Map<String, dynamic> json) {
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
  int? id;
  int? userId;
  String? regrationNo;
  String? name;
  String? session;
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  String? action;
  String? createDate;
  Null? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  Data(
      {this.id,
      this.userId,
      this.regrationNo,
      this.name,
      this.session,
      this.classId,
      this.className,
      this.sectionId,
      this.sectionName,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    regrationNo = json['regrationNo'];
    name = json['name'];
    session = json['session'];
    classId = json['classId'];
    className = json['className'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['regrationNo'] = this.regrationNo;
    data['name'] = this.name;
    data['session'] = this.session;
    data['classId'] = this.classId;
    data['className'] = this.className;
    data['sectionId'] = this.sectionId;
    data['sectionName'] = this.sectionName;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}