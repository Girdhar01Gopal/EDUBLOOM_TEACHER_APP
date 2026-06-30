class StationaryFeePrintResponse {
  final List<StationaryFeePrint> listData;

  StationaryFeePrintResponse({required this.listData});

  factory StationaryFeePrintResponse.fromJson(Map<String, dynamic> json) {
    return StationaryFeePrintResponse(
      listData: (json['listData'] as List<dynamic>? ?? [])
          .map((e) => StationaryFeePrint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StationaryFeePrint {
  final int sfeeId;
  final int? pmasterId;
  final String product;
  final String? createBy;
  final String? updateBy;
  final dynamic schoolId;
  final String? updateDate;
  final String? createDate;
  final dynamic action;
  final int quantity;
  final int? quantity1;
  final int amount;
  final String registrationNo;
  final String studentName;
  final String session;
  final int? classId;
  final String className;
  final int? sectionId;
  final String section;
  final String receiptno;
  final int? cquantity;
  final String paymentMode;
  final String payDate;
  final String fatherName;
  final String fmobileno;
  final String femail;

  StationaryFeePrint({
    required this.sfeeId,
    this.pmasterId,
    required this.product,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.updateDate,
    this.createDate,
    this.action,
    required this.quantity,
    this.quantity1,
    required this.amount,
    required this.registrationNo,
    required this.studentName,
    required this.session,
    this.classId,
    required this.className,
    this.sectionId,
    required this.section,
    required this.receiptno,
    this.cquantity,
    required this.paymentMode,
    required this.payDate,
    required this.fatherName,
    required this.fmobileno,
    required this.femail,
  });

  factory StationaryFeePrint.fromJson(Map<String, dynamic> json) {
    return StationaryFeePrint(
      sfeeId: json['sfeeId'] ?? 0,
      pmasterId: json['pmasterId'],
      product: json['product'] ?? '',
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
      updateDate: json['updateDate'],
      createDate: json['createDate'],
      action: json['action'],
      quantity: json['quantity'] ?? 0,
      quantity1: json['quantity1'],
      amount: json['amount'] ?? 0,
      registrationNo: json['registrationNo'] ?? '',
      studentName: json['studentName'] ?? '',
      session: json['session'] ?? '',
      classId: json['classId'],
      className: json['class'] ?? '',
      sectionId: json['sectionId'],
      section: json['section'] ?? '',
      receiptno: json['receiptno'] ?? '',
      cquantity: json['cquantity'],
      paymentMode: json['paymentMode'] ?? '',
      payDate: json['payDate'] ?? '',
      fatherName: json['fatherName'] ?? '',
      fmobileno: json['fmobileno'] ?? '',
      femail: json['femail'] ?? '',
    );
  }
}

class SchoolDetailModel {
  final String schoolName;
  final String schoolAddress;
  final String schoolEmailID;
  final String? phoneNumber1;
  final String? mobileNumber;
  final String? uploadLogo1;
  final String schoolId;

  SchoolDetailModel({
    required this.schoolName,
    required this.schoolAddress,
    required this.schoolEmailID,
    this.phoneNumber1,
    this.mobileNumber,
    this.uploadLogo1,
    required this.schoolId,
  });

  factory SchoolDetailModel.fromJson(Map<String, dynamic> json) {
    return SchoolDetailModel(
      schoolName: json['schoolName'] ?? '',
      schoolAddress: json['schoolAddress'] ?? '',
      schoolEmailID: json['schoolEmailID'] ?? '',
      phoneNumber1: json['phoneNumber1'],
      mobileNumber: json['mobileNumber'],
      uploadLogo1: json['uploadLogo1'],
      schoolId: json['schoolId'] ?? '',
    );
  }

  String get displayPhone {
    final p = (phoneNumber1 ?? '').trim();
    final m = (mobileNumber ?? '').trim();
    if (p.isNotEmpty) return p;
    if (m.isNotEmpty) return m;
    return '';
  }
}