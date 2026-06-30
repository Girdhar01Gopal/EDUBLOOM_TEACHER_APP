class DueResponse {
  final List<DueListDatum> listData;
  final dynamic unpaiddata;

  DueResponse({
    required this.listData,
    required this.unpaiddata,
  });

  factory DueResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['listData'] as List?) ?? const [];
    return DueResponse(
      listData: list
          .map((e) => DueListDatum.fromJson(e as Map<String, dynamic>))
          .toList(),
      unpaiddata: json['unpaiddata'],
    );
  }

  Map<String, dynamic> toJson() => {
        "listData": listData.map((e) => e.toJson()).toList(),
        "unpaiddata": unpaiddata,
      };
}

class DueListDatum {
  final int? studentId;
  final int? totalDueFeeAmount;
  final String? registrationNo;
  final dynamic admissionNo;
  final dynamic session;
  final String? studentName;
  final dynamic transportUser;
  final int? classId;

  // json key = "class"
  final dynamic className;

  final dynamic section;
  final int? sectionId;
  final dynamic fatherName;

  final String? feeMonth;
  final int? totalAmount;
  final int? payAmount;

  // ✅ NEW FIELD in your JSON
  final int? totalPay;

  final int? dueAmount;
  final dynamic monthName;
  final int? fee;

  // can be null in your JSON
  final String? feeType; // json key = "feetype"
  final String? feeTypeDisplay; // json key = "fee_type_display"

  final dynamic schoolId;

  // "0001-01-01T00:00:00" should be treated as null
  final DateTime? payDate;

  final int? todayAmount;
  final dynamic remarks;
  final String? paymentMode;
  final int? dueAmount1;
  final int? netFeeAmount;
  final int? discount;

  // can be null in your JSON
  final String? paidaction;

  DueListDatum({
    this.studentId,
    this.totalDueFeeAmount,
    this.registrationNo,
    this.admissionNo,
    this.session,
    this.studentName,
    this.transportUser,
    this.classId,
    this.className,
    this.section,
    this.sectionId,
    this.fatherName,
    this.feeMonth,
    this.totalAmount,
    this.payAmount,
    this.totalPay,
    this.dueAmount,
    this.monthName,
    this.fee,
    this.feeType,
    this.feeTypeDisplay,
    this.schoolId,
    this.payDate,
    this.todayAmount,
    this.remarks,
    this.paymentMode,
    this.dueAmount1,
    this.netFeeAmount,
    this.discount,
    this.paidaction,
  });

  factory DueListDatum.fromJson(Map<String, dynamic> json) {
    return DueListDatum(
      studentId: _toInt(json['studentId']),
      totalDueFeeAmount: _toInt(json['totalDueFeeAmount']),
      registrationNo: json['registrationNo']?.toString(),
      admissionNo: json['admissionNo'],
      session: json['session'],
      studentName: json['studentName']?.toString(),
      transportUser: json['transportUser'],
      classId: _toInt(json['classId']),
      className: json['class'], // <-- key is "class"
      section: json['section'],
      sectionId: _toInt(json['sectionId']),
      fatherName: json['fatherName'],
      feeMonth: json['feeMonth']?.toString(),
      totalAmount: _toInt(json['totalAmount']),
      payAmount: _toInt(json['payAmount']),
      totalPay: _toInt(json['totalPay']), // ✅ NEW
      dueAmount: _toInt(json['dueAmount']),
      monthName: json['monthName'],
      fee: _toInt(json['fee']),
      feeType: json['feetype']?.toString(),
      feeTypeDisplay: json['fee_type_display']?.toString(),
      schoolId: json['schoolId'],
      payDate: _toDateOrNull(json['payDate']),
      todayAmount: _toInt(json['todayAmount']),
      remarks: json['remarks'],
      paymentMode: json['paymentMode']?.toString(),
      dueAmount1: _toInt(json['dueAmount1']),
      netFeeAmount: _toInt(json['netFeeAmount']),
      discount: _toInt(json['discount']),
      paidaction: json['paidaction']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "studentId": studentId,
        "totalDueFeeAmount": totalDueFeeAmount,
        "registrationNo": registrationNo,
        "admissionNo": admissionNo,
        "session": session,
        "studentName": studentName,
        "transportUser": transportUser,
        "classId": classId,
        "class": className,
        "section": section,
        "sectionId": sectionId,
        "fatherName": fatherName,
        "feeMonth": feeMonth,
        "totalAmount": totalAmount,
        "payAmount": payAmount,
        "totalPay": totalPay,
        "dueAmount": dueAmount,
        "monthName": monthName,
        "fee": fee,
        "feetype": feeType,
        "fee_type_display": feeTypeDisplay,
        "schoolId": schoolId,
        "payDate": payDate?.toIso8601String(),
        "todayAmount": todayAmount,
        "remarks": remarks,
        "paymentMode": paymentMode,
        "dueAmount1": dueAmount1,
        "netFeeAmount": netFeeAmount,
        "discount": discount,
        "paidaction": paidaction,
      };

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static DateTime? _toDateOrNull(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    if (s.startsWith("0001-01-01")) return null; // API "empty date"
    return DateTime.tryParse(s);
  }
}
