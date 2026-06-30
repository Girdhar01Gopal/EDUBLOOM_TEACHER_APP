import 'dart:convert';

StaffDetailsResponse staffDetailsResponseFromJson(String str) =>
    StaffDetailsResponse.fromJson(json.decode(str));

String staffDetailsResponseToJson(StaffDetailsResponse data) =>
    json.encode(data.toJson());

class StaffDetailsResponse {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  StaffData? data;
  bool? showPopup;
  String? popupMessage;

  StaffDetailsResponse({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory StaffDetailsResponse.fromJson(Map<String, dynamic> json) {
    return StaffDetailsResponse(
      statusCode: _toInt(json['statusCode']),
      isSuccess: json['isSuccess'] is bool ? json['isSuccess'] : false,
      messages: json['messages']?.toString(),
      data: json['data'] != null ? StaffData.fromJson(json['data']) : null,
      showPopup: json['showPopup'] is bool ? json['showPopup'] : false,
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

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class StaffData {
  int? id;
  int? staffId;
  String? staffReg;
  String? name;
  String? userName;
  String? fhname;
  DateTime? dob;
  String? caste;
  String? bloodGroup;
  String? gender;
  String? address;
  String? city;
  String? state;
  String? emailid;
  String? mobileNo;
  int? staffTypeId;
  String? qualification;
  String? lastOrganization;
  String? totalExperience;
  String? specialization;
  String? designation;
  String? staffType;
  String? bankName;
  String? accountNo;
  String? ifsccode;
  String? salary;
  DateTime? dateofJoining;
  String? staffPic;
  String? idproof;
  String? licenceImages;
  String? callLetter;
  dynamic isActive;
  DateTime? createDate;
  DateTime? updateDate;
  dynamic createBy;
  String? aadharNo;
  dynamic userId;
  String? password;
  String? licenceNo;
  dynamic updateBy;
  String? tpassword;
  dynamic schoolId;
  String? schoolName;
  String? schoolEmail;
  String? schoolPhone;
  String? schoolAddress;
  String? accessToker;

  StaffData({
    this.id,
    this.staffId,
    this.staffReg,
    this.name,
    this.userName,
    this.fhname,
    this.dob,
    this.caste,
    this.bloodGroup,
    this.gender,
    this.address,
    this.city,
    this.state,
    this.emailid,
    this.mobileNo,
    this.staffTypeId,
    this.qualification,
    this.lastOrganization,
    this.totalExperience,
    this.specialization,
    this.designation,
    this.staffType,
    this.bankName,
    this.accountNo,
    this.ifsccode,
    this.salary,
    this.dateofJoining,
    this.staffPic,
    this.idproof,
    this.licenceImages,
    this.callLetter,
    this.isActive,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.aadharNo,
    this.userId,
    this.password,
    this.licenceNo,
    this.updateBy,
    this.tpassword,
    this.schoolId,
    this.schoolName,
    this.schoolEmail,
    this.schoolPhone,
    this.schoolAddress,
    this.accessToker,
  });

  factory StaffData.fromJson(Map<String, dynamic> json) {
    return StaffData(
      id: _toInt(json['id']),
      staffId: _toInt(json['staffId']),
      staffReg: json['staffReg']?.toString(),
      name: json['name']?.toString(),
      userName: json['userName']?.toString(),
      fhname: json['fhname']?.toString(),
      dob: _toDate(json['dob']),
      caste: json['caste']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      emailid: json['emailid']?.toString(),
      mobileNo: json['mobileNo']?.toString(),
      staffTypeId: _toInt(json['staffTypeId']),
      qualification: json['qualification']?.toString(),
      lastOrganization: json['lastOrganization']?.toString(),
      totalExperience: json['totalExperience']?.toString(),
      specialization: json['specialization']?.toString(),
      designation: json['designation']?.toString(),
      staffType: json['staffType']?.toString(),
      bankName: json['bankName']?.toString(),
      accountNo: json['accountNo']?.toString(),
      ifsccode: json['ifsccode']?.toString(),
      salary: json['salary']?.toString(),
      dateofJoining: _toDate(json['dateofJoining']),
      staffPic: json['staffPic']?.toString(),
      idproof: json['idproof']?.toString(),
      licenceImages: json['licenceImages']?.toString(),
      callLetter: json['callLetter']?.toString(),
      isActive: json['isActive'],
      createDate: _toDate(json['createDate']),
      updateDate: _toDate(json['updateDate']),
      createBy: json['createBy'],
      aadharNo: json['aadharNo']?.toString(),
      userId: json['userId'],
      password: json['password']?.toString(),
      licenceNo: json['licenceNo']?.toString(),
      updateBy: json['updateBy'],
      tpassword: json['tpassword']?.toString(),
      schoolId: json['schoolId'],
      schoolName: json['schoolName']?.toString(),
      schoolEmail: json['schoolEmail']?.toString(),
      schoolPhone: json['schoolPhone']?.toString(),
      schoolAddress: json['schoolAddress']?.toString(),
      accessToker: json['accessToker']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staffId': staffId,
      'staffReg': staffReg,
      'name': name,
      'userName': userName,
      'fhname': fhname,
      'dob': dob?.toIso8601String(),
      'caste': caste,
      'bloodGroup': bloodGroup,
      'gender': gender,
      'address': address,
      'city': city,
      'state': state,
      'emailid': emailid,
      'mobileNo': mobileNo,
      'staffTypeId': staffTypeId,
      'qualification': qualification == 'null' ? null : qualification,
      'lastOrganization': lastOrganization == 'null' ? null : lastOrganization,
      'totalExperience': totalExperience == 'null' ? null : totalExperience,
      'specialization': specialization == 'null' ? null : specialization,
      'designation': designation == 'null' ? null : designation,
      'staffType': staffType,
      'bankName': bankName == 'null' ? null : bankName,
      'accountNo': accountNo == 'null' ? null : accountNo,
      'ifsccode': ifsccode == 'null' ? null : ifsccode,
      'salary': salary == 'null' ? null : salary,
      'dateofJoining': dateofJoining?.toIso8601String(),
      'staffPic': staffPic,
      'idproof': idproof == 'null' ? null : idproof,
      'licenceImages': licenceImages == 'null' ? null : licenceImages,
      'callLetter': callLetter == 'null' ? null : callLetter,
      'isActive': isActive,
      'createDate': createDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'aadharNo': aadharNo,
      'userId': userId,
      'password': password,
      'licenceNo': licenceNo,
      'updateBy': updateBy,
      'tpassword': tpassword == 'null' ? null : tpassword,
      'schoolId': schoolId,
      'schoolName': schoolName == 'null' ? null : schoolName,
      'schoolEmail': schoolEmail == 'null' ? null : schoolEmail,
      'schoolPhone': schoolPhone == 'null' ? null : schoolPhone,
      'schoolAddress': schoolAddress == 'null' ? null : schoolAddress,
      'accessToker': accessToker == 'null' ? null : accessToker,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}