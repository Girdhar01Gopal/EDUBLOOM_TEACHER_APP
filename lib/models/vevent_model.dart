class VEventResponse {
  List<ListData>? listData;

  VEventResponse({this.listData});

  VEventResponse.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <ListData>[];
      json['listData'].forEach((v) {
        listData!.add(new ListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData != null) {
      data['listData'] = this.listData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListData {
  int? eventId;
  int? classId;
  int? sectionId;
  String? session;
  String? eventDate;
  String? eventName;
  String? eventPlace;
  String? description;
  String? eventPic;
  String? action;
  String? createDate;
  Null? updateDate;
  String? createBy;
  Null? updateBy;
  String? schoolId;

  ListData(
      {this.eventId,
      this.classId,
      this.sectionId,
      this.session,
      this.eventDate,
      this.eventName,
      this.eventPlace,
      this.description,
      this.eventPic,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId});

  ListData.fromJson(Map<String, dynamic> json) {
    eventId = json['eventId'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    session = json['session'];
    eventDate = json['eventDate'];
    eventName = json['eventName'];
    eventPlace = json['eventPlace'];
    description = json['description'];
    eventPic = json['eventPic'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  get className => null;

  get sectionName => null;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventId'] = this.eventId;
    data['classId'] = this.classId;
    data['sectionId'] = this.sectionId;
    data['session'] = this.session;
    data['eventDate'] = this.eventDate;
    data['eventName'] = this.eventName;
    data['eventPlace'] = this.eventPlace;
    data['description'] = this.description;
    data['eventPic'] = this.eventPic;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}