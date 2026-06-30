class sectionmodel {
  List<stListData>? listData;
  Null? currentSession;

  sectionmodel({this.listData, this.currentSession});

  sectionmodel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <stListData>[];
      json['listData'].forEach((v) {
        listData!.add(new stListData.fromJson(v));
      });
    }
    currentSession = json['currentSession'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData != null) {
      data['listData'] = this.listData!.map((v) => v.toJson()).toList();
    }
    data['currentSession'] = this.currentSession;
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