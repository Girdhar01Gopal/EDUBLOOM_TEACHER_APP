import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/session_model.dart' as session_model; // ✅ fixed: relative import, only one import of this file

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import 'package:http/http.dart' as http;

import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
// ❌ removed: import '../models/session_model.dart';  -> this caused the type-mismatch errors
import '../models/student_fee_model.dart';
import '../res/app_url.dart';

class FeesController extends GetxController {
  var studentfee = StudentFeeModel().obs;
  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs; // ✅ fixed type

  // Rx object for currently selected session
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null); // ✅ fixed type

  // String to store session name (optional)
  var session = ''.obs;
  var classes = <ClassItem>[].obs; // Whole API object
  var listDataa = <ListDataa>[].obs; // Flattened list of classes
  var selectedClass = Rx<ListDataa?>(null);

  var section = 0;
  var studentClass = ''.obs;

  var sectionList = <ListDatta>[].obs; // Observable list for dropdown
  var selectedSection = Rxn<ListDatta>(); // To store the selected section
  var isLoading = true.obs; // Loading state
  var isloading = false.obs; // Loading state

  var token = "";
  var schoolId = "";
  @override
  void onInit() async {
    // TODO: implement onInit
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    fetchClasses();
    fetchSessions();
    fetchSections();
    // fetchStudentFeeData();
    super.onInit();
  }

  // fetch sections
  Future<void> fetchSections() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> data = decoded['listData'] ?? decoded['data'] ?? [];

        // update observable list
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();

        // ❌ STOP auto-selecting first section
        // selectedSection.value = sectionList.first;

        // ✔ Allow dropdown to show "Select Section"
        selectedSection.value = null;
      } else {
        print(" Failed to load sections: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Exception loading sections: $e");
    } finally {
      isLoading(false);
    }
  }

  // Method to set selected section
  void setSelectedSection(ListDatta? section) {
    selectedSection.value = section;
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);

      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
      );

      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));

        // Filter the listData to include only classes where action == "1"
        listDataa.value =
            parsed.listData?.where((e) => e.action == "1").toList() ?? [];

        // Set empty selection so dropdown shows "Select Class"
        selectedClass.value = null;
      }
    } catch (e) {
      print("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ListDataa? studentClassId) {
    selectedClass.value = studentClassId;
  }

  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        // Purana sessionList ko clear karte hain
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );

          sessionList.add(cs);

          // Default session ko select kar rahe hain
          selectedSession.value = cs;
          session.value = cs.session ??
              ''; // Ye line ensure karegi ki session default select ho
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  // Set the selected session
  void setSelectedSession(session_model.sListDdata session) {
    selectedSession.value = session;
  }

  var students = <sdataData>[].obs;

  Future<void> fetchStudents() async {
    try {
      isloading(true);
      var url =
      Uri.parse('${AppUrl.base_url}api/FeePaymentApp/ViewFeeStudentApp');
      Map<String, dynamic> body = {
        "session": session.value,
        "schoolId": schoolId,
        "classId": selectedClass.value?.classId,
        "sectionId": section,
      };
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      print(url);
      print(response.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Handle both cases: flat list or nested
        if (data['listData'] is List) {
          // If listData is a list of students (as objects)
          final List<sdataData> allStudents = [];
          for (var studentJson in data['listData']) {
            // If each studentJson contains a listData property (nested structure)
            if (studentJson is Map && studentJson.containsKey('listData')) {
              var nestedList = studentJson['listData'] as List;
              allStudents.addAll(nestedList.map((v) => sdataData.fromJson(v)));
            } else {
              // If flat
              allStudents.add(sdataData.fromJson(studentJson));
            }
          }
          students.value = allStudents;
        } else {
          students.clear();
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch students');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isloading(false);
    }
  }

  Future<void> fetchStudentFeeData({
    required int studentId,
    required String pickupPoint,
    String? registrationNo,
  }) async {
    final String apiUrl = "${AppUrl.base_url}api/FeePayment/GetShowdata";

    if (selectedClass.value == null) {
      print("Class is not selected.");
      return;
    }

    final requestBody = {
      "session": session.value,
      "schoolId": schoolId,
      "classId": selectedClass.value?.classId,
      "sectionId": section,
      "studentId": studentId,
      "pickupPoint": pickupPoint.trim(),
    };

    print("Request Body: $requestBody");
    print("API URL: $apiUrl");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("Response Body: $jsonResponse");
        studentfee.value = StudentFeeModel.fromApi(jsonResponse);

        // Attach registrationNo only when the caller provides it.
        if (registrationNo != null && registrationNo.trim().isNotEmpty) {
          for (var item in studentfee.value.listData ?? []) {
            item.registrationNo = registrationNo.trim();
          }
        }

        print("Fee items loaded successfully.");
      } else {
        print("Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void filterAndNavigate(
      StudentFeeModel studentFeeModel,
      String registrationNo,
      int studentId,
      ) {
    final dataList = studentFeeModel.listData;

    if (dataList == null || dataList.isEmpty) {
      Get.snackbar("Error", "No fee data available for filtering.");
      return;
    }

    final inputRegNo = registrationNo.trim();

    // Filter based on injected registrationNo
    final filteredList = dataList.where((item) {
      final listRegNo = item.registrationNo?.trim() ?? '';
      return listRegNo == inputRegNo;
    }).toList();

    print("Input Registration No: $inputRegNo");
    print("Filtered List Length: ${filteredList.length}");

    if (filteredList.isEmpty) {
      Get.snackbar(
          "Error", "No matching data found for this registration number.");
      return;
    }

    // Remove duplicates
    final uniqueList = filteredList
        .fold<Map<String, ListData>>({}, (map, item) {
      map[item.className ?? ''] = item;
      return map;
    })
        .values
        .toList();

    print("Filtered List: $uniqueList");

    Get.toNamed(
      RouteName.submit_fee,
      arguments: {
        'feeItems': filteredList,
        'studentId': studentId,
      },
    );
  }
}

class Student {
  List<sdataData>? listData;

  Student({this.listData});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      listData: (json['listData'] as List<dynamic>?)
          ?.map((v) => sdataData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (listData != null)
        'listData': listData!.map((v) => v.toJson()).toList(),
    };
  }
}

class sdataData {
  final int? studentID;
  final String? studentName;
  final String? fatherName;
  final String? motherName;
  final int? classId;
  final int? sectionId;
  final String? className;
  final String? sectionName;
  final String? createDate;
  final String? session;
  final String? action;
  final String? schoolId;
  final String? fatherPhone;
  final String? registrationNo;
  final String? pickupPoint;
  final String? playAmount;

  sdataData({
    this.studentID,
    this.studentName,
    this.fatherName,
    this.motherName,
    this.classId,
    this.sectionId,
    this.className,
    this.sectionName,
    this.createDate,
    this.session,
    this.action,
    this.schoolId,
    this.fatherPhone,
    this.registrationNo,
    this.pickupPoint,
    this.playAmount,
  });

  factory sdataData.fromJson(Map<String, dynamic> json) {
    return sdataData(
      studentID: json['studentID'],
      studentName: json['studentName'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      classId: json['classId'],
      sectionId: json['sectionId'],
      className: json['className'],
      sectionName: json['sectionName'],
      createDate: json['createDate'],
      session: json['session'],
      action: json['action'],
      schoolId: json['schoolId'],
      fatherPhone: json['fatherPhone'],
      registrationNo: json['registrationNo'],
      pickupPoint: json['pickupPoint'],
      playAmount: json['playAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'studentName': studentName,
      'fatherName': fatherName,
      'motherName': motherName,
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'sectionName': sectionName,
      'createDate': createDate,
      'session': session,
      'action': action,
      'schoolId': schoolId,
      'fatherPhone': fatherPhone,
      'registrationNo': registrationNo,
      'pickupPoint': pickupPoint,
      'playAmount': playAmount,
    };
  }
}