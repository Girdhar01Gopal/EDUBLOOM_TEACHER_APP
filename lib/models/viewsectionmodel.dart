class sectionmodel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<stListData>? listData;
  bool? showPopup;
  String? popupMessage;

  sectionmodel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.listData,
    this.showPopup,
    this.popupMessage,
  });

  sectionmodel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];

    // ✅ सुरक्षित तरीका: अगर API 'data' भेजे या 'listData', दोनों चलेंगे
    var rawData = json['data'] ?? json['listData'];

    if (rawData != null) {
      listData = <stListData>[];
      rawData.forEach((v) {
        listData!.add(stListData.fromJson(v));
      });
    }
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['isSuccess'] = isSuccess;
    data['messages'] = messages;
    if (listData != null) {
      // API की कंसिस्टेंसी के लिए हम 'listData' में भेज रहे हैं
      data['listData'] = listData!.map((v) => v.toJson()).toList();
    }
    data['showPopup'] = showPopup;
    data['popupMessage'] = popupMessage;
    return data;
  }
}

class stListData {
  int? sectionId;
  String? section;
  String? action;
  String? createDate;
  String? updateDate;
  String? createBy;
  String? updateBy;
  String? schoolId;

  stListData({
    this.sectionId,
    this.section,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
  });

  stListData.fromJson(Map<String, dynamic> json) {
    sectionId = json['sectionId'];
    section = json['section']?.toString();
    action = json['action']?.toString();
    createDate = json['createDate']?.toString();
    updateDate = json['updateDate']?.toString();
    createBy = json['createBy']?.toString();
    updateBy = json['updateBy']?.toString();
    schoolId = json['schoolId']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sectionId'] = sectionId;
    data['section'] = section;
    data['action'] = action;
    data['createDate'] = createDate;
    data['updateDate'] = updateDate;
    data['createBy'] = createBy;
    data['updateBy'] = updateBy;
    data['schoolId'] = schoolId;
    return data;
  }
}