class SchoolUsersModel {
  final int statusCode;
  final bool isSuccess;
  final String messages;
  final List<SchoolUser> data;
  final bool showPopup;
  final String? popupMessage;

  SchoolUsersModel({
    required this.statusCode,
    required this.isSuccess,
    required this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory SchoolUsersModel.fromJson(Map<String, dynamic> json) {
    return SchoolUsersModel(
      statusCode: json['statusCode'],
      isSuccess: json['isSuccess'],
      messages: json['messages'],
      data: (json['data'] as List)
          .map((e) => SchoolUser.fromJson(e))
          .toList(),
      showPopup: json['showPopup'],
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data.map((e) => e.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class SchoolUser {
  final int userId;
  final String firstName;
  final String? lastName;
  final String userName;
  final String password;
  final String email;
  final String? contact;
  final String role;
  final int roleId;
  final int? staffTypeId;
  final String? staffTypeName;
  final int? tdId;
  final String? teacherTypeName;
  final String registrationNo;

  SchoolUser({
    required this.userId,
    required this.firstName,
    this.lastName,
    required this.userName,
    required this.password,
    required this.email,
    this.contact,
    required this.role,
    required this.roleId,
    this.staffTypeId,
    this.staffTypeName,
    this.tdId,
    this.teacherTypeName,
    required this.registrationNo,
  });

  factory SchoolUser.fromJson(Map<String, dynamic> json) {
    return SchoolUser(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      userName: json['userName'],
      password: json['password'],
      email: json['email'],
      contact: json['contact'],
      role: json['role'],
      roleId: json['roleId'],
      staffTypeId: json['staffTypeId'],
      staffTypeName: json['staffTypeName'],
      tdId: json['tdId'],
      teacherTypeName: json['teacherTypeName'],
      registrationNo: json['registrationNo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'password': password,
      'email': email,
      'contact': contact,
      'role': role,
      'roleId': roleId,
      'staffTypeId': staffTypeId,
      'staffTypeName': staffTypeName,
      'tdId': tdId,
      'teacherTypeName': teacherTypeName,
      'registrationNo': registrationNo,
    };
  }
}