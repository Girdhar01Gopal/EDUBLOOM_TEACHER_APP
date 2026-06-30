class FeeReport {
  List<fListData>? listData;

  FeeReport({this.listData});

  FeeReport.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <fListData>[];
      json['listData'].forEach((v) {
        listData!.add(new fListData.fromJson(v));
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

class fListData {
  String? payDate;
  int? payAmount;
  String? feeType;
  int? classId;
  String? className;
  String? registrationNo;
  String? session;
  String? studentName;
  String? sectionName;
  String? feeMonth;
  Null? paidAmount;
  String? payment;
  String? dueAmount;
  String? fatherName;
  Null? createDate;
  Null? feeDurationId;
  Null? amount;

  fListData(
      {this.payDate,
        this.payAmount,
        this.feeType,
        this.classId,
        this.className,
        this.registrationNo,
        this.session,
        this.studentName,
        this.sectionName,
        this.feeMonth,
        this.paidAmount,
        this.payment,
        this.dueAmount,
        this.fatherName,
        this.createDate,
        this.feeDurationId,
        this.amount});

  fListData.fromJson(Map<String, dynamic> json) {
    payDate = json['payDate'];
    payAmount = json['payAmount'];
    feeType = json['feeType'];
    classId = json['classId'];
    className = json['className'];
    registrationNo = json['registrationNo'];
    session = json['session'];
    studentName = json['studentName'];
    sectionName = json['sectionName'];
    feeMonth = json['feeMonth'];
    paidAmount = json['paidAmount'];
    payment = json['payment'];
    dueAmount = json['dueAmount'];
    fatherName = json['fatherName'];
    createDate = json['createDate'];
    feeDurationId = json['feeDurationId'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['payDate'] = this.payDate;
    data['payAmount'] = this.payAmount;
    data['feeType'] = this.feeType;
    data['classId'] = this.classId;
    data['className'] = this.className;
    data['registrationNo'] = this.registrationNo;
    data['session'] = this.session;
    data['studentName'] = this.studentName;
    data['sectionName'] = this.sectionName;
    data['feeMonth'] = this.feeMonth;
    data['paidAmount'] = this.paidAmount;
    data['payment'] = this.payment;
    data['dueAmount'] = this.dueAmount;
    data['fatherName'] = this.fatherName;
    data['createDate'] = this.createDate;
    data['feeDurationId'] = this.feeDurationId;
    data['amount'] = this.amount;
    return data;
  }
}