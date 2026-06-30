class videomodel {
  int? statusCode;
  bool? isSuccess;
  Null? messages;
  List<vData>? data;
  bool? showPopup;
  Null? popupMessage;

  videomodel(
      {this.statusCode,
      this.isSuccess,
      this.messages,
      this.data,
      this.showPopup,
      this.popupMessage});

  videomodel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    isSuccess = json['isSuccess'];
    messages = json['messages'];
    if (json['data'] != null) {
      data = <vData>[];
      json['data'].forEach((v) {
        data!.add(new vData.fromJson(v));
      });
    }
    showPopup = json['showPopup'];
    popupMessage = json['popupMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['isSuccess'] = this.isSuccess;
    data['messages'] = this.messages;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['showPopup'] = this.showPopup;
    data['popupMessage'] = this.popupMessage;
    return data;
  }
}

class vData {
  int? videoId;
  String? className;
  String? sectionName;
  String? videoUrl;
  String? createDate;
  String? createBy;
  String? action;

  vData(
      {this.videoId,
      this.className,
      this.sectionName,
      this.videoUrl,
      this.createDate,
      this.createBy,
      this.action});

  vData.fromJson(Map<String, dynamic> json) {
    videoId = json['videoId'];
    className = json['className'];
    sectionName = json['sectionName'];
    videoUrl = json['videoUrl'];
    createDate = json['createDate'];
    createBy = json['createBy'];
    action = json['action'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoId'] = this.videoId;
    data['className'] = this.className;
    data['sectionName'] = this.sectionName;
    data['videoUrl'] = this.videoUrl;
    data['createDate'] = this.createDate;
    data['createBy'] = this.createBy;
    data['action'] = this.action;
    return data;
  }
}