class Login_Model {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  Data? data;
  bool? showPopup;
  Null? popupMessage;

  Login_Model(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  Login_Model.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['isSuccess'] = this.isSuccess;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['showPopup'] = this.showPopup;
    data['popupMessage'] = this.popupMessage;
    return data;
  }
}

class Data {
  int? userId;
  AccessToker? accessToker;
  String? userName;
  String? schoolId;
  String? currentSession;
  Role? role;
  String? name;
  String? schoolName;
  String? logoWithName;
  String? webandApp;

  Data(
      {this.userId,
      this.accessToker,
      this.userName,
      this.schoolId,
      this.currentSession,
      this.role,
      this.name,
      this.schoolName,
      this.logoWithName,
      this.webandApp});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    accessToker = json['accessToker'] != null
        ? new AccessToker.fromJson(json['accessToker'])
        : null;
    userName = json['userName'];
    schoolId = json['schoolId'];
    currentSession = json['currentSession'];
    role = json['role'] != null ? new Role.fromJson(json['role']) : null;
    name = json['name'];
    schoolName = json['schoolName'];
    logoWithName = json['logoWithName'];
    webandApp = json['webandApp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    if (this.accessToker != null) {
      data['accessToker'] = this.accessToker!.toJson();
    }
    data['userName'] = this.userName;
    data['schoolId'] = this.schoolId;
    data['currentSession'] = this.currentSession;
    if (this.role != null) {
      data['role'] = this.role!.toJson();
    }
    data['name'] = this.name;
    data['schoolName'] = this.schoolName;
    data['logoWithName'] = this.logoWithName;
    data['webandApp'] = this.webandApp;
    return data;
  }
}

class AccessToker {
  String? token;
  String? expireIn;

  AccessToker({this.token, this.expireIn});

  AccessToker.fromJson(Map<String, dynamic> json) {
    token = json['token'];
    expireIn = json['expireIn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['token'] = this.token;
    data['expireIn'] = this.expireIn;
    return data;
  }
}

class Role {
  int? roleId;
  String? roleName;
  int? userRole;

  Role({this.roleId, this.roleName, this.userRole});

  Role.fromJson(Map<String, dynamic> json) {
    roleId = json['roleId'];
    roleName = json['roleName'];
    userRole = json['userRole'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['roleId'] = this.roleId;
    data['roleName'] = this.roleName;
    data['userRole'] = this.userRole;
    return data;
  }
}