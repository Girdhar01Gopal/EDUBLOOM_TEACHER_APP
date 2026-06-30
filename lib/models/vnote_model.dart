class VNoteModel {
  List<Dataa>? listData;

  VNoteModel({this.listData});

  VNoteModel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <Dataa>[];
      json['listData'].forEach((v) {
        listData!.add(new Dataa.fromJson(v));
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

class Dataa {
  int? nid;
  int? classId;
  int? sectionId;
  int? subjectId;
  String? session;
  String? remarks;
  String? notesFile;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  Dataa(
      {this.nid,
      this.classId,
      this.sectionId,
      this.subjectId,
      this.session,
      this.remarks,
      this.notesFile,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId});

  Dataa.fromJson(Map<String, dynamic> json) {
    nid = json['nid'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    subjectId = json['subjectId'];
    session = json['session'];
    remarks = json['remarks'];
    notesFile = json['notesFile'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nid'] = this.nid;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['subjectId'] = this.subjectId;
    data['session'] = this.session;
    data['remarks'] = this.remarks;
    data['notesFile'] = this.notesFile;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}