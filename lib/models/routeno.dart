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

  // Constructor
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

  // Factory constructor for creating an instance of RouteData from JSON
  factory RouteData.fromJson(Map<String, dynamic> json) {
    return RouteData(
      routeNameId: json['routeNameId'],
      routeNo: json['routeNo'],
      busNo: json['busNo'],
      action: json['action'],
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null ? DateTime.parse(json['updateDate']) : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
    );
  }

  // Method to convert RouteData instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'routeNameId': routeNameId,
      'routeNo': routeNo,
      'busNo': busNo,
      'action': action,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }
}

class RouteResponse {
  final List<RouteData> data;

  // Constructor
  RouteResponse({required this.data});

  // Factory constructor to create a RouteResponse instance from JSON
  factory RouteResponse.fromJson(Map<String, dynamic> json) {
    return RouteResponse(
      data: (json['data'] as List)
          .map((item) => RouteData.fromJson(item)) // Mapping each item to RouteData
          .toList(),
    );
  }

  // Method to convert RouteResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(), // Converting each RouteData instance to JSON
    };
  }
}
