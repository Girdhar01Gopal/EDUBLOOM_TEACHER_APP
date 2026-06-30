class FeeDetailsDiscountModel {
  List<dynamic>? listData;
  List<FeeDetailsDiscount>? listData1;

  FeeDetailsDiscountModel({this.listData, this.listData1});

  FeeDetailsDiscountModel.fromJson(Map<String, dynamic> json) {
    listData = json['listData'] ?? [];

    if (json['listData1'] != null) {
      listData1 = <FeeDetailsDiscount>[];
      json['listData1'].forEach((v) {
        listData1!.add(FeeDetailsDiscount.fromJson(v));
      });
    } else {
      listData1 = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['listData'] = listData;
    if (listData1 != null) {
      data['listData1'] = listData1!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FeeDetailsDiscount {
  int? id;
  String? session;
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  int? feeTypeId;
  String? feeTypeName;
  int? feeDurationId;
  String? feeDurationName;
  String? registrationNo;
  String? studentName;
  String? fatherName;
  double? discount;
  String? description;
  String? fileName1;
  String? action;
  String? schoolId;
  String? createDate;
  String? createdBy;
  String? updateBy;
  String? updateDate;
  String? sqnid;

  FeeDetailsDiscount({
    this.id,
    this.session,
    this.classId,
    this.className,
    this.sectionId,
    this.sectionName,
    this.feeTypeId,
    this.feeTypeName,
    this.feeDurationId,
    this.feeDurationName,
    this.registrationNo,
    this.studentName,
    this.fatherName,
    this.discount,
    this.description,
    this.fileName1,
    this.action,
    this.schoolId,
    this.createDate,
    this.createdBy,
    this.updateBy,
    this.updateDate,
    this.sqnid,
  });

  FeeDetailsDiscount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    session = json['session'];
    classId = json['classId'];
    className = json['className'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    feeTypeId = json['feeTypeId'];
    feeTypeName = json['feeTypeName'];
    feeDurationId = json['feeDurationId'];
    feeDurationName = json['feeDurationName'];
    registrationNo = json['registrationNo'];
    studentName = json['studentName'];
    fatherName = json['fatherName'];
    discount =
    json['discount'] != null ? (json['discount'] as num).toDouble() : 0.0;
    description = json['description'];
    fileName1 = json['fileName1'];
    action = json['action'];
    schoolId = json['schoolId'];
    createDate = json['createDate'];
    createdBy = json['createdBy'];
    updateBy = json['updateBy'];
    updateDate = json['updateDate'];
    sqnid = json['sqnid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['session'] = session;
    data['classId'] = classId;
    data['className'] = className;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['feeTypeId'] = feeTypeId;
    data['feeTypeName'] = feeTypeName;
    data['feeDurationId'] = feeDurationId;
    data['feeDurationName'] = feeDurationName;
    data['registrationNo'] = registrationNo;
    data['studentName'] = studentName;
    data['fatherName'] = fatherName;
    data['discount'] = discount;
    data['description'] = description;
    data['fileName1'] = fileName1;
    data['action'] = action;
    data['schoolId'] = schoolId;
    data['createDate'] = createDate;
    data['createdBy'] = createdBy;
    data['updateBy'] = updateBy;
    data['updateDate'] = updateDate;
    data['sqnid'] = sqnid;
    return data;
  }
}