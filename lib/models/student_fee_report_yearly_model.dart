// ── File: models/yearly_report_model.dart ──────────────────────────────────

class YearlyReportModel {
  final int sNo;
  final String registrationNo;
  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final double totalFee;
  final double totalDiscount;
  final double netFee;
  final double totalPaid;
  final double totalDue;

  YearlyReportModel({
    required this.sNo,
    required this.registrationNo,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.totalFee,
    required this.totalDiscount,
    required this.netFee,
    required this.totalPaid,
    required this.totalDue,
  });

  factory YearlyReportModel.fromJson(Map<String, dynamic> json, int index) {
    return YearlyReportModel(
      sNo: index + 1,
      registrationNo: json['registrationNo'] ?? json['RegistrationNo'] ?? '',
      studentName: json['studentName'] ?? json['StudentName'] ?? '',
      fatherName: json['fatherName'] ?? json['FatherName'] ?? '',
      // API returns "class" key
      className: json['class'] ?? json['className'] ?? json['ClassName'] ?? '',
      section: json['section'] ?? json['Section'] ?? '',
      totalFee: (json['totalFee'] ?? json['TotalFee'] ?? 0).toDouble(),
      totalDiscount:
      (json['totalDiscount'] ?? json['TotalDiscount'] ?? 0).toDouble(),
      netFee: (json['netFee'] ?? json['NetFee'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? json['TotalPaid'] ?? 0).toDouble(),
      totalDue: (json['totalDue'] ?? json['TotalDue'] ?? 0).toDouble(),
    );
  }
}