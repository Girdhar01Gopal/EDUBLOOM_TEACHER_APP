class viewattendence {
  List<ListData>? listData;

  viewattendence({this.listData});

  viewattendence.fromJson(Map<String, dynamic> json) {
    if (json['listData'] != null) {
      listData = <ListData>[];
      json['listData'].forEach((v) {
        listData!.add(ListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (listData != null) {
      data['listData'] = listData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListData {
  int? studentId;
  String? studentName;
  String? className;
  int? classId;
  int? sectionId;
  String? sectionName;
  int? months;
  String? sex;
  String? session;
  String? dob;
  String? adate; // ✅ ADDED

  String? day1;
  String? day2;
  String? day3;
  String? day4;
  String? day5;
  String? day6;
  String? day7;
  String? day8;
  String? day9;
  String? day10;
  String? day11;
  String? day12;
  String? day13;
  String? day14;
  String? day15;
  String? day16;
  String? day17;
  String? day18;
  String? day19;
  String? day20;
  String? day21;
  String? day22;
  String? day23;
  String? day24;
  String? day25;
  String? day26;
  String? day27;
  String? day28;
  String? day29;
  String? day30;
  String? day31;

  Map<String, dynamic>? attendanceDateWise; // ✅ ADDED

  ListData({
    this.studentId,
    this.studentName,
    this.className,
    this.classId,
    this.sectionId,
    this.sectionName,
    this.months,
    this.sex,
    this.session,
    this.dob,
    this.adate,
    this.day1,
    this.day2,
    this.day3,
    this.day4,
    this.day5,
    this.day6,
    this.day7,
    this.day8,
    this.day9,
    this.day10,
    this.day11,
    this.day12,
    this.day13,
    this.day14,
    this.day15,
    this.day16,
    this.day17,
    this.day18,
    this.day19,
    this.day20,
    this.day21,
    this.day22,
    this.day23,
    this.day24,
    this.day25,
    this.day26,
    this.day27,
    this.day28,
    this.day29,
    this.day30,
    this.day31,
    this.attendanceDateWise,
  });

  ListData.fromJson(Map<String, dynamic> json) {
    studentId = json['studentId'];
    studentName = json['studentName'];
    className = json['className'];
    classId = json['classId'];
    sectionId = json['sectionId'];
    sectionName = json['sectionName'];
    months = json['months'];
    sex = json['sex'];
    session = json['session'];
    dob = json['dob'];
    adate = json['adate']; // ✅ ADDED

    day1 = json['day1'];
    day2 = json['day2'];
    day3 = json['day3'];
    day4 = json['day4'];
    day5 = json['day5'];
    day6 = json['day6'];
    day7 = json['day7'];
    day8 = json['day8'];
    day9 = json['day9'];
    day10 = json['day10'];
    day11 = json['day11'];
    day12 = json['day12'];
    day13 = json['day13'];
    day14 = json['day14'];
    day15 = json['day15'];
    day16 = json['day16'];
    day17 = json['day17'];
    day18 = json['day18'];
    day19 = json['day19'];
    day20 = json['day20'];
    day21 = json['day21'];
    day22 = json['day22'];
    day23 = json['day23'];
    day24 = json['day24'];
    day25 = json['day25'];
    day26 = json['day26'];
    day27 = json['day27'];
    day28 = json['day28'];
    day29 = json['day29'];
    day30 = json['day30'];
    day31 = json['day31'];

    attendanceDateWise = json['attendanceDateWise']; // ✅ ADDED
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['studentId'] = studentId;
    data['studentName'] = studentName;
    data['className'] = className;
    data['classId'] = classId;
    data['sectionId'] = sectionId;
    data['sectionName'] = sectionName;
    data['months'] = months;
    data['sex'] = sex;
    data['session'] = session;
    data['dob'] = dob;
    data['adate'] = adate; // ✅ ADDED

    data['day1'] = day1;
    data['day2'] = day2;
    data['day3'] = day3;
    data['day4'] = day4;
    data['day5'] = day5;
    data['day6'] = day6;
    data['day7'] = day7;
    data['day8'] = day8;
    data['day9'] = day9;
    data['day10'] = day10;
    data['day11'] = day11;
    data['day12'] = day12;
    data['day13'] = day13;
    data['day14'] = day14;
    data['day15'] = day15;
    data['day16'] = day16;
    data['day17'] = day17;
    data['day18'] = day18;
    data['day19'] = day19;
    data['day20'] = day20;
    data['day21'] = day21;
    data['day22'] = day22;
    data['day23'] = day23;
    data['day24'] = day24;
    data['day25'] = day25;
    data['day26'] = day26;
    data['day27'] = day27;
    data['day28'] = day28;
    data['day29'] = day29;
    data['day30'] = day30;
    data['day31'] = day31;

    data['attendanceDateWise'] = attendanceDateWise; // ✅ ADDED

    return data;
  }
}