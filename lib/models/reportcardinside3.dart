class ReportCardInside3Model {
  final int? id;
  final int? classId;
  final String? foundationalSkills;
  final String? action;
  final String? createDate;
  final String? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;
  final String? level;
  final String? session;

  ReportCardInside3Model({
    this.id,
    this.classId,
    this.foundationalSkills,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.level,
    this.session,
  });

  factory ReportCardInside3Model.fromJson(Map<String, dynamic> json) {
    return ReportCardInside3Model(
      id: json['id'] as int?,
      classId: json['classId'] as int?,
      foundationalSkills: json['foundationalSkills'] as String?,
      action: json['action'] as String?,
      createDate: json['createDate'] as String?,
      updateDate: json['updateDate'] as String?,
      createBy: json['createBy'] as String?,
      updateBy: json['updateBy'] as String?,
      schoolId: json['schoolId'] as String?,
      level: json['level'] as String?,
      session: json['session'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'foundationalSkills': foundationalSkills,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'level': level,
      'session': session,
    };
  }

  ReportCardInside3Model copyWith({
    int? id,
    int? classId,
    String? foundationalSkills,
    String? action,
    String? createDate,
    String? updateDate,
    String? createBy,
    String? updateBy,
    String? schoolId,
    String? level,
    String? session,
  }) {
    return ReportCardInside3Model(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      foundationalSkills: foundationalSkills ?? this.foundationalSkills,
      action: action ?? this.action,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      createBy: createBy ?? this.createBy,
      updateBy: updateBy ?? this.updateBy,
      schoolId: schoolId ?? this.schoolId,
      level: level ?? this.level,
      session: session ?? this.session,
    );
  }

  @override
  String toString() {
    return 'ReportCardInside3Model(id: $id, classId: $classId, '
        'foundationalSkills: $foundationalSkills, level: $level, session: $session)';
  }
}