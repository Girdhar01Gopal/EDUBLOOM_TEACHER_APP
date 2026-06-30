class StationaryFeePrint2 {
  final int id;

  final String? principalUserName;
  final String? principalPassword;
  final String? adminUserName;
  final String? adminPassword;
  final String? accountantUserName;
  final String? accountantPassword;

  final String schoolName;
  final String? affiliationNumber;
  final String? udiseNumber;
  final String? schoolNumber;

  final String? principalName;
  final String? principalMobNo;
  final String? adminOfficerName;
  final String? adminOfficerMobNo;
  final String? accountantName;
  final String? accountantMobNo;

  final String? phoneNumber1;
  final String? phoneNumber2;
  final String? mobileNumber;

  final String schoolEmailID;
  final String? principalEmailID;
  final String? accountsDepartmentEmailID;

  final String schoolAddress;

  final String? uploadLogo1;
  final String? uploadLogo2;

  final String schoolId;
  final String? createBy;
  final String? action;
  final DateTime? createDate;

  StationaryFeePrint2({
    required this.id,
    this.principalUserName,
    this.principalPassword,
    this.adminUserName,
    this.adminPassword,
    this.accountantUserName,
    this.accountantPassword,
    required this.schoolName,
    this.affiliationNumber,
    this.udiseNumber,
    this.schoolNumber,
    this.principalName,
    this.principalMobNo,
    this.adminOfficerName,
    this.adminOfficerMobNo,
    this.accountantName,
    this.accountantMobNo,
    this.phoneNumber1,
    this.phoneNumber2,
    this.mobileNumber,
    required this.schoolEmailID,
    this.principalEmailID,
    this.accountsDepartmentEmailID,
    required this.schoolAddress,
    this.uploadLogo1,
    this.uploadLogo2,
    required this.schoolId,
    this.createBy,
    this.action,
    this.createDate,
  });

  factory StationaryFeePrint2.fromJson(Map<String, dynamic> json) {
    return StationaryFeePrint2(
      id: json['id'] ?? 0,

      principalUserName: json['principalUserName'],
      principalPassword: json['principalPassword'],
      adminUserName: json['adminUserName'],
      adminPassword: json['adminPassword'],
      accountantUserName: json['accountantUserName'],
      accountantPassword: json['accountantPassword'],

      schoolName: json['schoolName'] ?? '',
      affiliationNumber: json['affiliationNumber'],
      udiseNumber: json['udiseNumber'],
      schoolNumber: json['schoolNumber'],

      principalName: json['principalName'],
      principalMobNo: json['principalMobNo'],
      adminOfficerName: json['adminOfficerName'],
      adminOfficerMobNo: json['adminOfficerMobNo'],
      accountantName: json['accountantName'],
      accountantMobNo: json['accountantMobNo'],

      phoneNumber1: json['phoneNumber1'],
      phoneNumber2: json['phoneNumber2'],
      mobileNumber: json['mobileNumber'],

      schoolEmailID: json['schoolEmailID'] ?? '',
      principalEmailID: json['principalEmailID'],
      accountsDepartmentEmailID: json['accountsDepartmentEmailID'],

      schoolAddress: json['schoolAddress'] ?? '',

      uploadLogo1: json['uploadLogo1'],
      uploadLogo2: json['uploadLogo2'],

      schoolId: json['schoolId'] ?? '',
      createBy: json['createBy'],
      action: json['action'],

      createDate: json['createDate'] != null
          ? DateTime.tryParse(json['createDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,

      'principalUserName': principalUserName,
      'principalPassword': principalPassword,
      'adminUserName': adminUserName,
      'adminPassword': adminPassword,
      'accountantUserName': accountantUserName,
      'accountantPassword': accountantPassword,

      'schoolName': schoolName,
      'affiliationNumber': affiliationNumber,
      'udiseNumber': udiseNumber,
      'schoolNumber': schoolNumber,

      'principalName': principalName,
      'principalMobNo': principalMobNo,
      'adminOfficerName': adminOfficerName,
      'adminOfficerMobNo': adminOfficerMobNo,
      'accountantName': accountantName,
      'accountantMobNo': accountantMobNo,

      'phoneNumber1': phoneNumber1,
      'phoneNumber2': phoneNumber2,
      'mobileNumber': mobileNumber,

      'schoolEmailID': schoolEmailID,
      'principalEmailID': principalEmailID,
      'accountsDepartmentEmailID': accountsDepartmentEmailID,

      'schoolAddress': schoolAddress,

      'uploadLogo1': uploadLogo1,
      'uploadLogo2': uploadLogo2,

      'schoolId': schoolId,
      'createBy': createBy,
      'action': action,
      'createDate': createDate?.toIso8601String(),
    };
  }
}