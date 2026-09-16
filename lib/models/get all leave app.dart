// get_all_leave_app_model.dart
// Generated from GetAllLeveApp API response
// Endpoint: /api/SchoolApp/GetAllLeveApp/{schoolCode}/{userId}

class GetAllLeaveAppResponse {
  final int? statusCode;
  final bool? isSuccess;
  final String? messages;
  final List<EmployeeLeaveData> data;
  final bool? showPopup;
  final String? popupMessage;

  GetAllLeaveAppResponse({
    this.statusCode,
    this.isSuccess,
    this.messages,
    required this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory GetAllLeaveAppResponse.fromJson(Map<String, dynamic> json) {
    return GetAllLeaveAppResponse(
      statusCode: json['statusCode'],
      isSuccess: json['isSuccess'],
      messages: json['messages'],
      data: json['data'] != null
          ? List<EmployeeLeaveData>.from(
          (json['data'] as List).map((x) => EmployeeLeaveData.fromJson(x)))
          : [],
      showPopup: json['showPopup'],
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data.map((x) => x.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class EmployeeLeaveData {
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? password;
  final String? email;
  final String? contact;
  final String? role;
  final int? roleId;
  final int? staffTypeId;
  final String? staffTypeName;
  final int? tdId;
  final String? teacherTypeName;
  final String? registrationNo;
  final int? leaveId;
  final String? leave;
  final int? noOfDay;
  final int? totalLeave;
  final String? takenLeaveTypes;
  final int? totalTaken;
  final int? remainingLeave;

  EmployeeLeaveData({
    this.userId,
    this.firstName,
    this.lastName,
    this.userName,
    this.password,
    this.email,
    this.contact,
    this.role,
    this.roleId,
    this.staffTypeId,
    this.staffTypeName,
    this.tdId,
    this.teacherTypeName,
    this.registrationNo,
    this.leaveId,
    this.leave,
    this.noOfDay,
    this.totalLeave,
    this.takenLeaveTypes,
    this.totalTaken,
    this.remainingLeave,
  });

  factory EmployeeLeaveData.fromJson(Map<String, dynamic> json) {
    return EmployeeLeaveData(
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
      leaveId: json['leaveId'],
      leave: json['leave'],
      noOfDay: json['noOfDay'],
      totalLeave: json['totalLeave'],
      takenLeaveTypes: json['takenLeaveTypes'],
      totalTaken: json['totalTaken'],
      remainingLeave: json['remainingLeave'],
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
      'leaveId': leaveId,
      'leave': leave,
      'noOfDay': noOfDay,
      'totalLeave': totalLeave,
      'takenLeaveTypes': takenLeaveTypes,
      'totalTaken': totalTaken,
      'remainingLeave': remainingLeave,
    };
  }

  /// Full name helper (firstName + lastName, handles null lastName)
  String get fullName =>
      lastName != null && lastName!.trim().isNotEmpty ? '$firstName $lastName' : (firstName ?? '');
}