class Login_Model {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  Data? data;
  bool? showPopup;
  Null? popupMessage;

  Login_Model(
      {this.statusCode,
        this.isSuccess,
        this.messages,
        this.data,
        this.showPopup,
        this.popupMessage});

  Login_Model.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['isSuccess'] = this.isSuccess;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['showPopup'] = this.showPopup;
    data['popupMessage'] = this.popupMessage;
    return data;
  }
}

class Data {
  int? studentID;
  String? studentName;
  String? gender;
  String? fatherName;
  String? motherName;
  String? fatherOccupation;
  String? dateOfBirth;
  String? className;
  String? classId;
  String? sectionId;
  String? sectionName;
  String? rollNo;
  String? bloodGroup;
  String? religion;
  String? admissionDate;
  String? admissionNo;
  String? phone;
  String? address;
  String? createDate;
  String? email;
  Null? updateBy;
  String? session;
  String? ppassword;
  String? registrationNo;
  String? action;
  String? studentPic;
  String? schoolId;
  String? schoolName;
  String? schoolEmail;
  String? schoolPhone;
  String? schoolAddress;
  String? logowithName;
  String? addDaycare;
  String? parentID;
  AccessToker? accessToker;

  Data(
      {this.studentID,
        this.studentName,
        this.gender,
        this.fatherName,
        this.motherName,
        this.fatherOccupation,
        this.dateOfBirth,
        this.className,
        this.classId,
        this.sectionId,
        this.sectionName,
        this.rollNo,
        this.bloodGroup,
        this.religion,
        this.admissionDate,
        this.admissionNo,
        this.phone,
        this.address,
        this.createDate,
        this.email,
        this.updateBy,
        this.session,
        this.ppassword,
        this.registrationNo,
        this.action,
        this.studentPic,
        this.schoolId,
        this.schoolName,
        this.schoolEmail,
        this.schoolPhone,
        this.schoolAddress,
        this.logowithName,
        this.addDaycare,
        this.parentID,
        this.accessToker});

  Data.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    studentName = json['studentName'];
    gender = json['gender'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    fatherOccupation = json['fatherOccupation'];
    dateOfBirth = json['dateOfBirth'];
    className = json['className'];

    // ✅ Fix — int ko String mein convert kiya
    classId = json['classId']?.toString();
    sectionId = json['sectionId']?.toString();

    sectionName = json['sectionName'];
    rollNo = json['rollNo'];
    bloodGroup = json['bloodGroup'];
    religion = json['religion'];
    admissionDate = json['admissionDate'];
    admissionNo = json['admissionNo'];
    phone = json['phone'];
    address = json['address'];
    createDate = json['createDate'];
    email = json['email'];
    updateBy = json['updateBy'];
    session = json['session'];
    ppassword = json['ppassword'];
    registrationNo = json['registrationNo'];
    action = json['action'];
    studentPic = json['studentPic'];
    schoolId = json['schoolId'];
    schoolName = json['schoolName'];
    schoolEmail = json['schoolEmail'];
    schoolPhone = json['schoolPhone'];
    schoolAddress = json['schoolAddress'];
    logowithName = json['logowithName'];
    addDaycare = json['addDaycare'];
    parentID = json['parentID'];
    accessToker = json['accessToker'] != null
        ? AccessToker.fromJson(json['accessToker'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentID'] = this.studentID;
    data['studentName'] = this.studentName;
    data['gender'] = this.gender;
    data['fatherName'] = this.fatherName;
    data['motherName'] = this.motherName;
    data['fatherOccupation'] = this.fatherOccupation;
    data['dateOfBirth'] = this.dateOfBirth;
    data['className'] = this.className;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['sectionName'] = this.sectionName;
    data['rollNo'] = this.rollNo;
    data['bloodGroup'] = this.bloodGroup;
    data['religion'] = this.religion;
    data['admissionDate'] = this.admissionDate;
    data['admissionNo'] = this.admissionNo;
    data['phone'] = this.phone;
    data['address'] = this.address;
    data['createDate'] = this.createDate;
    data['email'] = this.email;
    data['updateBy'] = this.updateBy;
    data['session'] = this.session;
    data['ppassword'] = this.ppassword;
    data['registrationNo'] = this.registrationNo;
    data['action'] = this.action;
    data['studentPic'] = this.studentPic;
    data['schoolId'] = this.schoolId;
    data['schoolName'] = this.schoolName;
    data['schoolEmail'] = this.schoolEmail;
    data['schoolPhone'] = this.schoolPhone;
    data['schoolAddress'] = this.schoolAddress;
    data['logowithName'] = this.logowithName;
    data['addDaycare'] = this.addDaycare;
    data['parentID'] = this.parentID;
    if (this.accessToker != null) {
      data['accessToker'] = this.accessToker!.toJson();
    }
    return data;
  }
}

class AccessToker {
  String? token;
  String? expireIn;

  AccessToker({this.token, this.expireIn});

  AccessToker.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expireIn = json['expireIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['expireIn'] = this.expireIn;
    return data;
  }
}