class attendencestudent {
  List<ListData>? listData;

  attendencestudent({this.listData});

  attendencestudent.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <ListData>[];
      json['listData'].forEach((v) {
        listData!.add(new ListData.fromJson(v));
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

class ListData {
  int? studentID;
  Null? sadId;
  String? studentName;
  Null? gender;
  String? fatherName;
  String? motherName;
  Null? fatherOccupation;
  Null? dateOfBirth;
  int? classId;
  int? sectionId;
  String? className;
  String? sectionName;
  Null? rollNo;
  Null? bloodGroup;
  Null? religion;
  Null? admissionDate;
  Null? parentId;
  Null? phone;
  Null? whatsAppNo;
  Null? emergencyNo;
  Null? createDate;
  Null? email;
  Null? updateBy;
  Null? session;
  Null? ppassword;
  Null? registrationNo;
  String? action;
  Null? studentPic;
  Null? fatherPic;
  Null? motherPic;
  Null? guardianImage;
  Null? startTime;
  Null? endTime;
  String? date;
  Null? updateDate;
  Null? studentAttendence;
  Null? toTime;
  Null? fromTime;
  Null? feesDurationId;
  Null? feesDuration;
  Null? schoolId;
  Null? presentDays;
  Null? absentDays;
  Null? totalDays;
  Null? attendancePercentage;
  bool? isPresent;

  ListData(
      {this.studentID,
      this.sadId,
      this.studentName,
      this.gender,
      this.fatherName,
      this.motherName,
      this.fatherOccupation,
      this.dateOfBirth,
      this.classId,
      this.sectionId,
      this.className,
      this.sectionName,
      this.rollNo,
      this.bloodGroup,
      this.religion,
      this.admissionDate,
      this.parentId,
      this.phone,
      this.whatsAppNo,
      this.emergencyNo,
      this.createDate,
      this.email,
      this.updateBy,
      this.session,
      this.ppassword,
      this.registrationNo,
      this.action,
      this.studentPic,
      this.fatherPic,
      this.motherPic,
      this.guardianImage,
      this.startTime,
      this.endTime,
      this.date,
      this.updateDate,
      this.studentAttendence,
      this.toTime,
      this.fromTime,
      this.feesDurationId,
      this.feesDuration,
      this.schoolId,
      this.presentDays,
      this.absentDays,
      this.totalDays,
      this.attendancePercentage,
      this.isPresent});

  ListData.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    sadId = json['sadId'];
    studentName = json['studentName'];
    gender = json['gender'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    fatherOccupation = json['fatherOccupation'];
    dateOfBirth = json['dateOfBirth'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    className = json['className'];
    sectionName = json['sectionName'];
    rollNo = json['rollNo'];
    bloodGroup = json['bloodGroup'];
    religion = json['religion'];
    admissionDate = json['admissionDate'];
    parentId = json['parentId'];
    phone = json['phone'];
    whatsAppNo = json['whatsAppNo'];
    emergencyNo = json['emergencyNo'];
    createDate = json['createDate'];
    email = json['email'];
    updateBy = json['updateBy'];
    session = json['session'];
    ppassword = json['ppassword'];
    registrationNo = json['registrationNo'];
    action = json['action'];
    studentPic = json['studentPic'];
    fatherPic = json['fatherPic'];
    motherPic = json['motherPic'];
    guardianImage = json['guardianImage'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    date = json['date'];
    updateDate = json['updateDate'];
    studentAttendence = json['studentAttendence'];
    toTime = json['toTime'];
    fromTime = json['fromTime'];
    feesDurationId = json['feesDurationId'];
    feesDuration = json['feesDuration'];
    schoolId = json['schoolId'];
    presentDays = json['presentDays'];
    absentDays = json['absentDays'];
    totalDays = json['totalDays'];
    attendancePercentage = json['attendancePercentage'];
    isPresent = json['isPresent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentID'] = this.studentID;
    data['sadId'] = this.sadId;
    data['studentName'] = this.studentName;
    data['gender'] = this.gender;
    data['fatherName'] = this.fatherName;
    data['motherName'] = this.motherName;
    data['fatherOccupation'] = this.fatherOccupation;
    data['dateOfBirth'] = this.dateOfBirth;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['className'] = this.className;
    data['sectionName'] = this.sectionName;
    data['rollNo'] = this.rollNo;
    data['bloodGroup'] = this.bloodGroup;
    data['religion'] = this.religion;
    data['admissionDate'] = this.admissionDate;
    data['parentId'] = this.parentId;
    data['phone'] = this.phone;
    data['whatsAppNo'] = this.whatsAppNo;
    data['emergencyNo'] = this.emergencyNo;
    data['createDate'] = this.createDate;
    data['email'] = this.email;
    data['updateBy'] = this.updateBy;
    data['session'] = this.session;
    data['ppassword'] = this.ppassword;
    data['registrationNo'] = this.registrationNo;
    data['action'] = this.action;
    data['studentPic'] = this.studentPic;
    data['fatherPic'] = this.fatherPic;
    data['motherPic'] = this.motherPic;
    data['guardianImage'] = this.guardianImage;
    data['startTime'] = this.startTime;
    data['endTime'] = this.endTime;
    data['date'] = this.date;
    data['updateDate'] = this.updateDate;
    data['studentAttendence'] = this.studentAttendence;
    data['toTime'] = this.toTime;
    data['fromTime'] = this.fromTime;
    data['feesDurationId'] = this.feesDurationId;
    data['feesDuration'] = this.feesDuration;
    data['schoolId'] = this.schoolId;
    data['presentDays'] = this.presentDays;
    data['absentDays'] = this.absentDays;
    data['totalDays'] = this.totalDays;
    data['attendancePercentage'] = this.attendancePercentage;
    data['isPresent'] = this.isPresent;
    return data;
  }
}