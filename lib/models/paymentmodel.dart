class PaymentModel {
  List<PaymentData> listData;
  dynamic currentSession;

  // Default constructor with empty list for listData
  PaymentModel({this.listData = const [], this.currentSession});

  // Factory constructor to create PaymentModel from JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      listData: (json['listData'] as List<dynamic>? ?? [])
          .map((item) => PaymentData.fromJson(item))
          .toList(),
      currentSession: json['currentSession'],
    );
  }

  // Converts PaymentModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((v) => v.toJson()).toList(),
      'currentSession': currentSession,
    };
  }
}

class PaymentData {
  int? paymentModeId;
  String? paymentMode;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  // Default constructor for PaymentData
  PaymentData({
    this.paymentModeId,
    this.paymentMode,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
  });

  // Factory constructor to create PaymentData from JSON
  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      paymentModeId: json['paymentModeId'] ?? 0,
      paymentMode: json['paymentMode'] ?? '',
      action: json['action'] ?? '',
      createDate: json['createDate'] ?? '',
      updateDate: json['updateDate'], // Can be null
      createBy: json['createBy'] ?? '',
      updateBy: json['updateBy'], // Can be null
      schoolId: json['schoolId'] ?? '',
    );
  }

  // Converts PaymentData object to JSON
  Map<String, dynamic> toJson() {
    return {
      'paymentModeId': paymentModeId,
      'paymentMode': paymentMode,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }
}