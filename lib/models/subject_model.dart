class SubjectModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<ListDaataa>? listData;
  bool? showPopup;
  String? popupMessage;

  SubjectModel(
      {this.statusCode,
        this.isSuccess,
        this.messages,
        this.listData,
        this.showPopup,
        this.popupMessage});

  SubjectModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      listData = <ListDaataa>[];
      json['data'].forEach((v) {
        listData!.add(new ListDaataa.fromJson(v));
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
    if (this.listData != null) {
      data['data'] = this.listData!.map((v) => v.toJson()).toList();
    }
    data['showPopup'] = this.showPopup;
    data['popupMessage'] = this.popupMessage;
    return data;
  }
}

class ListDaataa {
  int? subjectId;
  String? subject;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  ListDaataa(
      {this.subjectId,
        this.subject,
        this.action,
        this.createDate,
        this.updateDate,
        this.createBy,
        this.updateBy,
        this.schoolId});

  ListDaataa.fromJson(Map<String, dynamic> json) {
    subjectId = json['subjectId'];
    subject = json['subject'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subjectId'] = this.subjectId;
    data['subject'] = this.subject;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}