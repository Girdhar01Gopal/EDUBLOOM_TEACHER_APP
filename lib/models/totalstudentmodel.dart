class totalstudent {
  int? statusCode;
  bool? isSuccess;
  Null? messages;
  List<tData>? data;
  bool? showPopup;
  Null? popupMessage;

  totalstudent(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  totalstudent.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <tData>[];
      json['data'].forEach((v) {
        data!.add(new tData.fromJson(v));
      });
    }
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['isSuccess'] = this.isSuccess;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['showPopup'] = this.showPopup;
    data['popupMessage'] = this.popupMessage;
    return data;
  }
}

class tData {
  int? studentID;
  int? totalStudent;
  Null? studentName;
  Null? gender;
  Null? fatherName;
  Null? motherName;
  Null? fatherOccupation;
  Null? dateOfBirth;
  Null? dateOfBirth1;
  Null? classId;
  Null? sectionId;
  Null? className;
  Null? nationality;
  Null? sectionName;
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
  Null? action;
  Null? studentPic;
  Null? fatherPic;
  Null? motherPic;
  Null? guardianImage;
  int? feesDurationId;
  Null? feesDuration;
  Null? status;
  Null? fromTime;
  Null? toTime;
  Null? schoolId;
  Null? feesType;
  Null? feesTypeId;
  Null? discount;
  Null? schoolName;
  Null? affiliated;
  Null? schoolAddress;
  Null? schoolPhone;
  Null? schoolEmail;
  Null? schoolWebsite;
  Null? logo;
  Null? logoWithName;
  Null? address;
  Null? addDaycare;

  tData(
      {this.studentID,
      this.totalStudent,
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
      this.addDaycare});

  tData.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    totalStudent = json['totalStudent'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentID'] = this.studentID;
    data['totalStudent'] = this.totalStudent;
    data['studentName'] = this.studentName;
    data['gender'] = this.gender;
    data['fatherName'] = this.fatherName;
    data['motherName'] = this.motherName;
    data['fatherOccupation'] = this.fatherOccupation;
    data['dateOfBirth'] = this.dateOfBirth;
    data['dateOfBirth1'] = this.dateOfBirth1;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['className'] = this.className;
    data['nationality'] = this.nationality;
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
    data['feesDurationId'] = this.feesDurationId;
    data['feesDuration'] = this.feesDuration;
    data['status'] = this.status;
    data['fromTime'] = this.fromTime;
    data['toTime'] = this.toTime;
    data['schoolId'] = this.schoolId;
    data['feesType'] = this.feesType;
    data['feesTypeId'] = this.feesTypeId;
    data['discount'] = this.discount;
    data['schoolName'] = this.schoolName;
    data['affiliated'] = this.affiliated;
    data['schoolAddress'] = this.schoolAddress;
    data['schoolPhone'] = this.schoolPhone;
    data['schoolEmail'] = this.schoolEmail;
    data['schoolWebsite'] = this.schoolWebsite;
    data['logo'] = this.logo;
    data['logoWithName'] = this.logoWithName;
    data['address'] = this.address;
    data['addDaycare'] = this.addDaycare;
    return data;
  }
}