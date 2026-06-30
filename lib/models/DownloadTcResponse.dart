// ============================================================
// download_tc_model.dart
// Auto-generated Dart model for Download TC API Response
// ============================================================

class DownloadTcResponse {
  final int statusCode;
  final bool isSuccess;
  final String messages;
  final List<DownloadTcModel> data;
  final bool showPopup;
  final String? popupMessage;

  DownloadTcResponse({
    required this.statusCode,
    required this.isSuccess,
    required this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory DownloadTcResponse.fromJson(Map<String, dynamic> json) {
    return DownloadTcResponse(
      statusCode: json['statusCode'] as int? ?? 0,
      isSuccess: json['isSuccess'] as bool? ?? false,
      messages: json['messages'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => DownloadTcModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      showPopup: json['showPopup'] as bool? ?? false,
      popupMessage: json['popupMessage'] as String?,
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

  @override
  String toString() {
    return 'DownloadTcResponse(statusCode: $statusCode, isSuccess: $isSuccess, '
        'messages: $messages, data: $data, showPopup: $showPopup, '
        'popupMessage: $popupMessage)';
  }
}

// ============================================================

class DownloadTcModel {
  final int tcId;
  final int stuId;
  final String registrationNo;
  final String schoolName;
  final String? phone;
  final String state;
  final String city;
  final String email;
  final String address;
  final String session;
  final String? schoolId;
  final String studentName;
  final String fatherName;
  final String motherName;
  final String nationality;
  final String className;
  final String? section;
  final String dob;
  final String month14;
  final String conduct20;
  final String issue22;
  final String reasons23;
  final String admissionDate;
  final String remark;
  final String createBy;
  final int sNo;

  DownloadTcModel({
    required this.tcId,
    required this.stuId,
    required this.registrationNo,
    required this.schoolName,
    this.phone,
    required this.state,
    required this.city,
    required this.email,
    required this.address,
    required this.session,
    this.schoolId,
    required this.studentName,
    required this.fatherName,
    required this.motherName,
    required this.nationality,
    required this.className,
    this.section,
    required this.dob,
    required this.month14,
    required this.conduct20,
    required this.issue22,
    required this.reasons23,
    required this.admissionDate,
    required this.remark,
    required this.createBy,
    required this.sNo,
  });

  factory DownloadTcModel.fromJson(Map<String, dynamic> json) {
    return DownloadTcModel(
      tcId: json['tcId'] as int? ?? 0,
      stuId: json['stuId'] as int? ?? 0,
      registrationNo: json['registrationNo'] as String? ?? '',
      schoolName: json['schoolName'] as String? ?? '',
      phone: json['phone'] as String?,
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address: json['address'] as String? ?? '',
      session: json['session'] as String? ?? '',
      schoolId: json['schoolId'] as String?,
      studentName: json['studentName'] as String? ?? '',
      fatherName: json['fatherName'] as String? ?? '',
      motherName: json['motherName'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
      className: json['class'] as String? ?? '',
      section: json['section'] as String?,
      dob: json['dob'] as String? ?? '',
      month14: json['month14'] as String? ?? '',
      conduct20: json['conduct20'] as String? ?? '',
      issue22: json['issue22'] as String? ?? '',
      reasons23: json['reasons23'] as String? ?? '',
      admissionDate: json['admissionDate'] as String? ?? '',
      remark: json['remark'] as String? ?? '',
      createBy: json['createBy'] as String? ?? '',
      sNo: json['sNo'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tcId': tcId,
      'stuId': stuId,
      'registrationNo': registrationNo,
      'schoolName': schoolName,
      'phone': phone,
      'state': state,
      'city': city,
      'email': email,
      'address': address,
      'session': session,
      'schoolId': schoolId,
      'studentName': studentName,
      'fatherName': fatherName,
      'motherName': motherName,
      'nationality': nationality,
      'class': className,
      'section': section,
      'dob': dob,
      'month14': month14,
      'conduct20': conduct20,
      'issue22': issue22,
      'reasons23': reasons23,
      'admissionDate': admissionDate,
      'remark': remark,
      'createBy': createBy,
      'sNo': sNo,
    };
  }

  DownloadTcModel copyWith({
    int? tcId,
    int? stuId,
    String? registrationNo,
    String? schoolName,
    String? phone,
    String? state,
    String? city,
    String? email,
    String? address,
    String? session,
    String? schoolId,
    String? studentName,
    String? fatherName,
    String? motherName,
    String? nationality,
    String? className,
    String? section,
    String? dob,
    String? month14,
    String? conduct20,
    String? issue22,
    String? reasons23,
    String? admissionDate,
    String? remark,
    String? createBy,
    int? sNo,
  }) {
    return DownloadTcModel(
      tcId: tcId ?? this.tcId,
      stuId: stuId ?? this.stuId,
      registrationNo: registrationNo ?? this.registrationNo,
      schoolName: schoolName ?? this.schoolName,
      phone: phone ?? this.phone,
      state: state ?? this.state,
      city: city ?? this.city,
      email: email ?? this.email,
      address: address ?? this.address,
      session: session ?? this.session,
      schoolId: schoolId ?? this.schoolId,
      studentName: studentName ?? this.studentName,
      fatherName: fatherName ?? this.fatherName,
      motherName: motherName ?? this.motherName,
      nationality: nationality ?? this.nationality,
      className: className ?? this.className,
      section: section ?? this.section,
      dob: dob ?? this.dob,
      month14: month14 ?? this.month14,
      conduct20: conduct20 ?? this.conduct20,
      issue22: issue22 ?? this.issue22,
      reasons23: reasons23 ?? this.reasons23,
      admissionDate: admissionDate ?? this.admissionDate,
      remark: remark ?? this.remark,
      createBy: createBy ?? this.createBy,
      sNo: sNo ?? this.sNo,
    );
  }

  @override
  String toString() {
    return 'DownloadTcModel(tcId: $tcId, stuId: $stuId, registrationNo: $registrationNo, '
        'schoolName: $schoolName, phone: $phone, state: $state, city: $city, '
        'email: $email, address: $address, session: $session, schoolId: $schoolId, '
        'studentName: $studentName, fatherName: $fatherName, motherName: $motherName, '
        'nationality: $nationality, className: $className, section: $section, '
        'dob: $dob, month14: $month14, conduct20: $conduct20, issue22: $issue22, '
        'reasons23: $reasons23, admissionDate: $admissionDate, remark: $remark, '
        'createBy: $createBy, sNo: $sNo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DownloadTcModel && other.tcId == tcId && other.stuId == stuId;
  }

  @override
  int get hashCode => tcId.hashCode ^ stuId.hashCode;
}