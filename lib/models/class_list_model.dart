import 'dart:convert';

/// ==============================
/// CLASS LIST MODEL
/// ==============================
class ClassListModel {
  final List<ClassData> listData;
  final int statusCode;
  final bool isSuccess;
  final String? messages;

  ClassListModel({
    required this.listData,
    this.statusCode = 0,
    this.isSuccess = false,
    this.messages,
  });

  /// GetClassTeacher API sends the list inside "data", not "listData".
  factory ClassListModel.fromJson(Map<String, dynamic> json) {
    return ClassListModel(
      listData: (json['data'] as List?)
          ?.map((e) => ClassData.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      statusCode: json['statusCode'] is int
          ? json['statusCode']
          : int.tryParse(json['statusCode']?.toString() ?? '') ?? 0,
      isSuccess: json['isSuccess'] == true,
      messages: json['messages']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': listData.map((e) => e.toJson()).toList(),
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
    };
  }

  static ClassListModel fromJsonString(String source) {
    return ClassListModel.fromJson(jsonDecode(source));
  }

  String toJsonString() => jsonEncode(toJson());
}

/// ==============================
/// CLASS DATA MODEL
/// ==============================
class ClassData {
  final int classId;
  final String className;
  final String? studentClassId;
  final String action;
  final DateTime? createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String schoolId;
  final int? sqno;

  ClassData({
    required this.classId,
    required this.className,
    this.studentClassId,
    required this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    required this.schoolId,
    this.sqno,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      classId: _toInt(json['classId']),
      className: (json['class'] ?? '').toString().trim(),
      studentClassId: json['studentClassId']?.toString(),
      // GetClassTeacher sends "action": null -> fallback to "" so
      // c.action.trim() in the view never crashes on a null.
      action: (json['action'] ?? '').toString(),
      createDate: _toDateTime(json['createDate']),
      updateDate: _toDateTime(json['updateDate']),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      // GetClassTeacher sends "schoolId": null -> fallback to "" so the
      // field stays a non-null String as declared above.
      schoolId: (json['schoolId'] ?? '').toString(),
      sqno: _toNullableInt(json['sqno']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'class': className,
      'studentClassId': studentClassId,
      'action': action,
      'createDate': createDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'sqno': sqno,
    };
  }

  /// Optional copyWith if needed in edit/update
  ClassData copyWith({
    int? classId,
    String? className,
    String? studentClassId,
    String? action,
    DateTime? createDate,
    DateTime? updateDate,
    String? createBy,
    String? updateBy,
    String? schoolId,
    int? sqno,
  }) {
    return ClassData(
      classId: classId ?? this.classId,
      className: className ?? this.className,
      studentClassId: studentClassId ?? this.studentClassId,
      action: action ?? this.action,
      createDate: createDate ?? this.createDate,
      updateDate: updateDate ?? this.updateDate,
      createBy: createBy ?? this.createBy,
      updateBy: updateBy ?? this.updateBy,
      schoolId: schoolId ?? this.schoolId,
      sqno: sqno ?? this.sqno,
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}