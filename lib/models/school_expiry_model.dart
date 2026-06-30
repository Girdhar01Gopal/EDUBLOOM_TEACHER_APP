class SchoolExpiryModel {
  final int statusCode;
  final bool isSuccess;
  final String? messages;
  final List<ExpiryData> data;
  final bool showPopup;
  final String? popupMessage;

  SchoolExpiryModel({
    required this.statusCode,
    required this.isSuccess,
    this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory SchoolExpiryModel.fromJson(Map<String, dynamic> json) =>
      SchoolExpiryModel(
        statusCode: json['statusCode'] ?? 0,
        isSuccess: json['isSuccess'] ?? false,
        messages: json['messages'],
        data: json['data'] != null
            ? List<ExpiryData>.from(
            (json['data'] as List).map((x) => ExpiryData.fromJson(x)))
            : [],
        showPopup: json['showPopup'] ?? false,
        popupMessage: json['popupMessage'],
      );
}

class ExpiryData {
  final int id;
  final String? schoolName;
  final String? planName;
  final DateTime createDate;
  final DateTime expirydate;
  final DateTime? updatedate;
  final String action;
  final String schoolId;

  ExpiryData({
    required this.id,
    this.schoolName,
    this.planName,
    required this.createDate,
    required this.expirydate,
    this.updatedate,
    required this.action,
    required this.schoolId,
  });

  factory ExpiryData.fromJson(Map<String, dynamic> json) => ExpiryData(
    id: json['id'] ?? 0,
    schoolName: json['schoolName'],
    planName: json['planName'],
    createDate: DateTime.parse(json['createDate']),
    expirydate: DateTime.parse(json['expirydate']),
    updatedate: json['updatedate'] != null
        ? DateTime.parse(json['updatedate'])
        : null,
    action: json['action'] ?? '',
    schoolId: json['schoolId'] ?? '',
  );
}