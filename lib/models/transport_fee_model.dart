// ── transport_fee_model.dart ──────────────────────────────────
// Model for: GET /api/MasterApp/GetTransportFeeHeadAppAsync/{schoolId}/{session}

class TransportFee {
  final int transFeeHeadId;
  final String session;
  final dynamic routeNo;
  final dynamic routeNameId;
  final int routePointId;
  final dynamic feesDurationId;
  final String feesHead;
  final String amount;
  final dynamic action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String createBy;
  final dynamic updateBy;
  final String schoolId;
  final int feeTypeId;
  final String transportType;
  final String feesDuration;
  final String pickupPoint;

  TransportFee({
    required this.transFeeHeadId,
    required this.session,
    this.routeNo,
    this.routeNameId,
    required this.routePointId,
    this.feesDurationId,
    required this.feesHead,
    required this.amount,
    this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
    required this.feeTypeId,
    required this.transportType,
    required this.feesDuration,
    required this.pickupPoint,
  });

  factory TransportFee.fromJson(Map<String, dynamic> json) {
    return TransportFee(
      transFeeHeadId: json['transFeeHeadId'] ?? 0,
      session: json['session'] ?? '',
      routeNo: json['routeNo'],
      routeNameId: json['routeNameId'],
      routePointId: json['routePointId'] ?? 0,
      feesDurationId: json['feesDurationId'],
      feesHead: json['feesHead'] ?? '',
      amount: json['amount']?.toString() ?? '',
      action: json['action'],
      createDate: DateTime.tryParse(json['createDate'] ?? '') ?? DateTime.now(),
      updateDate: json['updateDate'] != null
          ? DateTime.tryParse(json['updateDate'])
          : null,
      createBy: json['createBy'] ?? '',
      updateBy: json['updateBy'],
      schoolId: json['schoolId'] ?? '',
      feeTypeId: json['feeTypeId'] ?? 0,
      transportType: json['transportType'] ?? '',
      feesDuration: json['feesDuration'] ?? '',
      pickupPoint: json['pickupPoint'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transFeeHeadId': transFeeHeadId,
      'session': session,
      'routeNo': routeNo,
      'routeNameId': routeNameId,
      'routePointId': routePointId,
      'feesDurationId': feesDurationId,
      'feesHead': feesHead,
      'amount': amount,
      'action': action,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'feeTypeId': feeTypeId,
      'transportType': transportType,
      'feesDuration': feesDuration,
      'pickupPoint': pickupPoint,
    };
  }
}

class TransportFeeResponse {
  final int statusCode;
  final bool isSuccess;
  final String messages;
  final List<TransportFee> data;
  final bool showPopup;
  final dynamic popupMessage;

  TransportFeeResponse({
    required this.statusCode,
    required this.isSuccess,
    required this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory TransportFeeResponse.fromJson(Map<String, dynamic> json) {
    return TransportFeeResponse(
      statusCode: json['statusCode'] ?? 0,
      isSuccess: json['isSuccess'] ?? false,
      messages: json['messages'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => TransportFee.fromJson(item as Map<String, dynamic>))
          .toList(),
      showPopup: json['showPopup'] ?? false,
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data.map((item) => item.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}