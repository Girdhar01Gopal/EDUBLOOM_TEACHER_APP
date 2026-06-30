import 'dart:convert';

StaffDetail15Model staffDetail15ModelFromJson(String str) =>
    StaffDetail15Model.fromJson(json.decode(str));

String staffDetail15ModelToJson(StaffDetail15Model data) =>
    json.encode(data.toJson());

class StaffDetail15Model {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<StaffDetail15Data>? data;
  bool? showPopup;
  String? popupMessage;

  StaffDetail15Model({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory StaffDetail15Model.fromJson(Map<String, dynamic> json) {
    return StaffDetail15Model(
      statusCode: _toInt(json['statusCode']),
      isSuccess: json['isSuccess'] is bool ? json['isSuccess'] : false,
      messages: json['messages']?.toString(),
      data: json['data'] is List
          ? (json['data'] as List)
          .map((e) => StaffDetail15Data.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : <StaffDetail15Data>[],
      showPopup: json['showPopup'] is bool ? json['showPopup'] : false,
      popupMessage: json['popupMessage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data?.map((e) => e.toJson()).toList() ?? [],
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

class StaffDetail15Data {
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

  StaffDetail15Data({
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

  factory StaffDetail15Data.fromJson(Map<String, dynamic> json) {
    return StaffDetail15Data(
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
      qualification: _toNullableString(json['qualification']),
      lastOrganization: _toNullableString(json['lastOrganization']),
      totalExperience: _toNullableString(json['totalExperience']),
      specialization: _toNullableString(json['specialization']),
      designation: _toNullableString(json['designation']),
      staffType: _toNullableString(json['staffType']),
      bankName: _toNullableString(json['bankName']),
      accountNo: _toNullableString(json['accountNo']),
      ifsccode: _toNullableString(json['ifsccode']),
      salary: _toNullableString(json['salary']),
      dateofJoining: _toDate(json['dateofJoining']),
      staffPic: _toNullableString(json['staffPic']),
      idproof: _toNullableString(json['idproof']),
      licenceImages: _toNullableString(json['licenceImages']),
      callLetter: _toNullableString(json['callLetter']),
      isActive: json['isActive'],
      createDate: _toDate(json['createDate']),
      updateDate: _toDate(json['updateDate']),
      createBy: json['createBy'],
      aadharNo: _toNullableString(json['aadharNo']),
      userId: json['userId'],
      password: _toNullableString(json['password']),
      licenceNo: _toNullableString(json['licenceNo']),
      updateBy: json['updateBy'],
      tpassword: _toNullableString(json['tpassword']),
      schoolId: json['schoolId'],
      schoolName: _toNullableString(json['schoolName']),
      schoolEmail: _toNullableString(json['schoolEmail']),
      schoolPhone: _toNullableString(json['schoolPhone']),
      schoolAddress: _toNullableString(json['schoolAddress']),
      accessToker: _toNullableString(json['accessToker']),
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
      'qualification': qualification,
      'lastOrganization': lastOrganization,
      'totalExperience': totalExperience,
      'specialization': specialization,
      'designation': designation,
      'staffType': staffType,
      'bankName': bankName,
      'accountNo': accountNo,
      'ifsccode': ifsccode,
      'salary': salary,
      'dateofJoining': dateofJoining?.toIso8601String(),
      'staffPic': staffPic,
      'idproof': idproof,
      'licenceImages': licenceImages,
      'callLetter': callLetter,
      'isActive': isActive,
      'createDate': createDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'aadharNo': aadharNo,
      'userId': userId,
      'password': password,
      'licenceNo': licenceNo,
      'updateBy': updateBy,
      'tpassword': tpassword,
      'schoolId': schoolId,
      'schoolName': schoolName,
      'schoolEmail': schoolEmail,
      'schoolPhone': schoolPhone,
      'schoolAddress': schoolAddress,
      'accessToker': accessToker,
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

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }
}