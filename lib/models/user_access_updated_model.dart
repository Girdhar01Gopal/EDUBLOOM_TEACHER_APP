class UserAccessModel {
  final int? id;
  final int schoolAccessId;
  final int activityId;
  final String activityName;
  final String displayName;
  final bool isActive;
  final int? parentActivityId;
  final bool displayOnMenuFlag;
  final int sequence;
  final bool isDelete;
  final bool access;
  final List<UserAccessModel>? childActivity;

  UserAccessModel({
    this.id,
    required this.schoolAccessId,
    required this.activityId,
    required this.activityName,
    required this.displayName,
    required this.isActive,
    this.parentActivityId,
    required this.displayOnMenuFlag,
    required this.sequence,
    required this.isDelete,
    required this.access,
    this.childActivity,
  });

  factory UserAccessModel.fromJson(Map<String, dynamic> json) {
    return UserAccessModel(
      id: json['id'] as int?,
      schoolAccessId: json['schoolAccessId'] as int? ?? 0,
      activityId: json['activityId'] as int,
      activityName: json['activityName'] as String,
      displayName: json['displayName'] as String,
      isActive: json['isActive'] as bool? ?? false,
      parentActivityId: json['parentActivityId'] as int?,
      displayOnMenuFlag: json['displayOnMenuFlag'] as bool? ?? false,
      sequence: json['sequence'] as int? ?? 0,
      isDelete: json['isDelete'] as bool? ?? false,
      access: json['access'] as bool? ?? false,
      childActivity: json['childActivity'] != null
          ? (json['childActivity'] as List<dynamic>)
          .map((e) => UserAccessModel.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolAccessId': schoolAccessId,
      'activityId': activityId,
      'activityName': activityName,
      'displayName': displayName,
      'isActive': isActive,
      'parentActivityId': parentActivityId,
      'displayOnMenuFlag': displayOnMenuFlag,
      'sequence': sequence,
      'isDelete': isDelete,
      'access': access,
      'childActivity': childActivity?.map((e) => e.toJson()).toList(),
    };
  }

  UserAccessModel copyWith({
    int? id,
    int? schoolAccessId,
    int? activityId,
    String? activityName,
    String? displayName,
    bool? isActive,
    int? parentActivityId,
    bool? displayOnMenuFlag,
    int? sequence,
    bool? isDelete,
    bool? access,
    List<UserAccessModel>? childActivity,
  }) {
    return UserAccessModel(
      id: id ?? this.id,
      schoolAccessId: schoolAccessId ?? this.schoolAccessId,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      displayName: displayName ?? this.displayName,
      isActive: isActive ?? this.isActive,
      parentActivityId: parentActivityId ?? this.parentActivityId,
      displayOnMenuFlag: displayOnMenuFlag ?? this.displayOnMenuFlag,
      sequence: sequence ?? this.sequence,
      isDelete: isDelete ?? this.isDelete,
      access: access ?? this.access,
      childActivity: childActivity ?? this.childActivity,
    );
  }

  @override
  String toString() {
    return 'UserAccessModel('
        'id: $id, '
        'schoolAccessId: $schoolAccessId, '
        'activityId: $activityId, '
        'activityName: $activityName, '
        'displayName: $displayName, '
        'isActive: $isActive, '
        'parentActivityId: $parentActivityId, '
        'displayOnMenuFlag: $displayOnMenuFlag, '
        'sequence: $sequence, '
        'isDelete: $isDelete, '
        'access: $access, '
        'childActivity: $childActivity'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserAccessModel &&
        other.id == id &&
        other.activityId == activityId &&
        other.schoolAccessId == schoolAccessId;
  }

  @override
  int get hashCode => Object.hash(id, activityId, schoolAccessId);
}

/// Helper to parse a JSON list into a List<UserAccessModel>
List<UserAccessModel> userAccessModelListFromJson(List<dynamic> jsonList) {
  return jsonList
      .map((e) => UserAccessModel.fromJson(e as Map<String, dynamic>))
      .toList();
}