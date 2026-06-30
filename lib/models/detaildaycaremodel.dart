class detailDaycareStudentModel {
  int? sadid;
  int? paymentId;
  int? invid;
  bool? isCheck;
  int? daycareHeadId;
  String? registrationNo;
  int? studentId;
  String? studentName;
  dynamic amount;
  String? fromTime;
  int? feeTypeId;
  String? feeTypeName;
  String? toTime;
  String? totalHour;
  dynamic mappingPayMonth;
  String? session;
  dynamic action;
  dynamic discount;
  dynamic january;
  String? schoolId;
  dynamic deleteBy;
  dynamic feeMonth1;
  int? totalAmount;
  int? payAmount;
  dynamic totalPay;
  String? paymentStatus;
  dynamic remarks;
  int? dueAmount;
  dynamic paidaction;

  detailDaycareStudentModel(
      {this.sadid,
      this.paymentId,
      this.invid,
      this.isCheck,
      this.daycareHeadId,
      this.registrationNo,
      this.studentId,
      this.studentName,
      this.amount,
      this.fromTime,
      this.feeTypeId,
      this.feeTypeName,
      this.toTime,
      this.totalHour,
      this.mappingPayMonth,
      this.session,
      this.action,
      this.discount,
      this.january,
      this.schoolId,
      this.deleteBy,
      this.feeMonth1,
      this.totalAmount,
      this.payAmount,
      this.totalPay,
      this.paymentStatus,
      this.remarks,
      this.dueAmount,
      this.paidaction});

  factory detailDaycareStudentModel.fromJson(Map<String, dynamic> json) {
    return detailDaycareStudentModel(
      sadid: _parseInt(json['sadid']),
      paymentId: _parseInt(json['paymentId']),
      invid: _parseInt(json['invid']),
      isCheck: json['isCheck'] as bool?,
      daycareHeadId: _parseInt(json['daycareHeadId']),
      registrationNo: _parseString(json['registrationNo']),
      studentId: _parseInt(json['studentId']),
      studentName: _parseString(json['studentName']),
      amount: json['amount'],
      fromTime: _parseString(json['fromTime']),
      feeTypeId: _parseInt(json['feeTypeId']),
      feeTypeName: _parseString(json['feeTypeName']),
      toTime: _parseString(json['toTime']),
      totalHour: _parseString(json['totalHour']),
      mappingPayMonth: json['mappingPayMonth'],
      session: _parseString(json['session']),
      action: json['action'],
      discount: json['discount'],
      january: json['january'],
      schoolId: _parseString(json['schoolId']),
      deleteBy: json['deleteBy'],
      feeMonth1: json['feeMonth1'],
      totalAmount: _parseInt(json['totalAmount']),
      payAmount: _parseInt(json['payAmount']),
      totalPay: json['totalPay'],
      paymentStatus: _parseString(json['paymentStatus']),
      remarks: json['remarks'],
      dueAmount: _parseInt(json['dueAmount']),
      paidaction: json['paidaction'],
    );
  }

  // Safe type conversion helpers
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int || value is double) return value.toString();
    return value.toString();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Helper method to safely get amount as int
  int getAmountAsInt() {
    return _parseInt(amount) ?? 0;
  }

  // Helper method to safely get discount as int
  int getDiscountAsInt() {
    return _parseInt(discount) ?? 0;
  }

  // Helper method to check if payment is paid
  bool isPaid() {
    final status = paymentStatus?.toLowerCase() ?? '';
    return status == 'paid' || status == 'p';
  }

  // Helper method to get status badge
  String getStatusBadge() {
    if (isPaid()) return 'PAID';
    if (payAmount != null && payAmount! > 0) return 'PARTIAL';
    return 'PENDING';
  }

  Map<String, dynamic> toJson() {
    return {
      'sadid': sadid,
      'paymentId': paymentId,
      'invid': invid,
      'isCheck': isCheck,
      'daycareHeadId': daycareHeadId,
      'registrationNo': registrationNo,
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'fromTime': fromTime,
      'feeTypeId': feeTypeId,
      'feeTypeName': feeTypeName,
      'toTime': toTime,
      'totalHour': totalHour,
      'mappingPayMonth': mappingPayMonth,
      'session': session,
      'action': action,
      'discount': discount,
      'january': january,
      'schoolId': schoolId,
      'deleteBy': deleteBy,
      'feeMonth1': feeMonth1,
      'totalAmount': totalAmount,
      'payAmount': payAmount,
      'totalPay': totalPay,
      'paymentStatus': paymentStatus,
      'remarks': remarks,
      'dueAmount': dueAmount,
      'paidaction': paidaction,
    };
  }

  @override
  String toString() {
    return 'detailDaycareStudentModel('
        'sadid: $sadid, '
        'registrationNo: $registrationNo, '
        'studentName: $studentName, '
        'amount: $amount, '
        'fromTime: $fromTime, '
        'toTime: $toTime, '
        'totalHour: $totalHour, '
        'totalAmount: $totalAmount, '
        'payAmount: $payAmount, '
        'dueAmount: $dueAmount, '
        'paymentStatus: $paymentStatus)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is detailDaycareStudentModel &&
          runtimeType == other.runtimeType &&
          sadid == other.sadid &&
          registrationNo == other.registrationNo;

  @override
  int get hashCode => sadid.hashCode ^ registrationNo.hashCode;
}