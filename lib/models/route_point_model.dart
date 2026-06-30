// ===============================
// Route Point API Response Model
// ===============================

class RoutePointResponse {
  final List<RoutePoint> data;

  RoutePointResponse({
    required this.data,
  });

  factory RoutePointResponse.fromJson(Map<String, dynamic> json) {
    return RoutePointResponse(
      data: json['data'] != null
          ? List<RoutePoint>.from(
        json['data'].map((x) => RoutePoint.fromJson(x)),
      )
          : <RoutePoint>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
  }
}

// ===============================
// Route Point Model
// ===============================

class RoutePoint {
  final int routePointId;
  final int routeNo;
  final int? routeNameId;
  final String pickupPoint;
  final String? dropPoint;
  final DateTime createDate;
  final DateTime? updateDate;
  final String action;
  final String createBy;
  final String? updateBy;
  final String schoolId;

  RoutePoint({
    required this.routePointId,
    required this.routeNo,
    this.routeNameId,
    required this.pickupPoint,
    this.dropPoint,
    required this.createDate,
    this.updateDate,
    required this.action,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      routePointId: json['routePointId'] is int
          ? json['routePointId']
          : int.tryParse(json['routePointId'].toString()) ?? 0,

      routeNo: json['routeNo'] is int
          ? json['routeNo']
          : int.tryParse(json['routeNo'].toString()) ?? 0,

      routeNameId: json['routeNameId'],

      pickupPoint: json['pickupPoint']?.toString() ?? '',

      dropPoint: json['dropPoint']?.toString(),

      createDate: DateTime.tryParse(json['createDate'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),

      updateDate: json['updateDate'] != null
          ? DateTime.tryParse(json['updateDate'])
          : null,

      action: json['action']?.toString() ?? '',

      createBy: json['createBy']?.toString() ?? '',

      updateBy: json['updateBy']?.toString(),

      schoolId: json['schoolId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "routePointId": routePointId,
      "routeNo": routeNo,
      "routeNameId": routeNameId,
      "pickupPoint": pickupPoint,
      "dropPoint": dropPoint,
      "createDate": createDate.toIso8601String(),
      "updateDate": updateDate?.toIso8601String(),
      "action": action,
      "createBy": createBy,
      "updateBy": updateBy,
      "schoolId": schoolId,
    };
  }
}
