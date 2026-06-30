import 'dart:convert';

/// ==============================
/// CLASS LIST MODEL
/// ==============================
class ClassListModel {
  final List<ClassData> listData;
  final String? currentSession;

  ClassListModel({
    required this.listData,
    this.currentSession,
  });

  factory ClassListModel.fromJson(Map<String, dynamic> json) {
    return ClassListModel(
      listData: (json['listData'] as List?)
          ?.map((e) => ClassData.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      currentSession: json['currentSession']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((e) => e.toJson()).toList(),
      'currentSession': currentSession,
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
      action: (json['action'] ?? '').toString(),
      createDate: _toDateTime(json['createDate']),
      updateDate: _toDateTime(json['updateDate']),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
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