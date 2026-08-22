class sectionmodel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<stListData>? listData;
  bool? showPopup;
  String? popupMessage;

  sectionmodel(
      {this.statusCode,
        this.isSuccess,
        this.messages,
        this.listData,
        this.showPopup,
        this.popupMessage});

  sectionmodel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      listData = <stListData>[];
      json['data'].forEach((v) {
        listData!.add(new stListData.fromJson(v));
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

class stListData {
  int? sectionId;
  String? section;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  stListData(
      {this.sectionId,
        this.section,
        this.action,
        this.createDate,
        this.updateDate,
        this.createBy,
        this.updateBy,
        this.schoolId});

  stListData.fromJson(Map<String, dynamic> json) {
    sectionId = json['sectionId'];
    section = json['section'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sectionId'] = this.sectionId;
    data['section'] = this.section;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}