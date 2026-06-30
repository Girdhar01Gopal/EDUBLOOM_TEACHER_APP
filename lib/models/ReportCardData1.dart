class ReportCardData1 {
  final int id;
  final int studentId;
  final String studentName;
  final String registrationNo;
  final String className;
  final String? fatherName;
  final int classId;
  final int sectionId;
  final String section;
  final int subjectId;
  final String? subject;
  final String term;
  final String? grade;
  final String session;
  final String? schoolId;
  final String? createBy;

  ReportCardData1({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.registrationNo,
    required this.className,
    this.fatherName,
    required this.classId,
    required this.sectionId,
    required this.section,
    required this.subjectId,
    this.subject,
    required this.term,
    this.grade,
    required this.session,
    this.schoolId,
    this.createBy,
  });

  factory ReportCardData1.fromJson(Map<String, dynamic> json) {
    return ReportCardData1(
      id: json['id'] as int,
      studentId: json['studentId'] as int,
      studentName: json['studentName'] as String,
      registrationNo: json['registrationNo'] as String,
      className: json['class'] as String,
      fatherName: json['fatherName'] as String?,
      classId: json['classId'] as int,
      sectionId: json['sectionId'] as int,
      section: json['section'] as String,
      subjectId: json['subjectId'] as int,
      subject: json['subject'] as String?,
      term: json['term'] as String,
      grade: json['grade'] as String?,
      session: json['session'] as String,
      schoolId: json['schoolId'] as String?,
      createBy: json['createBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
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

  static List<ReportCardData1> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((e) => ReportCardData1.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}