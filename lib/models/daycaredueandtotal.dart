class duefeesandtotal {
  List<ListData>? listData;

  duefeesandtotal({this.listData});

  duefeesandtotal.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <ListData>[];
      json['listData'].forEach((v) {
        listData!.add(new ListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData != null) {
      data['listData'] = this.listData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListData {
  int? paId;
  Null? studentId;
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
  Null? paymentReceiptNo;
  String? action;
  Null? remarks;
  Null? paymentMode;
  Null? bankName;
  Null? chequeDate;
  Null? chequeNo;
  Null? createBy;
  Null? createDate;
  Null? schoolId;
  Null? feeTypeId;
  Null? duesAmount;
  String? feetype;
  int? paymentId;
  Null? transactionDate;
  Null? transactionid;
  Null? orderNumber;
  Null? transactiondate;
  Null? modePaymentOnline;
  Null? wholeyear;

  ListData(
      {this.paId,
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
      this.transactionDate,
      this.transactionid,
      this.orderNumber,
      this.transactiondate,
      this.modePaymentOnline,
      this.wholeyear});

  ListData.fromJson(Map<String, dynamic> json) {
    paId = json['paId'];
    studentId = json['studentId'];
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
    feeTypeId = json['feeTypeId'];
    duesAmount = json['duesAmount'];
    feetype = json['feetype'];
    paymentId = json['paymentId'];
    transactionDate = json['transaction_date'];
    transactionid = json['transactionid'];
    orderNumber = json['orderNumber'];
    transactiondate = json['transactiondate'];
    modePaymentOnline = json['modePaymentOnline'];
    wholeyear = json['wholeyear'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['paId'] = this.paId;
    data['studentId'] = this.studentId;
    data['registrationNo'] = this.registrationNo;
    data['studentName'] = this.studentName;
    data['session'] = this.session;
    data['payDate'] = this.payDate;
    data['feeMonth'] = this.feeMonth;
    data['totalAmount'] = this.totalAmount;
    data['dueAmount'] = this.dueAmount;
    data['payAmount'] = this.payAmount;
    data['totalPay'] = this.totalPay;
    data['discount'] = this.discount;
    data['receiptno'] = this.receiptno;
    data['paymentReceiptNo'] = this.paymentReceiptNo;
    data['action'] = this.action;
    data['remarks'] = this.remarks;
    data['paymentMode'] = this.paymentMode;
    data['bankName'] = this.bankName;
    data['chequeDate'] = this.chequeDate;
    data['chequeNo'] = this.chequeNo;
    data['createBy'] = this.createBy;
    data['createDate'] = this.createDate;
    data['schoolId'] = this.schoolId;
    data['feeTypeId'] = this.feeTypeId;
    data['duesAmount'] = this.duesAmount;
    data['feetype'] = this.feetype;
    data['paymentId'] = this.paymentId;
    data['transaction_date'] = this.transactionDate;
    data['transactionid'] = this.transactionid;
    data['orderNumber'] = this.orderNumber;
    data['transactiondate'] = this.transactiondate;
    data['modePaymentOnline'] = this.modePaymentOnline;
    data['wholeyear'] = this.wholeyear;
    return data;
  }
}