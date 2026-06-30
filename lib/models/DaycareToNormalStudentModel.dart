class DaycareToNormalStudentModel {
  final int? statusCode;
  final bool? isSuccess;
  final String? messages;
  final DaycareToNormalStudentData? data;
  final bool? showPopup;
  final String? popupMessage;

  DaycareToNormalStudentModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory DaycareToNormalStudentModel.fromJson(Map<String, dynamic> json) {
    return DaycareToNormalStudentModel(
      statusCode: _toInt(json['statusCode']),
      isSuccess: _toBool(json['isSuccess']),
      messages: json['messages']?.toString(),
      data: json['data'] != null
          ? DaycareToNormalStudentData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      showPopup: _toBool(json['showPopup']),
      popupMessage: json['popupMessage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data?.toJson(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class DaycareToNormalStudentData {
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
  final int? parentId;
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
  final int? schoolId;
  final String? feesType;
  final int? feesTypeId;
  final double? discount;
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
  final String? aAdharNo;
  final dynamic isDaycare;

  DaycareToNormalStudentData({
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
    this.aAdharNo,
    this.isDaycare,
  });

  factory DaycareToNormalStudentData.fromJson(Map<String, dynamic> json) {
    return DaycareToNormalStudentData(
      studentID: _toInt(json['studentID']),
      totalStudent: _toInt(json['totalStudent']),
      totalBirthdaysToday: _toInt(json['totalBirthdaysToday']),
      studentName: json['studentName']?.toString(),
      gender: json['gender']?.toString(),
      fatherName: json['fatherName']?.toString(),
      motherName: json['motherName']?.toString(),
      fatherOccupation: json['fatherOccupation']?.toString(),
      dateOfBirth: _toDateTime(json['dateOfBirth']),
      dateOfBirth1: _toDateTime(json['dateOfBirth1']),
      classId: _toInt(json['classId']),
      sectionId: _toInt(json['sectionId']),
      className: json['className']?.toString(),
      nationality: json['nationality']?.toString(),
      sectionName: json['sectionName']?.toString(),
      rollNo: json['rollNo']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      religion: json['religion']?.toString(),
      admissionDate: _toDateTime(json['admissionDate']),
      parentId: _toInt(json['parentId']),
      phone: json['phone']?.toString(),
      whatsAppNo: json['whatsAppNo']?.toString(),
      emergencyNo: json['emergencyNo']?.toString(),
      createDate: _toDateTime(json['createDate']),
      email: json['email']?.toString(),
      updateBy: json['updateBy']?.toString(),
      session: json['session']?.toString(),
      ppassword: json['ppassword']?.toString(),
      registrationNo: json['registrationNo']?.toString(),
      action: json['action']?.toString(),
      studentPic: json['studentPic']?.toString(),
      fatherPic: json['fatherPic']?.toString(),
      motherPic: json['motherPic']?.toString(),
      guardianImage: json['guardianImage']?.toString(),
      feesDurationId: _toInt(json['feesDurationId']),
      feesDuration: json['feesDuration']?.toString(),
      status: json['status']?.toString(),
      fromTime: json['fromTime']?.toString(),
      toTime: json['toTime']?.toString(),
      schoolId: _toInt(json['schoolId']),
      feesType: json['feesType']?.toString(),
      feesTypeId: _toInt(json['feesTypeId']),
      discount: _toDouble(json['discount']),
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
      aAdharNo: json['aAdharNo']?.toString(),
      isDaycare: json['isDaycare'],
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
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'dateOfBirth1': dateOfBirth1?.toIso8601String(),
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'nationality': nationality,
      'sectionName': sectionName,
      'rollNo': rollNo,
      'bloodGroup': bloodGroup,
      'religion': religion,
      'admissionDate': admissionDate?.toIso8601String(),
      'parentId': parentId,
      'phone': phone,
      'whatsAppNo': whatsAppNo,
      'emergencyNo': emergencyNo,
      'createDate': createDate?.toIso8601String(),
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
      'aAdharNo': aAdharNo,
      'isDaycare': isDaycare,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _toBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  final val = value.toString().toLowerCase();
  if (val == 'true' || val == '1') return true;
  if (val == 'false' || val == '0') return false;
  return null;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  if (str.isEmpty || str == '0001-01-01T00:00:00') return null;
  return DateTime.tryParse(str);
}