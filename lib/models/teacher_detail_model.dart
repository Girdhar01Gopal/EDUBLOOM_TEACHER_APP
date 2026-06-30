class TeacherDetailView {
  final int? id;
  final String? teacherReg;
  final String? name;
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
  final DateTime? dateofJoining;
  final String? teacherPic;
  final String? idproof;
  final String? resume;
  final String? callLetter;
  final bool? isActive;
  final DateTime? createDate;
  final DateTime? updateDate;
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

  TeacherDetailView({
    this.id,
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
    this.isActive,
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

  factory TeacherDetailView.fromJson(Map<String, dynamic> json) {
    return TeacherDetailView(
      id: json["id"],
      teacherReg: json["teacherReg"],
      name: json["name"],
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
      tdId: json["tdId"],
      qualification: json["qualification"],
      lastOrganization: json["lastOrganization"],
      totalExperience: json["totalExperience"],
      specialization: json["specialization"],
      designation: json["designation"],
      bankName: json["bankName"],
      accountNo: json["accountNo"],
      ifsccode: json["ifsccode"],
      salary: json["salary"],
      dateofJoining: _parseDate(json["dateofJoining"]),
      teacherPic: json["teacherPic"],
      idproof: json["idproof"],
      resume: json["resume"],
      callLetter: json["callLetter"],
      isActive: json["isActive"],
      createDate: _parseDate(json["createDate"]),
      updateDate: _parseDate(json["updateDate"]),
      createBy: json["createBy"],
      updateBy: json["updateBy"],
      userName: json["userName"],
      tpassword: json["tpassword"],
      schoolId: json["schoolId"],
      schoolName: json["schoolName"],
      schoolEmail: json["schoolEmail"],
      schoolPhone: json["schoolPhone"],
      schoolAddress: json["schoolAddress"],
      stafftype: json["stafftype"],
      accessToker: json["accessToker"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "teacherReg": teacherReg,
      "name": name,
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
      "dateofJoining": dateofJoining?.toIso8601String(),
      "teacherPic": teacherPic,
      "idproof": idproof,
      "resume": resume,
      "callLetter": callLetter,
      "isActive": isActive,
      "createDate": createDate?.toIso8601String(),
      "updateDate": updateDate?.toIso8601String(),
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

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}