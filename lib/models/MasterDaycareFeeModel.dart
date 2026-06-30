class MasterDaycareFeeModel {
  final int statusCode;
  final bool isSuccess;
  final String messages;
  final List<MasterDaycareFeeData> data;
  final bool showPopup;
  final String? popupMessage;

  MasterDaycareFeeModel({
    required this.statusCode,
    required this.isSuccess,
    required this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory MasterDaycareFeeModel.fromJson(Map<String, dynamic> json) {
    return MasterDaycareFeeModel(
      statusCode: json['statusCode'] ?? 0,
      isSuccess: json['isSuccess'] ?? false,
      messages: json['messages'] ?? '',
      data: (json['data'] is List)
          ? List<MasterDaycareFeeData>.from(
        (json['data'] as List).map((x) => MasterDaycareFeeData.fromJson(x)),
      )
          : <MasterDaycareFeeData>[],
      showPopup: json['showPopup'] ?? false,
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data.map((x) => x.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class MasterDaycareFeeData {
  final int id;
  final int? sadId;
  final int? studentId;
  final String? studentName;
  final String? fatherName;
  final int feeTypeId;
  final String feeTypeName;
  final int? totalHour;
  final String amount;
  final String session;
  final String schoolId;
  final String createBy;
  final DateTime? createDate;
  final DateTime? updateDate;
  final String action;

  MasterDaycareFeeData({
    required this.id,
    this.sadId,
    this.studentId,
    this.studentName,
    this.fatherName,
    required this.feeTypeId,
    required this.feeTypeName,
    this.totalHour,
    required this.amount,
    required this.session,
    required this.schoolId,
    required this.createBy,
    this.createDate,
    this.updateDate,
    required this.action,
  });

  factory MasterDaycareFeeData.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return MasterDaycareFeeData(
      id: json['id'] ?? 0,
      sadId: _asInt(json['sadId']),
      studentId: _asInt(json['studentId']),
      studentName: json['studentName']?.toString(),
      fatherName: json['fatherName']?.toString(),
      feeTypeId: _asInt(json['feeTypeId']) ?? 0,
      feeTypeName: json['feeTypeName']?.toString() ?? '',
      totalHour: _asInt(json['totalHour']),
      amount: json['amount']?.toString() ?? '0',
      session: json['session']?.toString() ?? '',
      schoolId: json['schoolId']?.toString() ?? '',
      createBy: json['createBy']?.toString() ?? '',
      createDate: _parseDate(json['createDate']),
      updateDate: _parseDate(json['updateDate']),
      action: json['action']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sadId': sadId,
      'studentId': studentId,
      'studentName': studentName,
      'fatherName': fatherName,
      'feeTypeId': feeTypeId,
      'feeTypeName': feeTypeName,
      'totalHour': totalHour,
      'amount': amount,
      'session': session,
      'schoolId': schoolId,
      'createBy': createBy,
      'createDate': createDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'action': action,
    };
  }
}