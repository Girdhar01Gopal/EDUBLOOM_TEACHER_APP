// models/daycare_receipt_model.dart

class DaycareReceiptModel {
  final double? paid;
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
  final String? remarks;
  final String? paymentMode;
  final String? feetype;
  final String? fatherName;
  final String? schoolName;
  final String? email;
  final String? schoolAddress;
  final String? phone;

  DaycareReceiptModel({
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
    this.remarks,
    this.paymentMode,
    this.feetype,
    this.fatherName,
    this.schoolName,
    this.email,
    this.schoolAddress,
    this.phone,
  });

  factory DaycareReceiptModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    DateTime? parsedDate;
    try {
      final raw = json['payDate'];
      if (raw != null && raw.toString().isNotEmpty) {
        final dt = DateTime.parse(raw.toString());
        parsedDate = dt.year <= 1 ? null : dt;
      }
    } catch (_) {
      parsedDate = null;
    }

    return DaycareReceiptModel(
      paid:          toDouble(json['paid']),
      studentId:     json['studentId'] as int?,
      registrationNo: json['registrationNo'] as String?,
      studentName:   json['studentName'] as String?,
      session:       json['session'] as String?,
      payDate:       parsedDate,
      feeMonth:      json['feeMonth'] as String?,
      totalAmount:   toDouble(json['totalAmount']),
      dueAmount:     toDouble(json['dueAmount']),
      payAmount:     toDouble(json['payAmount']),
      totalPay:      toDouble(json['totalPay']),
      discount:      toDouble(json['discount']),
      receiptno:     json['receiptno']?.toString(),
      remarks:       json['remarks'] as String?,
      paymentMode:   json['paymentMode'] as String?,
      feetype:       json['feetype'] as String?,
      fatherName:    json['fatherName'] as String?,
      schoolName:    json['schoolName'] as String?,
      email:         json['email'] as String?,
      schoolAddress: json['schoolAddress'] as String?,
      phone:         json['phone'] as String?,
    );
  }
}