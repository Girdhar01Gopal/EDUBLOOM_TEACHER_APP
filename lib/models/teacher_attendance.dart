class TeacherListResponse {
  final List<TeacherUser> listData;

  TeacherListResponse({required this.listData});

  factory TeacherListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['listData'];
    return TeacherListResponse(
      listData: rawList is List
          ? rawList.map((e) => TeacherUser.fromJson(e as Map<String, dynamic>)).toList()
          : <TeacherUser>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'listData': listData.map((e) => e.toJson()).toList(),
  };
}

class TeacherUser {
  final int? userId;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? userEmail;
  final String? mobileNumber;
  final String? gender;

  final DateTime? dateOfBirth;
  final DateTime? date;
  final bool? isActive;
  final String? roleName;
  final DateTime? createdAt;
  final String? status;

  final TeacherAttendance? teacherAttendance; // ✅ proper model
  final DateTime? adDate;

  final AdditionalDetail? additionalDetail;

  TeacherUser({
    this.userId,
    this.firstName,
    this.lastName,
    this.userName,
    this.userEmail,
    this.mobileNumber,
    this.gender,
    this.dateOfBirth,
    this.date,
    this.isActive,
    this.roleName,
    this.createdAt,
    this.status,
    this.teacherAttendance,
    this.adDate,
    this.additionalDetail,
  });

  factory TeacherUser.fromJson(Map<String, dynamic> json) {
    return TeacherUser(
      userId: _asInt(json['userId']),
      firstName: _asString(json['firstName']),
      lastName: _asString(json['lastName']),
      userName: _asString(json['userName']),
      userEmail: _asString(json['userEmail']),
      mobileNumber: _asString(json['mobileNumber']),
      gender: _asString(json['gender']),

      dateOfBirth: _asDate(json['dateOfBirth']),
      date: _asDate(json['date']),
      isActive: _asBool(json['isActive']),
      roleName: _asString(json['roleName']),
      createdAt: _asDate(json['createdAt']),
      status: _asString(json['status']),

      // ✅ teacherAttendance can be null OR object OR list -> safe
      teacherAttendance: TeacherAttendance.fromAny(json['teacherAttendance']),

      adDate: _asDate(json['adDate']),
      additionalDetail: json['additionalDetail'] is Map<String, dynamic>
          ? AdditionalDetail.fromJson(json['additionalDetail'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'firstName': firstName,
    'lastName': lastName,
    'userName': userName,
    'userEmail': userEmail,
    'mobileNumber': mobileNumber,
    'gender': gender,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'date': date?.toIso8601String(),
    'isActive': isActive,
    'roleName': roleName,
    'createdAt': createdAt?.toIso8601String(),
    'status': status,
    'teacherAttendance': teacherAttendance?.toJson(),
    'adDate': adDate?.toIso8601String(),
    'additionalDetail': additionalDetail?.toJson(),
  };
}

class AdditionalDetail {
  final String? registrationNo;
  final String? qualification;
  final String? salary;
  final String? specialization;
  final String? address;
  final String? city;
  final String? state;
  final int? totalExperience;
  final DateTime? joiningDate;
  final int? tdId;
  final String? designation;
  final int? staffTypeId;
  final String? staffTypeName;

  AdditionalDetail({
    this.registrationNo,
    this.qualification,
    this.salary,
    this.specialization,
    this.address,
    this.city,
    this.state,
    this.totalExperience,
    this.joiningDate,
    this.tdId,
    this.designation,
    this.staffTypeId,
    this.staffTypeName,
  });

  factory AdditionalDetail.fromJson(Map<String, dynamic> json) {
    return AdditionalDetail(
      registrationNo: _asString(json['registrationNo']),
      qualification: _asString(json['qualification']),
      salary: _asString(json['salary']),
      specialization: _asString(json['specialization']),
      address: _asString(json['address']),
      city: _asString(json['city']),
      state: _asString(json['state']),
      totalExperience: _asInt(json['totalExperience']),
      joiningDate: _asDate(json['joiningDate']),
      tdId: _asInt(json['tdId']),
      designation: _asString(json['designation'])?.trim(),
      staffTypeId: _asInt(json['staffTypeId']),
      staffTypeName: _asString(json['staffTypeName']),
    );
  }

  Map<String, dynamic> toJson() => {
    'registrationNo': registrationNo,
    'qualification': qualification,
    'salary': salary,
    'specialization': specialization,
    'address': address,
    'city': city,
    'state': state,
    'totalExperience': totalExperience,
    'joiningDate': joiningDate?.toIso8601String(),
    'tdId': tdId,
    'designation': designation,
    'staffTypeId': staffTypeId,
    'staffTypeName': staffTypeName,
  };
}

/// ✅ TeacherAttendance model (safe even when API changes)
class TeacherAttendance {
  /// Sometimes backend sends an object, sometimes list, sometimes null.
  /// We'll store normalized data here.
  final String? attendanceStatus;
  final DateTime? attendanceDate;
  final String? inTime;
  final String? outTime;
  final int? attendanceId;

  /// If backend sends unknown extra keys, we keep them (future-proof).
  final Map<String, dynamic>? extra;

  TeacherAttendance({
    this.attendanceStatus,
    this.attendanceDate,
    this.inTime,
    this.outTime,
    this.attendanceId,
    this.extra,
  });

  /// ✅ Accepts null / Map / List and never crashes
  static TeacherAttendance? fromAny(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return TeacherAttendance.fromJson(value);
    }

    // If backend sends list, pick first item (common pattern)
    if (value is List && value.isNotEmpty && value.first is Map<String, dynamic>) {
      return TeacherAttendance.fromJson(value.first as Map<String, dynamic>);
    }

    // Unknown format -> don't crash
    return TeacherAttendance(extra: {'raw': value});
  }

  factory TeacherAttendance.fromJson(Map<String, dynamic> json) {
    return TeacherAttendance(
      attendanceStatus: _asString(json['status'] ?? json['attendanceStatus']),
      attendanceDate: _asDate(json['date'] ?? json['attendanceDate']),
      inTime: _asString(json['inTime']),
      outTime: _asString(json['outTime']),
      attendanceId: _asInt(json['id'] ?? json['attendanceId']),
      extra: json,
    );
  }

  Map<String, dynamic> toJson() => {
    'attendanceStatus': attendanceStatus,
    'attendanceDate': attendanceDate?.toIso8601String(),
    'inTime': inTime,
    'outTime': outTime,
    'attendanceId': attendanceId,
    if (extra != null) 'extra': extra,
  };
}

/* -------------------------
   ✅ Safe parsing helpers
------------------------- */

String? _asString(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  final s = v.toString();
  return DateTime.tryParse(s);
}