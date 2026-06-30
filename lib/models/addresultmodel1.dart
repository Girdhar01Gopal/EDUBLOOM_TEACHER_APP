class AddResultShow {
  final int id;
  final int studentId;
  final String studentName;
  final String registrationNo;
  final String className;
  final String fatherName;
  final int classId;
  final int sectionId;
  final String section;
  final int subjectId;
  final String subject;
  final String term;
  final String? grade;
  final String session;
  final int? schoolId;
  final String? createBy;

  AddResultShow({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.registrationNo,
    required this.className,
    required this.fatherName,
    required this.classId,
    required this.sectionId,
    required this.section,
    required this.subjectId,
    required this.subject,
    required this.term,
    this.grade,
    required this.session,
    this.schoolId,
    this.createBy,
  });

  /// Create an [AddResultShow] from a JSON map
  factory AddResultShow.fromJson(Map<String, dynamic> json) {
    return AddResultShow(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      studentName: json['studentName'] as String,
      registrationNo: json['registrationNo'] as String,
      className: json['class'] as String,
      fatherName: json['fatherName'] as String,
      classId: json['classId'] as int,
      sectionId: json['sectionId'] as int,
      section: json['section'] as String,
      subjectId: json['subjectId'] as int,
      subject: json['subject'] as String,
      term: json['term'] as String,
      grade: json['grade'] as String?,
      session: json['session'] as String,
      schoolId: json['schoolId'] as int?,
      createBy: json['createBy'] as String?,
    );
  }

  /// Convert this [AddResultShow] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'registrationNo': registrationNo,
      'class': className,
      'fatherName': fatherName,
      'classId': classId,
      'sectionId': sectionId,
      'section': section,
      'subjectId': subjectId,
      'subject': subject,
      'term': term,
      'grade': grade,
      'session': session,
      'schoolId': schoolId,
      'createBy': createBy,
    };
  }

  /// Parse a JSON list into a List of [AddResultShow]
  static List<AddResultShow> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((item) => AddResultShow.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Copy with updated fields
  AddResultShow copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? registrationNo,
    String? className,
    String? fatherName,
    int? classId,
    int? sectionId,
    String? section,
    int? subjectId,
    String? subject,
    String? term,
    String? grade,
    String? session,
    int? schoolId,
    String? createBy,
  }) {
    return AddResultShow(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      registrationNo: registrationNo ?? this.registrationNo,
      className: className ?? this.className,
      fatherName: fatherName ?? this.fatherName,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      section: section ?? this.section,
      subjectId: subjectId ?? this.subjectId,
      subject: subject ?? this.subject,
      term: term ?? this.term,
      grade: grade ?? this.grade,
      session: session ?? this.session,
      schoolId: schoolId ?? this.schoolId,
      createBy: createBy ?? this.createBy,
    );
  }

  @override
  String toString() {
    return 'AddResultShow('
        'id: $id, '
        'studentId: $studentId, '
        'studentName: $studentName, '
        'registrationNo: $registrationNo, '
        'className: $className, '
        'fatherName: $fatherName, '
        'classId: $classId, '
        'sectionId: $sectionId, '
        'section: $section, '
        'subjectId: $subjectId, '
        'subject: $subject, '
        'term: $term, '
        'grade: $grade, '
        'session: $session, '
        'schoolId: $schoolId, '
        'createBy: $createBy'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddResultShow &&
        other.id == id &&
        other.studentId == studentId &&
        other.studentName == studentName &&
        other.registrationNo == registrationNo &&
        other.className == className &&
        other.fatherName == fatherName &&
        other.classId == classId &&
        other.sectionId == sectionId &&
        other.section == section &&
        other.subjectId == subjectId &&
        other.subject == subject &&
        other.term == term &&
        other.grade == grade &&
        other.session == session &&
        other.schoolId == schoolId &&
        other.createBy == createBy;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      id,
      studentId,
      studentName,
      registrationNo,
      className,
      fatherName,
      classId,
      sectionId,
      section,
      subjectId,
      subject,
      term,
      grade,
      session,
      schoolId,
      createBy,
    ]);
  }
}