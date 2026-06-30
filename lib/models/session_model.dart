class SessionModel {
  List<sListDdata>? listData;
  sListDdata? currentSession;

  SessionModel({this.listData, this.currentSession});

  SessionModel.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <sListDdata>[];
      json['listData'].forEach((v) {
        listData!.add(sListDdata.fromJson(v));
      });
    }

    if (json['currentSession'] != null) {
      currentSession = sListDdata.fromJson(json['currentSession']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (listData != null) {
      data['listData'] = listData!.map((v) => v.toJson()).toList();
    }

    if (currentSession != null) {
      data['currentSession'] = currentSession!.toJson();
    }

    return data;
  }
}

/// 🔥 Unified session class (replaces sListDdata + CurrentSession)
class sListDdata {
  int? sessionId;
  String? session;
  String? action;
  String? createDate;
  String? updateDate;
  String? schoolId;

  sListDdata({
    this.sessionId,
    this.session,
    this.action,
    this.createDate,
    this.updateDate,
    this.schoolId,
  });

  factory sListDdata.fromJson(Map<String, dynamic> json) {
    return sListDdata(
      sessionId: json['sessionId'] ?? json['currentSessionId'],
      session: json['session'] ?? json['currentSession'],
      action: json['action'],
      createDate: json['createDate'],
      updateDate: json['updatedate'] ?? json['updateDate'],
      schoolId: json['schoolId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'session': session,
      'action': action,
      'createDate': createDate,
      'updateDate': updateDate,
      'schoolId': schoolId,
    };
  }
}
