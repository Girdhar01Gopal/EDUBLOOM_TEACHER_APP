class StaffDetailModel {
  final int? id;
  final int? staffId;
  final String? staffReg;
  final String? name;
  final String? userName;
  final String? fhname;
  final DateTime? dob;
  final String? caste;
  final String? bloodGroup;
  final String? gender;
  final String? address;
  final String? city;
  final String? state;
  final String? emailid;
  final String? mobileNo;
  final int? staffTypeId;
  final String? qualification;
  final String? lastOrganization;
  final String? totalExperience;
  final String? specialization;
  final String? designation;
  final String? staffType;
  final String? bankName;
  final String? accountNo;
  final String? ifsccode;
  final String? salary;
  final DateTime? dateofJoining;
  final String? staffPic;
  final String? idproof;
  final String? licenceImages;
  final String? callLetter;
  final bool? isActive;
  final DateTime? createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? aadharNo;
  final String? userId;
  final String? password;
  final String? licenceNo;
  final String? tpassword;
  final String? schoolId;
  final String? schoolName;
  final String? schoolEmail;
  final String? schoolPhone;
  final String? schoolAddress;
  final String? accessToker;

  StaffDetailModel({
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
    this.updateBy,
    this.aadharNo,
    this.userId,
    this.password,
    this.licenceNo,
    this.tpassword,
    this.schoolId,
    this.schoolName,
    this.schoolEmail,
    this.schoolPhone,
    this.schoolAddress,
    this.accessToker,
  });

  factory StaffDetailModel.fromJson(Map<String, dynamic> json) {
    return StaffDetailModel(
      id: json["id"],
      staffId: json["staffId"],
      staffReg: json["staffReg"],
      name: json["name"],
      userName: json["userName"],
      fhname: json["fhname"],
      dob: _parseDate(json["dob"]),
      caste: json["caste"],
      bloodGroup: json["bloodGroup"],
      gender: json["gender"],
      address: json["address"],
      city: json["city"],
      state: json["state"],
      emailid: json["emailid"],
      mobileNo: json["mobileNo"],
      staffTypeId: json["staffTypeId"],
      qualification: json["qualification"],
      lastOrganization: json["lastOrganization"],
      totalExperience: json["totalExperience"],
      specialization: json["specialization"],
      designation: json["designation"],
      staffType: json["staffType"],
      bankName: json["bankName"],
      accountNo: json["accountNo"],
      ifsccode: json["ifsccode"],
      salary: json["salary"],
      dateofJoining: _parseDate(json["dateofJoining"]),
      staffPic: json["staffPic"],
      idproof: json["idproof"],
      licenceImages: json["licenceImages"],
      callLetter: json["callLetter"],
      isActive: json["isActive"],
      createDate: _parseDate(json["createDate"]),
      updateDate: _parseDate(json["updateDate"]),
      createBy: json["createBy"],
      updateBy: json["updateBy"],
      aadharNo: json["aadharNo"],
      userId: json["userId"],
      password: json["password"],
      licenceNo: json["licenceNo"],
      tpassword: json["tpassword"],
      schoolId: json["schoolId"],
      schoolName: json["schoolName"],
      schoolEmail: json["schoolEmail"],
      schoolPhone: json["schoolPhone"],
      schoolAddress: json["schoolAddress"],
      accessToker: json["accessToker"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "staffId": staffId,
      "staffReg": staffReg,
      "name": name,
      "userName": userName,
      "fhname": fhname,
      "dob": dob?.toIso8601String(),
      "caste": caste,
      "bloodGroup": bloodGroup,
      "gender": gender,
      "address": address,
      "city": city,
      "state": state,
      "emailid": emailid,
      "mobileNo": mobileNo,
      "staffTypeId": staffTypeId,
      "qualification": qualification,
      "lastOrganization": lastOrganization,
      "totalExperience": totalExperience,
      "specialization": specialization,
      "designation": designation,
      "staffType": staffType,
      "bankName": bankName,
      "accountNo": accountNo,
      "ifsccode": ifsccode,
      "salary": salary,
      "dateofJoining": dateofJoining?.toIso8601String(),
      "staffPic": staffPic,
      "idproof": idproof,
      "licenceImages": licenceImages,
      "callLetter": callLetter,
      "isActive": isActive,
      "createDate": createDate?.toIso8601String(),
      "updateDate": updateDate?.toIso8601String(),
      "createBy": createBy,
      "updateBy": updateBy,
      "aadharNo": aadharNo,
      "userId": userId,
      "password": password,
      "licenceNo": licenceNo,
      "tpassword": tpassword,
      "schoolId": schoolId,
      "schoolName": schoolName,
      "schoolEmail": schoolEmail,
      "schoolPhone": schoolPhone,
      "schoolAddress": schoolAddress,
      "accessToker": accessToker,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}