class ProductQuantity {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<ProductQuantityData>? data;
  bool? showPopup;
  String? popupMessage;

  ProductQuantity({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  ProductQuantity.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];

    if (json['data'] != null) {
      data = <ProductQuantityData>[];
      json['data'].forEach((v) {
        data!.add(ProductQuantityData.fromJson(v));
      });
    }

    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};
    map['statusCode'] = statusCode;
    map['isSuccess'] = isSuccess;
    map['messages'] = messages;

    if (data != null) {
      map['data'] = data!.map((v) => v.toJson()).toList();
    }

    map['showPopup'] = showPopup;
    map['popupMessage'] = popupMessage;

    return map;
  }
}

class ProductQuantityData {
  int? productId;
  int? pmasterId;
  String? productName;
  String? createBy;
  String? updateBy;
  String? schoolId;
  String? updateDate;
  String? createDate;
  int? action;
  int? quantity;
  int? totalQuantity;
  double? amount;
  int? balanceQuantity;

  ProductQuantityData({
    this.productId,
    this.pmasterId,
    this.productName,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.updateDate,
    this.createDate,
    this.action,
    this.quantity,
    this.totalQuantity,
    this.amount,
    this.balanceQuantity,
  });

  ProductQuantityData.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    pmasterId = json['pmasterId'];
    productName = json['productName'];
    createBy = json['createBy'];
    updateBy = json['updateBy'];
    schoolId = json['schoolId'];
    updateDate = json['updateDate'];
    createDate = json['createDate'];
    action = json['action'];
    quantity = json['quantity'];
    totalQuantity = json['totalQuantity'];
    amount = json['amount']?.toDouble();
    balanceQuantity = json['balanceQuantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = <String, dynamic>{};

    map['productId'] = productId;
    map['pmasterId'] = pmasterId;
    map['productName'] = productName;
    map['createBy'] = createBy;
    map['updateBy'] = updateBy;
    map['schoolId'] = schoolId;
    map['updateDate'] = updateDate;
    map['createDate'] = createDate;
    map['action'] = action;
    map['quantity'] = quantity;
    map['totalQuantity'] = totalQuantity;
    map['amount'] = amount;
    map['balanceQuantity'] = balanceQuantity;

    return map;
  }
}