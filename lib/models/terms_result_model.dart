class TermsResultModel {
  final List<TermData>? listData;
  final String? currentSession;

  TermsResultModel({
    this.listData,
    this.currentSession,
  });

  factory TermsResultModel.fromJson(Map<String, dynamic> json) {
    return TermsResultModel(
      listData: json['listData'] != null
          ? List<TermData>.from(
          json['listData'].map((x) => TermData.fromJson(x)))
          : [],
      currentSession: json['currentSession'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'listData': listData != null
          ? listData!.map((x) => x.toJson()).toList()
          : [],
      'currentSession': currentSession,
    };
  }
}

class TermData {
  final int? id;
  final String? term;
  final String? action;
  final DateTime? createDate;
  final DateTime? updateDate;
  final String? createBy;
  final String? updateBy;
  final String? schoolId;
  final String? session; // ✅ NEW

  TermData({
    this.id,
    this.term,
    this.action,
    this.createDate,
    this.updateDate,
    this.createBy,
    this.updateBy,
    this.schoolId,
    this.session,
  });

  factory TermData.fromJson(Map<String, dynamic> json) {
    return TermData(
      id: json['id'],
      term: json['term'],
      action: json['action'],
      createDate: json['createDate'] != null
          ? DateTime.tryParse(json['createDate'].toString())
          : null,
      updateDate: json['updateDate'] != null
          ? DateTime.tryParse(json['updateDate'].toString())
          : null,
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      schoolId: json['schoolId'],
      session: json['session']?.toString(), // ✅ NEW
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term': term,
      'action': action,
      'createDate': createDate?.toIso8601String(),
      'updateDate': updateDate?.toIso8601String(),
      'createBy': createBy,
      'updateBy': updateBy,
      'schoolId': schoolId,
      'session': session, // ✅ NEW
    };
  }
}