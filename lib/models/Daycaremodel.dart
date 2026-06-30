class DaycareStudentModel {
  List<ListdData>? listData;

  DaycareStudentModel({this.listData});

  DaycareStudentModel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <ListdData>[];
      json['listData'].forEach((v) {
        listData!.add(new ListdData.fromJson(v));
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

class ListdData {
  int? studentID;
  String? studentName;
  String? fatherName;
  String? motherName;
  Null? classId;
  Null? sectionId;
  Null? className;
  Null? sectionName;
  String? createDate;
  String? session;
  String? action;
  String? schoolId;
  String? fatherPhone;
  String? registrationNo;
  Null? playAmount;

  ListdData(
      {this.studentID,
      this.studentName,
      this.fatherName,
      this.motherName,
      this.classId,
      this.sectionId,
      this.className,
      this.sectionName,
      this.createDate,
      this.session,
      this.action,
      this.schoolId,
      this.fatherPhone,
      this.registrationNo,
      this.playAmount});

  ListdData.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    studentName = json['studentName'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    className = json['className'];
    sectionName = json['sectionName'];
    createDate = json['createDate'];
    session = json['session'];
    action = json['action'];
    schoolId = json['schoolId'];
    fatherPhone = json['fatherPhone'];
    registrationNo = json['registrationNo'];
    playAmount = json['playAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentID'] = this.studentID;
    data['studentName'] = this.studentName;
    data['fatherName'] = this.fatherName;
    data['motherName'] = this.motherName;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['className'] = this.className;
    data['sectionName'] = this.sectionName;
    data['createDate'] = this.createDate;
    data['session'] = this.session;
    data['action'] = this.action;
    data['schoolId'] = this.schoolId;
    data['fatherPhone'] = this.fatherPhone;
    data['registrationNo'] = this.registrationNo;
    data['playAmount'] = this.playAmount;
    return data;
  }
}