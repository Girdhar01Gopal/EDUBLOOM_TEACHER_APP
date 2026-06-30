class PreschoolReceiptModel {
  final int? studentID;
  final int? totalStudent;
  final int? totalBirthdaysToday;
  final String? studentName;
  final String? gender;
  final String? fatherName;
  final String? motherName;
  final String? fatherOccupation;
  final DateTime? dateOfBirth;
  final DateTime? dateOfBirth1;
  final int? classId;
  final int? sectionId;
  final String? className;
  final String? nationality;
  final String? sectionName;
  final String? rollNo;
  final String? bloodGroup;
  final String? religion;
  final DateTime? admissionDate;
  final String? parentId;
  final String? phone;
  final String? whatsAppNo;
  final String? emergencyNo;
  final DateTime? createDate;
  final String? email;
  final String? updateBy;
  final String? session;
  final String? ppassword;
  final String? registrationNo;
  final String? action;
  final String? studentPic;
  final String? fatherPic;
  final String? motherPic;
  final String? guardianImage;
  final int? feesDurationId;
  final String? feesDuration;
  final String? status;
  final String? fromTime;
  final String? toTime;
  final String? schoolId;
  final String? feesType;
  final String? feesTypeId;
  final String? discount;
  final String? schoolName;
  final String? affiliated;
  final String? schoolAddress;
  final String? schoolPhone;
  final String? schoolEmail;
  final String? schoolWebsite;
  final String? logo;
  final String? logoWithName;
  final String? address;
  final String? addDaycare;
  final String? birthCertificatePic;
  final String? pickupPoint;
  final String? transportUser;
  final String? aAdharNo;
  final String? isDaycare;
  final String? certificateNo;
  final String? issuedOndate;

  PreschoolReceiptModel({
    this.studentID,
    this.totalStudent,
    this.totalBirthdaysToday,
    this.studentName,
    this.gender,
    this.fatherName,
    this.motherName,
    this.fatherOccupation,
    this.dateOfBirth,
    this.dateOfBirth1,
    this.classId,
    this.sectionId,
    this.className,
    this.nationality,
    this.sectionName,
    this.rollNo,
    this.bloodGroup,
    this.religion,
    this.admissionDate,
    this.parentId,
    this.phone,
    this.whatsAppNo,
    this.emergencyNo,
    this.createDate,
    this.email,
    this.updateBy,
    this.session,
    this.ppassword,
    this.registrationNo,
    this.action,
    this.studentPic,
    this.fatherPic,
    this.motherPic,
    this.guardianImage,
    this.feesDurationId,
    this.feesDuration,
    this.status,
    this.fromTime,
    this.toTime,
    this.schoolId,
    this.feesType,
    this.feesTypeId,
    this.discount,
    this.schoolName,
    this.affiliated,
    this.schoolAddress,
    this.schoolPhone,
    this.schoolEmail,
    this.schoolWebsite,
    this.logo,
    this.logoWithName,
    this.address,
    this.addDaycare,
    this.birthCertificatePic,
    this.pickupPoint,
    this.transportUser,
    this.aAdharNo,
    this.isDaycare,
    this.certificateNo,
    this.issuedOndate,
  });

  factory PreschoolReceiptModel.fromJson(Map<String, dynamic> json) {
    return PreschoolReceiptModel(
      studentID: json['studentID'] as int?,
      totalStudent: json['totalStudent'] as int?,
      totalBirthdaysToday: json['totalBirthdaysToday'] as int?,
      studentName: json['studentName'] as String?,
      gender: json['gender'] as String?,
      fatherName: json['fatherName'] as String?,
      motherName: json['motherName'] as String?,
      fatherOccupation: json['fatherOccupation'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      dateOfBirth1: json['dateOfBirth1'] != null
          ? DateTime.tryParse(json['dateOfBirth1'])
          : null,
      classId: json['classId'] as int?,
      sectionId: json['sectionId'] as int?,
      className: json['className'] as String?,
      nationality: json['nationality'] as String?,
      sectionName: json['sectionName'] as String?,
      rollNo: json['rollNo'] as String?,
      bloodGroup: json['bloodGroup'] as String?,
      religion: json['religion'] as String?,
      admissionDate: json['admissionDate'] != null
          ? DateTime.tryParse(json['admissionDate'])
          : null,
      parentId: json['parentId'] as String?,
      phone: json['phone'] as String?,
      whatsAppNo: json['whatsAppNo'] as String?,
      emergencyNo: json['emergencyNo'] as String?,
      createDate: json['createDate'] != null
          ? DateTime.tryParse(json['createDate'])
          : null,
      email: json['email'] as String?,
      updateBy: json['updateBy'] as String?,
      session: json['session'] as String?,
      ppassword: json['ppassword'] as String?,
      registrationNo: json['registrationNo'] as String?,
      action: json['action'] as String?,
      studentPic: json['studentPic'] as String?,
      fatherPic: json['fatherPic'] as String?,
      motherPic: json['motherPic'] as String?,
      guardianImage: json['guardianImage'] as String?,
      feesDurationId: json['feesDurationId'] as int?,
      feesDuration: json['feesDuration'] as String?,
      status: json['status'] as String?,
      fromTime: json['fromTime'] as String?,
      toTime: json['toTime'] as String?,
      schoolId: json['schoolId'] as String?,
      feesType: json['feesType'] as String?,
      feesTypeId: json['feesTypeId'] as String?,
      discount: json['discount'] as String?,
      schoolName: json['schoolName'] as String?,
      affiliated: json['affiliated'] as String?,
      schoolAddress: json['schoolAddress'] as String?,
      schoolPhone: json['schoolPhone'] as String?,
      schoolEmail: json['schoolEmail'] as String?,
      schoolWebsite: json['schoolWebsite'] as String?,
      logo: json['logo'] as String?,
      logoWithName: json['logoWithName'] as String?,
      address: json['address'] as String?,
      addDaycare: json['addDaycare'] as String?,
      birthCertificatePic: json['birthCertificatePic'] as String?,
      pickupPoint: json['pickupPoint'] as String?,
      transportUser: json['transportUser'] as String?,
      aAdharNo: json['aAdharNo'] as String?,
      isDaycare: json['isDaycare'] as String?,
      certificateNo: json['certificateNo'] as String?,
      issuedOndate: json['issuedOndate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'totalStudent': totalStudent,
      'totalBirthdaysToday': totalBirthdaysToday,
      'studentName': studentName,
      'gender': gender,
      'fatherName': fatherName,
      'motherName': motherName,
      'fatherOccupation': fatherOccupation,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'dateOfBirth1': dateOfBirth1?.toIso8601String(),
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'nationality': nationality,
      'sectionName': sectionName,
      'rollNo': rollNo,
      'bloodGroup': bloodGroup,
      'religion': religion,
      'admissionDate': admissionDate?.toIso8601String(),
      'parentId': parentId,
      'phone': phone,
      'whatsAppNo': whatsAppNo,
      'emergencyNo': emergencyNo,
      'createDate': createDate?.toIso8601String(),
      'email': email,
      'updateBy': updateBy,
      'session': session,
      'ppassword': ppassword,
      'registrationNo': registrationNo,
      'action': action,
      'studentPic': studentPic,
      'fatherPic': fatherPic,
      'motherPic': motherPic,
      'guardianImage': guardianImage,
      'feesDurationId': feesDurationId,
      'feesDuration': feesDuration,
      'status': status,
      'fromTime': fromTime,
      'toTime': toTime,
      'schoolId': schoolId,
      'feesType': feesType,
      'feesTypeId': feesTypeId,
      'discount': discount,
      'schoolName': schoolName,
      'affiliated': affiliated,
      'schoolAddress': schoolAddress,
      'schoolPhone': schoolPhone,
      'schoolEmail': schoolEmail,
      'schoolWebsite': schoolWebsite,
      'logo': logo,
      'logoWithName': logoWithName,
      'address': address,
      'addDaycare': addDaycare,
      'birthCertificatePic': birthCertificatePic,
      'pickupPoint': pickupPoint,
      'transportUser': transportUser,
      'aAdharNo': aAdharNo,
      'isDaycare': isDaycare,
      'certificateNo': certificateNo,
      'issuedOndate': issuedOndate,
    };
  }

  PreschoolReceiptModel copyWith({
    int? studentID,
    int? totalStudent,
    int? totalBirthdaysToday,
    String? studentName,
    String? gender,
    String? fatherName,
    String? motherName,
    String? fatherOccupation,
    DateTime? dateOfBirth,
    DateTime? dateOfBirth1,
    int? classId,
    int? sectionId,
    String? className,
    String? nationality,
    String? sectionName,
    String? rollNo,
    String? bloodGroup,
    String? religion,
    DateTime? admissionDate,
    String? parentId,
    String? phone,
    String? whatsAppNo,
    String? emergencyNo,
    DateTime? createDate,
    String? email,
    String? updateBy,
    String? session,
    String? ppassword,
    String? registrationNo,
    String? action,
    String? studentPic,
    String? fatherPic,
    String? motherPic,
    String? guardianImage,
    int? feesDurationId,
    String? feesDuration,
    String? status,
    String? fromTime,
    String? toTime,
    String? schoolId,
    String? feesType,
    String? feesTypeId,
    String? discount,
    String? schoolName,
    String? affiliated,
    String? schoolAddress,
    String? schoolPhone,
    String? schoolEmail,
    String? schoolWebsite,
    String? logo,
    String? logoWithName,
    String? address,
    String? addDaycare,
    String? birthCertificatePic,
    String? pickupPoint,
    String? transportUser,
    String? aAdharNo,
    String? isDaycare,
    String? certificateNo,
    String? issuedOndate,
  }) {
    return PreschoolReceiptModel(
      studentID: studentID ?? this.studentID,
      totalStudent: totalStudent ?? this.totalStudent,
      totalBirthdaysToday: totalBirthdaysToday ?? this.totalBirthdaysToday,
      studentName: studentName ?? this.studentName,
      gender: gender ?? this.gender,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      fatherOccupation: fatherOccupation ?? this.fatherOccupation,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfBirth1: dateOfBirth1 ?? this.dateOfBirth1,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      className: className ?? this.className,
      nationality: nationality ?? this.nationality,
      sectionName: sectionName ?? this.sectionName,
      rollNo: rollNo ?? this.rollNo,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      religion: religion ?? this.religion,
      admissionDate: admissionDate ?? this.admissionDate,
      parentId: parentId ?? this.parentId,
      phone: phone ?? this.phone,
      whatsAppNo: whatsAppNo ?? this.whatsAppNo,
      emergencyNo: emergencyNo ?? this.emergencyNo,
      createDate: createDate ?? this.createDate,
      email: email ?? this.email,
      updateBy: updateBy ?? this.updateBy,
      session: session ?? this.session,
      ppassword: ppassword ?? this.ppassword,
      registrationNo: registrationNo ?? this.registrationNo,
      action: action ?? this.action,
      studentPic: studentPic ?? this.studentPic,
      fatherPic: fatherPic ?? this.fatherPic,
      motherPic: motherPic ?? this.motherPic,
      guardianImage: guardianImage ?? this.guardianImage,
      feesDurationId: feesDurationId ?? this.feesDurationId,
      feesDuration: feesDuration ?? this.feesDuration,
      status: status ?? this.status,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      schoolId: schoolId ?? this.schoolId,
      feesType: feesType ?? this.feesType,
      feesTypeId: feesTypeId ?? this.feesTypeId,
      discount: discount ?? this.discount,
      schoolName: schoolName ?? this.schoolName,
      affiliated: affiliated ?? this.affiliated,
      schoolAddress: schoolAddress ?? this.schoolAddress,
      schoolPhone: schoolPhone ?? this.schoolPhone,
      schoolEmail: schoolEmail ?? this.schoolEmail,
      schoolWebsite: schoolWebsite ?? this.schoolWebsite,
      logo: logo ?? this.logo,
      logoWithName: logoWithName ?? this.logoWithName,
      address: address ?? this.address,
      addDaycare: addDaycare ?? this.addDaycare,
      birthCertificatePic: birthCertificatePic ?? this.birthCertificatePic,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      transportUser: transportUser ?? this.transportUser,
      aAdharNo: aAdharNo ?? this.aAdharNo,
      isDaycare: isDaycare ?? this.isDaycare,
      certificateNo: certificateNo ?? this.certificateNo,
      issuedOndate: issuedOndate ?? this.issuedOndate,
    );
  }

  @override
  String toString() {
    return 'PreschoolReceiptModel(studentID: $studentID, studentName: $studentName, schoolName: $schoolName, registrationNo: $registrationNo)';
  }
}

// ─── Wrapper model for the full API response ───────────────────────────────

class PreschoolReceiptResponse {
  final List<PreschoolReceiptModel> listData;

  PreschoolReceiptResponse({required this.listData});

  factory PreschoolReceiptResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['listData'] as List<dynamic>? ?? [];
    return PreschoolReceiptResponse(
      listData: rawList
          .map((e) =>
          PreschoolReceiptModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((e) => e.toJson()).toList(),
    };
  }
}