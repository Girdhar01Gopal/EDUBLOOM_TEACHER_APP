// Model for: GET /api/EnquiryApp/ViewEnquiry1/{session}/{admissionNo}

class ViewEnquiryModel {
  final int? id;
  final dynamic parentID;
  final String? className;
  final int? classId;
  final String? section;
  final int? sectionId;
  final dynamic session;
  final DateTime? createDate;
  final dynamic subject;
  final String? message;
  final dynamic action;
  final dynamic createBy;
  final dynamic updateBy;
  final String? reply;
  final DateTime? replyDate;
  final String? studentName;
  final dynamic schoolId;
  final dynamic name;
  final dynamic teacherReg;
  final dynamic admissionNo;
  final dynamic type;
  final int? replyId;
  final int? status;
  final String? title;

  ViewEnquiryModel({
    this.id,
    this.parentID,
    this.className,
    this.classId,
    this.section,
    this.sectionId,
    this.session,
    this.createDate,
    this.subject,
    this.message,
    this.action,
    this.createBy,
    this.updateBy,
    this.reply,
    this.replyDate,
    this.studentName,
    this.schoolId,
    this.name,
    this.teacherReg,
    this.admissionNo,
    this.type,
    this.replyId,
    this.status,
    this.title,
  });

  /// Reply nahi aaya -> pending (red)
  /// Reply aa gaya -> replied (green)
  bool get isReplied => reply != null && reply!.trim().isNotEmpty;

  factory ViewEnquiryModel.fromJson(Map<String, dynamic> json) {
    return ViewEnquiryModel(
      id: json['id'] as int?,
      parentID: json['parentID'],
      className: json['class'] as String?,
      classId: json['classId'] as int?,
      section: json['section'] as String?,
      sectionId: json['sectionId'] as int?,
      session: json['session'],
      createDate: _parseDate(json['createDate']),
      subject: json['subject'],
      message: json['message'] as String?,
      action: json['action'],
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      reply: json['reply'] as String?,
      replyDate: _parseDate(json['replyDate']),
      studentName: json['studentName'] as String?,
      schoolId: json['schoolId'],
      name: json['name'],
      teacherReg: json['teacherReg'],
      admissionNo: json['admissionNo'],
      type: json['type'],
      replyId: json['replyId'] as int?,
      status: json['status'] as int?,
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentID': parentID,
      'class': className,
      'classId': classId,
      'section': section,
      'sectionId': sectionId,
      'session': session,
      'createDate': createDate?.toIso8601String(),
      'subject': subject,
      'message': message,
      'action': action,
      'createBy': createBy,
      'updateBy': updateBy,
      'reply': reply,
      'replyDate': replyDate?.toIso8601String(),
      'studentName': studentName,
      'schoolId': schoolId,
      'name': name,
      'teacherReg': teacherReg,
      'admissionNo': admissionNo,
      'type': type,
      'replyId': replyId,
      'status': status,
      'title': title,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    if (str.startsWith('0001-01-01')) return null;
    return DateTime.tryParse(str);
  }
}

/// List parse karne ke liye helper
List<ViewEnquiryModel> viewEnquiryModelFromJson(List<dynamic> list) {
  return list
      .map((e) => ViewEnquiryModel.fromJson(e as Map<String, dynamic>))
      .toList();
}