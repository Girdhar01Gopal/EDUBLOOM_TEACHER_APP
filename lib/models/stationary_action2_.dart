import 'dart:convert';

StationaryAction2Model stationaryAction2ModelFromJson(String str) =>
    StationaryAction2Model.fromJson(json.decode(str));

String stationaryAction2ModelToJson(StationaryAction2Model data) =>
    json.encode(data.toJson());

class StationaryAction2Model {
  List<StationaryAction2ListData>? listData;

  StationaryAction2Model({
    this.listData,
  });

  factory StationaryAction2Model.fromJson(Map<String, dynamic> json) {
    return StationaryAction2Model(
      listData: json["listData"] == null
          ? []
          : List<StationaryAction2ListData>.from(
        json["listData"]!.map(
              (x) => StationaryAction2ListData.fromJson(x),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    "listData": listData == null
        ? []
        : List<dynamic>.from(listData!.map((x) => x.toJson())),
  };
}

class StationaryAction2ListData {
  int? sfeeId;
  int? pmasterId;
  String? product;
  String? createBy;
  String? updateBy;
  String? schoolId;
  String? updateDate;
  String? createDate;
  int? action;
  int? quantity;
  int? quantity1;
  dynamic amount;
  String? registrationNo;
  String? studentName;
  String? session;
  int? classId;
  String? className;
  int? sectionId;
  String? section;
  String? receiptno;
  dynamic cquantity;
  String? paymentMode;
  String? payDate;
  String? fatherName;
  String? fmobileno;
  String? femail;

  StationaryAction2ListData({
    this.sfeeId,
    this.pmasterId,
    this.product,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.updateDate,
    this.createDate,
    this.action,
    this.quantity,
    this.quantity1,
    this.amount,
    this.registrationNo,
    this.studentName,
    this.session,
    this.classId,
    this.className,
    this.sectionId,
    this.section,
    this.receiptno,
    this.cquantity,
    this.paymentMode,
    this.payDate,
    this.fatherName,
    this.fmobileno,
    this.femail,
  });

  factory StationaryAction2ListData.fromJson(Map<String, dynamic> json) =>
      StationaryAction2ListData(
        sfeeId: json["sfeeId"],
        pmasterId: json["pmasterId"],
        product: json["product"],
        createBy: json["createBy"],
        updateBy: json["updateBy"],
        schoolId: json["schoolId"],
        updateDate: json["updateDate"],
        createDate: json["createDate"],
        action: json["action"],
        quantity: json["quantity"],
        quantity1: json["quantity1"],
        amount: json["amount"],
        registrationNo: json["registrationNo"],
        studentName: json["studentName"],
        session: json["session"],
        classId: json["classId"],
        className: json["class"],
        sectionId: json["sectionId"],
        section: json["section"],
        receiptno: json["receiptno"],
        cquantity: json["cquantity"],
        paymentMode: json["paymentMode"],
        payDate: json["payDate"],
        fatherName: json["fatherName"],
        fmobileno: json["fmobileno"],
        femail: json["femail"],
      );

  Map<String, dynamic> toJson() => {
    "sfeeId": sfeeId,
    "pmasterId": pmasterId,
    "product": product,
    "createBy": createBy,
    "updateBy": updateBy,
    "schoolId": schoolId,
    "updateDate": updateDate,
    "createDate": createDate,
    "action": action,
    "quantity": quantity,
    "quantity1": quantity1,
    "amount": amount,
    "registrationNo": registrationNo,
    "studentName": studentName,
    "session": session,
    "classId": classId,
    "class": className,
    "sectionId": sectionId,
    "section": section,
    "receiptno": receiptno,
    "cquantity": cquantity,
    "paymentMode": paymentMode,
    "payDate": payDate,
    "fatherName": fatherName,
    "fmobileno": fmobileno,
    "femail": femail,
  };
}