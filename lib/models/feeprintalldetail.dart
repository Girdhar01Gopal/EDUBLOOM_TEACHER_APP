class FeeReceiptAllDetailModel {
  final int? paid;
  final int? studentId;
  final String? registrationNo;
  final String? studentName;
  final String? session;
  final DateTime? payDate;
  final String? feeMonth;
  final double? totalAmount;
  final double? dueAmount;
  final double? payAmount;
  final double? totalPay;
  final double? discount;
  final String? receiptno;
  final String? paymentReceiptNo;
  final String? action;
  final String? remarks;
  final String? paymentMode;
  final String? bankName;
  final String? chequeDate;
  final String? chequeNo;
  final String? createBy;
  final DateTime? createDate;
  final String? schoolId;
  final String? feeTypeId;
  final String? duesAmount;
  final String? feetype;
  final String? paymentId;
  final int? classid;
  final String? className;
  final String? sectionName;
  final String? transactionDate;
  final String? transactionid;
  final String? orderNumber;
  final String? transactiondate;
  final String? modePaymentOnline;
  final String? wholeyear;
  final String? paidaction;
  final String? rollNo;
  final String? fatherName;
  final String? schoolName;
  final String? email;
  final String? schoolAddress;
  final String? phone;
  final int? sectionId;
  final String? numbertoword;
  final String? feeDurationId;
  final String? feetype1;

  FeeReceiptAllDetailModel({
    this.paid,
    this.studentId,
    this.registrationNo,
    this.studentName,
    this.session,
    this.payDate,
    this.feeMonth,
    this.totalAmount,
    this.dueAmount,
    this.payAmount,
    this.totalPay,
    this.discount,
    this.receiptno,
    this.paymentReceiptNo,
    this.action,
    this.remarks,
    this.paymentMode,
    this.bankName,
    this.chequeDate,
    this.chequeNo,
    this.createBy,
    this.createDate,
    this.schoolId,
    this.feeTypeId,
    this.duesAmount,
    this.feetype,
    this.paymentId,
    this.classid,
    this.className,
    this.sectionName,
    this.transactionDate,
    this.transactionid,
    this.orderNumber,
    this.transactiondate,
    this.modePaymentOnline,
    this.wholeyear,
    this.paidaction,
    this.rollNo,
    this.fatherName,
    this.schoolName,
    this.email,
    this.schoolAddress,
    this.phone,
    this.sectionId,
    this.numbertoword,
    this.feeDurationId,
    this.feetype1,
  });

  factory FeeReceiptAllDetailModel.fromJson(Map<String, dynamic> json) {
    return FeeReceiptAllDetailModel(
      paid: json['paid'] as int?,
      studentId: json['studentId'] as int?,
      registrationNo: json['registrationNo'] as String?,
      studentName: json['studentName'] as String?,
      session: json['session'] as String?,
      payDate: json['payDate'] != null
          ? DateTime.tryParse(json['payDate'])
          : null,
      feeMonth: json['feeMonth'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      dueAmount: (json['dueAmount'] as num?)?.toDouble(),
      payAmount: (json['payAmount'] as num?)?.toDouble(),
      totalPay: (json['totalPay'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      receiptno: json['receiptno'] as String?,
      paymentReceiptNo: json['paymentReceiptNo'] as String?,
      action: json['action'] as String?,
      remarks: json['remarks'] as String?,
      paymentMode: json['paymentMode'] as String?,
      bankName: json['bankName'] as String?,
      chequeDate: json['chequeDate'] as String?,
      chequeNo: json['chequeNo'] as String?,
      createBy: json['createBy'] as String?,
      createDate: json['createDate'] != null
          ? DateTime.tryParse(json['createDate'])
          : null,
      schoolId: json['schoolId'] as String?,
      feeTypeId: json['feeTypeId'] as String?,
      duesAmount: json['duesAmount'] as String?,
      feetype: json['feetype'] as String?,
      paymentId: json['paymentId'] as String?,
      classid: json['classid'] as int?,
      className: json['className'] as String?,
      sectionName: json['sectionName'] as String?,
      transactionDate: json['transaction_date'] as String?,
      transactionid: json['transactionid'] as String?,
      orderNumber: json['orderNumber'] as String?,
      transactiondate: json['transactiondate'] as String?,
      modePaymentOnline: json['modePaymentOnline'] as String?,
      wholeyear: json['wholeyear'] as String?,
      paidaction: json['paidaction'] as String?,
      rollNo: json['rollNo'] as String?,
      fatherName: json['fatherName'] as String?,
      schoolName: json['schoolName'] as String?,
      email: json['email'] as String?,
      schoolAddress: json['schoolAddress'] as String?,
      phone: json['phone'] as String?,
      sectionId: json['sectionId'] as int?,
      numbertoword: json['numbertoword'] as String?,
      feeDurationId: json['feeDurationId'] as String?,
      feetype1: json['feetype1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paid': paid,
      'studentId': studentId,
      'registrationNo': registrationNo,
      'studentName': studentName,
      'session': session,
      'payDate': payDate?.toIso8601String(),
      'feeMonth': feeMonth,
      'totalAmount': totalAmount,
      'dueAmount': dueAmount,
      'payAmount': payAmount,
      'totalPay': totalPay,
      'discount': discount,
      'receiptno': receiptno,
      'paymentReceiptNo': paymentReceiptNo,
      'action': action,
      'remarks': remarks,
      'paymentMode': paymentMode,
      'bankName': bankName,
      'chequeDate': chequeDate,
      'chequeNo': chequeNo,
      'createBy': createBy,
      'createDate': createDate?.toIso8601String(),
      'schoolId': schoolId,
      'feeTypeId': feeTypeId,
      'duesAmount': duesAmount,
      'feetype': feetype,
      'paymentId': paymentId,
      'classid': classid,
      'className': className,
      'sectionName': sectionName,
      'transaction_date': transactionDate,
      'transactionid': transactionid,
      'orderNumber': orderNumber,
      'transactiondate': transactiondate,
      'modePaymentOnline': modePaymentOnline,
      'wholeyear': wholeyear,
      'paidaction': paidaction,
      'rollNo': rollNo,
      'fatherName': fatherName,
      'schoolName': schoolName,
      'email': email,
      'schoolAddress': schoolAddress,
      'phone': phone,
      'sectionId': sectionId,
      'numbertoword': numbertoword,
      'feeDurationId': feeDurationId,
      'feetype1': feetype1,
    };
  }

  FeeReceiptAllDetailModel copyWith({
    int? paid,
    int? studentId,
    String? registrationNo,
    String? studentName,
    String? session,
    DateTime? payDate,
    String? feeMonth,
    double? totalAmount,
    double? dueAmount,
    double? payAmount,
    double? totalPay,
    double? discount,
    String? receiptno,
    String? paymentReceiptNo,
    String? action,
    String? remarks,
    String? paymentMode,
    String? bankName,
    String? chequeDate,
    String? chequeNo,
    String? createBy,
    DateTime? createDate,
    String? schoolId,
    String? feeTypeId,
    String? duesAmount,
    String? feetype,
    String? paymentId,
    int? classid,
    String? className,
    String? sectionName,
    String? transactionDate,
    String? transactionid,
    String? orderNumber,
    String? transactiondate,
    String? modePaymentOnline,
    String? wholeyear,
    String? paidaction,
    String? rollNo,
    String? fatherName,
    String? schoolName,
    String? email,
    String? schoolAddress,
    String? phone,
    int? sectionId,
    String? numbertoword,
    String? feeDurationId,
    String? feetype1,
  }) {
    return FeeReceiptAllDetailModel(
      paid: paid ?? this.paid,
      studentId: studentId ?? this.studentId,
      registrationNo: registrationNo ?? this.registrationNo,
      studentName: studentName ?? this.studentName,
      session: session ?? this.session,
      payDate: payDate ?? this.payDate,
      feeMonth: feeMonth ?? this.feeMonth,
      totalAmount: totalAmount ?? this.totalAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      payAmount: payAmount ?? this.payAmount,
      totalPay: totalPay ?? this.totalPay,
      discount: discount ?? this.discount,
      receiptno: receiptno ?? this.receiptno,
      paymentReceiptNo: paymentReceiptNo ?? this.paymentReceiptNo,
      action: action ?? this.action,
      remarks: remarks ?? this.remarks,
      paymentMode: paymentMode ?? this.paymentMode,
      bankName: bankName ?? this.bankName,
      chequeDate: chequeDate ?? this.chequeDate,
      chequeNo: chequeNo ?? this.chequeNo,
      createBy: createBy ?? this.createBy,
      createDate: createDate ?? this.createDate,
      schoolId: schoolId ?? this.schoolId,
      feeTypeId: feeTypeId ?? this.feeTypeId,
      duesAmount: duesAmount ?? this.duesAmount,
      feetype: feetype ?? this.feetype,
      paymentId: paymentId ?? this.paymentId,
      classid: classid ?? this.classid,
      className: className ?? this.className,
      sectionName: sectionName ?? this.sectionName,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionid: transactionid ?? this.transactionid,
      orderNumber: orderNumber ?? this.orderNumber,
      transactiondate: transactiondate ?? this.transactiondate,
      modePaymentOnline: modePaymentOnline ?? this.modePaymentOnline,
      wholeyear: wholeyear ?? this.wholeyear,
      paidaction: paidaction ?? this.paidaction,
      rollNo: rollNo ?? this.rollNo,
      fatherName: fatherName ?? this.fatherName,
      schoolName: schoolName ?? this.schoolName,
      email: email ?? this.email,
      schoolAddress: schoolAddress ?? this.schoolAddress,
      phone: phone ?? this.phone,
      sectionId: sectionId ?? this.sectionId,
      numbertoword: numbertoword ?? this.numbertoword,
      feeDurationId: feeDurationId ?? this.feeDurationId,
      feetype1: feetype1 ?? this.feetype1,
    );
  }

  @override
  String toString() {
    return 'FeeReceiptAllDetailModel(paid: $paid, studentName: $studentName, feetype: $feetype, receiptno: $receiptno, payAmount: $payAmount)';
  }
}

// ─── Wrapper model for the full API response ───────────────────────────────

class FeeReceiptAllDetailResponse {
  final List<FeeReceiptAllDetailModel> listData;

  FeeReceiptAllDetailResponse({required this.listData});

  factory FeeReceiptAllDetailResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['listData'] as List<dynamic>? ?? [];
    return FeeReceiptAllDetailResponse(
      listData: rawList
          .map((e) =>
          FeeReceiptAllDetailModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((e) => e.toJson()).toList(),
    };
  }
}