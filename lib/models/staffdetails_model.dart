class StaffDetail {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  StaffData? data;
  bool? showPopup;
  dynamic popupMessage;

  StaffDetail({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  StaffDetail.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    data = json['data'] != null ? StaffData.fromJson(json['data']) : null;
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['statusCode'] = statusCode;
    json['isSuccess'] = isSuccess;
    json['messages'] = messages;
    if (data != null) {
      json['data'] = data!.toJson();
    }
    json['showPopup'] = showPopup;
    json['popupMessage'] = popupMessage;
    return json;
  }
}

class StaffData {
  int? id;
  int? staffId;
  String? staffReg;
  String? name;
  String? userName;
  String? fhname;
  String? dob;
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
  String? dateofJoining;
  String? staffPic;
  String? idproof;
  String? licenceImages;
  String? callLetter;
  dynamic isActive;
  dynamic createDate;
  dynamic updateDate;
  dynamic createBy;
  String? aadharNo;
  dynamic userId;
  String? password;
  String? licenceNo;
  dynamic updateBy;
  dynamic tpassword;
  dynamic schoolId;
  dynamic schoolName;
  dynamic schoolEmail;
  dynamic schoolPhone;
  dynamic schoolAddress;
  dynamic accessToker;

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

  StaffData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    staffId = json['staffId'];
    staffReg = json['staffReg']?.toString();
    name = json['name']?.toString();
    userName = json['userName']?.toString();
    fhname = json['fhname']?.toString();
    dob = json['dob']?.toString();
    caste = json['caste']?.toString();
    bloodGroup = json['bloodGroup']?.toString();
    gender = json['gender']?.toString();
    address = json['address']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    emailid = json['emailid']?.toString();
    mobileNo = json['mobileNo']?.toString();
    staffTypeId = json['staffTypeId'];
    qualification = json['qualification']?.toString();
    lastOrganization = json['lastOrganization']?.toString();
    totalExperience = json['totalExperience']?.toString();
    specialization = json['specialization']?.toString();
    designation = json['designation']?.toString();
    staffType = json['staffType']?.toString();
    bankName = json['bankName']?.toString();
    accountNo = json['accountNo']?.toString();
    ifsccode = json['ifsccode']?.toString();
    salary = json['salary']?.toString();
    dateofJoining = json['dateofJoining']?.toString();
    staffPic = json['staffPic']?.toString();
    idproof = json['idproof']?.toString();
    licenceImages = json['licenceImages']?.toString();
    callLetter = json['callLetter']?.toString();
    isActive = json['isActive'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    aadharNo = json['aadharNo']?.toString();
    userId = json['userId'];
    password = json['password']?.toString();
    licenceNo = json['licenceNo']?.toString();
    updateBy = json['updateBy'];
    tpassword = json['tpassword'];
    schoolId = json['schoolId'];
    schoolName = json['schoolName'];
    schoolEmail = json['schoolEmail'];
    schoolPhone = json['schoolPhone'];
    schoolAddress = json['schoolAddress'];
    accessToker = json['accessToker'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['id'] = id;
    json['staffId'] = staffId;
    json['staffReg'] = staffReg;
    json['name'] = name;
    json['userName'] = userName;
    json['fhname'] = fhname;
    json['dob'] = dob;
    json['caste'] = caste;
    json['bloodGroup'] = bloodGroup;
    json['gender'] = gender;
    json['address'] = address;
    json['city'] = city;
    json['state'] = state;
    json['emailid'] = emailid;
    json['mobileNo'] = mobileNo;
    json['staffTypeId'] = staffTypeId;
    json['qualification'] = qualification;
    json['lastOrganization'] = lastOrganization;
    json['totalExperience'] = totalExperience;
    json['specialization'] = specialization;
    json['designation'] = designation;
    json['staffType'] = staffType;
    json['bankName'] = bankName;
    json['accountNo'] = accountNo;
    json['ifsccode'] = ifsccode;
    json['salary'] = salary;
    json['dateofJoining'] = dateofJoining;
    json['staffPic'] = staffPic;
    json['idproof'] = idproof;
    json['licenceImages'] = licenceImages;
    json['callLetter'] = callLetter;
    json['isActive'] = isActive;
    json['createDate'] = createDate;
    json['updateDate'] = updateDate;
    json['createBy'] = createBy;
    json['aadharNo'] = aadharNo;
    json['userId'] = userId;
    json['password'] = password;
    json['licenceNo'] = licenceNo;
    json['updateBy'] = updateBy;
    json['tpassword'] = tpassword;
    json['schoolId'] = schoolId;
    json['schoolName'] = schoolName;
    json['schoolEmail'] = schoolEmail;
    json['schoolPhone'] = schoolPhone;
    json['schoolAddress'] = schoolAddress;
    json['accessToker'] = accessToker;
    return json;
  }
}