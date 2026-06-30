// designation_model.dart

class DesignationResponse {
  final List<DesignationModel> listData;
  final dynamic currentSession;

  DesignationResponse({
    required this.listData,
    this.currentSession,
  });

  factory DesignationResponse.fromJson(Map<String, dynamic> json) {
    return DesignationResponse(
      listData: json['listData'] == null
          ? <DesignationModel>[]
          : List<DesignationModel>.from(
        json['listData'].map(
              (x) => DesignationModel.fromJson(x),
        ),
      ),
      currentSession: json['currentSession'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((e) => e.toJson()).toList(),
      'currentSession': currentSession,
    };
  }
}

class DesignationModel {
  final int tdId;
  final String designation;
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String schoolId;

  DesignationModel({
    required this.tdId,
    required this.designation,
    required this.action,
    required this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      tdId: json['tdId'] ?? 0,
      designation: json['designation']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null && json['updateDate'].toString().isNotEmpty
          ? DateTime.parse(json['updateDate'])
          : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tdId': tdId,
      'designation': designation,
      'action': action,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }
}