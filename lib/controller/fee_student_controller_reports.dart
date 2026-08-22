import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/session_model.dart' as session_model; // ✅ fixed: relative import, only one import of this file

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import 'package:http/http.dart' as http;

import '../models/class_list_model.dart';
import '../models/fee_student_model_reports.dart';
import '../models/sectionmodel.dart';
// ❌ removed: import '../models/session_model.dart';  -> this caused the type-mismatch errors
import '../models/student_fee_model.dart';
import '../res/app_url.dart';

class FeeStudentReportsController extends GetxController {
  RxList<Student> studentList = <Student>[].obs; // List of student

  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs; // ✅ fixed type

  // Rx object for currently selected session
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null); // ✅ fixed type

  // String to store session name (optional)
  var session = ''.obs;
  var listDataa = <ClassData>[].obs;
  var selectedClass = Rx<ClassData?>(null);

  var section = 0;
  var studentClass = ''.obs;

  var sectionList = <ListDatta>[].obs; // Observable list for dropdown
  var selectedSection = Rxn<ListDatta>(); // To store the selected section
  var isLoading = true.obs; // Loading state
  var isloading = false.obs; // Loading state

  String token = "";
  String schoolId = "";
  String userId = ""; // ✅ naya

  get grandTotal => null;
  @override
  void onInit() async {
    // TODO: implement onInit
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? ""; // ✅ naya


    await fetchSessions();   // pehle session set hoga
    await fetchClasses();    // ab session.value available rahega
    await fetchSections();
  }
  // Method to fetch student data based on session, class, and section
  Future<void> fetchStudentData() async {
    if (selectedSession.value == null || selectedClass.value == null || selectedSection.value == null) {
      Get.snackbar('Error', 'Please select session, class, and section.');
      return;
    }

    final String url = '${AppUrl.base_url}api/ReportApp/ViewStudentListApp';

    try {
      isLoading(true);

      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode({
          'session': selectedSession.value!.session,
          'schoolId': schoolId,
          'classId': selectedClass.value!.classId,
          'sectionId': selectedSection.value!.sectionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        studentList.value = StudentList.fromJson(data).listData; // Populate the student list
      } else {
        print("Failed to load student data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching student data: $e");
    } finally {
      isLoading(false);
    }
  }

  // fetch sections
  Future<void> fetchSections() async {
    final String url =
        '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher?schoolId=$schoolId&Session=${session.value}&userId=$userId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> data = decoded['data'] ?? decoded['listData'] ?? [];

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
    if (session.value.isEmpty) {
      // session abhi tak select/available nahi hai
      Get.snackbar('Error', 'Session not found');
      return;
    }

    final String url =
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=${session.value}&userId=$userId';

    try {
      isLoading(true);

      final res = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final parsed = ClassListModel.fromJson(jsonDecode(res.body));

        // GetClassTeacher me action null aata hai, isliye filter nahi lagayenge
        listDataa.value = parsed.listData;

        selectedClass.value = null;
      } else {
        Get.snackbar('Error', 'Failed to load classes');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching classes: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ClassData? value) {   // 🔄 type change
    selectedClass.value = value;
  }

  Future<void> fetchSessions() async {
    final String apiUrl = '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

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
          session.value = cs.session ?? ''; // Ye line ensure karegi ki session default select ho
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
}