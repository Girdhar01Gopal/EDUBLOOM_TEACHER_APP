/// ===============================
/// फीस अवधि GET + POST मॉडल
/// एक ही फ़ाइल में
/// ===============================

/// -------- GET : फीस अवधि API देखने के लिए --------
class FeeDurationMaster {
  final List<FeeDurationItem> listData;
  final String? currentSession;

  FeeDurationMaster({
    required this.listData,
    this.currentSession,
  });

  factory FeeDurationMaster.fromJson(Map<String, dynamic> json) {
    return FeeDurationMaster(
      listData: json['listData'] == null
          ? <FeeDurationItem>[]
          : List<FeeDurationItem>.from(
        (json['listData'] as List)
            .map((x) => FeeDurationItem.fromJson(x as Map<String, dynamic>)),
      ),
      currentSession: json['currentSession']?.toString(),
    );
  }
}

class FeeDurationItem {
  final int feesDurationId;
  final String feesDuration;
  final String? month;
  final String action;
  final DateTime? createDate;   // nullable — safe parse
  final DateTime? updateDate;
  final String createBy;
  final String? updateBy;
  final String schoolId;

  FeeDurationItem({
    required this.feesDurationId,
    required this.feesDuration,
    this.month,
    required this.action,
    this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory FeeDurationItem.fromJson(Map<String, dynamic> json) {
    return FeeDurationItem(
      feesDurationId: json['feesDurationId'] ?? 0,
      feesDuration:   (json['feesDuration'] ?? '').toString().trim(),
      month:          json['month']?.toString(),
      action:         (json['action'] ?? '').toString(),
      // ✅ Safe DateTime parse — crash nahi karega ab
      createDate: _safeDate(json['createDate']),
      updateDate: _safeDate(json['updateDate']),
      createBy:   (json['createBy']  ?? '').toString(),
      updateBy:   json['updateBy']?.toString(),
      schoolId:   (json['schoolId']  ?? '').toString(),
    );
  }

  // ── Helper: null/invalid date pe null return karo, crash mat karo ──
  static DateTime? _safeDate(dynamic val) {
    if (val == null) return null;
    try {
      return DateTime.parse(val.toString());
    } catch (_) {
      return null;
    }
  }
}

/// -------- POST : सामान्य API प्रतिक्रिया --------
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
      statusCode:   json['statusCode']   ?? 0,
      isSuccess:    json['isSuccess']    ?? false,
      messages:     (json['messages']    ?? '').toString(),
      data:         json['data'],
      showPopup:    json['showPopup']    ?? false,
      popupMessage: json['popupMessage']?.toString(),
    );
  }
}