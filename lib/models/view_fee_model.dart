class ViewFeeModel {
  int myDueAmount;
  int paymentId;
  int discount;
  int totalAmount;
  String paymentMode;
  String? modePaymentOnline;
  String studentName;
  String session;
  String registrationNo;
  bool isCheckBoxHide;
  String feeType;
  String feeDuration;

  ViewFeeModel({
    required this.myDueAmount,
    required this.paymentId,
    required this.discount,
    required this.totalAmount,
    required this.paymentMode,
    this.modePaymentOnline,
    required this.studentName,
    required this.session,
    required this.registrationNo,
    required this.isCheckBoxHide,
    required this.feeType,
    required this.feeDuration,
  });

  factory ViewFeeModel.fromJson(Map<String, dynamic> json) {
    return ViewFeeModel(
      myDueAmount: json['myDueAmount'] ?? 0,
      paymentId: json['paymentId'] ?? 0,
      discount: json['discount'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      paymentMode: json['paymentMode'] ?? 'N/A',
      modePaymentOnline: json['modePaymentOnline'],
      studentName: json['studentName'] ?? 'N/A',
      session: json['session'] ?? 'N/A',
      registrationNo: json['registrationNo'] ?? 'N/A',
      isCheckBoxHide: json['isCheckBoxHide'] ?? false,
      feeType: json['feeType'] ?? 'N/A',
      feeDuration: json['feeDuration'] ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'myDueAmount': myDueAmount,
      'paymentId': paymentId,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMode': paymentMode,
      'modePaymentOnline': modePaymentOnline,
      'studentName': studentName,
      'session': session,
      'registrationNo': registrationNo,
      'isCheckBoxHide': isCheckBoxHide,
      'feeType': feeType,
      'feeDuration': feeDuration,
    };
  }

  @override
  String toString() {
    return 'ViewFeeModel(myDueAmount: $myDueAmount, paymentId: $paymentId, discount: $discount, totalAmount: $totalAmount, paymentMode: $paymentMode, studentName: $studentName, registrationNo: $registrationNo)';
  }
}
