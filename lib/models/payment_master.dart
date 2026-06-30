// payment_master.dart

class PaymentMaster {
  final List<PaymentMode> listData;
  final dynamic currentSession;

  PaymentMaster({
    required this.listData,
    this.currentSession,
  });

  factory PaymentMaster.fromJson(Map<String, dynamic> json) {
    return PaymentMaster(
      listData: json['listData'] != null
          ? List<PaymentMode>.from(
        json['listData'].map((x) => PaymentMode.fromJson(x)),
      )
          : [],
      currentSession: json['currentSession'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((x) => x.toJson()).toList(),
      'currentSession': currentSession,
    };
  }
}

class PaymentMode {
  final int paymentModeId;
  final String paymentMode;
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String createBy;
  final String? updateBy;
  final String schoolId;

  PaymentMode({
    required this.paymentModeId,
    required this.paymentMode,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory PaymentMode.fromJson(Map<String, dynamic> json) {
    return PaymentMode(
      paymentModeId: json['paymentModeId'],
      paymentMode: json['paymentMode'],
      action: json['action'],
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentModeId': paymentModeId,
      'paymentMode': paymentMode,
      'action': action,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }

  /// 🔥 Helper: active payment mode or not
  bool get isActive => action == "1";
}
