// teacher_list_model.dart

class TeacherListResponse {
  final int statusCode;
  final bool isSuccess;
  final dynamic messages;
  final List<TeacherModel> data;
  final bool showPopup;
  final dynamic popupMessage;

  TeacherListResponse({
    required this.statusCode,
    required this.isSuccess,
    this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory TeacherListResponse.fromJson(Map<String, dynamic> json) {
    return TeacherListResponse(
      statusCode: (json['statusCode'] is int) ? json['statusCode'] : 0,
      isSuccess: (json['isSuccess'] is bool) ? json['isSuccess'] : false,
      messages: json['messages'],
      data: (json['data'] is List)
          ? (json['data'] as List)
          .map((e) => TeacherModel.fromJson(
          (e is Map<String, dynamic>) ? e : <String, dynamic>{}))
          .toList()
          : <TeacherModel>[],
      showPopup: (json['showPopup'] is bool) ? json['showPopup'] : false,
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "statusCode": statusCode,
      "isSuccess": isSuccess,
      "messages": messages,
      "data": data.map((e) => e.toJson()).toList(),
      "showPopup": showPopup,
      "popupMessage": popupMessage,
    };
  }
}

class TeacherModel {
  final int id;
  final String? teacherReg;
  final String? name;
  final String? fhname;
  final String? dob;
  final String? caste;
  final String? bloodGroup;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? emailid;
  final String? mobileNo;
  final int? tdId;
  final String? qualification;
  final String? lastOrganization;
  final String? totalExperience;
  final String? specialization;
  final String? designation;
  final String? bankName;
  final String? accountNo;
  final String? ifsccode;
  final String? salary;
  final String? dateofJoining;
  final String? teacherPic;
  final String? idproof;
  final String? resume;
  final String? callLetter;
  final bool isActive;
  final String? createDate;
  final String? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? userName;
  final String? tpassword;
  final String? schoolId;
  final String? schoolName;
  final String? schoolEmail;
  final String? schoolPhone;
  final String? schoolAddress;
  final String? stafftype;
  final String? accessToker;

  TeacherModel({
    required this.id,
    this.teacherReg,
    this.name,
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
    this.tdId,
    this.qualification,
    this.lastOrganization,
    this.totalExperience,
    this.specialization,
    this.designation,
    this.bankName,
    this.accountNo,
    this.ifsccode,
    this.salary,
    this.dateofJoining,
    this.teacherPic,
    this.idproof,
    this.resume,
    this.callLetter,
    required this.isActive,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.userName,
    this.tpassword,
    this.schoolId,
    this.schoolName,
    this.schoolEmail,
    this.schoolPhone,
    this.schoolAddress,
    this.stafftype,
    this.accessToker,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: (json['id'] is int) ? json['id'] : 0,
      teacherReg: json['teacherReg']?.toString(),
      name: json['name']?.toString(),
      fhname: json['fhname']?.toString(),
      dob: json['dob']?.toString(),
      caste: json['caste']?.toString(),
      bloodGroup: json['bloodGroup']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      emailid: json['emailid']?.toString(),
      mobileNo: json['mobileNo']?.toString(),
      tdId: (json['tdId'] is int) ? json['tdId'] : _toInt(json['tdId']),
      qualification: json['qualification']?.toString(),
      lastOrganization: json['lastOrganization']?.toString(),
      totalExperience: json['totalExperience']?.toString(),
      specialization: json['specialization']?.toString(),
      designation: json['designation']?.toString(),
      bankName: json['bankName']?.toString(),
      accountNo: json['accountNo']?.toString(),
      ifsccode: json['ifsccode']?.toString(),
      salary: json['salary']?.toString(),
      dateofJoining: json['dateofJoining']?.toString(),
      teacherPic: json['teacherPic']?.toString(),
      idproof: json['idproof']?.toString(),
      resume: json['resume']?.toString(),
      callLetter: json['callLetter']?.toString(),
      isActive: (json['isActive'] is bool) ? json['isActive'] : false,
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      userName: json['userName']?.toString(),
      tpassword: json['tpassword']?.toString(),
      schoolId: json['schoolId']?.toString(),
      schoolName: json['schoolName']?.toString(),
      schoolEmail: json['schoolEmail']?.toString(),
      schoolPhone: json['schoolPhone']?.toString(),
      schoolAddress: json['schoolAddress']?.toString(),
      stafftype: json['stafftype']?.toString(),
      accessToker: json['accessToker']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "teacherReg": teacherReg,
      "name": name,
      "fhname": fhname,
      "dob": dob,
      "caste": caste,
      "bloodGroup": bloodGroup,
      "gender": gender,
      "address": address,
      "city": city,
      "state": state,
      "emailid": emailid,
      "mobileNo": mobileNo,
      "tdId": tdId,
      "qualification": qualification,
      "lastOrganization": lastOrganization,
      "totalExperience": totalExperience,
      "specialization": specialization,
      "designation": designation,
      "bankName": bankName,
      "accountNo": accountNo,
      "ifsccode": ifsccode,
      "salary": salary,
      "dateofJoining": dateofJoining,
      "teacherPic": teacherPic,
      "idproof": idproof,
      "resume": resume,
      "callLetter": callLetter,
      "isActive": isActive,
      "createDate": createDate,
      "updateDate": updateDate,
      "createBy": createBy,
      "updateBy": updateBy,
      "userName": userName,
      "tpassword": tpassword,
      "schoolId": schoolId,
      "schoolName": schoolName,
      "schoolEmail": schoolEmail,
      "schoolPhone": schoolPhone,
      "schoolAddress": schoolAddress,
      "stafftype": stafftype,
      "accessToker": accessToker,
    };
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}