class logo {
  bool? success;
  String? message;
  String? logoWithName;

  logo({this.success, this.message, this.logoWithName});

  logo.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    logoWithName = json['logoWithName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    data['logoWithName'] = this.logoWithName;
    return data;
  }
}