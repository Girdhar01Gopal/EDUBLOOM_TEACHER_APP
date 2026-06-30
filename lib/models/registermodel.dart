class registermodel {
  int? statusCode;
  bool? isSuccess;
  Null? messages;
  List<Data>? data;
  bool? showPopup;
  Null? popupMessage;

  registermodel(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  registermodel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['isSuccess'] = this.isSuccess;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['showPopup'] = this.showPopup;
    data['popupMessage'] = this.popupMessage;
    return data;
  }
}

class Data {
  String? sclInfoId;
  String? users;
  String? schoolName;
  String? email;
  String? address;
  String? phone;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? state;
  String? city;
  String? distec;
  String? password;
  String? currentSession;
  String? logo;
  String? logoWithName;

  Data(
      {this.sclInfoId,
      this.users,
      this.schoolName,
      this.email,
      this.address,
      this.phone,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.state,
      this.city,
      this.distec,
      this.password,
      this.currentSession,
      this.logo,
      this.logoWithName});

  Data.fromJson(Map<String, dynamic> json) {
    sclInfoId = json['sclInfoId'];
    users = json['users'];
    schoolName = json['schoolName'];
    email = json['email'];
    address = json['address'];
    phone = json['phone'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    state = json['state'];
    city = json['city'];
    distec = json['distec'];
    password = json['password'];
    currentSession = json['currentSession'];
    logo = json['logo'];
    logoWithName = json['logoWithName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sclInfoId'] = this.sclInfoId;
    data['users'] = this.users;
    data['schoolName'] = this.schoolName;
    data['email'] = this.email;
    data['address'] = this.address;
    data['phone'] = this.phone;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['state'] = this.state;
    data['city'] = this.city;
    data['distec'] = this.distec;
    data['password'] = this.password;
    data['currentSession'] = this.currentSession;
    data['logo'] = this.logo;
    data['logoWithName'] = this.logoWithName;
    return data;
  }
}