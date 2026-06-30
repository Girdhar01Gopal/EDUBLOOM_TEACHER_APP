class AddProductsResponse {
  List<AddProductsItem> listData;
  dynamic currentSession;

  AddProductsResponse({
    required this.listData,
    this.currentSession,
  });

  factory AddProductsResponse.fromJson(Map<String, dynamic> json) {
    return AddProductsResponse(
      listData: json['listData'] != null
          ? List<AddProductsItem>.from(
        (json['listData'] as List).map(
              (x) => AddProductsItem.fromJson(x as Map<String, dynamic>),
        ),
      )
          : <AddProductsItem>[],
      currentSession: json['currentSession'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData.map((e) => e.toJson()).toList(),
      'currentSession': currentSession,
    };
  }
}

class AddProductsItem {
  int pmasterId;
  String product;
  String? createBy;
  String? updateBy;
  String schoolId;
  DateTime? updateDate;
  DateTime? createDate;
  int action;

  AddProductsItem({
    required this.pmasterId,
    required this.product,
    this.createBy,
    this.updateBy,
    required this.schoolId,
    this.updateDate,
    this.createDate,
    required this.action,
  });

  factory AddProductsItem.fromJson(Map<String, dynamic> json) {
    return AddProductsItem(
      pmasterId: json['pmasterId'] ?? 0,
      product: json['product'] ?? '',
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'] ?? '',
      updateDate: json['updateDate'] != null &&
          json['updateDate'].toString().trim().isNotEmpty
          ? DateTime.tryParse(json['updateDate'].toString())
          : null,
      createDate: json['createDate'] != null &&
          json['createDate'].toString().trim().isNotEmpty
          ? DateTime.tryParse(json['createDate'].toString())
          : null,
      action: json['action'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pmasterId': pmasterId,
      'product': product,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'updateDate': updateDate?.toIso8601String(),
      'createDate': createDate?.toIso8601String(),
      'action': action,
    };
  }
}