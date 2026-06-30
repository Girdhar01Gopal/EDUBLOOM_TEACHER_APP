class expiry {
  int? id;
  String? schoolName;
  String? createDate;
  String? expirydate;
  Null? updatedate;
  String? action;

  expiry(
      {this.id,
      this.schoolName,
      this.createDate,
      this.expirydate,
      this.updatedate,
      this.action});

  expiry.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    schoolName = json['schoolName'];
    createDate = json['createDate'];
    expirydate = json['expirydate'];
    updatedate = json['updatedate'];
    action = json['action'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['schoolName'] = this.schoolName;
    data['createDate'] = this.createDate;
    data['expirydate'] = this.expirydate;
    data['updatedate'] = this.updatedate;
    data['action'] = this.action;
    return data;
  }
}