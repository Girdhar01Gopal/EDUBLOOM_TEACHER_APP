class MasterGradeModel {
  final int id;
  final String grade;
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String schoolId;
  final String? session;

  MasterGradeModel({
    required this.id,
    required this.grade,
    required this.action,
    required this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    required this.schoolId,
    this.session,
  });

  factory MasterGradeModel.fromJson(Map<String, dynamic> json) {
    return MasterGradeModel(
      id: json['id'] as int,
      grade: (json['grade'] ?? '') as String,
      action: (json['action'] ?? '0').toString(),
      createDate: json['createDate'] != null
          ? DateTime.parse(json['createDate'] as String)
          : DateTime.now(),
      updateDate: json['updateDate'] != null
          ? DateTime.parse(json['updateDate'] as String)
          : null,
      createBy: json['createBy'] as String?,
      updateBy: json['updateBy'] as String?,
      schoolId: (json['schoolId'] ?? '') as String,
      session: json['session'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grade': grade,
      'action': action,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'session': session,
    };
  }

  static List<MasterGradeModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => MasterGradeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}