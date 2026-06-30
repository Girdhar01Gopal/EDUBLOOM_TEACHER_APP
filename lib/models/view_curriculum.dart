class ViewCurriculumResponse {
  int? statusCode;
  bool? isSuccess;
  String? messages;
  List<ViewCurriculumModel>? data;
  bool? showPopup;
  String? popupMessage;

  ViewCurriculumResponse({
    this.statusCode,
    this.isSuccess,
    this.messages,
    this.data,
    this.showPopup,
    this.popupMessage,
  });

  factory ViewCurriculumResponse.fromJson(Map<String, dynamic> json) {
    return ViewCurriculumResponse(
      statusCode: json['statusCode'] as int?,
      isSuccess: json['isSuccess'] as bool?,
      messages: json['messages'] as String?,
      data: json['data'] != null
          ? List<ViewCurriculumModel>.from(
        (json['data'] as List).asMap().entries.map(
              (entry) => ViewCurriculumModel.fromJson(
            entry.value as Map<String, dynamic>,
            entry.key + 1,
          ),
        ),
      )
          : [],
      showPopup: json['showPopup'] as bool?,
      popupMessage: json['popupMessage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'isSuccess': isSuccess,
      'messages': messages,
      'data': data?.map((e) => e.toJson()).toList() ?? [],
      'showPopup': showPopup,
      'popupMessage': popupMessage,
    };
  }
}

class ViewCurriculumModel {
  int? curriculumId;
  int sno;
  String schoolName;
  String title;
  String file;
  String fileName;
  String schoolId;
  String createBy;
  String action;
  String createDate;

  ViewCurriculumModel({
    this.curriculumId,
    required this.sno,
    required this.schoolName,
    required this.title,
    required this.file,
    required this.fileName,
    required this.schoolId,
    required this.createBy,
    required this.action,
    required this.createDate,
  });

  factory ViewCurriculumModel.fromJson(
      Map<String, dynamic> json,
      int index,
      ) {
    return ViewCurriculumModel(
      curriculumId: json['curriculumId'] as int?,
      sno: index,
      schoolName: (json['schoolName'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      file: (json['curriculumFile'] ?? '').toString(),
      fileName: (json['fileName'] ?? '').toString(),
      schoolId: (json['schoolId'] ?? '').toString(),
      createBy: (json['createBy'] ?? '').toString(),
      action: (json['action'] ?? '').toString(),
      createDate: (json['createDate'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'curriculumId': curriculumId,
      'sno': sno,
      'schoolName': schoolName,
      'title': title,
      'file': file,
      'fileName': fileName,
      'schoolId': schoolId,
      'createBy': createBy,
      'action': action,
      'createDate': createDate,
    };
  }
}