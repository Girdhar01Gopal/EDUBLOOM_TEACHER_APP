class ReportCardInside4Model {
  final int? id;
  final int? classId;
  final String? className;
  final int? sectionId;
  final String? section;
  final String? session;
  final int? subjectId;
  final String? subject;
  final String? descriptors;
  final String? action;
  final String? createDate;
  final String? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;
  final String? grade;

  ReportCardInside4Model({
    this.id,
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.session,
    this.subjectId,
    this.subject,
    this.descriptors,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.grade,
  });

  factory ReportCardInside4Model.fromJson(Map<String, dynamic> json) {
    return ReportCardInside4Model(
      id: json['id'] as int?,
      classId: json['classId'] as int?,
      className: json['className'] as String?,
      sectionId: json['sectionId'] as int?,
      section: json['section'] as String?,
      session: json['session'] as String?,
      subjectId: json['subjectId'] as int?,
      subject: json['subject'] as String?,
      descriptors: json['descriptors'] as String?,
      action: json['action'] as String?,
      createDate: json['createDate'] as String?,
      updateDate: json['updateDate'] as String?,
      createBy: json['createBy'] as String?,
      updateBy: json['updateBy'] as String?,
      schoolId: json['schoolId'] as String?,
      grade: json['grade'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'sectionId': sectionId,
      'section': section,
      'session': session,
      'subjectId': subjectId,
      'subject': subject,
      'descriptors': descriptors,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'grade': grade,
    };
  }

  ReportCardInside4Model copyWith({
    int? id,
    int? classId,
    String? className,
    int? sectionId,
    String? section,
    String? session,
    int? subjectId,
    String? subject,
    String? descriptors,
    String? action,
    String? createDate,
    String? updateDate,
    String? createBy,
    String? updateBy,
    String? schoolId,
    String? grade,
  }) {
    return ReportCardInside4Model(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      sectionId: sectionId ?? this.sectionId,
      section: section ?? this.section,
      session: session ?? this.session,
      subjectId: subjectId ?? this.subjectId,
      subject: subject ?? this.subject,
      descriptors: descriptors ?? this.descriptors,
      action: action ?? this.action,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      createBy: createBy ?? this.createBy,
      updateBy: updateBy ?? this.updateBy,
      schoolId: schoolId ?? this.schoolId,
      grade: grade ?? this.grade,
    );
  }

  @override
  String toString() {
    return 'ReportCardInside4Model(id: $id, subject: $subject, '
        'descriptors: $descriptors, grade: $grade, session: $session)';
  }
}