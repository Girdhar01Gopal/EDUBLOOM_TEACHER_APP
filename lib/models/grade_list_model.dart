class GradeModel {
  final int id;
  final String grade;
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String schoolId;
  final String? session;
  GradeModel({
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
  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'],
      grade: json['grade'],
      action: json['action'],
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null ? DateTime.parse(json['updateDate']) : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
      session: json['session'],
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
}

class GradeListModel {
  final List<GradeModel> grades;
  GradeListModel({required this.grades});
  factory GradeListModel.fromJson(List<dynamic> json) {
    return GradeListModel(
      grades: json.map((e) => GradeModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
  List<Map<String, dynamic>> toJson() {
    return grades.map((e) => e.toJson()).toList();
  }
}