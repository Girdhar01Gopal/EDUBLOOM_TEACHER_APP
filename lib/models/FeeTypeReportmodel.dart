class FeeReport {
  List<fListData>? listData;

  FeeReport({this.listData});

  factory FeeReport.fromJson(dynamic json) {
    // Case 1: API returns an object -> { "listData": [...] }
    if (json is Map<String, dynamic>) {
      final list = json['listData'];
      return FeeReport(
        listData: list is List
            ? list
            .map((v) => fListData.fromJson(v as Map<String, dynamic>))
            .toList()
            : <fListData>[],
      );
    }

    // Case 2: API returns a raw array directly -> [ {...}, {...} ]
    if (json is List) {
      return FeeReport(
        listData: json
            .map((v) => fListData.fromJson(v as Map<String, dynamic>))
            .toList(),
      );
    }

    // Fallback: unexpected shape, return empty list instead of crashing
    return FeeReport(listData: <fListData>[]);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
  dynamic paidAmount;
  String? payment;
  String? dueAmount;
  String? fatherName;
  dynamic createDate;
  dynamic feeDurationId;
  dynamic amount;

  fListData({
    this.payDate,
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
    this.amount,
  });

  factory fListData.fromJson(Map<String, dynamic> json) {
    return fListData(
      payDate: json['payDate']?.toString(),
      payAmount: _toInt(json['payAmount']),
      feeType: json['feeType']?.toString(),
      classId: _toInt(json['classId']),
      className: json['className']?.toString(),
      registrationNo: json['registrationNo']?.toString(),
      session: json['session']?.toString(),
      studentName: json['studentName']?.toString(),
      sectionName: json['sectionName']?.toString(),
      feeMonth: json['feeMonth']?.toString(),
      paidAmount: json['paidAmount'],
      payment: json['payment']?.toString(),
      dueAmount: json['dueAmount']?.toString(),
      fatherName: json['fatherName']?.toString(),
      createDate: json['createDate'],
      feeDurationId: json['feeDurationId'],
      amount: json['amount'],
    );
  }

  // Safely converts values that might come as int, String, or double from API
  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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