class totalclasswisestudent {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<tcData>? data;

  totalclasswisestudent({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
  });

  factory totalclasswisestudent.fromJson(Map<String, dynamic> json) {
    return totalclasswisestudent(
      statusCode: json['statusCode'],
      isSuccess: json['isSuccess'],
      messages: json['messages']?.toString(),
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => tcData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class tcData {
  final String? className;
  final int? totalStudent;
  final int? classId;

  tcData({
    this.className,
    this.totalStudent,
    this.classId,
  });

  factory tcData.fromJson(Map<String, dynamic> json) {
    return tcData(
      className: json['className']?.toString() ??
          json['class']?.toString() ??
          json['ClassName']?.toString(),
      totalStudent: _toInt(json['totalStudent'] ??
          json['TotalStudent'] ??
          json['total']),
      classId: _toInt(json['classId'] ?? json['ClassId']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}