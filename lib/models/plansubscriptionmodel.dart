class PlanSubscriptionModel {
  final int statusCode;
  final bool isSuccess;
  final String messages;
  final List<FeePlan> data;
  final bool showPopup;
  final String? popupMessage;

  PlanSubscriptionModel({
    required this.statusCode,
    required this.isSuccess,
    required this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory PlanSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      PlanSubscriptionModel(
        statusCode: json['statusCode'] ?? 0,
        isSuccess: json['isSuccess'] ?? false,
        messages: json['messages'] ?? '',
        data: json['data'] != null
            ? List<FeePlan>.from(
            (json['data'] as List).map((x) => FeePlan.fromJson(x)))
            : [],
        showPopup: json['showPopup'] ?? false,
        popupMessage: json['popupMessage'],
      );
}

class FeePlan {
  final int id;
  final String planName;
  final double amount;
  final double discountAmount;
  final String feePlanType;
  final DateTime createDate;
  final DateTime? updatedate;
  final String action;
  final String planDescription;

  FeePlan({
    required this.id,
    required this.planName,
    required this.amount,
    required this.discountAmount,
    required this.feePlanType,
    required this.createDate,
    this.updatedate,
    required this.action,
    required this.planDescription,
  });

  factory FeePlan.fromJson(Map<String, dynamic> json) => FeePlan(
    id: json['id'] ?? 0,
    planName: json['planName'] ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
    feePlanType: json['feePlanType'] ?? '',
    createDate: DateTime.parse(json['createDate']),
    updatedate: json['updatedate'] != null
        ? DateTime.parse(json['updatedate'])
        : null,
    action: json['action'] ?? '',
    planDescription: json['planDescription'] ?? '',
  );
}