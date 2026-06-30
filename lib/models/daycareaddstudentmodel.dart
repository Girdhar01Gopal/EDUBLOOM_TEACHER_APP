class DaycareStudentResponse {
  final int? statusCode;
  final bool? isSuccess;
  final String? messages;
  final List<DaycareStudentData> data;
  final bool? showPopup;
  final String? popupMessage;

  DaycareStudentResponse({
    this.statusCode,
    this.isSuccess,
    this.messages,
    required this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory DaycareStudentResponse.fromJson(Map<String, dynamic> json) {
    return DaycareStudentResponse(
      statusCode: json['statusCode'] as int?,
      isSuccess: json['isSuccess'] as bool?,
      messages: json['messages'] as String?,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => DaycareStudentData.fromJson(e as Map<String, dynamic>))
          .toList(),
      showPopup: json['showPopup'] as bool?,
      popupMessage: json['popupMessage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data.map((e) => e.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class DaycareStudentData {
  final int? studentID;
  final int? totalStudent;
  final int? totalBirthdaysToday;
  final String? studentName;
  final String? gender;
  final String? fatherName;
  final String? motherName;
  final String? fatherOccupation;
  final String? dateOfBirth;
  final String? dateOfBirth1;
  final dynamic classId;
  final dynamic sectionId;
  final String? className;
  final String? nationality;
  final String? sectionName;
  final dynamic rollNo;
  final String? bloodGroup;
  final String? religion;
  final String? admissionDate;
  final dynamic parentId;
  final String? phone;
  final String? whatsAppNo;
  final String? emergencyNo;
  final String? createDate;
  final String? email;
  final dynamic updateBy;
  final String? session;
  final dynamic ppassword;
  final String? registrationNo;
  final String? action;
  final String? studentPic;
  final String? fatherPic;
  final String? motherPic;
  final String? guardianImage;
  final int? feesDurationId;
  final String? feesDuration;
  final dynamic status;
  final String? fromTime;
  final String? toTime;
  final dynamic schoolId;
  final String? feesType;
  final dynamic feesTypeId;
  final dynamic discount;
  final String? schoolName;
  final String? affiliated;
  final String? schoolAddress;
  final String? schoolPhone;
  final String? schoolEmail;
  final String? schoolWebsite;
  final String? logo;
  final String? logoWithName;
  final String? address;
  final dynamic addDaycare;
  final String? birthCertificatePic;
  final String? pickupPoint;
  final dynamic transportUser;

  DaycareStudentData({
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

  factory DaycareStudentData.fromJson(Map<String, dynamic> json) {
    return DaycareStudentData(
      studentID: _toInt(json['studentID']),
      totalStudent: _toInt(json['totalStudent']),
      totalBirthdaysToday: _toInt(json['totalBirthdaysToday']),
      studentName: json['studentName']?.toString(),
      gender: json['gender']?.toString(),
      fatherName: json['fatherName']?.toString(),
      motherName: json['motherName']?.toString(),
      fatherOccupation: json['fatherOccupation']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      dateOfBirth1: json['dateOfBirth1']?.toString(),
      classId: json['classId'],
      sectionId: json['sectionId'],
      className: json['className']?.toString(),
      nationality: json['nationality']?.toString(),
      sectionName: json['sectionName']?.toString(),
      rollNo: json['rollNo'],
      bloodGroup: json['bloodGroup']?.toString(),
      religion: json['religion']?.toString(),
      admissionDate: json['admissionDate']?.toString(),
      parentId: json['parentId'],
      phone: json['phone']?.toString(),
      whatsAppNo: json['whatsAppNo']?.toString(),
      emergencyNo: json['emergencyNo']?.toString(),
      createDate: json['createDate']?.toString(),
      email: json['email']?.toString(),
      updateBy: json['updateBy'],
      session: json['session']?.toString(),
      ppassword: json['ppassword'],
      registrationNo: json['registrationNo']?.toString(),
      action: json['action']?.toString(),
      studentPic: json['studentPic']?.toString(),
      fatherPic: json['fatherPic']?.toString(),
      motherPic: json['motherPic']?.toString(),
      guardianImage: json['guardianImage']?.toString(),
      feesDurationId: _toInt(json['feesDurationId']),
      feesDuration: json['feesDuration']?.toString(),
      status: json['status'],
      fromTime: json['fromTime']?.toString(),
      toTime: json['toTime']?.toString(),
      schoolId: json['schoolId'],
      feesType: json['feesType']?.toString(),
      feesTypeId: json['feesTypeId'],
      discount: json['discount'],
      schoolName: json['schoolName']?.toString(),
      affiliated: json['affiliated']?.toString(),
      schoolAddress: json['schoolAddress']?.toString(),
      schoolPhone: json['schoolPhone']?.toString(),
      schoolEmail: json['schoolEmail']?.toString(),
      schoolWebsite: json['schoolWebsite']?.toString(),
      logo: json['logo']?.toString(),
      logoWithName: json['logoWithName']?.toString(),
      address: json['address']?.toString(),
      addDaycare: json['addDaycare'],
      birthCertificatePic: json['birthCertificatePic']?.toString(),
      pickupPoint: json['pickupPoint']?.toString(),
      transportUser: json['transportUser'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'totalStudent': totalStudent,
      'totalBirthdaysToday': totalBirthdaysToday,
      'studentName': studentName,
      'gender': gender,
      'fatherName': fatherName,
      'motherName': motherName,
      'fatherOccupation': fatherOccupation,
      'dateOfBirth': dateOfBirth,
      'dateOfBirth1': dateOfBirth1,
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'nationality': nationality,
      'sectionName': sectionName,
      'rollNo': rollNo,
      'bloodGroup': bloodGroup,
      'religion': religion,
      'admissionDate': admissionDate,
      'parentId': parentId,
      'phone': phone,
      'whatsAppNo': whatsAppNo,
      'emergencyNo': emergencyNo,
      'createDate': createDate,
      'email': email,
      'updateBy': updateBy,
      'session': session,
      'ppassword': ppassword,
      'registrationNo': registrationNo,
      'action': action,
      'studentPic': studentPic,
      'fatherPic': fatherPic,
      'motherPic': motherPic,
      'guardianImage': guardianImage,
      'feesDurationId': feesDurationId,
      'feesDuration': feesDuration,
      'status': status,
      'fromTime': fromTime,
      'toTime': toTime,
      'schoolId': schoolId,
      'feesType': feesType,
      'feesTypeId': feesTypeId,
      'discount': discount,
      'schoolName': schoolName,
      'affiliated': affiliated,
      'schoolAddress': schoolAddress,
      'schoolPhone': schoolPhone,
      'schoolEmail': schoolEmail,
      'schoolWebsite': schoolWebsite,
      'logo': logo,
      'logoWithName': logoWithName,
      'address': address,
      'addDaycare': addDaycare,
      'birthCertificatePic': birthCertificatePic,
      'pickupPoint': pickupPoint,
      'transportUser': transportUser,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}