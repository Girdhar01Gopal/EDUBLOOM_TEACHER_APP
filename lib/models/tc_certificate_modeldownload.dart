class TcCertificateModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<TcStudentData>? data;
  bool? showPopup;
  dynamic popupMessage;

  TcCertificateModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  TcCertificateModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <TcStudentData>[];
      json['data'].forEach((v) {
        data!.add(TcStudentData.fromJson(v));
      });
    }
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['statusCode'] = statusCode;
    dataMap['isSuccess'] = isSuccess;
    dataMap['messages'] = messages;
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    dataMap['showPopup'] = showPopup;
    dataMap['popupMessage'] = popupMessage;
    return dataMap;
  }
}

class TcStudentData {
  int? studentID;
  int? totalStudent;
  int? totalBirthdaysToday;
  String? studentName;
  String? gender;
  String? fatherName;
  String? motherName;
  String? fatherOccupation;
  String? dateOfBirth;
  dynamic dateOfBirth1;
  int? classId;
  int? sectionId;
  String? className;
  dynamic nationality;
  String? sectionName;
  String? rollNo;
  String? bloodGroup;
  String? religion;
  String? admissionDate;
  String? parentId;
  String? phone;
  String? whatsAppNo;
  String? emergencyNo;
  String? createDate;
  String? email;
  String? updateBy;
  String? session;
  String? ppassword;
  String? registrationNo;
  String? action;
  String? studentPic;
  dynamic fatherPic;
  dynamic motherPic;
  dynamic guardianImage;
  int? feesDurationId;
  dynamic feesDuration;
  dynamic status;
  dynamic fromTime;
  dynamic toTime;
  dynamic schoolId;
  dynamic feesType;
  dynamic feesTypeId;
  dynamic discount;
  String? schoolName;
  dynamic affiliated;
  String? schoolAddress;
  String? schoolPhone;
  String? schoolEmail;
  dynamic schoolWebsite;
  String? logo;
  String? logoWithName;
  String? address;
  dynamic addDaycare;
  dynamic birthCertificatePic;
  dynamic pickupPoint;
  dynamic transportUser;
  dynamic aAdharNo;
  dynamic isDaycare;
  dynamic certificateNo;
  dynamic issuedOndate;

  TcStudentData({
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
    this.certificateNo,
    this.issuedOndate,
  });

  TcStudentData.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    totalStudent = json['totalStudent'];
    totalBirthdaysToday = json['totalBirthdaysToday'];
    studentName = json['studentName'];
    gender = json['gender'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    fatherOccupation = json['fatherOccupation'];
    dateOfBirth = json['dateOfBirth'];
    dateOfBirth1 = json['dateOfBirth1'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    className = json['className'];
    nationality = json['nationality'];
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
    feesDurationId = json['feesDurationId'];
    feesDuration = json['feesDuration'];
    status = json['status'];
    fromTime = json['fromTime'];
    toTime = json['toTime'];
    schoolId = json['schoolId'];
    feesType = json['feesType'];
    feesTypeId = json['feesTypeId'];
    discount = json['discount'];
    schoolName = json['schoolName'];
    affiliated = json['affiliated'];
    schoolAddress = json['schoolAddress'];
    schoolPhone = json['schoolPhone'];
    schoolEmail = json['schoolEmail'];
    schoolWebsite = json['schoolWebsite'];
    logo = json['logo'];
    logoWithName = json['logoWithName'];
    address = json['address'];
    addDaycare = json['addDaycare'];
    birthCertificatePic = json['birthCertificatePic'];
    pickupPoint = json['pickupPoint'];
    transportUser = json['transportUser'];
    aAdharNo = json['aAdharNo'];
    isDaycare = json['isDaycare'];
    certificateNo = json['certificateNo'];
    issuedOndate = json['issuedOndate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['studentID'] = studentID;
    dataMap['totalStudent'] = totalStudent;
    dataMap['totalBirthdaysToday'] = totalBirthdaysToday;
    dataMap['studentName'] = studentName;
    dataMap['gender'] = gender;
    dataMap['fatherName'] = fatherName;
    dataMap['motherName'] = motherName;
    dataMap['fatherOccupation'] = fatherOccupation;
    dataMap['dateOfBirth'] = dateOfBirth;
    dataMap['dateOfBirth1'] = dateOfBirth1;
    dataMap['classId'] = classId;
    dataMap['sectionId'] = sectionId;
    dataMap['className'] = className;
    dataMap['nationality'] = nationality;
    dataMap['sectionName'] = sectionName;
    dataMap['rollNo'] = rollNo;
    dataMap['bloodGroup'] = bloodGroup;
    dataMap['religion'] = religion;
    dataMap['admissionDate'] = admissionDate;
    dataMap['parentId'] = parentId;
    dataMap['phone'] = phone;
    dataMap['whatsAppNo'] = whatsAppNo;
    dataMap['emergencyNo'] = emergencyNo;
    dataMap['createDate'] = createDate;
    dataMap['email'] = email;
    dataMap['updateBy'] = updateBy;
    dataMap['session'] = session;
    dataMap['ppassword'] = ppassword;
    dataMap['registrationNo'] = registrationNo;
    dataMap['action'] = action;
    dataMap['studentPic'] = studentPic;
    dataMap['fatherPic'] = fatherPic;
    dataMap['motherPic'] = motherPic;
    dataMap['guardianImage'] = guardianImage;
    dataMap['feesDurationId'] = feesDurationId;
    dataMap['feesDuration'] = feesDuration;
    dataMap['status'] = status;
    dataMap['fromTime'] = fromTime;
    dataMap['toTime'] = toTime;
    dataMap['schoolId'] = schoolId;
    dataMap['feesType'] = feesType;
    dataMap['feesTypeId'] = feesTypeId;
    dataMap['discount'] = discount;
    dataMap['schoolName'] = schoolName;
    dataMap['affiliated'] = affiliated;
    dataMap['schoolAddress'] = schoolAddress;
    dataMap['schoolPhone'] = schoolPhone;
    dataMap['schoolEmail'] = schoolEmail;
    dataMap['schoolWebsite'] = schoolWebsite;
    dataMap['logo'] = logo;
    dataMap['logoWithName'] = logoWithName;
    dataMap['address'] = address;
    dataMap['addDaycare'] = addDaycare;
    dataMap['birthCertificatePic'] = birthCertificatePic;
    dataMap['pickupPoint'] = pickupPoint;
    dataMap['transportUser'] = transportUser;
    dataMap['aAdharNo'] = aAdharNo;
    dataMap['isDaycare'] = isDaycare;
    dataMap['certificateNo'] = certificateNo;
    dataMap['issuedOndate'] = issuedOndate;
    return dataMap;
  }
}