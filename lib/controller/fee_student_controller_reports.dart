import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/session_model.dart' as session_model; // ✅ fixed: relative import, only one import of this file

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import 'package:http/http.dart' as http;

import '../models/classmodel.dart';
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

  get grandTotal => null;
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
    final String url = '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

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
        listDataa.value = parsed.listData
            ?.where((e) => e.action == "1")
            .toList() ?? [];

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