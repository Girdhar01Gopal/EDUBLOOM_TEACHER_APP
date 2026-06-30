class TCTransferCertificateModel {
  List<TCStudentData>? listData;

  TCTransferCertificateModel({this.listData});

  factory TCTransferCertificateModel.fromJson(Map<String, dynamic> json) {
    return TCTransferCertificateModel(
      listData: json['listData'] != null
          ? List<TCStudentData>.from(
          json['listData'].map((v) => TCStudentData.fromJson(v)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData?.map((v) => v.toJson()).toList(),
    };
  }
}

class TCStudentData {
  int? studentID;
  String? studentName;
  String? fatherName;
  String? motherName;
  int? classId;
  int? sectionId;
  String? className;
  String? sectionName;
  String? createDate;
  String? session;
  String? action;
  String? schoolId;
  String? fatherPhone;
  String? registrationNo;
  dynamic playAmount;

  TCStudentData({
    this.studentID,
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
    this.playAmount,
  });

  factory TCStudentData.fromJson(Map<String, dynamic> json) {
    return TCStudentData(
      studentID: json['studentID'],
      studentName: json['studentName'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      classId: json['classId'],
      sectionId: json['sectionId'],
      className: json['className'],
      sectionName: json['sectionName'],
      createDate: json['createDate'],
      session: json['session'],
      action: json['action'],
      schoolId: json['schoolId'],
      fatherPhone: json['fatherPhone'],
      registrationNo: json['registrationNo'],
      playAmount: json['playAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'studentName': studentName,
      'fatherName': fatherName,
      'motherName': motherName,
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'sectionName': sectionName,
      'createDate': createDate,
      'session': session,
      'action': action,
      'schoolId': schoolId,
      'fatherPhone': fatherPhone,
      'registrationNo': registrationNo,
      'playAmount': playAmount,
    };
  }
}