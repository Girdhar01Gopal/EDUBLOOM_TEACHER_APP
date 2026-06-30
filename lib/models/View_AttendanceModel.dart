class ViewAttendanceModel {
  List<ListData> listData;

  ViewAttendanceModel({this.listData = const []});

  // Factory constructor for creating a new instance from JSON data
  factory ViewAttendanceModel.fromJson(Map<String, dynamic> json) {
    return ViewAttendanceModel(
      listData: json['listData'] != null
          ? (json['listData'] as List)
          .map((v) => ListData.fromJson(v))
          .toList()
          : [],
    );
  }

  // Convert the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((v) => v.toJson()).toList(),
    };
  }
}

class ListData {
  bool isCheck;
  int cFeesHId;
  String registrationNo;
  int studentId;
  String studentName;
  String amount;
  String? feesHead;
  String? mappingPayMonth;
  String? session;
  String? action;
  int classId;
  String? className;
  int sectionId;
  String? section;
  String? feeType;
  String? feesDuration;
  int? discount;
  String? schoolId;
  int feeTypeId;
  String? deleteBy;
  String? feeMonth1;
  int? totalAmount;
  int? dueAmount;
  int? payAmount;
  int? totalPay;
  String? remarks;
  String? dueAmount1;
  String? paidAction;
  int feeDurationId;

  // New fields for month payments
  int? january;
  int? february;
  int? march;
  int? april;
  int? may;
  int? june;
  int? july;
  int? august;
  int? september;
  int? october;
  int? november;
  int? december;

  ListData({
    this.isCheck = false,
    this.cFeesHId = 0,
    this.registrationNo = '',
    this.studentId = 0,
    this.studentName = '',
    this.amount = '0',
    this.feesHead,
    this.mappingPayMonth,
    this.session,
    this.action,
    this.classId = 0,
    this.className,
    this.sectionId = 0,
    this.section,
    this.feeType,
    this.feesDuration,
    this.discount,
    this.schoolId = '',
    this.feeTypeId = 0,
    this.deleteBy,
    this.feeMonth1,
    this.totalAmount,
    this.dueAmount,
    this.payAmount,
    this.totalPay,
    this.remarks,
    this.dueAmount1,
    this.paidAction,
    this.feeDurationId = 0,
    this.january,
    this.february,
    this.march,
    this.april,
    this.may,
    this.june,
    this.july,
    this.august,
    this.september,
    this.october,
    this.november,
    this.december,
  });

  factory ListData.fromJson(Map<String, dynamic> json) {
    return ListData(
      isCheck: json['isCheck'] ?? false,
      cFeesHId: json['cFeesHId'] ?? 0,
      registrationNo: json['registrationNo'] ?? '',
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      amount: json['amount']?.toString() ?? '0',
      feesHead: json['feesHead'],
      mappingPayMonth: json['mappingPayMonth'],
      session: json['session'],
      action: json['action'],
      classId: json['classId'] ?? 0,
      className: json['class'],
      sectionId: json['sectionId'] ?? 0,
      section: json['section'],
      feeType: json['feeType'],
      feesDuration: json['feesDuration'],
      discount: json['discount'] ?? 0,
      schoolId: json['schoolId'] ?? '',
      feeTypeId: json['feeTypeId'] ?? 0,
      deleteBy: json['deleteBy'],
      feeMonth1: json['feeMonth1'],
      totalAmount: json['totalAmount'] != null ? int.tryParse(json['totalAmount'].toString()) : 0,
      dueAmount: json['dueAmount'] != null ? int.tryParse(json['dueAmount'].toString()) : 0,
      payAmount: json['payAmount'] != null ? int.tryParse(json['payAmount'].toString()) : 0,
      totalPay: json['totalPay'] != null ? int.tryParse(json['totalPay'].toString()) : 0,
      remarks: json['remarks'],
      dueAmount1: json['dueAmount1'],
      paidAction: json['paidaction'],
      feeDurationId: json['feeDurationId'] ?? 0,
      january: json['january'] != null ? int.tryParse(json['january'].toString()) : null,
      february: json['february'] != null ? int.tryParse(json['february'].toString()) : null,
      march: json['march'] != null ? int.tryParse(json['march'].toString()) : null,
      april: json['april'] != null ? int.tryParse(json['april'].toString()) : null,
      may: json['may'] != null ? int.tryParse(json['may'].toString()) : null,
      june: json['june'] != null ? int.tryParse(json['june'].toString()) : null,
      july: json['july'] != null ? int.tryParse(json['july'].toString()) : null,
      august: json['august'] != null ? int.tryParse(json['august'].toString()) : null,
      september: json['september'] != null ? int.tryParse(json['september'].toString()) : null,
      october: json['october'] != null ? int.tryParse(json['october'].toString()) : null,
      november: json['november'] != null ? int.tryParse(json['november'].toString()) : null,
      december: json['december'] != null ? int.tryParse(json['december'].toString()) : null,
    );
  }

  // Convert this object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'isCheck': isCheck,
      'cFeesHId': cFeesHId,
      'registrationNo': registrationNo,
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'feesHead': feesHead,
      'mappingPayMonth': mappingPayMonth,
      'session': session,
      'action': action,
      'classId': classId,
      'class': className,
      'sectionId': sectionId,
      'section': section,
      'feeType': feeType,
      'feesDuration': feesDuration,
      'discount': discount,
      'schoolId': schoolId,
      'feeTypeId': feeTypeId,
      'deleteBy': deleteBy,
      'feeMonth1': feeMonth1,
      'totalAmount': totalAmount,
      'dueAmount': dueAmount,
      'payAmount': payAmount,
      'totalPay': totalPay,
      'remarks': remarks,
      'dueAmount1': dueAmount1,
      'paidaction': paidAction,
      'feeDurationId': feeDurationId,
      'january': january,
      'february': february,
      'march': march,
      'april': april,
      'may': may,
      'june': june,
      'july': july,
      'august': august,
      'september': september,
      'october': october,
      'november': november,
      'december': december,
    };
  }

  // Override toString method to print the object's properties
  @override
  String toString() {
    return 'ListData(studentName: $studentName, amount: $amount, class: $className, section: $section)';
  }
}
