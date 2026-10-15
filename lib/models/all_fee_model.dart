// Response of api/ReportApp/Getallfee/{schoolId}/{session}/{classId}/{sectionId}.
// Pre-school rows (studentList) and daycare rows (daycareList) use different
// field names, so both are normalised into one AllFeeStudent shape.

enum FeeCategory { preschool, daycare }

enum FeeStatus { fullyPaid, due, pending }

class AllFeeStudent {
  final int studentId;
  final String studentName;
  final String registrationNo;
  final String className;
  final String section;
  final double discount;
  final double totalFee;
  final double paidFee;
  final double due;
  final FeeCategory category;

  AllFeeStudent({
    required this.studentId,
    required this.studentName,
    required this.registrationNo,
    required this.className,
    required this.section,
    required this.discount,
    required this.totalFee,
    required this.paidFee,
    required this.due,
    required this.category,
  });

  static double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  factory AllFeeStudent.fromPreschool(Map<String, dynamic> json) {
    return AllFeeStudent(
      studentId: json['studentId'] ?? 0,
      studentName: (json['studentName'] ?? '').toString(),
      registrationNo: (json['registrationNo'] ?? '').toString(),
      className: (json['class'] ?? '').toString(),
      section: (json['section'] ?? '').toString(),
      discount: _num(json['discount']),
      totalFee: _num(json['totalFee']),
      paidFee: _num(json['paidFee']),
      due: _num(json['due']),
      category: FeeCategory.preschool,
    );
  }

  factory AllFeeStudent.fromDaycare(Map<String, dynamic> json) {
    return AllFeeStudent(
      studentId: json['studentId'] ?? 0,
      studentName: (json['studentName'] ?? '').toString(),
      registrationNo: (json['registrationNo'] ?? '').toString(),
      className: (json['class'] ?? 'Daycare').toString(),
      section: '',
      discount: _num(json['discount']),
      totalFee: _num(json['dTotalAmount']),
      paidFee: _num(json['dToPayAmount']),
      due: _num(json['dDueAmount']),
      category: FeeCategory.daycare,
    );
  }

  /// Fully paid: nothing due. Pending: nothing paid yet. Due: partly paid.
  FeeStatus get status {
    if (due <= 0) return FeeStatus.fullyPaid;
    if (paidFee <= 0) return FeeStatus.pending;
    return FeeStatus.due;
  }

  static List<AllFeeStudent> listFromJson(dynamic json) {
    if (json is! Map) return [];
    final list = <AllFeeStudent>[];
    final pre = json['studentList'];
    if (pre is List) {
      list.addAll(pre
          .whereType<Map>()
          .map((e) => AllFeeStudent.fromPreschool(Map<String, dynamic>.from(e))));
    }
    final day = json['daycareList'];
    if (day is List) {
      list.addAll(day
          .whereType<Map>()
          .map((e) => AllFeeStudent.fromDaycare(Map<String, dynamic>.from(e))));
    }
    return list;
  }
}
