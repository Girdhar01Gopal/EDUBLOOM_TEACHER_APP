class StudentResponse {
  final List<Student> listData;

  StudentResponse({required this.listData});

  factory StudentResponse.fromJson(Map<String, dynamic> json) {
    return StudentResponse(
      listData: json['listData'] != null
          ? List<Student>.from(
          json['listData'].map((x) => Student.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "listData": listData.map((x) => x.toJson()).toList(),
    };
  }
}

class Student {
  final int? studentID;
  final int? totalStudent;
  final int? totalBirthdaysToday;
  final String? studentName;
  final String? gender;
  final String? fatherName;
  final String? motherName;
  final String? fatherOccupation;
  final DateTime? dateOfBirth;
  final DateTime? dateOfBirth1;
  final int? classId;
  final int? sectionId;
  final String? className;
  final String? nationality;
  final String? sectionName;
  final String? rollNo;
  final String? bloodGroup;
  final String? religion;
  final DateTime? admissionDate;
  final String? parentId;
  final String? phone;
  final String? whatsAppNo;
  final String? emergencyNo;
  final DateTime? createDate;
  final String? email;
  final String? updateBy;
  final String? session;
  final String? ppassword;
  final String? registrationNo;
  final String? action;
  final String? studentPic;
  final String? fatherPic;
  final String? motherPic;
  final String? guardianImage;
  final int? feesDurationId;
  final String? feesDuration;
  final String? status;
  final String? fromTime;
  final String? toTime;
  final String? schoolId;
  final String? feesType;
  final String? feesTypeId;
  final String? discount;
  final String? schoolName;
  final String? affiliated;
  final String? schoolAddress;
  final String? schoolPhone;
  final String? schoolEmail;
  final String? schoolWebsite;
  final String? logo;
  final String? logoWithName;
  final String? address;
  final String? addDaycare;
  final String? birthCertificatePic;
  final String? pickupPoint;
  final String? transportUser;

  Student({
    this.studentID,
    this.totalStudent,
    this.totalBirthdaysToday,
    this.studentName,
    this.gender,
    this.fatherName,
    this.motherName,
    this.fatherOccupation,
    this.dateOfBirth,
    this.dateOfBirth1,
    this.classId,
    this.sectionId,
    this.className,
    this.nationality,
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
    this.feesDurationId,
    this.feesDuration,
    this.status,
    this.fromTime,
    this.toTime,
    this.schoolId,
    this.feesType,
    this.feesTypeId,
    this.discount,
    this.schoolName,
    this.affiliated,
    this.schoolAddress,
    this.schoolPhone,
    this.schoolEmail,
    this.schoolWebsite,
    this.logo,
    this.logoWithName,
    this.address,
    this.addDaycare,
    this.birthCertificatePic,
    this.pickupPoint,
    this.transportUser,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentID: json['studentID'],
      totalStudent: json['totalStudent'],
      totalBirthdaysToday: json['totalBirthdaysToday'],
      studentName: json['studentName'],
      gender: json['gender'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      fatherOccupation: json['fatherOccupation'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      dateOfBirth1: json['dateOfBirth1'] != null
          ? DateTime.parse(json['dateOfBirth1'])
          : null,
      classId: json['classId'],
      sectionId: json['sectionId'],
      className: json['className'],
      nationality: json['nationality'],
      sectionName: json['sectionName'],
      rollNo: json['rollNo'],
      bloodGroup: json['bloodGroup'],
      religion: json['religion'],
      admissionDate: json['admissionDate'] != null
          ? DateTime.parse(json['admissionDate'])
          : null,
      parentId: json['parentId'],
      phone: json['phone'],
      whatsAppNo: json['whatsAppNo'],
      emergencyNo: json['emergencyNo'],
      createDate: json['createDate'] != null
          ? DateTime.parse(json['createDate'])
          : null,
      email: json['email'],
      updateBy: json['updateBy'],
      session: json['session'],
      ppassword: json['ppassword'],
      registrationNo: json['registrationNo'],
      action: json['action'],
      studentPic: json['studentPic'],
      fatherPic: json['fatherPic'],
      motherPic: json['motherPic'],
      guardianImage: json['guardianImage'],
      feesDurationId: json['feesDurationId'],
      feesDuration: json['feesDuration'],
      status: json['status'],
      fromTime: json['fromTime'],
      toTime: json['toTime'],
      schoolId: json['schoolId'],
      feesType: json['feesType'],
      feesTypeId: json['feesTypeId'],
      discount: json['discount'],
      schoolName: json['schoolName'],
      affiliated: json['affiliated'],
      schoolAddress: json['schoolAddress'],
      schoolPhone: json['schoolPhone'],
      schoolEmail: json['schoolEmail'],
      schoolWebsite: json['schoolWebsite'],
      logo: json['logo'],
      logoWithName: json['logoWithName'],
      address: json['address'],
      addDaycare: json['addDaycare'],
      birthCertificatePic: json['birthCertificatePic'],
      pickupPoint: json['pickupPoint'],
      transportUser: json['transportUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "studentID": studentID,
      "totalStudent": totalStudent,
      "totalBirthdaysToday": totalBirthdaysToday,
      "studentName": studentName,
      "gender": gender,
      "fatherName": fatherName,
      "motherName": motherName,
      "fatherOccupation": fatherOccupation,
      "dateOfBirth": dateOfBirth?.toIso8601String(),
      "dateOfBirth1": dateOfBirth1?.toIso8601String(),
      "classId": classId,
      "sectionId": sectionId,
      "className": className,
      "nationality": nationality,
      "sectionName": sectionName,
      "rollNo": rollNo,
      "bloodGroup": bloodGroup,
      "religion": religion,
      "admissionDate": admissionDate?.toIso8601String(),
      "parentId": parentId,
      "phone": phone,
      "whatsAppNo": whatsAppNo,
      "emergencyNo": emergencyNo,
      "createDate": createDate?.toIso8601String(),
      "email": email,
      "updateBy": updateBy,
      "session": session,
      "ppassword": ppassword,
      "registrationNo": registrationNo,
      "action": action,
      "studentPic": studentPic,
      "fatherPic": fatherPic,
      "motherPic": motherPic,
      "guardianImage": guardianImage,
      "feesDurationId": feesDurationId,
      "feesDuration": feesDuration,
      "status": status,
      "fromTime": fromTime,
      "toTime": toTime,
      "schoolId": schoolId,
      "feesType": feesType,
      "feesTypeId": feesTypeId,
      "discount": discount,
      "schoolName": schoolName,
      "affiliated": affiliated,
      "schoolAddress": schoolAddress,
      "schoolPhone": schoolPhone,
      "schoolEmail": schoolEmail,
      "schoolWebsite": schoolWebsite,
      "logo": logo,
      "logoWithName": logoWithName,
      "address": address,
      "addDaycare": addDaycare,
      "birthCertificatePic": birthCertificatePic,
      "pickupPoint": pickupPoint,
      "transportUser": transportUser,
    };
  }
}