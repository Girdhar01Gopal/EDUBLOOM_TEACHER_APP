class RoutePoint {
  List<Data>? data;

  RoutePoint({this.data});

  RoutePoint.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? routePointId;
  int? routeNo;
  Null? routeNameId;
  String? pickupPoint;
  Null? dropPoint;
  String? createDate;
  Null? updateDate;
  String? action;
  String? createBy;
  Null? updateBy;
  String? schoolId;

  Data(
      {this.routePointId,
      this.routeNo,
      this.routeNameId,
      this.pickupPoint,
      this.dropPoint,
      this.createDate,
      this.updateDate,
      this.action,
      this.createBy,
      this.updateBy,
      this.schoolId});

  Data.fromJson(Map<String, dynamic> json) {
    routePointId = json['routePointId'];
    routeNo = json['routeNo'];
    routeNameId = json['routeNameId'];
    pickupPoint = json['pickupPoint'];
    dropPoint = json['dropPoint'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    action = json['action'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['routePointId'] = this.routePointId;
    data['routeNo'] = this.routeNo;
    data['routeNameId'] = this.routeNameId;
    data['pickupPoint'] = this.pickupPoint;
    data['dropPoint'] = this.dropPoint;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['action'] = this.action;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}