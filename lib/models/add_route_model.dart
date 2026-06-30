// route_model.dart

class RouteModel {
  final List<RouteData> data;

  RouteModel({
    required this.data,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      data: json['data'] != null
          ? List<RouteData>.from(
        (json['data'] as List).map(
              (e) => RouteData.fromJson(e as Map<String, dynamic>),
        ),
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class RouteData {
  final int routeNameId;
  final int routeNo;
  final String busNo;
  final String action;
  final DateTime createDate;
  final DateTime? updateDate;
  final String createBy;
  final String? updateBy;
  final String schoolId;

  RouteData({
    required this.routeNameId,
    required this.routeNo,
    required this.busNo,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      routeNameId: json['routeNameId'] ?? 0,
      routeNo: json['routeNo'] ?? 0,
      busNo: json['busNo'] ?? "",
      action: json['action'] ?? "",
      createDate: DateTime.parse(json['createDate']),
      updateDate:
      json['updateDate'] != null ? DateTime.parse(json['updateDate']) : null,
      createBy: json['createBy'] ?? "",
      updateBy: json['updateBy'],
      schoolId: json['schoolId'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "routeNameId": routeNameId,
      "routeNo": routeNo,
      "busNo": busNo,
      "action": action,
      "createDate": createDate.toIso8601String(),
      "updateDate": updateDate?.toIso8601String(),
      "createBy": createBy,
      "updateBy": updateBy,
      "schoolId": schoolId,
    };
  }
}
