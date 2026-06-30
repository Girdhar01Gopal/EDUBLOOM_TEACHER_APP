class AllFeesReport {
  int? feesDurationId;
  String? feesDuration;
  String? session;
  String? registrationNo;
  String? admissionNo;
  String? studentName;
  int? classId;
  String? className; // Changed from 'class' to 'className' (reserved keyword)
  int? sectionId;
  String? section;
  int? tutionFee;
  int? transportFee;
  String? transportUser;
  String? feeTypeName;
  String? createDate;
  String? fatherName;
  String? fMobileno;
  String? feeSummary;
  int? examFee;
  int? totalAmount;
  int? payAmount;
  int? dueAmount;
  String? feeMonth;
  double? amount; // Changed from dynamic to double
  String? paidAction; // Changed from dynamic to String
  String? feesHead;
  int? transportStudent;
  int? apRPayAmount;
  int? maYPayAmount;
  int? juNPayAmount;
  int? juLPayAmount;
  int? auGPayAmount;
  int? sePPayAmount;
  int? ocTPayAmount;
  int? noVPayAmount;
  int? deCPayAmount;
  int? maRPayAmount;
  int? feBPayAmount;
  int? jaNPayAmount;
  int? apRDueAmount;
  int? maYDueAmount;
  int? juNDueAmount;
  int? juLDueAmount;
  int? auGDueAmount;
  int? sePDueAmount;
  int? ocTDueAmount;
  int? noVDueAmount;
  int? deCDueAmount;
  int? maRDueAmount;
  int? feBDueAmount;
  int? jaNDueAmount;

  AllFeesReport({
    this.feesDurationId,
    this.feesDuration,
    this.session,
    this.registrationNo,
    this.admissionNo,
    this.studentName,
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.tutionFee,
    this.transportFee,
    this.transportUser,
    this.feeTypeName,
    this.createDate,
    this.fatherName,
    this.fMobileno,
    this.feeSummary,
    this.examFee,
    this.totalAmount,
    this.payAmount,
    this.dueAmount,
    this.feeMonth,
    this.amount,
    this.paidAction,
    this.feesHead,
    this.transportStudent,
    this.apRPayAmount,
    this.maYPayAmount,
    this.juNPayAmount,
    this.juLPayAmount,
    this.auGPayAmount,
    this.sePPayAmount,
    this.ocTPayAmount,
    this.noVPayAmount,
    this.deCPayAmount,
    this.maRPayAmount,
    this.feBPayAmount,
    this.jaNPayAmount,
    this.apRDueAmount,
    this.maYDueAmount,
    this.juNDueAmount,
    this.juLDueAmount,
    this.auGDueAmount,
    this.sePDueAmount,
    this.ocTDueAmount,
    this.noVDueAmount,
    this.deCDueAmount,
    this.maRDueAmount,
    this.feBDueAmount,
    this.jaNDueAmount,
  });

  AllFeesReport.fromJson(Map<String, dynamic> json) {
    feesDurationId = json['feesDurationId'];
    feesDuration = json['feesDuration'];
    session = json['session'];
    registrationNo = json['registrationNo'];
    admissionNo = json['admissionNo'];
    studentName = json['studentName'];
    classId = json['classid'];
    className = json['class']; // Mapped to 'className'
    sectionId = json['sectionId'];
    section = json['section'];
    tutionFee = json['tutionFee'];
    transportFee = json['transportFee'];
    transportUser = json['transportUser'];
    feeTypeName = json['FeeTypeName'];
    createDate = json['createDate'];
    fatherName = json['fatherName'];
    fMobileno = json['fMobileno'];
    feeSummary = json['feeSummary'];
    examFee = json['examfee'];
    totalAmount = json['totalAmount'];
    payAmount = json['payAmount'];
    dueAmount = json['dueAmount'];
    feeMonth = json['feeMonth'];
    amount = json['amount'];
    paidAction = json['paidaction'];
    feesHead = json['feesHead'];
    transportStudent = json['transportStudent'];
    apRPayAmount = json['apR_PayAmount'];
    maYPayAmount = json['maY_PayAmount'];
    juNPayAmount = json['juN_PayAmount'];
    juLPayAmount = json['juL_PayAmount'];
    auGPayAmount = json['auG_PayAmount'];
    sePPayAmount = json['seP_PayAmount'];
    ocTPayAmount = json['ocT_PayAmount'];
    noVPayAmount = json['noV_PayAmount'];
    deCPayAmount = json['deC_PayAmount'];
    maRPayAmount = json['maR_PayAmount'];
    feBPayAmount = json['feB_PayAmount'];
    jaNPayAmount = json['jaN_PayAmount'];
    apRDueAmount = json['apR_DueAmount'];
    maYDueAmount = json['maY_DueAmount'];
    juNDueAmount = json['juN_DueAmount'];
    juLDueAmount = json['juL_DueAmount'];
    auGDueAmount = json['auG_DueAmount'];
    sePDueAmount = json['seP_DueAmount'];
    ocTDueAmount = json['ocT_DueAmount'];
    noVDueAmount = json['noV_DueAmount'];
    deCDueAmount = json['deC_DueAmount'];
    maRDueAmount = json['maR_DueAmount'];
    feBDueAmount = json['feB_DueAmount'];
    jaNDueAmount = json['jaN_DueAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['feesDurationId'] = feesDurationId;
    data['feesDuration'] = feesDuration;
    data['session'] = session;
    data['registrationNo'] = registrationNo;
    data['admissionNo'] = admissionNo;
    data['studentName'] = studentName;
    data['classid'] = classId;
    data['class'] = className; // Mapped to 'className'
    data['sectionId'] = sectionId;
    data['section'] = section;
    data['tutionFee'] = tutionFee;
    data['transportFee'] = transportFee;
    data['transportUser'] = transportUser;
    data['FeeTypeName'] = feeTypeName;
    data['createDate'] = createDate;
    data['fatherName'] = fatherName;
    data['fMobileno'] = fMobileno;
    data['feeSummary'] = feeSummary;
    data['examfee'] = examFee;
    data['totalAmount'] = totalAmount;
    data['payAmount'] = payAmount;
    data['dueAmount'] = dueAmount;
    data['feeMonth'] = feeMonth;
    data['amount'] = amount;
    data['paidaction'] = paidAction;
    data['feesHead'] = feesHead;
    data['transportStudent'] = transportStudent;
    data['apR_PayAmount'] = apRPayAmount;
    data['maY_PayAmount'] = maYPayAmount;
    data['juN_PayAmount'] = juNPayAmount;
    data['juL_PayAmount'] = juLPayAmount;
    data['auG_PayAmount'] = auGPayAmount;
    data['seP_PayAmount'] = sePPayAmount;
    data['ocT_PayAmount'] = ocTPayAmount;
    data['noV_PayAmount'] = noVPayAmount;
    data['deC_PayAmount'] = deCPayAmount;
    data['maR_PayAmount'] = maRPayAmount;
    data['feB_PayAmount'] = feBPayAmount;
    data['jaN_PayAmount'] = jaNPayAmount;
    data['apR_DueAmount'] = apRDueAmount;
    data['maY_DueAmount'] = maYDueAmount;
    data['juN_DueAmount'] = juNDueAmount;
    data['juL_DueAmount'] = juLDueAmount;
    data['auG_DueAmount'] = auGDueAmount;
    data['seP_DueAmount'] = sePDueAmount;
    data['ocT_DueAmount'] = ocTDueAmount;
    data['noV_DueAmount'] = noVDueAmount;
    data['deC_DueAmount'] = deCDueAmount;
    data['maR_DueAmount'] = maRDueAmount;
    data['feB_DueAmount'] = feBDueAmount;
    data['jaN_DueAmount'] = jaNDueAmount;
    return data;
  }
}
