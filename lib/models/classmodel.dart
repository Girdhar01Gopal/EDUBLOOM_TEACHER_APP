class ClassItem {
  List<ListDataa>? listData;
  String? currentSession;

  ClassItem({this.listData, this.currentSession});

  ClassItem.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = (json['listData'] as List)
          .map((v) => ListDataa.fromJson(v))
          .toList();
    }
    currentSession = json['currentSession'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (listData != null) {
      data['listData'] = listData!.map((v) => v.toJson()).toList();
    }
    data['currentSession'] = currentSession;
    return data;
  }
}

class ListDataa {
  int? classId;
  String? className; // Removed final
  String? studentClassId;
  String? action;
  String? createDate;
  String? updateDate; // Removed final
  String? createBy;
  String? updateBy;
  String? schoolId;
  String? sqno;

  ListDataa({
    this.classId,
    this.className,
    this.studentClassId,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.sqno,
  });

  ListDataa.fromJson(Map<String, dynamic> json) {
    classId = json['classId'];
    className = json['class'];
    studentClassId = json['studentClassId'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
    sqno = json['sqno'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['classId'] = classId;
    data['class'] = className;
    data['studentClassId'] = studentClassId;
    data['action'] = action;
    data['createDate'] = createDate;
    data['updateDate'] = updateDate;
    data['createBy'] = createBy;
    data['updateBy'] = updateBy;
    data['schoolId'] = schoolId;
    data['sqno'] = sqno;
    return data;
  }
}