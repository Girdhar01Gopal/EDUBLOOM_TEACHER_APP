// leave_apply_model.dart
// Generated from ViewLeaveApply API response
// Endpoint: /api/MasterApp/ViewLeaveApply/{schoolCode}/{session}/{userId}

class LeaveApplyResponse {
  final List<LeaveData> listData;

  LeaveApplyResponse({
    required this.listData,
  });

  factory LeaveApplyResponse.fromJson(Map<String, dynamic> json) {
    return LeaveApplyResponse(
      listData: json['listData'] != null
          ? List<LeaveData>.from(
          (json['listData'] as List).map((x) => LeaveData.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((x) => x.toJson()).toList(),
    };
  }
}

class LeaveData {
  final int? leaveId;
  final int? userId;
  final String? employeeCode;
  final String? employeeName;
  final String? registrationNo;
  final String? leave;
  final int? balanceLeave;
  final int? totalLeave;
  final String? reasonforLeave;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? noOfDay;
  final String? remark;
  final String? approvedRemark;
  final int? action;
  final int? schoolId;
  final String? session;
  final DateTime? createdate;
  final DateTime? updatedate;
  final String? createBy;
  final String? updateBy;
  final String? status;
  final String? leaveFile;
  final String? leaveFileBytes;
  final String? leaveFileName;
  final String? leaveFileType;

  LeaveData({
    this.leaveId,
    this.userId,
    this.employeeCode,
    this.employeeName,
    this.registrationNo,
    this.leave,
    this.balanceLeave,
    this.totalLeave,
    this.reasonforLeave,
    this.fromDate,
    this.toDate,
    this.noOfDay,
    this.remark,
    this.approvedRemark,
    this.action,
    this.schoolId,
    this.session,
    this.createdate,
    this.updatedate,
    this.createBy,
    this.updateBy,
    this.status,
    this.leaveFile,
    this.leaveFileBytes,
    this.leaveFileName,
    this.leaveFileType,
  });

  factory LeaveData.fromJson(Map<String, dynamic> json) {
    return LeaveData(
      leaveId: json['leaveId'],
      userId: json['userId'],
      employeeCode: json['employeeCode'],
      employeeName: json['employeeName'],
      registrationNo: json['registrationNo'],
      leave: json['leave'],
      balanceLeave: json['balanceLeave'],
      totalLeave: json['totalLeave'],
      reasonforLeave: json['reasonforLeave'],
      fromDate: json['fromDate'] != null ? DateTime.tryParse(json['fromDate']) : null,
      toDate: json['toDate'] != null ? DateTime.tryParse(json['toDate']) : null,
      noOfDay: json['noOfDay'],
      remark: json['remark'],
      approvedRemark: json['approvedRemark'],
      action: json['action'],
      schoolId: json['schoolId'],
      session: json['session'],
      createdate: json['createdate'] != null ? DateTime.tryParse(json['createdate']) : null,
      updatedate: json['updatedate'] != null ? DateTime.tryParse(json['updatedate']) : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      status: json['status'],
      leaveFile: json['leaveFile'],
      leaveFileBytes: json['leaveFileBytes'],
      leaveFileName: json['leaveFileName'],
      leaveFileType: json['leaveFileType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'leaveId': leaveId,
      'userId': userId,
      'employeeCode': employeeCode,
      'employeeName': employeeName,
      'registrationNo': registrationNo,
      'leave': leave,
      'balanceLeave': balanceLeave,
      'totalLeave': totalLeave,
      'reasonforLeave': reasonforLeave,
      'fromDate': fromDate?.toIso8601String(),
      'toDate': toDate?.toIso8601String(),
      'noOfDay': noOfDay,
      'remark': remark,
      'approvedRemark': approvedRemark,
      'action': action,
      'schoolId': schoolId,
      'session': session,
      'createdate': createdate?.toIso8601String(),
      'updatedate': updatedate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'status': status,
      'leaveFile': leaveFile,
      'leaveFileBytes': leaveFileBytes,
      'leaveFileName': leaveFileName,
      'leaveFileType': leaveFileType,
    };
  }
}