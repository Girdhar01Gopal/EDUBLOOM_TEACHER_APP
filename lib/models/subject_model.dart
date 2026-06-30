class SubjectModel {
  List<ListDaataa>? listData;
  String? currentSession;

  SubjectModel({this.listData, this.currentSession});

  SubjectModel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <ListDaataa>[];
      json['listData'].forEach((v) {
        listData!.add(new ListDaataa.fromJson(v));
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
