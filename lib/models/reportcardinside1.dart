class ReportCard1Model {
  final String? sclInfoId;
  final String? schoolName;
  final String? email;
  final String? website;
  final String? certified;
  final String? address;
  final String? phone;
  final String? affiliated;
  final String? action;
  final String? createDate;
  final String? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;
  final int? studentThreshold;
  final String? udisenumber;
  final String? schoolNumber;
  final String? phone1;
  final String? city;
  final String? state;
  final String? shortName;
  final int? userThreshold;
  final String? logo;
  final String? logoWithName;
  final String? webandApp;
  final List<dynamic> users;

  ReportCard1Model({
    this.sclInfoId,
    this.schoolName,
    this.email,
    this.website,
    this.certified,
    this.address,
    this.phone,
    this.affiliated,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.studentThreshold,
    this.udisenumber,
    this.schoolNumber,
    this.phone1,
    this.city,
    this.state,
    this.shortName,
    this.userThreshold,
    this.logo,
    this.logoWithName,
    this.webandApp,
    this.users = const [],
  });

  factory ReportCard1Model.fromJson(Map<String, dynamic> json) {
    return ReportCard1Model(
      sclInfoId: json['sclInfoId'] as String?,
      schoolName: json['schoolName'] as String?,
      email: json['email'] as String?,
      website: json['website'] as String?,
      certified: json['certified'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      affiliated: json['affiliated'] as String?,
      action: json['action'] as String?,
      createDate: json['createDate'] as String?,
      updateDate: json['updateDate'] as String?,
      createBy: json['createBy'] as String?,
      updateBy: json['updateBy'] as String?,
      schoolId: json['schoolId'] as String?,
      studentThreshold: json['studentThreshold'] as int?,
      udisenumber: json['udisenumber'] as String?,
      schoolNumber: json['schoolNumber'] as String?,
      phone1: json['phone1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      shortName: json['shortName'] as String?,
      userThreshold: json['userThreshold'] as int?,
      logo: json['logo'] as String?,
      logoWithName: json['logoWithName'] as String?,
      webandApp: json['webandApp'] as String?,
      users: json['users'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sclInfoId': sclInfoId,
      'schoolName': schoolName,
      'email': email,
      'website': website,
      'certified': certified,
      'address': address,
      'phone': phone,
      'affiliated': affiliated,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'studentThreshold': studentThreshold,
      'udisenumber': udisenumber,
      'schoolNumber': schoolNumber,
      'phone1': phone1,
      'city': city,
      'state': state,
      'shortName': shortName,
      'userThreshold': userThreshold,
      'logo': logo,
      'logoWithName': logoWithName,
      'webandApp': webandApp,
      'users': users,
    };
  }

  ReportCard1Model copyWith({
    String? sclInfoId,
    String? schoolName,
    String? email,
    String? website,
    String? certified,
    String? address,
    String? phone,
    String? affiliated,
    String? action,
    String? createDate,
    String? updateDate,
    String? createBy,
    String? updateBy,
    String? schoolId,
    int? studentThreshold,
    String? udisenumber,
    String? schoolNumber,
    String? phone1,
    String? city,
    String? state,
    String? shortName,
    int? userThreshold,
    String? logo,
    String? logoWithName,
    String? webandApp,
    List<dynamic>? users,
  }) {
    return ReportCard1Model(
      sclInfoId: sclInfoId ?? this.sclInfoId,
      schoolName: schoolName ?? this.schoolName,
      email: email ?? this.email,
      website: website ?? this.website,
      certified: certified ?? this.certified,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      affiliated: affiliated ?? this.affiliated,
      action: action ?? this.action,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      createBy: createBy ?? this.createBy,
      updateBy: updateBy ?? this.updateBy,
      schoolId: schoolId ?? this.schoolId,
      studentThreshold: studentThreshold ?? this.studentThreshold,
      udisenumber: udisenumber ?? this.udisenumber,
      schoolNumber: schoolNumber ?? this.schoolNumber,
      phone1: phone1 ?? this.phone1,
      city: city ?? this.city,
      state: state ?? this.state,
      shortName: shortName ?? this.shortName,
      userThreshold: userThreshold ?? this.userThreshold,
      logo: logo ?? this.logo,
      logoWithName: logoWithName ?? this.logoWithName,
      webandApp: webandApp ?? this.webandApp,
      users: users ?? this.users,
    );
  }

  @override
  String toString() {
    return 'ReportCard1Model(sclInfoId: $sclInfoId, schoolName: $schoolName, '
        'email: $email, schoolId: $schoolId, shortName: $shortName)';
  }
}