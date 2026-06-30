class FeesView {
  List<fListData>? listData;

  FeesView({this.listData});

  FeesView.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <fListData>[];
      json['listData'].forEach((v) {
        listData!.add(fListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (listData != null) {
      data['listData'] = listData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class fListData {
  int? paymentId;
  String? registrationNo;
  String? studentName;
  String? session;
  String? payDate;
  String? feeMonth;
  int? totalAmount;
  int? dueAmount;
  int? payAmount;
  int? totalPay;
  int? discount;
  String? receiptno;
  String? paymentReceiptNo;
  String? action;
  String? remarks;
  String? paymentMode;
  String? bankName;
  String? chequeDate;
  String? chequeNo;
  String? createBy;
  String? createDate;
  String? schoolId;
  String? feeType;
  int? classId;
  String? className;
  String? transactionDate;
  String? transactionId;
  String? modePaymentOnline;

  fListData({
    this.paymentId,
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
    this.feeType,
    this.classId,
    this.className,
    this.transactionDate,
    this.transactionId,
    this.modePaymentOnline,
  });

  fListData.fromJson(Map<String, dynamic> json) {
    paymentId = json['paymentId'];
    registrationNo = json['registrationNo'];
    studentName = json['studentName'];
    session = json['session'];
    payDate = json['payDate'];
    feeMonth = json['feeMonth'];
    totalAmount = json['totalAmount'];
    dueAmount = json['dueAmount'];
    payAmount = json['payAmount'];
    totalPay = json['totalPay'];
    discount = json['discount'];
    receiptno = json['receiptno'];
    paymentReceiptNo = json['paymentReceiptNo'];
    action = json['action'];
    remarks = json['remarks'];
    paymentMode = json['paymentMode'];
    bankName = json['bankName'];
    chequeDate = json['chequeDate'];
    chequeNo = json['chequeNo'];
    createBy = json['createBy'];
    createDate = json['createDate'];
    schoolId = json['schoolId'];
    feeType = json['feeType'];
    classId = json['classId'];
    className = json['className'];
    transactionDate = json['transaction_date'];
    transactionId = json['transactionid'];
    modePaymentOnline = json['modePaymentOnline'];
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'registrationNo': registrationNo,
      'studentName': studentName,
      'session': session,
      'payDate': payDate,
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
      'createDate': createDate,
      'schoolId': schoolId,
      'feeType': feeType,
      'classId': classId,
      'className': className,
      'transaction_date': transactionDate,
      'transactionid': transactionId,
      'modePaymentOnline': modePaymentOnline,
    };
  }
}
