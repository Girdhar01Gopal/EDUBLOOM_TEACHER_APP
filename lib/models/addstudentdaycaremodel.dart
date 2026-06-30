class Student2Model {
  List<daListData>? listData;

  Student2Model({this.listData});

  Student2Model.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <daListData>[];
      json['listData'].forEach((v) {
        listData!.add(new daListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listData != null) {
      data['listData'] = this.listData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class daListData {
  int? studentID;
  String? studentName;
  String? gender;
  String? fatherName;
  String? motherName;
  String? fatherOccupation;
  String? dateOfBirth;
  String? rollNo;
  String? bloodGroup;
  String? religion;
  String? admissionDate;
  String? parentId;
  String? phone;
  String? whatsAppNo;
  String? emergencyNo;
  String? createDate;
  String? email;
  String? updateBy;
  String? session;
  String? ppassword;
  String? registrationNo;
  String? action;
  String? studentPic;
  String? fatherPic;
  String? motherPic;
  String? guardianImage;
  int? feesDurationId;
  String? feesDuration;

  daListData(
      {this.studentID,
        this.studentName,
        this.gender,
        this.fatherName,
        this.motherName,
        this.fatherOccupation,
        this.dateOfBirth,
        this.rollNo,
        this.bloodGroup,
        this.religion,
        this.admissionDate,
        this.parentId,
        this.phone,
        this.whatsAppNo,
        this.emergencyNo,
        this.createDate,
        this.email,
        this.updateBy,
        this.session,
        this.ppassword,
        this.registrationNo,
        this.action,
        this.studentPic,
        this.fatherPic,
        this.motherPic,
        this.guardianImage,
        this.feesDurationId,
        this.feesDuration});

  daListData.fromJson(Map<String, dynamic> json) {
    studentID = json['studentID'];
    studentName = json['studentName'];
    gender = json['gender'];
    fatherName = json['fatherName'];
    motherName = json['motherName'];
    fatherOccupation = json['fatherOccupation'];
    dateOfBirth = json['dateOfBirth'];
    rollNo = json['rollNo'];
    bloodGroup = json['bloodGroup'];
    religion = json['religion'];
    admissionDate = json['admissionDate'];
    parentId = json['parentId'];
    phone = json['phone'];
    whatsAppNo = json['whatsAppNo'];
    emergencyNo = json['emergencyNo'];
    createDate = json['createDate'];
    email = json['email'];
    updateBy = json['updateBy'];
    session = json['session'];
    ppassword = json['ppassword'];
    registrationNo = json['registrationNo'];
    action = json['action'];
    studentPic = json['studentPic'];
    fatherPic = json['fatherPic'];
    motherPic = json['motherPic'];
    guardianImage = json['guardianImage'];
    feesDurationId = json['feesDurationId'];
    feesDuration = json['feesDuration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentID'] = this.studentID;
    data['studentName'] = this.studentName;
    data['gender'] = this.gender;
    data['fatherName'] = this.fatherName;
    data['motherName'] = this.motherName;
    data['fatherOccupation'] = this.fatherOccupation;
    data['dateOfBirth'] = this.dateOfBirth;
    data['rollNo'] = this.rollNo;
    data['bloodGroup'] = this.bloodGroup;
    data['religion'] = this.religion;
    data['admissionDate'] = this.admissionDate;
    data['parentId'] = this.parentId;
    data['phone'] = this.phone;
    data['whatsAppNo'] = this.whatsAppNo;
    data['emergencyNo'] = this.emergencyNo;
    data['createDate'] = this.createDate;
    data['email'] = this.email;
    data['updateBy'] = this.updateBy;
    data['session'] = this.session;
    data['ppassword'] = this.ppassword;
    data['registrationNo'] = this.registrationNo;
    data['action'] = this.action;
    data['studentPic'] = this.studentPic;
    data['fatherPic'] = this.fatherPic;
    data['motherPic'] = this.motherPic;
    data['guardianImage'] = this.guardianImage;
    data['feesDurationId'] = this.feesDurationId;
    data['feesDuration'] = this.feesDuration;
    return data;
  }
}
 