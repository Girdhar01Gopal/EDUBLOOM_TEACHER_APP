class Student {
  int? studentId;
  String registrationNo;
  String studentName;
  String? fatherName;
  String? section;
  int sectionId;
  int classId;
  String? className;
  double totalFeeAmount;
  double totalDiscountAmount;
  String session;
  String schoolId;

  Student({
    this.studentId,
    required this.registrationNo,
    required this.studentName,
    this.fatherName,
    this.section,
    required this.sectionId,
    required this.classId,
    this.className,
    required this.totalFeeAmount,
    required this.totalDiscountAmount,
    required this.session,
    required this.schoolId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] as int?,
      registrationNo: json['registrationNo'],
      studentName: json['studentName'],
      fatherName: json['fatherName'],
      section: json['section'],
      sectionId: json['sectionId'],
      classId: json['classId'],
      className: json['class'],
      totalFeeAmount: json['totalFeeAmount'].toDouble(),
      totalDiscountAmount: json['totalDiscountAmount'].toDouble(),
      session: json['session'],
      schoolId: json['schoolId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'registrationNo': registrationNo,
      'studentName': studentName,
      'fatherName': fatherName,
      'section': section,
      'sectionId': sectionId,
      'classId': classId,
      'class': className,
      'totalFeeAmount': totalFeeAmount,
      'totalDiscountAmount': totalDiscountAmount,
      'session': session,
      'schoolId': schoolId,
    };
  }
}

class StudentList {
  List<Student> listData;

  StudentList({required this.listData});

  factory StudentList.fromJson(Map<String, dynamic> json) {
    return StudentList(
      listData: List<Student>.from(
        json['listData'].map((item) => Student.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((student) => student.toJson()).toList(),
    };
  }
}