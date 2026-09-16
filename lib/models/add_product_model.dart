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
  num pAmount;
  String? createBy;
  String? updateBy;
  String schoolId;
  DateTime? updateDate;
  DateTime? createDate;
  int action;

  AddProductsItem({
    required this.pmasterId,
    required this.product,
    this.pAmount = 0,
    this.createBy,
    this.updateBy,
    required this.schoolId,
    this.updateDate,
    this.createDate,
    required this.action,
  });

  factory AddProductsItem.fromJson(Map<String, dynamic> json) {
    final amountValues = [
      json['pAmount'],
      json['PAmount'],
      json['amount'],
      json['Amount'],
    ];
    final rawAmount = amountValues.firstWhere(
          (value) {
        final parsed = num.tryParse(value?.toString() ?? '');
        return parsed != null && parsed != 0;
      },
      orElse: () => amountValues.firstWhere(
            (value) => value != null,
        orElse: () => 0,
      ),
    );
    final rawAction = json['action'] ?? json['Action'] ?? 0;
    final parsedAction = rawAction is bool
        ? (rawAction ? 1 : 0)
        : int.tryParse(rawAction.toString()) ?? 0;

    return AddProductsItem(
      pmasterId: json['pmasterId'] ?? 0,
      product: json['product'] ?? '',
      pAmount: num.tryParse(rawAmount?.toString() ?? '') ?? 0,
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
      action: parsedAction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pmasterId': pmasterId,
      'product': product,
      'pAmount': pAmount,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'updateDate': updateDate?.toIso8601String(),
      'createDate': createDate?.toIso8601String(),
      'action': action,
    };
  }
}
