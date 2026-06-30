import 'dart:convert';

class FeePaymentModel {
  final int paId;
  final int? studentId;
  final String registrationNo;
  final String studentName;
  final String? session;

  final DateTime? payDate; // nullable-safe
  final String feeMonth;

  final int totalAmount;
  final int dueAmount;
  final int payAmount;
  final int? totalPay;
  final int discount;

  final String receiptNo; // maps from "receiptno"
  final String? paymentReceiptNo;

  final String? action;
  final String? remarks;

  final String paymentMode;
  final String? bankName;
  final DateTime? chequeDate;
  final String? chequeNo;

  final String? createBy;
  final DateTime? createDate;

  final int? schoolId;
  final int? feeTypeId;
  final int? duesAmount;

  final String feetype;

  final int? paymentId;
  final int? classId;

  final DateTime? transactionDate; // maps from "transaction_date"
  final String? transactionId;
  final String? orderNumber;

  final DateTime? transactiondate; // maps from "transactiondate"
  final String? modePaymentOnline;

  final bool? wholeYear; // maps from "wholeyear"

  const FeePaymentModel({
    required this.paId,
    required this.studentId,
    required this.registrationNo,
    required this.studentName,
    required this.session,
    required this.payDate,
    required this.feeMonth,
    required this.totalAmount,
    required this.dueAmount,
    required this.payAmount,
    required this.totalPay,
    required this.discount,
    required this.receiptNo,
    required this.paymentReceiptNo,
    required this.action,
    required this.remarks,
    required this.paymentMode,
    required this.bankName,
    required this.chequeDate,
    required this.chequeNo,
    required this.createBy,
    required this.createDate,
    required this.schoolId,
    required this.feeTypeId,
    required this.duesAmount,
    required this.feetype,
    required this.paymentId,
    required this.classId,
    required this.transactionDate,
    required this.transactionId,
    required this.orderNumber,
    required this.transactiondate,
    required this.modePaymentOnline,
    required this.wholeYear,
  });

