class SchoolDetailModel {
  int? iD;
  var principalUserName;
  var principalPassword;
  var adminUserName;
  var adminPassword;
  var accountantUserName;
  var accountantPassword;
  String? schoolName;
  var affiliationNumber;
  var uDISENumber;
  var schoolNumber;
  var principalName;
  var principalMobNo;
  var adminOfficerName;
  var adminOfficerMobNo;
  var accountantName;
  var accountantMobNo;
  var phoneNumber1;
  var phoneNumber2;
  var mobileNumber;
  var schoolEmailID;
  var principalEmailID;
  var accountsDepartmentEmailID;
  var schoolAddress;
  var uploadLogo1;
  var uploadLogo2;
  String? schoolId;
  String? createBy;
  String? action;
  String? createDate;
  String? applicationURL;
  String? city;
  String? state;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  SchoolDetailModel(
      {this.iD,
        this.principalUserName,
        this.principalPassword,
        this.adminUserName,
        this.adminPassword,
        this.accountantUserName,
        this.accountantPassword,
        this.schoolName,
        this.affiliationNumber,
        this.uDISENumber,
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
        this.schoolEmailID,
        this.principalEmailID,
        this.accountsDepartmentEmailID,
        this.schoolAddress,
        this.uploadLogo1,
        this.uploadLogo2,
        this.schoolId,
        this.createBy,
        this.action,
        this.createDate,
        this.applicationURL,
        this.city,
        this.state,
        this.isActive,
        this.createdDate,
        this.date,
        this.modifiedDate,
        this.createdby,
        this.updatedby});

  SchoolDetailModel.fromJson(Map<String, dynamic> json) {
    iD = json['ID'];
    principalUserName = json['PrincipalUserName'];
    principalPassword = json['PrincipalPassword'];
    adminUserName = json['AdminUserName'];
    adminPassword = json['AdminPassword'];
    accountantUserName = json['AccountantUserName'];
    accountantPassword = json['AccountantPassword'];
    schoolName = json['SchoolName'];
    affiliationNumber = json['AffiliationNumber'];
    uDISENumber = json['UDISENumber'];
    schoolNumber = json['SchoolNumber'];
    principalName = json['PrincipalName'];
    principalMobNo = json['PrincipalMobNo'];
    adminOfficerName = json['AdminOfficerName'];
    adminOfficerMobNo = json['AdminOfficerMobNo'];
    accountantName = json['AccountantName'];
    accountantMobNo = json['AccountantMobNo'];
    phoneNumber1 = json['PhoneNumber1'];
    phoneNumber2 = json['PhoneNumber2'];
    mobileNumber = json['MobileNumber'];
    schoolEmailID = json['SchoolEmailID'];
    principalEmailID = json['PrincipalEmailID'];
    accountsDepartmentEmailID = json['AccountsDepartmentEmailID'];
    schoolAddress = json['SchoolAddress'];
    uploadLogo1 = json['UploadLogo1'];
    uploadLogo2 = json['UploadLogo2'];
    schoolId = json['SchoolId'];
    createBy = json['CreateBy'];
    action = json['Action'];
    createDate = json['CreateDate'];
    applicationURL = json['ApplicationURL'];
    city = json['City'];
    state = json['State'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdby = json['Createdby'];
    updatedby = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ID'] = this.iD;
    data['PrincipalUserName'] = this.principalUserName;
    data['PrincipalPassword'] = this.principalPassword;
    data['AdminUserName'] = this.adminUserName;
    data['AdminPassword'] = this.adminPassword;
    data['AccountantUserName'] = this.accountantUserName;
    data['AccountantPassword'] = this.accountantPassword;
    data['SchoolName'] = this.schoolName;
    data['AffiliationNumber'] = this.affiliationNumber;
    data['UDISENumber'] = this.uDISENumber;
    data['SchoolNumber'] = this.schoolNumber;
    data['PrincipalName'] = this.principalName;
    data['PrincipalMobNo'] = this.principalMobNo;
    data['AdminOfficerName'] = this.adminOfficerName;
    data['AdminOfficerMobNo'] = this.adminOfficerMobNo;
    data['AccountantName'] = this.accountantName;
    data['AccountantMobNo'] = this.accountantMobNo;
    data['PhoneNumber1'] = this.phoneNumber1;
    data['PhoneNumber2'] = this.phoneNumber2;
    data['MobileNumber'] = this.mobileNumber;
    data['SchoolEmailID'] = this.schoolEmailID;
    data['PrincipalEmailID'] = this.principalEmailID;
    data['AccountsDepartmentEmailID'] = this.accountsDepartmentEmailID;
    data['SchoolAddress'] = this.schoolAddress;
    data['UploadLogo1'] = this.uploadLogo1;
    data['UploadLogo2'] = this.uploadLogo2;
    data['SchoolId'] = this.schoolId;
    data['CreateBy'] = this.createBy;
    data['Action'] = this.action;
    data['CreateDate'] = this.createDate;
    data['ApplicationURL'] = this.applicationURL;
    data['City'] = this.city;
    data['State'] = this.state;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}
