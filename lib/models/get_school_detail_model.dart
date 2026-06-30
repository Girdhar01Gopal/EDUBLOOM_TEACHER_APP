class GetSchoolDetailModel {
  int? uRLID;
  String? applicationURL;
  String? appurl;
  String? appName;
  int? action;
  String? schoolId;
  var smsUname;
  var smspass;
  var smsHeader;
  var smsUrl;
  String? schoolName;
  String? affiliationNumber;
  String? uDISENumber;
  var schoolNumber;
  String? phoneNumber1;
  var phoneNumber2;
  String? mobileNumber;
  String? schoolEmailID;
  String? schoolAddress;
  String? uploadLogo1;
  String? uploadLogo2;
  String? schoolWebSite;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  GetSchoolDetailModel(
      {this.uRLID,
        this.applicationURL,
        this.appurl,
        this.appName,
        this.action,
        this.schoolId,
        this.smsUname,
        this.smspass,
        this.smsHeader,
        this.smsUrl,
        this.schoolName,
        this.affiliationNumber,
        this.uDISENumber,
        this.schoolNumber,
        this.phoneNumber1,
        this.phoneNumber2,
        this.mobileNumber,
        this.schoolEmailID,
        this.schoolAddress,
        this.uploadLogo1,
        this.uploadLogo2,
        this.schoolWebSite,
        this.isActive,
        this.createdDate,
        this.date,
        this.modifiedDate,
        this.createdby,
        this.updatedby});

  GetSchoolDetailModel.fromJson(Map<String, dynamic> json) {
    uRLID = json['URLID'];
    applicationURL = json['ApplicationURL'];
    appurl = json['Appurl'];
    appName = json['AppName'];
    action = json['Action'];
    schoolId = json['SchoolId'];
    smsUname = json['SmsUname'];
    smspass = json['Smspass'];
    smsHeader = json['SmsHeader'];
    smsUrl = json['SmsUrl'];
    schoolName = json['SchoolName'];
    affiliationNumber = json['AffiliationNumber'];
    uDISENumber = json['UDISENumber'];
    schoolNumber = json['SchoolNumber'];
    phoneNumber1 = json['PhoneNumber1'];
    phoneNumber2 = json['PhoneNumber2'];
    mobileNumber = json['MobileNumber'];
    schoolEmailID = json['SchoolEmailID'];
    schoolAddress = json['SchoolAddress'];
    uploadLogo1 = json['UploadLogo1'];
    uploadLogo2 = json['UploadLogo2'];
    schoolWebSite = json['SchoolWebSite'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdby = json['Createdby'];
    updatedby = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['URLID'] = this.uRLID;
    data['ApplicationURL'] = this.applicationURL;
    data['Appurl'] = this.appurl;
    data['AppName'] = this.appName;
    data['Action'] = this.action;
    data['SchoolId'] = this.schoolId;
    data['SmsUname'] = this.smsUname;
    data['Smspass'] = this.smspass;
    data['SmsHeader'] = this.smsHeader;
    data['SmsUrl'] = this.smsUrl;
    data['SchoolName'] = this.schoolName;
    data['AffiliationNumber'] = this.affiliationNumber;
    data['UDISENumber'] = this.uDISENumber;
    data['SchoolNumber'] = this.schoolNumber;
    data['PhoneNumber1'] = this.phoneNumber1;
    data['PhoneNumber2'] = this.phoneNumber2;
    data['MobileNumber'] = this.mobileNumber;
    data['SchoolEmailID'] = this.schoolEmailID;
    data['SchoolAddress'] = this.schoolAddress;
    data['UploadLogo1'] = this.uploadLogo1;
    data['UploadLogo2'] = this.uploadLogo2;
    data['SchoolWebSite'] = this.schoolWebSite;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}