  // ---------- Helpers (safe parsing) ----------
  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return null;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is String) {
      final s = v.trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }
    return null;
  }

  static String _asString(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  // ---------- JSON ----------
  factory FeePaymentModel.fromJson(Map<String, dynamic> json) {
    return FeePaymentModel(
      paId: _asInt(json['paId']),
      studentId: json['studentId'] is num || json['studentId'] is String
          ? _asInt(json['studentId'], fallback: 0)
          : null,

      registrationNo: _asString(json['registrationNo']),
      studentName: _asString(json['studentName']),
      session: json['session']?.toString(),

      payDate: _asDate(json['payDate']),
      feeMonth: _asString(json['feeMonth']),

      totalAmount: _asInt(json['totalAmount']),
      dueAmount: _asInt(json['dueAmount']),
      payAmount: _asInt(json['payAmount']),
      totalPay: json['totalPay'] == null ? null : _asInt(json['totalPay']),
      discount: _asInt(json['discount']),

      receiptNo: _asString(json['receiptno']),
      paymentReceiptNo: json['paymentReceiptNo']?.toString(),

      action: json['action']?.toString(),
      remarks: json['remarks']?.toString(),

      paymentMode: _asString(json['paymentMode']),
      bankName: json['bankName']?.toString(),
      chequeDate: _asDate(json['chequeDate']),
      chequeNo: json['chequeNo']?.toString(),

      createBy: json['createBy']?.toString(),
      createDate: _asDate(json['createDate']),

      schoolId: json['schoolId'] == null ? null : _asInt(json['schoolId']),
      feeTypeId: json['feeTypeId'] == null ? null : _asInt(json['feeTypeId']),
      duesAmount: json['duesAmount'] == null ? null : _asInt(json['duesAmount']),

      feetype: _asString(json['feetype']),

      paymentId: json['paymentId'] == null ? null : _asInt(json['paymentId']),
      classId: json['classid'] == null ? null : _asInt(json['classid']),

      transactionDate: _asDate(json['transaction_date']),
      transactionId: json['transactionid']?.toString(),
      orderNumber: json['orderNumber']?.toString(),

      transactiondate: _asDate(json['transactiondate']),
      modePaymentOnline: json['modePaymentOnline']?.toString(),

      wholeYear: _asBool(json['wholeyear']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paId': paId,
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
      'receiptno': receiptNo,
      'paymentReceiptNo': paymentReceiptNo,
      'action': action,
      'remarks': remarks,
      'paymentMode': paymentMode,
      'bankName': bankName,
      'chequeDate': chequeDate?.toIso8601String(),
      'chequeNo': chequeNo,
      'createBy': createBy,
      'createDate': createDate?.toIso8601String(),
      'schoolId': schoolId,
      'feeTypeId': feeTypeId,
      'duesAmount': duesAmount,
      'feetype': feetype,
      'paymentId': paymentId,
      'classid': classId,
      'transaction_date': transactionDate?.toIso8601String(),
      'transactionid': transactionId,
      'orderNumber': orderNumber,
      'transactiondate': transactiondate?.toIso8601String(),
      'modePaymentOnline': modePaymentOnline,
      'wholeyear': wholeYear,
    };
  }

  // ---------- List helpers ----------
  static List<FeePaymentModel> listFromJson(dynamic source) {
    if (source is String) {
      final decoded = jsonDecode(source);
      return listFromJson(decoded);
    }
    if (source is List) {
      return source
          .map((e) => FeePaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return <FeePaymentModel>[];
  }

  static String listToJsonString(List<FeePaymentModel> list) {
    return jsonEncode(list.map((e) => e.toJson()).toList());
  }

  // ---------- copyWith ----------
  FeePaymentModel copyWith({
    int? paId,
    int? studentId,
    String? registrationNo,
    String? studentName,
    String? session,
    DateTime? payDate,
    String? feeMonth,
    int? totalAmount,
    int? dueAmount,
    int? payAmount,
    int? totalPay,
    int? discount,
    String? receiptNo,
    String? paymentReceiptNo,
    String? action,
    String? remarks,
    String? paymentMode,
    String? bankName,
    DateTime? chequeDate,
    String? chequeNo,
    String? createBy,
    DateTime? createDate,
    int? schoolId,
    int? feeTypeId,
    int? duesAmount,
    String? feetype,
    int? paymentId,
    int? classId,
    DateTime? transactionDate,
    String? transactionId,
    String? orderNumber,
    DateTime? transactiondate,
    String? modePaymentOnline,
    bool? wholeYear,
  }) {
    return FeePaymentModel(
      paId: paId ?? this.paId,
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
      receiptNo: receiptNo ?? this.receiptNo,
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
      classId: classId ?? this.classId,
      transactionDate: transactionDate ?? this.transactionDate,
      transactionId: transactionId ?? this.transactionId,
      orderNumber: orderNumber ?? this.orderNumber,
      transactiondate: transactiondate ?? this.transactiondate,
      modePaymentOnline: modePaymentOnline ?? this.modePaymentOnline,
      wholeYear: wholeYear ?? this.wholeYear,
    );
  }

  // ---------- equality ----------
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeePaymentModel &&
        other.paId == paId &&
        other.studentId == studentId &&
        other.registrationNo == registrationNo &&
        other.studentName == studentName &&
        other.session == session &&
        other.payDate == payDate &&
        other.feeMonth == feeMonth &&
        other.totalAmount == totalAmount &&
        other.dueAmount == dueAmount &&
        other.payAmount == payAmount &&
        other.totalPay == totalPay &&
        other.discount == discount &&
        other.receiptNo == receiptNo &&
        other.paymentReceiptNo == paymentReceiptNo &&
        other.action == action &&
        other.remarks == remarks &&
        other.paymentMode == paymentMode &&
        other.bankName == bankName &&
        other.chequeDate == chequeDate &&
        other.chequeNo == chequeNo &&
        other.createBy == createBy &&
        other.createDate == createDate &&
        other.schoolId == schoolId &&
        other.feeTypeId == feeTypeId &&
        other.duesAmount == duesAmount &&
        other.feetype == feetype &&
        other.paymentId == paymentId &&
        other.classId == classId &&
        other.transactionDate == transactionDate &&
        other.transactionId == transactionId &&
        other.orderNumber == orderNumber &&
        other.transactiondate == transactiondate &&
        other.modePaymentOnline == modePaymentOnline &&
        other.wholeYear == wholeYear;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      paId,
      studentId,
      registrationNo,
      studentName,
      session,
      payDate,
      feeMonth,
      totalAmount,
      dueAmount,
      payAmount,
      totalPay,
      discount,
      receiptNo,
      paymentReceiptNo,
      action,
      remarks,
      paymentMode,
      bankName,
      chequeDate,
      chequeNo,
      createBy,
      createDate,
      schoolId,
      feeTypeId,
      duesAmount,
      feetype,
      paymentId,
      classId,
      transactionDate,
      transactionId,
      orderNumber,
      transactiondate,
      modePaymentOnline,
      wholeYear,
    ]);
  }

  @override
  String toString() {
    return 'FeePaymentModel(registrationNo: $registrationNo, studentName: $studentName, feeMonth: $feeMonth, payAmount: $payAmount, receiptNo: $receiptNo)';
  }
}
