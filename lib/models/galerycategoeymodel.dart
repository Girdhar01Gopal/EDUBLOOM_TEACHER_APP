class GalleryCategory {
  List<ListData1>? listData1;
  Null? currentSession;

  GalleryCategory({this.listData1, this.currentSession});

  GalleryCategory.fromJson(Map<String, dynamic> json) {
    if (json['listData1'] != null) {
      listData1 = <ListData1>[];
      json['listData1'].forEach((v) {
        listData1!.add(new ListData1.fromJson(v));
      });
    }
    currentSession = json['currentSession'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData1 != null) {
      data['listData1'] = this.listData1!.map((v) => v.toJson()).toList();
    }
    data['currentSession'] = this.currentSession;
    return data;
  }
}

class ListData1 {
  int? addCategoryId;
  String? category;
  String? action;
  String? createDate;
  Null? updateDate;
  String? createBy;
  Null? updateBy;
  String? schoolId;
  String? session;

  ListData1(
      {this.addCategoryId,
      this.category,
      this.action,
      this.createDate,
      this.updateDate,
      this.createBy,
      this.updateBy,
      this.schoolId,
      this.session});

  ListData1.fromJson(Map<String, dynamic> json) {
    addCategoryId = json['addCategoryId'];
    category = json['category'];
    action = json['action'];
    createDate = json['createDate'];
    updateDate = json['updateDate'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
    session = json['session'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['addCategoryId'] = this.addCategoryId;
    data['category'] = this.category;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['updateDate'] = this.updateDate;
    data['createBy'] = this.createBy;
    data['updateBy'] = this.updateBy;
    data['schoolId'] = this.schoolId;
    data['session'] = this.session;
    return data;
  }
}