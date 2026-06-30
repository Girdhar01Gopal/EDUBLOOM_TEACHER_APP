// models/daycarefeespaymentmodel.dart

import 'dart:convert';

class ViewTransactionNewModel {
  final List<TransactionItem> listData;
  final dynamic unpaiddata;

  ViewTransactionNewModel({
    required this.listData,
    this.unpaiddata,
  });

  factory ViewTransactionNewModel.fromJson(Map<String, dynamic> json) {
    return ViewTransactionNewModel(
      listData: (json['listData'] as List<dynamic>? ?? [])
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      unpaiddata: json['unpaiddata'],
    );
  }
}

class TransactionItem {
  final int?    studentId;
  final double? totalDueFeeAmount;
  final String? registrationNo;
  final String? admissionNo;
  final String? session;
  final String? studentName;
  final String? transportUser;
  final int?    classId;
  final String? className;
  final String? section;
  final int?    sectionId;
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
  final DateTime? payDate;   // null if invalid/missing
  final double? todayAmount;
  final String? remarks;
  final String? paymentMode;
  final double? dueAmount1;
  final double? netFeeAmount;
  final double? discount;
  final String? paidaction;
  final String? receiptno;

  TransactionItem({
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
    this.receiptno,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    }

    // Null-safe date parse — reject year <= 1 (0001-01-01 etc.)
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

    // studentId: API sends int, guard against string
    int? parseStudentId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return TransactionItem(
      studentId:         parseStudentId(json['studentId']),
      totalDueFeeAmount: toDouble(json['totalDueFeeAmount']),
      registrationNo:    json['registrationNo'] as String?,
      admissionNo:       json['admissionNo']    as String?,
      session:           json['session']         as String?,
      studentName:       json['studentName']     as String?,
      transportUser:     json['transportUser']   as String?,
      classId:           json['classId'] is int ? json['classId'] as int : null,
      className:         json['class']           as String?,
      section:           json['section']         as String?,
      sectionId:         json['sectionId'] is int ? json['sectionId'] as int : null,
      fatherName:        json['fatherName']      as String?,
      feeMonth:          json['feeMonth']        as String?,
      totalAmount:       toDouble(json['totalAmount']),
      payAmount:         toDouble(json['payAmount']),
      totalPay:          toDouble(json['totalPay']),
      dueAmount:         toDouble(json['dueAmount']),
      monthName:         json['monthName']       as String?,
      fee:               toDouble(json['fee']),
      feetype:           json['feetype']         as String?,
      feeTypeDisplay:    json['fee_type_display'] as String?,
      schoolId:          json['schoolId']        as String?,
      payDate:           parsedDate,
      todayAmount:       toDouble(json['todayAmount']),
      remarks:           json['remarks']         as String?,
      paymentMode:       json['paymentMode']     as String?,
      dueAmount1:        toDouble(json['dueAmount1']),
      netFeeAmount:      toDouble(json['netFeeAmount']),
      discount:          toDouble(json['discount']),
      paidaction:        json['paidaction']      as String?,
      receiptno:         json['receiptno']?.toString(),
    );
  }
}