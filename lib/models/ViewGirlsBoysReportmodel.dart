class ViewGirlBoyModelReport {
  dynamic language1;
  dynamic tcNumber;
  int? studentId;
  String? registrationNo;
  dynamic siblingDetails;
  dynamic sibling;
  dynamic staffFirstChild;
  dynamic admissionNo;
  String? session;
  String? studentName;
  String? sex;
  dynamic placeofBirth;
  String? dob;
  dynamic age;
  int? classId;

  /// JSON key is "class" (reserved word in Dart), so we store in className
  String? className;

  String? section;
  int? sectionId;
  String? religion;
  dynamic caste;
  dynamic nationality;
  dynamic motherTongue;
  int? qnId;
  dynamic sqnId;
  int? hostel;
  dynamic parentStatus;
  dynamic quotaName;
  dynamic parentID;
  String? fatherName;
  dynamic fAge;
  dynamic fEducation;
  String? fOccupation;
  dynamic fDesignation;
  dynamic fOrganisation;
  dynamic fAddressRes;
  dynamic fAddressPerm;
  dynamic fAddressOffice;
  dynamic fPhoneOffice;
  String? fMobileno;
  String? fEmail;
  String? motherName;
  dynamic mAge;
  dynamic mEducation;
  dynamic mOccupation;
  dynamic mDesignation;
  dynamic mOrganisation;
  dynamic mAddressRes;
  dynamic mAddressPerm;
  dynamic mAddressOffice;
  dynamic mPhoneoffice;
  dynamic mMobileno;
  dynamic mEmail;
  dynamic smsFather;
  dynamic smsMother;
  String? bloodGroup;
  dynamic identificationMark;
  dynamic height;
  dynamic weight;
  dynamic asthma;
  dynamic epilepsy;
  dynamic anyOther;
  dynamic bcg;
  dynamic hib;
  dynamic dpt;
  dynamic influenza;
  dynamic mmr;
  dynamic typhoid;
  dynamic polio;
  dynamic measles;
  dynamic hepatitisA;
  dynamic hepatitisB;
  dynamic chickenpox;
  dynamic dtap;
  dynamic anyMedicine;
  dynamic anyFood;
  dynamic anythingElse;
  dynamic spectacles;
  dynamic blindness;
  int? routeNo;
  dynamic routeName;
  dynamic pickupPoint;
  dynamic dropPoint;
  String? midDayTo;
  String? midDayFrom;
  String? studentPic;
  String? fatherPic;
  String? motherPic;
  dynamic aadharPic;
  dynamic birthCertificatePic;
  String? action;
  String? action1;
  String? action2;
  dynamic attendance;
  dynamic createBy;
  dynamic updateBy;
  String? ppassword;
  dynamic rollNo;
  dynamic ddob;
  int? sNo;
  String? schoolId;
  dynamic schoolName;
  dynamic aAdharNo;
  dynamic emisNo;
  int? routePointId;
  int? routeNameId;
  dynamic transportUser;
  dynamic description1;
  dynamic feeType;
  dynamic createddBy;
  dynamic doa;
  String? dateOfAdmission;
  dynamic fQualification;
  dynamic mQualification;
  String? whatsAppNo;
  dynamic guardianName;
  dynamic guardianPhone;
  dynamic pinCode;
  int? languageId;
  int? activityId;
  int? serviceId;
  int? casteId;
  dynamic activity;
  dynamic serviceMovement;
  int? coachingId;
  dynamic coaching;
  dynamic community;

  /// JSON key is "city_state"
  dynamic cityState;

  /// JSON key is "city_name"
  dynamic cityName;

  dynamic language;
  int? groupId;
  dynamic groupName;
  int? houseId;
  dynamic houseName;
  dynamic tcStatus;
  dynamic neetiitca;
  dynamic studentRegNo;
  dynamic classInWords;
  dynamic dobinWords;
  dynamic games19;
  dynamic whether18;
  dynamic conduct20;
  dynamic aAdmissionDate;
  dynamic receiptno;
  dynamic term;
  dynamic remark;
  String? updateDate;
  dynamic transportremark;
  String? transportdate;
  dynamic whichclass;
  dynamic smsMobileNoNumber;
  int? feeTypeId;
  dynamic studentQRCode;
  dynamic email;
  dynamic website;
  dynamic certified;
  dynamic address;
  dynamic phone;
  dynamic affiliated;
  int? sclInfoId;
  String? createDate;
  int? bonafiedId;
  dynamic bonafiedNo;
  dynamic stuId;
  dynamic purpose;
  dynamic session1;
  dynamic rupees;
  dynamic doB1;
  dynamic rupeeInWords;
  int? bonId;
  dynamic conduct;
  dynamic shortName;
  dynamic tcUpload;
  dynamic lastResult;
  dynamic schoolAddress;
  dynamic phoneNumber1;
  dynamic uploadLogo1;
  dynamic dateinword;
  dynamic house;
  dynamic identities;
  int? guardId;
  dynamic classYear;
  dynamic datet;
  dynamic dateOfBirth;
  dynamic doB2;
  dynamic transferCertificate;
  dynamic aadharParents;
  dynamic relation;
  dynamic guardName;
  dynamic idno;
  int? relationId;
  dynamic newStudent;
  dynamic motherAAdharNo;
  dynamic fatherAAdharNo;
  int? feesDurationId;
  dynamic registrationNo1;
  dynamic studentPic1;
  dynamic fatherPic1;
  dynamic motherPic1;
  dynamic schoolEmailID;
  dynamic days;
  int? defaulterFee;

  ViewGirlBoyModelReport({
    this.language1,
    this.tcNumber,
    this.studentId,
    this.registrationNo,
    this.siblingDetails,
    this.sibling,
    this.staffFirstChild,
    this.admissionNo,
    this.session,
    this.studentName,
    this.sex,
    this.placeofBirth,
    this.dob,
    this.age,
    this.classId,
    this.className,
    this.section,
    this.sectionId,
    this.religion,
    this.caste,
    this.nationality,
    this.motherTongue,
    this.qnId,
    this.sqnId,
    this.hostel,
    this.parentStatus,
    this.quotaName,
    this.parentID,
    this.fatherName,
    this.fAge,
    this.fEducation,
    this.fOccupation,
    this.fDesignation,
    this.fOrganisation,
    this.fAddressRes,
    this.fAddressPerm,
    this.fAddressOffice,
    this.fPhoneOffice,
    this.fMobileno,
    this.fEmail,
    this.motherName,
    this.mAge,
    this.mEducation,
    this.mOccupation,
    this.mDesignation,
    this.mOrganisation,
    this.mAddressRes,
    this.mAddressPerm,
    this.mAddressOffice,
    this.mPhoneoffice,
    this.mMobileno,
    this.mEmail,
    this.smsFather,
    this.smsMother,
    this.bloodGroup,
    this.identificationMark,
    this.height,
    this.weight,
    this.asthma,
    this.epilepsy,
    this.anyOther,
    this.bcg,
    this.hib,
    this.dpt,
    this.influenza,
    this.mmr,
    this.typhoid,
    this.polio,
    this.measles,
    this.hepatitisA,
    this.hepatitisB,
    this.chickenpox,
    this.dtap,
    this.anyMedicine,
    this.anyFood,
    this.anythingElse,
    this.spectacles,
    this.blindness,
    this.routeNo,
    this.routeName,
    this.pickupPoint,
    this.dropPoint,
    this.midDayTo,
    this.midDayFrom,
    this.studentPic,
    this.fatherPic,
    this.motherPic,
    this.aadharPic,
    this.birthCertificatePic,
    this.action,
    this.action1,
    this.action2,
    this.attendance,
    this.createBy,
    this.updateBy,
    this.ppassword,
    this.rollNo,
    this.ddob,
    this.sNo,
    this.schoolId,
    this.schoolName,
    this.aAdharNo,
    this.emisNo,
    this.routePointId,
    this.routeNameId,
    this.transportUser,
    this.description1,
    this.feeType,
    this.createddBy,
    this.doa,
    this.dateOfAdmission,
    this.fQualification,
    this.mQualification,
    this.whatsAppNo,
    this.guardianName,
    this.guardianPhone,
    this.pinCode,
    this.languageId,
    this.activityId,
    this.serviceId,
    this.casteId,
    this.activity,
    this.serviceMovement,
    this.coachingId,
    this.coaching,
    this.community,
    this.cityState,
    this.cityName,
    this.language,
    this.groupId,
    this.groupName,
    this.houseId,
    this.houseName,
    this.tcStatus,
    this.neetiitca,
    this.studentRegNo,
    this.classInWords,
    this.dobinWords,
    this.games19,
    this.whether18,
    this.conduct20,
    this.aAdmissionDate,
    this.receiptno,
    this.term,
    this.remark,
    this.updateDate,
    this.transportremark,
    this.transportdate,
    this.whichclass,
    this.smsMobileNoNumber,
    this.feeTypeId,
    this.studentQRCode,
    this.email,
    this.website,
    this.certified,
    this.address,
    this.phone,
    this.affiliated,
    this.sclInfoId,
    this.createDate,
    this.bonafiedId,
    this.bonafiedNo,
    this.stuId,
    this.purpose,
    this.session1,
    this.rupees,
    this.doB1,
    this.rupeeInWords,
    this.bonId,
    this.conduct,
    this.shortName,
    this.tcUpload,
    this.lastResult,
    this.schoolAddress,
    this.phoneNumber1,
    this.uploadLogo1,
    this.dateinword,
    this.house,
    this.identities,
    this.guardId,
    this.classYear,
    this.datet,
    this.dateOfBirth,
    this.doB2,
    this.transferCertificate,
    this.aadharParents,
    this.relation,
    this.guardName,
    this.idno,
    this.relationId,
    this.newStudent,
    this.motherAAdharNo,
    this.fatherAAdharNo,
    this.feesDurationId,
    this.registrationNo1,
    this.studentPic1,
    this.fatherPic1,
    this.motherPic1,
    this.schoolEmailID,
    this.days,
    this.defaulterFee,
  });

  factory ViewGirlBoyModelReport.fromJson(Map<String, dynamic> json) {
    return ViewGirlBoyModelReport(
      language1: json['language1'],
      tcNumber: json['tcNumber'],
      studentId: json['studentId'],
      registrationNo: json['registrationNo'],
      siblingDetails: json['siblingDetails'],
      sibling: json['sibling'],
      staffFirstChild: json['staffFirstChild'],
      admissionNo: json['admissionNo'],
      session: json['session'],
      studentName: json['studentName'],
      sex: json['sex'],
      placeofBirth: json['placeofBirth'],
      dob: json['dob'],
      age: json['age'],
      classId: json['classId'],
      className: json['class'],
      section: json['section'],
      sectionId: json['sectionId'],
      religion: json['religion'],
      caste: json['caste'],
      nationality: json['nationality'],
      motherTongue: json['motherTongue'],
      qnId: json['qnId'],
      sqnId: json['sqnId'],
      hostel: json['hostel'],
      parentStatus: json['parentStatus'],
      quotaName: json['quotaName'],
      parentID: json['parentID'],
      fatherName: json['fatherName'],
      fAge: json['fAge'],
      fEducation: json['fEducation'],
      fOccupation: json['fOccupation'],
      fDesignation: json['fDesignation'],
      fOrganisation: json['fOrganisation'],
      fAddressRes: json['fAddressRes'],
      fAddressPerm: json['fAddressPerm'],
      fAddressOffice: json['fAddressOffice'],
      fPhoneOffice: json['fPhoneOffice'],
      fMobileno: json['fMobileno'],
      fEmail: json['fEmail'],
      motherName: json['motherName'],
      mAge: json['mAge'],
      mEducation: json['mEducation'],
      mOccupation: json['mOccupation'],
      mDesignation: json['mDesignation'],
      mOrganisation: json['mOrganisation'],
      mAddressRes: json['mAddressRes'],
      mAddressPerm: json['mAddressPerm'],
      mAddressOffice: json['mAddressOffice'],
      mPhoneoffice: json['mPhoneoffice'],
      mMobileno: json['mMobileno'],
      mEmail: json['mEmail'],
      smsFather: json['smsFather'],
      smsMother: json['smsMother'],
      bloodGroup: json['bloodGroup'],
      identificationMark: json['identificationMark'],
      height: json['height'],
      weight: json['weight'],
      asthma: json['asthma'],
      epilepsy: json['epilepsy'],
      anyOther: json['anyOther'],
      bcg: json['bcg'],
      hib: json['hib'],
      dpt: json['dpt'],
      influenza: json['influenza'],
      mmr: json['mmr'],
      typhoid: json['typhoid'],
      polio: json['polio'],
      measles: json['measles'],
      hepatitisA: json['hepatitisA'],
      hepatitisB: json['hepatitisB'],
      chickenpox: json['chickenpox'],
      dtap: json['dtap'],
      anyMedicine: json['anyMedicine'],
      anyFood: json['anyFood'],
      anythingElse: json['anythingElse'],
      spectacles: json['spectacles'],
      blindness: json['blindness'],
      routeNo: json['routeNo'],
      routeName: json['routeName'],
      pickupPoint: json['pickupPoint'],
      dropPoint: json['dropPoint'],
      midDayTo: json['midDayTo'],
      midDayFrom: json['midDayFrom'],
      studentPic: json['studentPic'],
      fatherPic: json['fatherPic'],
      motherPic: json['motherPic'],
      aadharPic: json['aadharPic'],
      birthCertificatePic: json['birthCertificatePic'],
      action: json['action'],
      action1: json['action1'],
      action2: json['action2'],
      attendance: json['attendance'],
      createBy: json['createBy'],
      updateBy: json['updateBy'],
      ppassword: json['ppassword'],
      rollNo: json['rollNo'],
      ddob: json['ddob'],
      sNo: json['sNo'],
      schoolId: json['schoolId'],
      schoolName: json['schoolName'],
      aAdharNo: json['aAdharNo'],
      emisNo: json['emisNo'],
      routePointId: json['routePointId'],
      routeNameId: json['routeNameId'],
      transportUser: json['transportUser'],
      description1: json['description1'],
      feeType: json['feeType'],
      createddBy: json['createddBy'],
      doa: json['doa'],
      dateOfAdmission: json['dateOfAdmission'],
      fQualification: json['fQualification'],
      mQualification: json['mQualification'],
      whatsAppNo: json['whatsAppNo'],
      guardianName: json['guardianName'],
      guardianPhone: json['guardianPhone'],
      pinCode: json['pinCode'],
      languageId: json['languageId'],
      activityId: json['activityId'],
      serviceId: json['serviceId'],
      casteId: json['casteId'],
      activity: json['activity'],
      serviceMovement: json['serviceMovement'],
      coachingId: json['coachingId'],
      coaching: json['coaching'],
      community: json['community'],
      cityState: json['city_state'],
      cityName: json['city_name'],
      language: json['language'],
      groupId: json['groupId'],
      groupName: json['groupName'],
      houseId: json['houseId'],
      houseName: json['houseName'],
      tcStatus: json['tcStatus'],
      neetiitca: json['neetiitca'],
      studentRegNo: json['studentRegNo'],
      classInWords: json['classInWords'],
      dobinWords: json['dobinWords'],
      games19: json['games19'],
      whether18: json['whether18'],
      conduct20: json['conduct20'],
      aAdmissionDate: json['aAdmissionDate'],
      receiptno: json['receiptno'],
      term: json['term'],
      remark: json['remark'],
      updateDate: json['updateDate'],
      transportremark: json['transportremark'],
      transportdate: json['transportdate'],
      whichclass: json['whichclass'],
      smsMobileNoNumber: json['smsMobileNoNumber'],
      feeTypeId: json['feeTypeId'],
      studentQRCode: json['studentQRCode'],
      email: json['email'],
      website: json['website'],
      certified: json['certified'],
      address: json['address'],
      phone: json['phone'],
      affiliated: json['affiliated'],
      sclInfoId: json['sclInfoId'],
      createDate: json['createDate'],
      bonafiedId: json['bonafiedId'],
      bonafiedNo: json['bonafiedNo'],
      stuId: json['stuId'],
      purpose: json['purpose'],
      session1: json['session1'],
      rupees: json['rupees'],
      doB1: json['doB1'],
      rupeeInWords: json['rupeeInWords'],
      bonId: json['bonId'],
      conduct: json['conduct'],
      shortName: json['shortName'],
      tcUpload: json['tcUpload'],
      lastResult: json['lastResult'],
      schoolAddress: json['schoolAddress'],
      phoneNumber1: json['phoneNumber1'],
      uploadLogo1: json['uploadLogo1'],
      dateinword: json['dateinword'],
      house: json['house'],
      identities: json['identities'],
      guardId: json['guardId'],
      classYear: json['classYear'],
      datet: json['datet'],
      dateOfBirth: json['dateOfBirth'],
      doB2: json['doB2'],
      transferCertificate: json['transferCertificate'],
      aadharParents: json['aadharParents'],
      relation: json['relation'],
      guardName: json['guardName'],
      idno: json['idno'],
      relationId: json['relationId'],
      newStudent: json['newStudent'],
      motherAAdharNo: json['motherAAdharNo'],
      fatherAAdharNo: json['fatherAAdharNo'],
      feesDurationId: json['feesDurationId'],
      registrationNo1: json['registrationNo1'],
      studentPic1: json['studentPic1'],
      fatherPic1: json['fatherPic1'],
      motherPic1: json['motherPic1'],
      schoolEmailID: json['schoolEmailID'],
      days: json['days'],
      defaulterFee: json['defaulterFee'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['language1'] = language1;
    data['tcNumber'] = tcNumber;
    data['studentId'] = studentId;
    data['registrationNo'] = registrationNo;
    data['siblingDetails'] = siblingDetails;
    data['sibling'] = sibling;
    data['staffFirstChild'] = staffFirstChild;
    data['admissionNo'] = admissionNo;
    data['session'] = session;
    data['studentName'] = studentName;
    data['sex'] = sex;
    data['placeofBirth'] = placeofBirth;
    data['dob'] = dob;
    data['age'] = age;
    data['classId'] = classId;

    // write back to JSON key "class"
    data['class'] = className;

    data['section'] = section;
    data['sectionId'] = sectionId;
    data['religion'] = religion;
    data['caste'] = caste;
    data['nationality'] = nationality;
    data['motherTongue'] = motherTongue;
    data['qnId'] = qnId;
    data['sqnId'] = sqnId;
    data['hostel'] = hostel;
    data['parentStatus'] = parentStatus;
    data['quotaName'] = quotaName;
    data['parentID'] = parentID;
    data['fatherName'] = fatherName;
    data['fAge'] = fAge;
    data['fEducation'] = fEducation;
    data['fOccupation'] = fOccupation;
    data['fDesignation'] = fDesignation;
    data['fOrganisation'] = fOrganisation;
    data['fAddressRes'] = fAddressRes;
    data['fAddressPerm'] = fAddressPerm;
    data['fAddressOffice'] = fAddressOffice;
    data['fPhoneOffice'] = fPhoneOffice;
    data['fMobileno'] = fMobileno;
    data['fEmail'] = fEmail;
    data['motherName'] = motherName;
    data['mAge'] = mAge;
    data['mEducation'] = mEducation;
    data['mOccupation'] = mOccupation;
    data['mDesignation'] = mDesignation;
    data['mOrganisation'] = mOrganisation;
    data['mAddressRes'] = mAddressRes;
    data['mAddressPerm'] = mAddressPerm;
    data['mAddressOffice'] = mAddressOffice;
    data['mPhoneoffice'] = mPhoneoffice;
    data['mMobileno'] = mMobileno;
    data['mEmail'] = mEmail;
    data['smsFather'] = smsFather;
    data['smsMother'] = smsMother;
    data['bloodGroup'] = bloodGroup;
    data['identificationMark'] = identificationMark;
    data['height'] = height;
    data['weight'] = weight;
    data['asthma'] = asthma;
    data['epilepsy'] = epilepsy;
    data['anyOther'] = anyOther;
    data['bcg'] = bcg;
    data['hib'] = hib;
    data['dpt'] = dpt;
    data['influenza'] = influenza;
    data['mmr'] = mmr;
    data['typhoid'] = typhoid;
    data['polio'] = polio;
    data['measles'] = measles;
    data['hepatitisA'] = hepatitisA;
    data['hepatitisB'] = hepatitisB;
    data['chickenpox'] = chickenpox;
    data['dtap'] = dtap;
    data['anyMedicine'] = anyMedicine;
    data['anyFood'] = anyFood;
    data['anythingElse'] = anythingElse;
    data['spectacles'] = spectacles;
    data['blindness'] = blindness;
    data['routeNo'] = routeNo;
    data['routeName'] = routeName;
    data['pickupPoint'] = pickupPoint;
    data['dropPoint'] = dropPoint;
    data['midDayTo'] = midDayTo;
    data['midDayFrom'] = midDayFrom;
    data['studentPic'] = studentPic;
    data['fatherPic'] = fatherPic;
    data['motherPic'] = motherPic;
    data['aadharPic'] = aadharPic;
    data['birthCertificatePic'] = birthCertificatePic;
    data['action'] = action;
    data['action1'] = action1;
    data['action2'] = action2;
    data['attendance'] = attendance;
    data['createBy'] = createBy;
    data['updateBy'] = updateBy;
    data['ppassword'] = ppassword;
    data['rollNo'] = rollNo;
    data['ddob'] = ddob;
    data['sNo'] = sNo;
    data['schoolId'] = schoolId;
    data['schoolName'] = schoolName;
    data['aAdharNo'] = aAdharNo;
    data['emisNo'] = emisNo;
    data['routePointId'] = routePointId;
    data['routeNameId'] = routeNameId;
    data['transportUser'] = transportUser;
    data['description1'] = description1;
    data['feeType'] = feeType;
    data['createddBy'] = createddBy;
    data['doa'] = doa;
    data['dateOfAdmission'] = dateOfAdmission;
    data['fQualification'] = fQualification;
    data['mQualification'] = mQualification;
    data['whatsAppNo'] = whatsAppNo;
    data['guardianName'] = guardianName;
    data['guardianPhone'] = guardianPhone;
    data['pinCode'] = pinCode;
    data['languageId'] = languageId;
    data['activityId'] = activityId;
    data['serviceId'] = serviceId;
    data['casteId'] = casteId;
    data['activity'] = activity;
    data['serviceMovement'] = serviceMovement;
    data['coachingId'] = coachingId;
    data['coaching'] = coaching;
    data['community'] = community;

    // keep exact JSON keys
    data['city_state'] = cityState;
    data['city_name'] = cityName;

    data['language'] = language;
    data['groupId'] = groupId;
    data['groupName'] = groupName;
    data['houseId'] = houseId;
    data['houseName'] = houseName;
    data['tcStatus'] = tcStatus;
    data['neetiitca'] = neetiitca;
    data['studentRegNo'] = studentRegNo;
    data['classInWords'] = classInWords;
    data['dobinWords'] = dobinWords;
    data['games19'] = games19;
    data['whether18'] = whether18;
    data['conduct20'] = conduct20;
    data['aAdmissionDate'] = aAdmissionDate;
    data['receiptno'] = receiptno;
    data['term'] = term;
    data['remark'] = remark;
    data['updateDate'] = updateDate;
    data['transportremark'] = transportremark;
    data['transportdate'] = transportdate;
    data['whichclass'] = whichclass;
    data['smsMobileNoNumber'] = smsMobileNoNumber;
    data['feeTypeId'] = feeTypeId;
    data['studentQRCode'] = studentQRCode;
    data['email'] = email;
    data['website'] = website;
    data['certified'] = certified;
    data['address'] = address;
    data['phone'] = phone;
    data['affiliated'] = affiliated;
    data['sclInfoId'] = sclInfoId;
    data['createDate'] = createDate;
    data['bonafiedId'] = bonafiedId;
    data['bonafiedNo'] = bonafiedNo;
    data['stuId'] = stuId;
    data['purpose'] = purpose;
    data['session1'] = session1;
    data['rupees'] = rupees;
    data['doB1'] = doB1;
    data['rupeeInWords'] = rupeeInWords;
    data['bonId'] = bonId;
    data['conduct'] = conduct;
    data['shortName'] = shortName;
    data['tcUpload'] = tcUpload;
    data['lastResult'] = lastResult;
    data['schoolAddress'] = schoolAddress;
    data['phoneNumber1'] = phoneNumber1;
    data['uploadLogo1'] = uploadLogo1;
    data['dateinword'] = dateinword;
    data['house'] = house;
    data['identities'] = identities;
    data['guardId'] = guardId;
    data['classYear'] = classYear;
    data['datet'] = datet;
    data['dateOfBirth'] = dateOfBirth;
    data['doB2'] = doB2;
    data['transferCertificate'] = transferCertificate;
    data['aadharParents'] = aadharParents;
    data['relation'] = relation;
    data['guardName'] = guardName;
    data['idno'] = idno;
    data['relationId'] = relationId;
    data['newStudent'] = newStudent;
    data['motherAAdharNo'] = motherAAdharNo;
    data['fatherAAdharNo'] = fatherAAdharNo;
    data['feesDurationId'] = feesDurationId;
    data['registrationNo1'] = registrationNo1;
    data['studentPic1'] = studentPic1;
    data['fatherPic1'] = fatherPic1;
    data['motherPic1'] = motherPic1;
    data['schoolEmailID'] = schoolEmailID;
    data['days'] = days;
    data['defaulterFee'] = defaulterFee;

    return data;
  }

  // Helpers for list parsing
  static List<ViewGirlBoyModelReport> listFromJson(List<dynamic> list) {
    return list.map((e) => ViewGirlBoyModelReport.fromJson(e as Map<String, dynamic>)).toList();
  }
}
