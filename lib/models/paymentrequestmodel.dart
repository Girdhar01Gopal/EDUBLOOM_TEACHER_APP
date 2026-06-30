class PaymentRecord {
  int? sadId;
  int? paymentId;
  String? registrationNo;
  String? studentName;
  String? session;
  String? payDate;
  String? feetype;
  num? totalAmount;
  num? totalHourlyAmount;
  num? payAmount;
  num? dueAmount;
  num? totalPay;
  num? discount;
  String? receiptno;
  String? paymentReceiptNo;
  int? action;
  String? paymentMode;
  String? remarks;
  String? bankName;
  String? chequeDate;
  String? chequeNo;
  String? createDate;
  String? createBy;
  String? schoolId;
  String? paidAction;
  String? feeMonth;
  String? modePaymentOnline;
  String? orderNumber;
  String? transactionid;
  int? invid;
  String? createBy1;

  PaymentRecord({
    this.sadId,
    this.paymentId,
    this.registrationNo,
    this.studentName,
    this.session,
    this.payDate,
    this.feetype,
    this.totalAmount,
    this.totalHourlyAmount,
    this.payAmount,
    this.dueAmount,
    this.totalPay,
    this.discount,
    this.receiptno,
    this.paymentReceiptNo,
    this.action,
    this.paymentMode,
    this.remarks,
    this.bankName,
    this.chequeDate,
    this.chequeNo,
    this.createDate,
    this.createBy,
    this.schoolId,
    this.paidAction,
    this.feeMonth,
    this.modePaymentOnline,
    this.orderNumber,
    this.transactionid,
    this.invid,
    this.createBy1,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      sadId: json['sadId'],
      paymentId: json['paymentId'],
      registrationNo: json['registrationNo'],
      studentName: json['studentName'],
      session: json['session'],
      payDate: json['payDate'],
      feetype: json['feetype'],
      totalAmount: json['totalAmount'],
      totalHourlyAmount: json['totalHourlyAmount'],
      payAmount: json['payAmount'],
      dueAmount: json['dueAmount'],
      totalPay: json['totalPay'],
      discount: json['discount'],
      receiptno: json['receiptno'],
      paymentReceiptNo: json['paymentReceiptNo'],
      action: json['action'],
      paymentMode: json['paymentMode'],
      remarks: json['remarks'],
      bankName: json['bankName'],
      chequeDate: json['chequeDate'],
      chequeNo: json['chequeNo'],
      createDate: json['createDate'],
      createBy: json['createBy'],
      schoolId: json['schoolId'],
      paidAction: json['paidAction'],
      feeMonth: json['feeMonth'],
      modePaymentOnline: json['modePaymentOnline'],
      orderNumber: json['orderNumber'],
      transactionid: json['transactionid'],
      invid: json['invid'],
      createBy1: json['createBy1'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sadId': sadId,
      'paymentId': paymentId,
      'registrationNo': registrationNo,
      'studentName': studentName,
      'session': session,
      'payDate': payDate,
      'feetype': feetype,
      'totalAmount': totalAmount,
      'totalHourlyAmount': totalHourlyAmount,
      'payAmount': payAmount,
      'dueAmount': dueAmount,
      'totalPay': totalPay,
      'discount': discount,
      'receiptno': receiptno,
      'paymentReceiptNo': paymentReceiptNo,
      'action': action,
      'paymentMode': paymentMode,
      'remarks': remarks,
      'bankName': bankName,
      'chequeDate': chequeDate,
      'chequeNo': chequeNo,
      'createDate': createDate,
      'createBy': createBy,
      'schoolId': schoolId,
      'paidAction': paidAction,
      'feeMonth': feeMonth,
      'modePaymentOnline': modePaymentOnline,
      'orderNumber': orderNumber,
      'transactionid': transactionid,
      'invid': invid,
      'createBy1': createBy1,
    };
  }
}
