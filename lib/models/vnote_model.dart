// vnote_model.dart
//
// Model for TeacherViewNoteApp API response.
// Field types are kept as raw String/int (not DateTime) so they match
// exactly how NoteController and ViewNoteTab already use them
// (e.g. DateTime.parse(item.createDate ?? ""), item.subjectId, item.classId).

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
  final int? subjectId; // ✅ added so ViewNoteTab can look up Subject name
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
      noteId: json['noteId'] is int
          ? json['noteId']
          : int.tryParse('${json['noteId'] ?? ''}'),
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
      className: json['className']?.toString(),
      sectionName: json['sectionName']?.toString(),
      session: json['session']?.toString(),
      remarks: json['remarks']?.toString(),
      notesFile: json['notesFile']?.toString(),
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
      'noteId': noteId,
      'title': title,
      'message': message,
      'classId': classId,
      'sectionId': sectionId,
      'subjectId': subjectId,
      'className': className,
      'sectionName': sectionName,
      'session': session,
      'remarks': remarks,
      'notesFile': notesFile,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
    };
  }
}