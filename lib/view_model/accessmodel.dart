class Accessmodel {
  int? id;
  int? schoolAccessId;
  int? activityId;
  String? activityName;
  String? displayName;
  bool? isActive;
  int? parentActivityId; // Null? tha pehle — int? use karo taaki value aa sake
  bool? displayOnMenuFlag;
  int? sequence;
  bool? isDelete;
  bool? access;
  List<Accessmodel>? childActivity;

  Accessmodel({
    this.id,
    this.schoolAccessId,
    this.activityId,
    this.activityName,
    this.displayName,
    this.isActive,
    this.parentActivityId,
    this.displayOnMenuFlag,
    this.sequence,
    this.isDelete,
    this.access,
    this.childActivity,
  });

  Accessmodel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    schoolAccessId = json['schoolAccessId'];
    activityId = json['activityId'];
    activityName = json['activityName'];
    displayName = json['displayName'];
    isActive = json['isActive'];
    parentActivityId = json['parentActivityId'];
    displayOnMenuFlag = json['displayOnMenuFlag'];
    sequence = json['sequence'];
    isDelete = json['isDelete'];
    access = json['access'];
    if (json['childActivity'] != null) {
      childActivity = <Accessmodel>[];
      json['childActivity'].forEach((v) {
        childActivity!.add(Accessmodel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['schoolAccessId'] = schoolAccessId;
    data['activityId'] = activityId;
    data['activityName'] = activityName;
    data['displayName'] = displayName;
    data['isActive'] = isActive;
    data['parentActivityId'] = parentActivityId;
    data['displayOnMenuFlag'] = displayOnMenuFlag;
    data['sequence'] = sequence;
    data['isDelete'] = isDelete;
    data['access'] = access;
    if (childActivity != null) {
      data['childActivity'] = childActivity!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}