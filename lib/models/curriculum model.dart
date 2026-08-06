class CurriculumModel {
  bool? isSuccess;
  String? messages;
  List<CurriculumData>? data;

  CurriculumModel({this.isSuccess, this.messages, this.data});

  factory CurriculumModel.fromJson(Map<String, dynamic> json) {
    return CurriculumModel(
      isSuccess: json['isSuccess'] as bool?,
      messages: json['messages']?.toString(),
      data: json['data'] != null
          ? (json['data'] as List)
          .map((e) => CurriculumData.fromJson(e as Map<String, dynamic>))
          .toList()
          : <CurriculumData>[],
    );
  }

  Map<String, dynamic> toJson() => {
    'isSuccess': isSuccess,
    'messages': messages,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

class CurriculumData {
  int? curriculumId;
  String? curriculumName;
  String? className;
  String? section;
  List<dynamic>? classId;
  List<dynamic>? sectionId;
  String? session;
  String? description;
  String? schoolId;
  String? action; // "1" = Active, "0" = Inactive
  String? createBy;
  String? createDate;
  String? updateBy;
  String? updateDate;
  String? pdfFile;
  String? pdfFileName;

  CurriculumData({
    this.curriculumId,
    this.curriculumName,
    this.className,
    this.section,
    this.classId,
    this.sectionId,
    this.session,
    this.description,
    this.schoolId,
    this.action,
    this.createBy,
    this.createDate,
    this.updateBy,
    this.updateDate,
    this.pdfFile,
    this.pdfFileName,
  });

  factory CurriculumData.fromJson(Map<String, dynamic> json) {
    return CurriculumData(
      curriculumId: json['curriculumId'] is int
          ? json['curriculumId'] as int
          : int.tryParse(json['curriculumId']?.toString() ?? ''),
      curriculumName: json['curriculumName']?.toString(),
      className: json['className']?.toString(),
      section: json['section']?.toString(),
      classId: json['classId'] is List ? json['classId'] as List : <dynamic>[],
      sectionId:
      json['sectionId'] is List ? json['sectionId'] as List : <dynamic>[],
      session: json['session']?.toString(),
      description: json['description']?.toString(),
      schoolId: json['schoolId']?.toString(),
      action: json['action']?.toString(),
      createBy: json['createBy']?.toString(),
      createDate: json['createDate']?.toString(),
      updateBy: json['updateBy']?.toString(),
      updateDate: json['updateDate']?.toString(),
      pdfFile: json['pdfFile']?.toString(),
      pdfFileName: json['pdfFileName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'curriculumId': curriculumId,
    'curriculumName': curriculumName,
    'className': className,
    'section': section,
    'classId': classId,
    'sectionId': sectionId,
    'session': session,
    'description': description,
    'schoolId': schoolId,
    'action': action,
    'createBy': createBy,
    'createDate': createDate,
    'updateBy': updateBy,
    'updateDate': updateDate,
    'pdfFile': pdfFile,
    'pdfFileName': pdfFileName,
  };
}

/// Response model for GET
/// `api/MasterApp/ActiveInactiveCurriculum/{schoolId}/{curriculumId}`
/// Yeh API ek plain JSON array return karti hai (CurriculumData jaisa hi shape),
/// jisme toggle hui record(s) ki updated status hoti hai.
class CurriculumStatusModel {
  List<CurriculumData> data;

  CurriculumStatusModel({required this.data});

  factory CurriculumStatusModel.fromJson(dynamic json) {
    final list = (json is List) ? json : <dynamic>[];
    return CurriculumStatusModel(
      data: list
          .map((e) => CurriculumData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}