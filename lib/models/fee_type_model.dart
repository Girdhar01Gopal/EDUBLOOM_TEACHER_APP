class FeeTypeModel {
  List<fData>? listData;
  Null? currentSession;

  FeeTypeModel({this.listData, this.currentSession});

  FeeTypeModel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <fData>[];
      json['listData'].forEach((v) {
        listData!.add(new fData.fromJson(v));
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

class fData {
  int? feeTypeId;
  String? feeType;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;
  Null? sequenceno;

  fData(
      {this.feeTypeId,
      this.feeType,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId,
      this.sequenceno});

  fData.fromJson(Map<String, dynamic> json) {
    feeTypeId = json['feeTypeId'];
    feeType = json['feeType'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
    sequenceno = json['sequenceno'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['feeTypeId'] = this.feeTypeId;
    data['feeType'] = this.feeType;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    data['sequenceno'] = this.sequenceno;
    return data;
  }
}