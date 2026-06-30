class ImageModel {
  String? message;
  List<Data>? data;
  int? statuscode;
  int? totalCount;

  ImageModel({this.message, this.data, this.statuscode, this.totalCount});

  ImageModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    statuscode = json['statuscode'];
    totalCount = json['totalCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statuscode'] = this.statuscode;
    data['totalCount'] = this.totalCount;
    return data;
  }
}

class Data {
  int? appId;
  String? image;
  int? mAppId;
  int? mAppId1;
  String? typeofIcon;
  var image1;
  var type;
  var sequence;
  var header;
  var schoolId;
  int? action;
  String? createBy;
  var result;
  var updateBy;
  String? updateDate;
  String? createDate;
  bool? isActive;
  String? createdDate;
  String? date;
  String? modifiedDate;
  int? createdby;
  int? updatedby;

  Data(
      {this.appId,
      this.image,
      this.mAppId,
      this.mAppId1,
      this.typeofIcon,
      this.image1,
      this.type,
      this.sequence,
      this.header,
      this.schoolId,
      this.action,
      this.createBy,
      this.result,
      this.updateBy,
      this.updateDate,
      this.createDate,
      this.isActive,
      this.createdDate,
      this.date,
      this.modifiedDate,
      this.createdby,
      this.updatedby});

  Data.fromJson(Map<String, dynamic> json) {
    appId = json['AppId'];
    image = json['Image'];
    mAppId = json['MAppId'];
    mAppId1 = json['MAppId1'];
    typeofIcon = json['TypeofIcon'];
    image1 = json['Image1'];
    type = json['Type'];
    sequence = json['Sequence'];
    header = json['Header'];
    schoolId = json['SchoolId'];
    action = json['Action'];
    createBy = json['CreateBy'];
    result = json['Result'];
    updateBy = json['UpdateBy'];
    updateDate = json['UpdateDate'];
    createDate = json['CreateDate'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    date = json['Date'];
    modifiedDate = json['ModifiedDate'];
    createdby = json['Createdby'];
    updatedby = json['Updatedby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AppId'] = this.appId;
    data['Image'] = this.image;
    data['MAppId'] = this.mAppId;
    data['MAppId1'] = this.mAppId1;
    data['TypeofIcon'] = this.typeofIcon;
    data['Image1'] = this.image1;
    data['Type'] = this.type;
    data['Sequence'] = this.sequence;
    data['Header'] = this.header;
    data['SchoolId'] = this.schoolId;
    data['Action'] = this.action;
    data['CreateBy'] = this.createBy;
    data['Result'] = this.result;
    data['UpdateBy'] = this.updateBy;
    data['UpdateDate'] = this.updateDate;
    data['CreateDate'] = this.createDate;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['Date'] = this.date;
    data['ModifiedDate'] = this.modifiedDate;
    data['Createdby'] = this.createdby;
    data['Updatedby'] = this.updatedby;
    return data;
  }
}
