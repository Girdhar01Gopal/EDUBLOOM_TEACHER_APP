import 'dart:convert';

StationaryAction1Model stationaryAction1ModelFromJson(String str) =>
    StationaryAction1Model.fromJson(json.decode(str));

String stationaryAction1ModelToJson(StationaryAction1Model data) =>
    json.encode(data.toJson());

class StationaryAction1Model {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  StudentData? data;
  bool? showPopup;
  String? popupMessage;

  StationaryAction1Model({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory StationaryAction1Model.fromJson(Map<String, dynamic> json) {
    return StationaryAction1Model(
      statusCode: json["statusCode"],
      isSuccess: json["isSuccess"],
      messages: json["messages"],
      data: json["data"] != null ? StudentData.fromJson(json["data"]) : null,
      showPopup: json["showPopup"],
      popupMessage: json["popupMessage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "isSuccess": isSuccess,
      "messages": messages,
      "data": data?.toJson(),
      "showPopup": showPopup,
      "popupMessage": popupMessage,
    };
  }
}

class StudentData {
  int? studentID;
  int? totalStudent;
  int? totalBirthdaysToday;
  String? studentName;
  String? gender;
  String? fatherName;
  String? motherName;
  String? fatherOccupation;
  String? dateOfBirth;
  String? dateOfBirth1;
  int? classId;
  int? sectionId;
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
  int? feesDurationId;
  String? feesDuration;
  String? status;
  String? fromTime;
  String? toTime;
  String? schoolId;
  String? feesType;
  int? feesTypeId;
  dynamic discount;
  String? schoolName;
  String? affiliated;
  String? schoolAddress;
  String? schoolPhone;
  String? schoolEmail;
  String? schoolWebsite;
  String? logo;
  String? logoWithName;
  String? address;
  dynamic addDaycare;
  String? birthCertificatePic;
  String? pickupPoint;
  String? transportUser;

  StudentData({
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

  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      studentID: json["studentID"],
      totalStudent: json["totalStudent"],
      totalBirthdaysToday: json["totalBirthdaysToday"],
      studentName: json["studentName"],
      gender: json["gender"],
      fatherName: json["fatherName"],
      motherName: json["motherName"],
      fatherOccupation: json["fatherOccupation"],
      dateOfBirth: json["dateOfBirth"],
      dateOfBirth1: json["dateOfBirth1"],
      classId: json["classId"],
      sectionId: json["sectionId"],
      className: json["className"],
      nationality: json["nationality"],
      sectionName: json["sectionName"],
      rollNo: json["rollNo"],
      bloodGroup: json["bloodGroup"],
      religion: json["religion"],
      admissionDate: json["admissionDate"],
      parentId: json["parentId"],
      phone: json["phone"],
      whatsAppNo: json["whatsAppNo"],
      emergencyNo: json["emergencyNo"],
      createDate: json["createDate"],
      email: json["email"],
      updateBy: json["updateBy"],
      session: json["session"],
      ppassword: json["ppassword"],
      registrationNo: json["registrationNo"],
      action: json["action"],
      studentPic: json["studentPic"],
      fatherPic: json["fatherPic"],
      motherPic: json["motherPic"],
      guardianImage: json["guardianImage"],
      feesDurationId: json["feesDurationId"],
      feesDuration: json["feesDuration"],
      status: json["status"],
      fromTime: json["fromTime"],
      toTime: json["toTime"],
      schoolId: json["schoolId"],
      feesType: json["feesType"],
      feesTypeId: json["feesTypeId"],
      discount: json["discount"],
      schoolName: json["schoolName"],
      affiliated: json["affiliated"],
      schoolAddress: json["schoolAddress"],
      schoolPhone: json["schoolPhone"],
      schoolEmail: json["schoolEmail"],
      schoolWebsite: json["schoolWebsite"],
      logo: json["logo"],
      logoWithName: json["logoWithName"],
      address: json["address"],
      addDaycare: json["addDaycare"],
      birthCertificatePic: json["birthCertificatePic"],
      pickupPoint: json["pickupPoint"],
      transportUser: json["transportUser"],
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
      "dateOfBirth": dateOfBirth,
      "dateOfBirth1": dateOfBirth1,
      "classId": classId,
      "sectionId": sectionId,
      "className": className,
      "nationality": nationality,
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