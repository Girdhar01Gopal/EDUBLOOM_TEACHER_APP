class FeesDurationModel {
  List<DListData>? listData;
  Null? currentSession;

  FeesDurationModel({this.listData, this.currentSession});

  FeesDurationModel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <DListData>[];
      json['listData'].forEach((v) {
        listData!.add(new DListData.fromJson(v));
      });
    }
    currentSession = json['currentSession'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData != null) {
      data['listData'] = this.listData!.map((v) => v.toJson()).toList();
    }
    data['currentSession'] = this.currentSession;
    return data;
  }
}

class DListData {
  int? feesDurationId;
  String? feesDuration;
  String? month;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  DListData(
      {this.feesDurationId,
      this.feesDuration,
      this.month,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId});

  DListData.fromJson(Map<String, dynamic> json) {
    feesDurationId = json['feesDurationId'];
    feesDuration = json['feesDuration'];
    month = json['month'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['feesDurationId'] = this.feesDurationId;
    data['feesDuration'] = this.feesDuration;
    data['month'] = this.month;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    return data;
  }
}
