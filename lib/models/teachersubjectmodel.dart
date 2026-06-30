class TeacherSubjectModel {
  List<TeacherSubjectItem> listData;

  TeacherSubjectModel({required this.listData});

  factory TeacherSubjectModel.fromJson(Map<String, dynamic> json) {
    final raw = (json['listData'] ?? []) as List;
    return TeacherSubjectModel(
      listData: raw.map((e) => TeacherSubjectItem.fromJson(e)).toList(),
    );
  }
}

class TeacherSubjectItem {
  final int? id;
  final String? registrationNo;
  final String? teacherName;
  final String? session;
  final int? classId;
  final String? className;
  final String? sectionName;
  final int? sectionId;
  final String? subjectName;
  final int? subjectId;
  final String? action;
  final String? createDate;
  final String? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;

  TeacherSubjectItem({
    this.id,
    this.registrationNo,
    this.teacherName,
    this.session,
    this.classId,
    this.className,
    this.sectionName,
    this.sectionId,
    this.subjectName,
    this.subjectId,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
  });

  factory TeacherSubjectItem.fromJson(Map<String, dynamic> json) {
    return TeacherSubjectItem(
      id: json['id'],
      registrationNo: json['registrationNo']?.toString(),
      teacherName: json['teacherName']?.toString(),
      session: json['session']?.toString(),
      classId: _toInt(json['classId']),
      className: json['className']?.toString(),
      sectionName: json['sectionName']?.toString(),
      sectionId: _toInt(json['sectionId']),
      subjectName: json['subjectName']?.toString(),
      subjectId: _toInt(json['subjectId']),
      action: json['action']?.toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      schoolId: json['schoolId']?.toString(),
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
