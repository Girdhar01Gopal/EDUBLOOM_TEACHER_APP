class StudentModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<StudentData>? data;
  bool? showPopup;
  String? popupMessage;

  StudentModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  StudentModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];

    if (json['data'] != null) {
      data = (json['data'] as List)
          .map((e) => StudentData.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "isSuccess": isSuccess,
    "messages": messages,
    "showPopup": showPopup,
    "popupMessage": popupMessage,
    "data": data?.map((e) => e.toJson()).toList(),
  };
}

class StudentData {
  int? studentID;
  String? studentName;
  String? gender;
  String? fatherName;
  String? motherName;
  String? fatherOccupation;
  String? dateOfBirth;

  int? classId;
  int? sectionId;
  String? className;
  String? sectionName;

  String? rollNo;
  String? bloodGroup;
  String? religion;

  String? admissionDate;
  String? parentId;
  String? aAdharNo;

  String? phone;
  String? whatsAppNo;
  String? emergencyNo;

  String? createDate;
  String? email;
  String? session;
  String? ppassword;
  String? registrationNo;

  String? action;

  // Images
  String? studentPic;
  String? fatherPic;
  String? motherPic;
  String? guardianImage;

  // Fee / School / Others
  int? feesDurationId;
  String? schoolName;
  String? affiliated;
  String? schoolAddress;
  String? schoolPhone;
  String? schoolEmail;
  String? schoolWebsite;
  String? logo;
  String? logoWithName;

  String? address;

  StudentData({
    this.studentID,
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
    this.aAdharNo,
    this.phone,
    this.whatsAppNo,
    this.emergencyNo,
    this.createDate,
    this.email,
    this.session,
    this.ppassword,
    this.registrationNo,
    this.action,
    this.studentPic,
    this.fatherPic,
    this.motherPic,
    this.guardianImage,
    this.feesDurationId,
    this.schoolName,
    this.affiliated,
    this.schoolAddress,
    this.schoolPhone,
    this.schoolEmail,
    this.schoolWebsite,
    this.logo,
    this.logoWithName,
    this.address,
  });

  StudentData.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    studentName = json['studentName'];
    gender = json['gender'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    fatherOccupation = json['fatherOccupation'];
    dateOfBirth = json['dateOfBirth'];

    aAdharNo = (json['aAdharNo'] ?? json['AAdharNo'] ?? json['aadhaarNo'] ?? json['aadharNo'])
        ?.toString()
        .trim();

    classId = json['classId'];
    sectionId = json['sectionId'];
    className = json['className'];
    sectionName = json['sectionName'];

    rollNo = json['rollNo']?.toString() ??
        json['roll']?.toString() ??
        json['Roll']?.toString();

    bloodGroup = json['bloodGroup'];
    religion = json['religion'];

    admissionDate = json['admissionDate'];
    parentId = json['parentId'];

    phone = json['phone'];
    whatsAppNo = json['whatsAppNo'];
    emergencyNo = json['emergencyNo'];

    createDate = json['createDate'];
    email = (json['email'] ??
        json['Email'] ??
        json['emailId'] ??
        json['EmailId'] ??
        json['studentEmail'] ??
        json['StudentEmail'])
        ?.toString()
        .trim();

    session = json['session'];
    ppassword = json['ppassword'];
    registrationNo = json['registrationNo'];
    action = json['action'];

    studentPic = json['studentPic'];
    fatherPic = json['fatherPic'];
    motherPic = json['motherPic'];
    guardianImage = json['guardianImage'];

    feesDurationId = json['feesDurationId'];

    schoolName = json['schoolName'];
    affiliated = json['affiliated'];
    schoolAddress = json['schoolAddress'];
    schoolPhone = json['schoolPhone'];
    schoolEmail = json['schoolEmail'];
    schoolWebsite = json['schoolWebsite'];
    logo = json['logo'];
    logoWithName = json['logoWithName'];

    address = json['address'];
  }

  Map<String, dynamic> toJson() => {
    "studentID": studentID,
    "studentName": studentName,
    "gender": gender,
    "fatherName": fatherName,
    "motherName": motherName,
    "fatherOccupation": fatherOccupation,
    "dateOfBirth": dateOfBirth,
    "aAdharNo": aAdharNo,
    "classId": classId,
    "sectionId": sectionId,
    "className": className,
    "sectionName": sectionName,
    "rollNo": rollNo,
    "bloodGroup": bloodGroup,
    "religion": religion,
    "admissionDate": admissionDate,
    "parentId": parentId,
    "phone": phone,
    "whatsAppNo": whatsAppNo,
    "emergencyNo": emergencyNo,
    "createDate": createDate,
    "email": email,
    "session": session,
    "ppassword": ppassword,
    "registrationNo": registrationNo,
    "action": action,
    "studentPic": studentPic,
    "fatherPic": fatherPic,
    "motherPic": motherPic,
    "guardianImage": guardianImage,
    "feesDurationId": feesDurationId,
    "schoolName": schoolName,
    "affiliated": affiliated,
    "schoolAddress": schoolAddress,
    "schoolPhone": schoolPhone,
    "schoolEmail": schoolEmail,
    "schoolWebsite": schoolWebsite,
    "logo": logo,
    "logoWithName": logoWithName,
    "address": address,
  };
}