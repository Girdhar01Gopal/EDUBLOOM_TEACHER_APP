class GalleryPhotoModel {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<PhotoData>? data;
  bool? showPopup;
  dynamic popupMessage;

  GalleryPhotoModel({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory GalleryPhotoModel.fromJson(Map<String, dynamic> json) {
    return GalleryPhotoModel(
      statusCode: json['statusCode'],
      isSuccess: json['isSuccess'],
      messages: json['messages'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((v) => PhotoData.fromJson(v))
          .toList()
          : [],
      showPopup: json['showPopup'],
      popupMessage: json['popupMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data?.map((v) => v.toJson()).toList(),
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class PhotoData {
  int? uploadImageId;
  dynamic classId;
  dynamic className;
  dynamic session;
  String? imageHeading;
  String? date;
  String? uploadImage;
  String? action;
  dynamic sectionId;
  dynamic sectionName;
  dynamic createDate;
  dynamic updateDate;
  dynamic createBy;
  dynamic updateBy;
  String? schoolId;
  dynamic imageCategoryId;
  dynamic imageCategory;
  String? imageBase64;

  PhotoData({
    this.uploadImageId,
    this.classId,
    this.className,
    this.session,
    this.imageHeading,
    this.date,
    this.uploadImage,
    this.action,
    this.sectionId,
    this.sectionName,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.imageCategoryId,
    this.imageCategory,
    this.imageBase64,
  });

  factory PhotoData.fromJson(Map<String, dynamic> json) {
    return PhotoData(
      uploadImageId: json['uploadImageId'],
      classId: json['classId'],
      className: json['className'],
      session: json['session'],
      imageHeading: json['imageHeading'],
      date: json['date'],
      uploadImage: json['uploadImage'],
      action: json['action'],
      sectionId: json['sectionId'],
      sectionName: json['sectionName'],
      createDate: json['createDate'],
      updateDate: json['updateDate'],
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
      imageCategoryId: json['imageCategoryId'],
      imageCategory: json['imageCategory'],
      imageBase64: json['imageBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uploadImageId': uploadImageId,
      'classId': classId,
      'className': className,
      'session': session,
      'imageHeading': imageHeading,
      'date': date,
      'uploadImage': uploadImage,
      'action': action,
      'sectionId': sectionId,
      'sectionName': sectionName,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'imageCategoryId': imageCategoryId,
      'imageCategory': imageCategory,
      'imageBase64': imageBase64,
    };
  }
}