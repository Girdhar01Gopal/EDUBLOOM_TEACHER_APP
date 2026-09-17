class ClassItem {
  List<ListDataa> listData; // Non-nullable with default
  String? currentSession;

  ClassItem({required this.listData, this.currentSession});

  ClassItem.fromJson(Map<String, dynamic> json) :
        listData = [] {
    var items = json['listData'] ?? json['data'];
    if (items != null && items is List) {
      listData = items.map((v) => ListDataa.fromJson(v)).toList();
    }
    currentSession = json['currentSession']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['listData'] = listData.map((v) => v.toJson()).toList();
    data['currentSession'] = currentSession;
    return data;
  }
}

class ListDataa {
  int? classId;
  String className;
  String? studentClassId;
  String action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;
  String? sqno;

  ListDataa({
    this.classId,
    required this.className,
    this.studentClassId,
    required this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.sqno,
  });

  ListDataa.fromJson(Map<String, dynamic> json) :
        className = (json['class'] ?? json['className'] ?? "").toString(),
        action = (json['action'] ?? "").toString() {
    classId = json['classId'] is int ? json['classId'] : int.tryParse(json['classId']?.toString() ?? '');
    studentClassId = json['studentClassId']?.toString();
    createDate = json['createDate']?.toString();
    updateDate = json['updateDate']?.toString();
    createBy = json['createBy']?.toString();
    updateBy = json['updateBy']?.toString();
    schoolId = json['schoolId']?.toString();
    sqno = json['sqno']?.toString();
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