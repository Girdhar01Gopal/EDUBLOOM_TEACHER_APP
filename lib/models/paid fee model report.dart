class PaidFeeModel {
  final List<PaidData>? listData;
  final List<dynamic>? unpaiddata;

  PaidFeeModel({
    this.listData,
    this.unpaiddata,
  });

  factory PaidFeeModel.fromJson(Map<String, dynamic> json) {
    return PaidFeeModel(
      listData: json['listData'] != null
          ? List<PaidData>.from(
          json['listData'].map((x) => PaidData.fromJson(x)))
          : null,
      unpaiddata: json['unpaiddata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData != null
          ? List<dynamic>.from(listData!.map((x) => x.toJson()))
          : null,
      'unpaiddata': unpaiddata,
    };
  }
}

class PaidData {
  final int? studentId;
  final double? totalDueFeeAmount;
  final String? registrationNo;
  final String? admissionNo;
  final String? session;
  final String? studentName;
  final String? transportUser;
  final int? classId;
  final String? studentClass;
  final String? section;
  final int? sectionId;
  final String? fatherName;
  final String? feeMonth;
  final double? totalAmount;
  final double? payAmount;
  final double? totalPay;
  final double? dueAmount;
  final String? monthName;
  final double? fee;
  final String? feetype;
  final String? feeTypeDisplay;
  final String? schoolId;
  final String? payDate;
  final double? todayAmount;
  final String? remarks;
  final String? paymentMode;
  final double? dueAmount1;
  final double? netFeeAmount;
  final double? discount;
  final String? paidaction;
  final String? receiptno; // ← ADDED

  PaidData({
    this.studentId,
    this.totalDueFeeAmount,
    this.registrationNo,
    this.admissionNo,
    this.session,
    this.studentName,
    this.transportUser,
    this.classId,
    this.studentClass,
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
    this.feetype,
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
    this.receiptno, // ← ADDED
  });

  factory PaidData.fromJson(Map<String, dynamic> json) {
    return PaidData(
      studentId: json['studentId'] as int?,
      totalDueFeeAmount: (json['totalDueFeeAmount'] as num?)?.toDouble(),
      registrationNo: json['registrationNo'] as String?,
      admissionNo: json['admissionNo'] as String?,
      session: json['session'] as String?,
      studentName: json['studentName'] as String?,
      transportUser: json['transportUser'] as String?,
      classId: json['classId'] as int?,
      studentClass: json['class'] as String?,
      section: json['section'] as String?,
      sectionId: json['sectionId'] as int?,
      fatherName: json['fatherName'] as String?,
      feeMonth: json['feeMonth'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      payAmount: (json['payAmount'] as num?)?.toDouble(),
      totalPay: (json['totalPay'] as num?)?.toDouble(),
      dueAmount: (json['dueAmount'] as num?)?.toDouble(),
      monthName: json['monthName'] as String?,
      fee: (json['fee'] as num?)?.toDouble(),
      feetype: json['feetype'] as String?,
      feeTypeDisplay: json['fee_type_display'] as String?,
      schoolId: json['schoolId'] as String?,
      payDate: json['payDate'] as String?,
      todayAmount: (json['todayAmount'] as num?)?.toDouble(),
      remarks: json['remarks'] as String?,
      paymentMode: json['paymentMode'] as String?,
      dueAmount1: (json['dueAmount1'] as num?)?.toDouble(),
      netFeeAmount: (json['netFeeAmount'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      paidaction: json['paidaction'] as String?,
      receiptno: json['receiptno'] as String?, // ← ADDED
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'totalDueFeeAmount': totalDueFeeAmount,
      'registrationNo': registrationNo,
      'admissionNo': admissionNo,
      'session': session,
      'studentName': studentName,
      'transportUser': transportUser,
      'classId': classId,
      'class': studentClass,
      'section': section,
      'sectionId': sectionId,
      'fatherName': fatherName,
      'feeMonth': feeMonth,
      'totalAmount': totalAmount,
      'payAmount': payAmount,
      'totalPay': totalPay,
      'dueAmount': dueAmount,
      'monthName': monthName,
      'fee': fee,
      'feetype': feetype,
      'fee_type_display': feeTypeDisplay,
      'schoolId': schoolId,
      'payDate': payDate,
      'todayAmount': todayAmount,
      'remarks': remarks,
      'paymentMode': paymentMode,
      'dueAmount1': dueAmount1,
      'netFeeAmount': netFeeAmount,
      'discount': discount,
      'paidaction': paidaction,
      'receiptno': receiptno, // ← ADDED
    };
  }
}