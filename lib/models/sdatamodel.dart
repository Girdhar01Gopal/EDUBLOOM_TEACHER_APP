class SData {
  final int? studentID;
  final String? studentName;
  final String? fatherName;
  final String? motherName;
  final int? classId;
  final int? sectionId;
  final String? className;
  final String? sectionName;
  final String? createDate;
  final String? session;
  final String? action;
  final String? schoolId;
  final String? fatherPhone;
  final String? registrationNo;
  final String? playAmount;

  SData({
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

  factory SData.fromJson(Map<String, dynamic> json) {
    return SData(
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
