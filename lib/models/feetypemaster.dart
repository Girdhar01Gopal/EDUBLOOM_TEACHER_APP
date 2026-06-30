/// ===============================
/// Fee Type GET + POST Models
/// Single source of truth
/// ===============================

/// -------- GET : View Fee Type API --------
class FeeTypeMaster {
  final List<FeeTypeItem> listData;
  final String? currentSession;

  FeeTypeMaster({
    required this.listData,
    this.currentSession,
  });

  factory FeeTypeMaster.fromJson(Map<String, dynamic> json) {
    return FeeTypeMaster(
      listData: json['listData'] == null
          ? <FeeTypeItem>[]
          : List<FeeTypeItem>.from(
        (json['listData'] as List).map(
              (x) => FeeTypeItem.fromJson(x),
        ),
      ),
      currentSession: json['currentSession']?.toString(),
    );
  }
}

class FeeTypeItem {
  final int feeTypeId;
  final String feeType;
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String createBy;
  final String? updateBy;
  final String schoolId;
  final int? sequenceno;
  bool isActive;  // New field to track active/inactive status


  FeeTypeItem({
    required this.feeTypeId,
    required this.feeType,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
    this.sequenceno,
    this.isActive = true,  // Default to true (active)

  });

  factory FeeTypeItem.fromJson(Map<String, dynamic> json) {
    return FeeTypeItem(
      feeTypeId: json['feeTypeId'] ?? 0,
      feeType: json['feeType'] ?? '',
      action: json['action'] ?? '',
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'])
          : null,
      createBy: json['createBy'] ?? '',
      updateBy: json['updateBy'],
      schoolId: json['schoolId'] ?? '',
      sequenceno: json['sequenceno'],
      isActive: json['isActive'] ?? true,  // Parse active status from API

    );
  }
}

/// -------- POST : Add Fee Type API --------
class ApiResponseModel {
  final int statusCode;
  final bool isSuccess;
  final String messages;
  final dynamic data;
  final bool showPopup;
  final String? popupMessage;

  ApiResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.messages,
    this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      statusCode: json['statusCode'] ?? 0,
      isSuccess: json['isSuccess'] ?? false,
      messages: json['messages'] ?? '',
      data: json['data'],
      showPopup: json['showPopup'] ?? false,
      popupMessage: json['popupMessage'],
    );
  }
}
