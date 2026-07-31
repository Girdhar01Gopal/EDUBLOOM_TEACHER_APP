class DayCareDurationModel {
  final int id;
  final String dayCareDuration; // maps to "daycareDurations" in API
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String createBy;
  final String? updateBy;
  final String schoolId;
 
  DayCareDurationModel({
    required this.id,
    required this.dayCareDuration,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory DayCareDurationModel.fromJson(Map<String, dynamic> json) {
    return DayCareDurationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      dayCareDuration: (json['daycareDurations'] ?? '').toString(),
      action: (json['action'] ?? '0').toString(),
      createDate: json['createDate'] != null
          ? DateTime.tryParse(json['createDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updateDate: (json['updateDate'] != null &&
          json['updateDate'].toString().isNotEmpty)
          ? DateTime.tryParse(json['updateDate'].toString())
          : null,
      createBy: (json['createBy'] ?? '').toString(),
      updateBy: json['updateBy']?.toString(),
      schoolId: (json['schoolId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "daycareDurations": dayCareDuration,
      "action": action,
      "createDate": createDate.toIso8601String(),
      "updateDate": updateDate?.toIso8601String(),
      "createBy": createBy,
      "updateBy": updateBy,
      "schoolId": schoolId,
    };
  }

  /// Parses the full GET API response:
  /// {
  ///   "listData": [ {...}, {...} ],
  ///   "currentSession": null
  /// }
  ///
  /// Also safely handles a plain List response, just in case.
  static List<DayCareDurationModel> fromJsonList(dynamic decoded) {
    List<dynamic> rawList;

    if (decoded is Map<String, dynamic>) {
      rawList = (decoded['listData'] as List<dynamic>?) ?? [];
    } else if (decoded is List) {
      rawList = decoded;
    } else {
      rawList = [];
    }

    return rawList
        .map((e) => DayCareDurationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}