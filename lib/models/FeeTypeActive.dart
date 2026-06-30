class FeeTypeActive {
  int? feeTypeId;
  String? feeType;
  String? action;
  DateTime? createDate;
  DateTime? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;
  int? sequenceNo;

  // Constructor
  FeeTypeActive({
    this.feeTypeId,
    this.feeType,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.sequenceNo,
  });

  // Factory constructor to create an instance from JSON
  factory FeeTypeActive.fromJson(Map<String, dynamic> json) {
    return FeeTypeActive(
      feeTypeId: json['feeTypeId'],
      feeType: json['feeType'],
      action: json['action'],
      createDate: json['createDate'] != null ? DateTime.parse(json['createDate']) : null,
      updateDate: json['updateDate'] != null ? DateTime.parse(json['updateDate']) : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
      sequenceNo: json['sequenceno'],
    );
  }

  // Method to convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'feeTypeId': feeTypeId,
      'feeType': feeType,
      'action': action,
      'createDate': createDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'sequenceno': sequenceNo,
    };
  }
}