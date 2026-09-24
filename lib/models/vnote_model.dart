class VNoteModel {
  final List<Dataa>? listData;

  VNoteModel({
    this.listData,
  });

  factory VNoteModel.fromJson(Map<String, dynamic> json) {
    return VNoteModel(
      listData: json['listData'] != null
          ? (json['listData'] as List)
          .map((e) => Dataa.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData?.map((e) => e.toJson()).toList(),
    };
  }
}

class Dataa {
  final int? noteId;
  final String? title;
  final String? message;
  final int? classId;
  final int? sectionId;
  final int? subjectId;
  final String? subjectName; // 🆕 added — API ab ye field bhejta hai
  final String? className;
  final String? sectionName;
  final String? session;
  final String? remarks;
  final String? notesFile;
  final String? action;
  final String? createDate;
  final String? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;

  Dataa({
    this.noteId,
    this.title,
    this.message,
    this.classId,
    this.sectionId,
    this.subjectId,
    this.subjectName,
    this.className,
    this.sectionName,
    this.session,
    this.remarks,
    this.notesFile,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
  });

  factory Dataa.fromJson(Map<String, dynamic> json) {
    return Dataa(
      // ✅ dono key names handle: purana "nid" aur naya "noteId"
      noteId: json['nid'] is int
          ? json['nid']
          : int.tryParse('${json['nid'] ?? json['noteId'] ?? ''}'),
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      classId: json['classId'] is int
          ? json['classId']
          : int.tryParse('${json['classId'] ?? ''}'),
      sectionId: json['sectionId'] is int
          ? json['sectionId']
          : int.tryParse('${json['sectionId'] ?? ''}'),
      subjectId: json['subjectId'] is int
          ? json['subjectId']
          : int.tryParse('${json['subjectId'] ?? ''}'),
      subjectName: json['subjectName']?.toString(), // 🆕
      className: json['className']?.toString(),
      sectionName: json['sectionName']?.toString(),
      session: json['session']?.toString(),
      remarks: json['remarks']?.toString(),
      // ✅ FIX: actual API field "noteFile" hai, "notesFile" nahi.
      // Dono handle kar liya taaki purana/naya dono response safe rahe.
      notesFile: (json['noteFile'] ?? json['notesFile'])?.toString(),
      action: json['action']?.toString(),
      createDate: json['createDate']?.toString(),
      updateDate: json['updateDate']?.toString(),
      createBy: json['createBy']?.toString(),
      updateBy: json['updateBy']?.toString(),
      schoolId: json['schoolId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nid': noteId,
      'title': title,
      'message': message,
      'classId': classId,
      'sectionId': sectionId,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'className': className,
      'sectionName': sectionName,
      'session': session,
      'remarks': remarks,
      'noteFile': notesFile, // ✅ ab yahan bhi actual API key naam use kiya
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }
}