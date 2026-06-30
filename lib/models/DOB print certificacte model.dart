// ============================================================
// dob_certificate_model.dart
// ============================================================

class PrintCertificateModel {
  int?    statusCode;
  bool?   isSuccess;
  String? messages;
  PrintCertificateData? data;
  bool?   showPopup;
  String? popupMessage;

  PrintCertificateModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory PrintCertificateModel.fromJson(Map<String, dynamic> json) {
    return PrintCertificateModel(
      statusCode:   json['statusCode']   as int?,
      isSuccess:    json['isSuccess']    as bool?,
      messages:     json['messages']     as String?,
      showPopup:    json['showPopup']    as bool?,
      popupMessage: json['popupMessage'] as String?,
      data: json['data'] != null
          ? PrintCertificateData.fromJson(
          json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PrintCertificateData {
  int?    studentID;
  int?    totalStudent;
  int?    totalBirthdaysToday;
  String? studentName;
  String? gender;
  String? fatherName;
  String? motherName;
  String? fatherOccupation;
  String? dateOfBirth;
  String? dateOfBirth1;
  int?    classId;
  int?    sectionId;
  String? className;
  String? nationality;
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
  String? fatherPic;
  String? motherPic;
  String? guardianImage;
  int?    feesDurationId;
  String? feesDuration;
  String? status;
  String? fromTime;
  String? toTime;
  String? schoolId;
  String? feesType;
  String? feesTypeId;
  String? discount;
  String? schoolName;
  String? affiliated;
  String? schoolAddress;
  String? schoolPhone;
  String? schoolEmail;
  String? schoolWebsite;
  String? logo;
  String? logoWithName;
  String? address;
  String? addDaycare;
  String? birthCertificatePic;
  String? pickupPoint;
  String? transportUser;
  String? aAdharNo;
  String? isDaycare;
  String? certificateNo;
  String? issuedOndate;

  PrintCertificateData({
    this.studentID, this.totalStudent, this.totalBirthdaysToday,
    this.studentName, this.gender, this.fatherName, this.motherName,
    this.fatherOccupation, this.dateOfBirth, this.dateOfBirth1,
    this.classId, this.sectionId, this.className, this.nationality,
    this.sectionName, this.rollNo, this.bloodGroup, this.religion,
    this.admissionDate, this.parentId, this.phone, this.whatsAppNo,
    this.emergencyNo, this.createDate, this.email, this.updateBy,
    this.session, this.ppassword, this.registrationNo, this.action,
    this.studentPic, this.fatherPic, this.motherPic, this.guardianImage,
    this.feesDurationId, this.feesDuration, this.status, this.fromTime,
    this.toTime, this.schoolId, this.feesType, this.feesTypeId,
    this.discount, this.schoolName, this.affiliated, this.schoolAddress,
    this.schoolPhone, this.schoolEmail, this.schoolWebsite, this.logo,
    this.logoWithName, this.address, this.addDaycare,
    this.birthCertificatePic, this.pickupPoint, this.transportUser,
    this.aAdharNo, this.isDaycare, this.certificateNo, this.issuedOndate,
  });

  factory PrintCertificateData.fromJson(Map<String, dynamic> json) {
    return PrintCertificateData(
      studentID:           json['studentID']           as int?,
      totalStudent:        json['totalStudent']        as int?,
      totalBirthdaysToday: json['totalBirthdaysToday'] as int?,
      studentName:         json['studentName']         as String?,
      gender:              json['gender']              as String?,
      fatherName:          json['fatherName']          as String?,
      motherName:          json['motherName']          as String?,
      fatherOccupation:    json['fatherOccupation']    as String?,
      dateOfBirth:         json['dateOfBirth']         as String?,
      dateOfBirth1:        json['dateOfBirth1']        as String?,
      classId:             json['classId']             as int?,
      sectionId:           json['sectionId']           as int?,
      className:           json['className']           as String?,
      nationality:         json['nationality']         as String?,
      sectionName:         json['sectionName']         as String?,
      rollNo:              json['rollNo']?.toString(),
      bloodGroup:          json['bloodGroup']          as String?,
      religion:            json['religion']            as String?,
      admissionDate:       json['admissionDate']       as String?,
      parentId:            json['parentId']            as String?,
      phone:               json['phone']               as String?,
      whatsAppNo:          json['whatsAppNo']          as String?,
      emergencyNo:         json['emergencyNo']         as String?,
      createDate:          json['createDate']          as String?,
      email:               json['email']?.toString().trim(),
      updateBy:            json['updateBy']            as String?,
      session:             json['session']             as String?,
      ppassword:           json['ppassword']           as String?,
      registrationNo:      json['registrationNo']      as String?,
      action:              json['action']              as String?,
      studentPic:          json['studentPic']          as String?,
      fatherPic:           json['fatherPic']           as String?,
      motherPic:           json['motherPic']           as String?,
      guardianImage:       json['guardianImage']       as String?,
      feesDurationId:      json['feesDurationId']      as int?,
      feesDuration:        json['feesDuration']        as String?,
      status:              json['status']              as String?,
      fromTime:            json['fromTime']            as String?,
      toTime:              json['toTime']              as String?,
      schoolId:            json['schoolId']?.toString(),
      feesType:            json['feesType']            as String?,
      feesTypeId:          json['feesTypeId']?.toString(),
      discount:            json['discount']?.toString(),
      schoolName:          json['schoolName']          as String?,
      affiliated:          json['affiliated']          as String?,
      schoolAddress:       json['schoolAddress']       as String?,
      schoolPhone:         json['schoolPhone']         as String?,
      schoolEmail:         json['schoolEmail']         as String?,
      schoolWebsite:       json['schoolWebsite']       as String?,
      logo:                json['logo']                as String?,
      logoWithName:        json['logoWithName']        as String?,
      address:             json['address']             as String?,
      addDaycare:          json['addDaycare']          as String?,
      birthCertificatePic: json['birthCertificatePic'] as String?,
      pickupPoint:         json['pickupPoint']         as String?,
      transportUser:       json['transportUser']       as String?,
      aAdharNo:            json['aAdharNo']            as String?,
      isDaycare:           json['isDaycare']           as String?,
      certificateNo:       json['certificateNo']       as String?,
      issuedOndate:        json['issuedOndate']        as String?,
    );
  }

  // Format ISO date → dd-MM-yyyy
  static String formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(isoDate);
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      return '$dd-$mm-${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}