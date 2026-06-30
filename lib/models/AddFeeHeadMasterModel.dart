class AddFeeHeadMasterModel {
  final int statusCode;
  final bool isSuccess;
  final String messages;
  final List<AddFeeHeadMasterData> data;
  final bool showPopup;
  final String? popupMessage;

  AddFeeHeadMasterModel({
    required this.statusCode,
    required this.isSuccess,
    required this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory AddFeeHeadMasterModel.fromJson(Map<String, dynamic> json) {
    return AddFeeHeadMasterModel(
      statusCode: json['statusCode'] ?? 0,
      isSuccess: json['isSuccess'] ?? false,
      messages: json['messages'] ?? '',
      data: (json['data'] is List)
          ? List<AddFeeHeadMasterData>.from(
        (json['data'] as List).map((e) => AddFeeHeadMasterData.fromJson(e)),
      )
          : <AddFeeHeadMasterData>[],
      showPopup: json['showPopup'] ?? false,
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data.map((e) => e.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class AddFeeHeadMasterData {
  final int? feeHeadId;
  final String? session;
  final int? classId;
  final String? className;
  final String? feesDurationName;
  final int? sectionId;
  final String? sectionName;
  final String? feesHead;
  final String? amount;
  final int? feesDuration;
  final String? action;
  final String? statues; // backend spelling
  final String? createDate;
  final String? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;
  final int? feeTypeId;
  final String? feeType;

  AddFeeHeadMasterData({
    this.feeHeadId,
    this.session,
    this.classId,
    this.className,
    this.feesDurationName,
    this.sectionId,
    this.sectionName,
    this.feesHead,
    this.amount,
    this.feesDuration,
    this.action,
    this.statues,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.feeTypeId,
    this.feeType,
  });

  factory AddFeeHeadMasterData.fromJson(Map<String, dynamic> json) {
    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return AddFeeHeadMasterData(
      feeHeadId: _asInt(json['feeHeadId']),
      session: json['session']?.toString(),
      classId: _asInt(json['classId']),
      className: json['className']?.toString(),
      feesDurationName: json['feesDurationName']?.toString(),
      sectionId: _asInt(json['sectionId']),
      sectionName: json['sectionName']?.toString(),
      feesHead: json['feesHead']?.toString(),
      amount: json['amount']?.toString(),
      feesDuration: _asInt(json['feesDuration']),
      action: json['action']?.toString(),
      statues: json['statues']?.toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      schoolId: json['schoolId']?.toString(),
      feeTypeId: _asInt(json['feeTypeId']),
      feeType: json['feeType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feeHeadId': feeHeadId,
      'session': session,
      'classId': classId,
      'className': className,
      'feesDurationName': feesDurationName,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'feesHead': feesHead,
      'amount': amount,
      'feesDuration': feesDuration,
      'action': action,
      'statues': statues,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'feeTypeId': feeTypeId,
      'feeType': feeType,
    };
  }
}