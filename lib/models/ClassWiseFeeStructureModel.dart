class FeeResponse {
  final int statusCode;
  final bool isSuccess;
  final String? messages;
  final List<FeeData> data;
  final bool showPopup;
  final String? popupMessage;

  FeeResponse({
    required this.statusCode,
    required this.isSuccess,
    this.messages,
    required this.data,
    required this.showPopup,
    this.popupMessage,
  });

  factory FeeResponse.fromJson(Map<String, dynamic> json) {
    return FeeResponse(
      statusCode: json['statusCode'] ?? 0,
      isSuccess: json['isSuccess'] ?? false,
      messages: json['messages']?.toString(),
      data: (json['data'] is List)
          ? (json['data'] as List)
          .map((e) => FeeData.fromJson((e as Map).cast<String, dynamic>()))
          .toList()
          : <FeeData>[],
      showPopup: json['showPopup'] ?? false,
      popupMessage: json['popupMessage']?.toString(),
    );
  }
}

class FeeData {
  final int classId;
  final String session;
  final String amount;

  final String? className;     // ✅ ADDED
  final String? feeTypeName;
  final String? feeDuration;

  FeeData({
    required this.classId,
    required this.session,
    required this.amount,
    this.className,            // ✅ ADDED
    this.feeTypeName,
    this.feeDuration,
  });

  factory FeeData.fromJson(Map<String, dynamic> json) {
    return FeeData(
      classId: json['classId'] ?? 0,
      session: (json['session'] ?? '').toString(),
      amount: (json['amount'] ?? '0').toString(),
      className: json['className']?.toString(),     // ✅ ADDED
      feeTypeName: json['feeTypeName']?.toString(),
      feeDuration: json['feeDuration']?.toString(),
    );
  }

  int get amountAsInt => int.tryParse(amount) ?? 0;

  String get feeTypeText =>
      (feeTypeName == null || feeTypeName!.trim().isEmpty) ? "-" : feeTypeName!.trim();

  String get durationText =>
      (feeDuration == null || feeDuration!.trim().isEmpty) ? "-" : feeDuration!.trim();

  // ✅ Use className if present, else fallback to classId
  String get classBatchText {
    final n = (className ?? "").trim();
    return n.isEmpty ? classId.toString() : n;
  }
}

class FeeStructureTableRow {
  final String sno;
  final String classBatch;
  final String feeType;
  final String feeDuration;
  final String amount;

  FeeStructureTableRow({
    required this.sno,
    required this.classBatch,
    required this.feeType,
    required this.feeDuration,
    required this.amount,
  });
}
