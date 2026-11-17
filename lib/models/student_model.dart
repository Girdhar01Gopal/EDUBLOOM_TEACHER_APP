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
  String? admissionNo;

  String? action;

  /// Images
  String? studentPic;
  String? fatherPic;
  String? motherPic;
  String? guardianImage;

  /// Fee / School / Others
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

  /// 🆕 Transport
  String? transportUser;
  String? routeNo;
  String? pickupPoint;

  /// 🆕 Extra fields (update ke time purana record wapas bhejne ke liye)
  String? remark;
  String? fromTime;
  String? toTime;
  String? addDaycare;
  String? isDaycare;
  String? daycareDurations;
  String? transportType;

  /// 🆕 API ka poora raw record (update ke time kuch bhi null na ho)
  Map<String, dynamic>? raw;

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
    this.phone,
    this.whatsAppNo,
    this.emergencyNo,
    this.createDate,
    this.email,
    this.session,
    this.ppassword,
    this.registrationNo,
    this.admissionNo,
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
    this.aAdharNo,
    this.transportUser,
    this.routeNo,
    this.pickupPoint,
    this.remark,
    this.fromTime,
    this.toTime,
    this.addDaycare,
    this.isDaycare,
    this.daycareDurations,
    this.transportType,
    this.raw,
  });

  StudentData.fromJson(Map<String, dynamic> json) {
    // 🆕 poora raw record save karo (update me kuch null na ho)
    raw = Map<String, dynamic>.from(json);

    studentID = json['studentID'];
    studentName = json['studentName'];
    gender = json['gender'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    fatherOccupation = json['fatherOccupation'];
    dateOfBirth = json['dateOfBirth'];
    aAdharNo = json['aAdharNo'];

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
    // 🔧 toString() taaki int aaye to bhi crash na ho
    parentId = (json['parentId'] ?? json['parentID'] ?? json['ParentID'])
        ?.toString();

    phone = json['phone'];
    whatsAppNo = json['whatsAppNo'];
    emergencyNo = json['emergencyNo'];

    createDate = json['createDate'];
    // ✅ MAIN FIX (Email multi-key)
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
    admissionNo = json['admissionNo'] ?? json['AdmissionNo'];
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

    // 🆕 Transport (multi-key, kyunki API ka exact key pata nahi)
    transportUser = (json['transportUser'] ??
        json['TransportUser'] ??
        json['transport'] ??
        json['isTransport'])
        ?.toString()
        .trim();
    routeNo = (json['routeNo'] ??
        json['RouteNo'] ??
        json['route'] ??
        json['routeNumber'])
        ?.toString()
        .trim();
    pickupPoint = (json['pickupPoint'] ??
        json['PickupPoint'] ??
        json['pickUpPoint'] ??
        json['stoppage'] ??
        json['Stoppage'])
        ?.toString()
        .trim();

    // 🆕 Extra fields (multi-key)
    remark = (json['remark'] ?? json['Remark'])?.toString().trim();
    fromTime = (json['fromTime'] ?? json['FromTime'])?.toString().trim();
    toTime = (json['toTime'] ?? json['ToTime'])?.toString().trim();
    addDaycare = (json['addDaycare'] ?? json['AddDaycare'])?.toString().trim();
    isDaycare = (json['isDaycare'] ??
        json['isDayCare'] ??
        json['IsDayCare'] ??
        json['IsDaycare'])
        ?.toString()
        .trim();
    daycareDurations = (json['daycareDurations'] ??
        json['DaycareDurations'] ??
        json['daycareDuration'])
        ?.toString()
        .trim();
    transportType =
        (json['transportType'] ?? json['TransportType'])?.toString().trim();
  }

  Map<String, dynamic> toJson() => {
    "studentID": studentID,
    "studentName": studentName,
    "gender": gender,
    "fatherName": fatherName,
    "motherName": motherName,
    "fatherOccupation": fatherOccupation,
    "dateOfBirth": dateOfBirth,
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
    "admissionNo": admissionNo,
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
    "aAdharNo": aAdharNo,
    "transportUser": transportUser,
    "routeNo": routeNo,
    "pickupPoint": pickupPoint,
    "remark": remark,
    "fromTime": fromTime,
    "toTime": toTime,
    "addDaycare": addDaycare,
    "isDaycare": isDaycare,
    "daycareDurations": daycareDurations,
    "transportType": transportType,
  };
}