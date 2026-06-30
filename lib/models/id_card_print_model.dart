// ─────────────────────────────────────────────────────────────
//  Model: IdCardPrintModel  (same StudentData used elsewhere)
//  API : GET /api/StudentApp/GetStudentDetailsIdCardApp
//        ?studentIds={id}&schoolId={schoolId}&currentSession={session}
// ─────────────────────────────────────────────────────────────

class IdCardPrintModel {
  final int? statusCode;
  final bool? isSuccess;
  final String? messages;
  final List<IdCardStudentData>? data;
  final bool? showPopup;
  final String? popupMessage;

  IdCardPrintModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory IdCardPrintModel.fromJson(Map<String, dynamic> json) {
    return IdCardPrintModel(
      statusCode: json['statusCode'],
      isSuccess: json['isSuccess'],
      messages: json['messages'],
      data: json['data'] != null
          ? List<IdCardStudentData>.from(
          json['data'].map((x) => IdCardStudentData.fromJson(x)))
          : null,
      showPopup: json['showPopup'],
      popupMessage: json['popupMessage'],
    );
  }
}

class IdCardStudentData {
  final int? studentID;
  final String? studentName;
  final String? gender;
  final String? fatherName;
  final String? motherName;
  final String? fatherOccupation;
  final DateTime? dateOfBirth;
  final String? className;
  final String? sectionName;
  final String? rollNo;
  final String? bloodGroup;
  final String? religion;
  final String? phone;
  final String? whatsAppNo;
  final String? emergencyNo;
  final String? email;
  final String? session;
  final String? ppassword;
  final String? registrationNo;
  final String? action;
  final String? studentPic;
  final String? fatherPic;
  final String? motherPic;
  final String? guardianImage;
  final String? schoolName;
  final String? affiliated;
  final String? schoolAddress;
  final String? schoolPhone;
  final String? schoolEmail;
  final String? schoolWebsite;
  final String? logo;
  final String? logoWithName;
  final String? address;
  final String? nationality;
  final String? aAdharNo;
  final String? pickupPoint;
  final String? transportUser;
  final String? routeNo;

  IdCardStudentData({
    this.studentID,
    this.studentName,
    this.gender,
    this.fatherName,
    this.motherName,
    this.fatherOccupation,
    this.dateOfBirth,
    this.className,
    this.sectionName,
    this.rollNo,
    this.bloodGroup,
    this.religion,
    this.phone,
    this.whatsAppNo,
    this.emergencyNo,
    this.email,
    this.session,
    this.ppassword,
    this.registrationNo,
    this.action,
    this.studentPic,
    this.fatherPic,
    this.motherPic,
    this.guardianImage,
    this.schoolName,
    this.affiliated,
    this.schoolAddress,
    this.schoolPhone,
    this.schoolEmail,
    this.schoolWebsite,
    this.logo,
    this.logoWithName,
    this.address,
    this.nationality,
    this.aAdharNo,
    this.pickupPoint,
    this.transportUser,
    this.routeNo,
  });

  factory IdCardStudentData.fromJson(Map<String, dynamic> json) {
    return IdCardStudentData(
      studentID: json['studentID'],
      studentName: json['studentName'],
      gender: json['gender'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      fatherOccupation: json['fatherOccupation'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      className: json['className'],
      sectionName: json['sectionName'],
      rollNo: json['rollNo'],
      bloodGroup: json['bloodGroup'],
      religion: json['religion'],
      phone: json['phone'],
      whatsAppNo: json['whatsAppNo'],
      emergencyNo: json['emergencyNo'],
      email: json['email'],
      session: json['session'],
      ppassword: json['ppassword'],
      registrationNo: json['registrationNo'],
      action: json['action'],
      studentPic: json['studentPic'],
      fatherPic: json['fatherPic'],
      motherPic: json['motherPic'],
      guardianImage: json['guardianImage'],
      schoolName: json['schoolName'],
      affiliated: json['affiliated'],
      schoolAddress: json['schoolAddress'],
      schoolPhone: json['schoolPhone'],
      schoolEmail: json['schoolEmail'],
      schoolWebsite: json['schoolWebsite'],
      logo: json['logo'],
      logoWithName: json['logoWithName'],
      address: json['address'],
      nationality: json['nationality'],
      aAdharNo: json['aAdharNo'],
      pickupPoint: json['pickupPoint'],
      transportUser: json['transportUser'],
      routeNo: json['routeNo'],
    );
  }
}