import 'dart:convert';

StationaryInventoryModel stationaryInventoryModelFromJson(String str) =>
    StationaryInventoryModel.fromJson(json.decode(str));

String stationaryInventoryModelToJson(StationaryInventoryModel data) =>
    json.encode(data.toJson());

class StationaryInventoryModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<StationaryInventoryData>? data;
  bool? showPopup;
  dynamic popupMessage;

  StationaryInventoryModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory StationaryInventoryModel.fromJson(Map<String, dynamic> json) =>
      StationaryInventoryModel(
        statusCode: json["statusCode"],
        isSuccess: json["isSuccess"],
        messages: json["messages"],
        data: json["data"] == null
            ? []
            : List<StationaryInventoryData>.from(
          json["data"].map(
                (x) => StationaryInventoryData.fromJson(x),
          ),
        ),
        showPopup: json["showPopup"],
        popupMessage: json["popupMessage"],
      );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "isSuccess": isSuccess,
    "messages": messages,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "showPopup": showPopup,
    "popupMessage": popupMessage,
  };
}

class StationaryInventoryData {
  int? productId;
  dynamic pmasterId;
  String? productName;
  dynamic createBy;
  dynamic updateBy;
  dynamic schoolId;
  dynamic updateDate;
  dynamic createDate;
  dynamic action;
  int? quantity;
  int? totalQuantity;
  dynamic amount;
  int? balanceQuantity;

  StationaryInventoryData({
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

  factory StationaryInventoryData.fromJson(Map<String, dynamic> json) =>
      StationaryInventoryData(
        productId: json["productId"],
        pmasterId: json["pmasterId"],
        productName: json["productName"],
        createBy: json["createBy"],
        updateBy: json["updateBy"],
        schoolId: json["schoolId"],
        updateDate: json["updateDate"],
        createDate: json["createDate"],
        action: json["action"],
        quantity: json["quantity"],
        totalQuantity: json["totalQuantity"],
        amount: json["amount"],
        balanceQuantity: json["balanceQuantity"],
      );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "pmasterId": pmasterId,
    "productName": productName,
    "createBy": createBy,
    "updateBy": updateBy,
    "schoolId": schoolId,
    "updateDate": updateDate,
    "createDate": createDate,
    "action": action,
    "quantity": quantity,
    "totalQuantity": totalQuantity,
    "amount": amount,
    "balanceQuantity": balanceQuantity,
  };
}