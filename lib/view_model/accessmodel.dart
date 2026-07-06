class accessmodel {
  int? id;
  int? schoolAccessId;
  int? activityId;
  String? activityName;
  String? displayName;
  bool? isActive;
  Null? parentActivityId;
  bool? displayOnMenuFlag;
  int? sequence;
  bool? isDelete;
  bool? access;
  List<accessmodel>? childActivity;

  accessmodel(
      {this.id,
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
      this.childActivity});

  accessmodel.fromJson(Map<String, dynamic> json) {
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
      childActivity = <accessmodel>[];
      json['childActivity'].forEach((v) {
        childActivity!.add(accessmodel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['schoolAccessId'] = this.schoolAccessId;
    data['activityId'] = this.activityId;
    data['activityName'] = this.activityName;
    data['displayName'] = this.displayName;
    data['isActive'] = this.isActive;
    data['parentActivityId'] = this.parentActivityId;
    data['displayOnMenuFlag'] = this.displayOnMenuFlag;
    data['sequence'] = this.sequence;
    data['isDelete'] = this.isDelete;
    data['access'] = this.access;
    if (this.childActivity != null) {
      data['childActivity'] =
          this.childActivity!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}