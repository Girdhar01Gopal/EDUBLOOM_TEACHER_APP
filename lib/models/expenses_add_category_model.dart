class AddCategory {
  int addEcategoryId;
  String category;
  String action;
  DateTime createDate;
  DateTime? updateDate;
  String createBy;
  String? updateBy;
  String schoolId;

  // Constructor
  AddCategory({
    required this.addEcategoryId,
    required this.category,
    required this.action,
    required this.createDate,
    this.updateDate,
    required this.createBy,
    this.updateBy,
    required this.schoolId,
  });


  factory AddCategory.fromJson(Map<String, dynamic> json) {
    return AddCategory(
      addEcategoryId: json['addEcategoryId'],
      category: json['category'],
      action: json['action'],
      createDate: DateTime.parse(json['createDate']),
      updateDate: json['updateDate'] != null ? DateTime.parse(json['updateDate']) : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'addEcategoryId': addEcategoryId,
      'category': category,
      'action': action,
      'createDate': createDate.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }
}

class AddCategoryResponse {
  List<AddCategory> listData;
  dynamic currentSession;

  // Constructor
  AddCategoryResponse({
    required this.listData,
    this.currentSession,
  });


  factory AddCategoryResponse.fromJson(Map<String, dynamic> json) {
    return AddCategoryResponse(
      listData: (json['listData'] as List)
          .map((item) => AddCategory.fromJson(item))
          .toList(),
      currentSession: json['currentSession'],
    );
  }

  // Dart Object
  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((item) => item.toJson()).toList(),
      'currentSession': currentSession,
    };
  }
}