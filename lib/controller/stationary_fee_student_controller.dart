import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../models/session_model.dart' as session_model; // ✅ fixed: relative import

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
// ❌ removed: import '../models/session_model.dart';  -> this caused duplicate import / type-mismatch
import '../models/stationary_student_fee_list.dart';
import '../res/app_url.dart';

class StationaryFeeStudentController extends GetxController {
  RxList<StudentListData> studentList = <StudentListData>[].obs;

  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs; // ✅ fixed type
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null); // ✅ fixed type
  var session = ''.obs;

  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rx<ListDatta?>(null);

  var isLoading = false.obs;

  String token = "";
  String schoolId = "";

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    await initData();
  }

  Future<void> initData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchClasses(),
        fetchSections(),
        fetchSessions(),
      ]);
    } catch (e) {
      Get.snackbar("Error", "Failed to initialize data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedClass(ListDataa? value) {
    selectedClass.value = value;
  }

  void setSelectedSection(ListDatta? value) {
    selectedSection.value = value;
  }

  void setSelectedSession(session_model.sListDdata? value) {
    selectedSession.value = value;
    session.value = value?.session ?? '';
  }

  Future<void> fetchStudentData() async {
    if (selectedSession.value == null ||
        selectedClass.value == null ||
        selectedSection.value == null) {
      Get.snackbar(
        'Error',
        'Please select session, class and section.',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final String url =
        'https://playschool.edubloom.in/api/FeePaymentApp/ViewFeeStudentApp';

    try {
      isLoading.value = true;
      studentList.clear();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "session": selectedSession.value?.session ?? '',
          "schoolId": schoolId,
          "classId": selectedClass.value?.classId ?? 0,
          "sectionId": selectedSection.value?.sectionId ?? 0,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final model = StationaryFeeStudentList.fromJson(data);
        studentList.assignAll(model.listData ?? []);

        if (studentList.isEmpty) {
          Get.snackbar(
            "Info",
            "No data found",
            backgroundColor: Colors.orange.shade100,
          );
        }
      } else {
        studentList.clear();
        Get.snackbar(
          "Error",
          "Failed to load student list. Status: ${response.statusCode}",
          backgroundColor: Colors.red.shade100,
        );
      }
    } catch (e) {
      studentList.clear();
      Get.snackbar(
        "Error",
        "Error fetching student data: $e",
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSections() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data =
        (decoded['listData'] ?? decoded['data'] ?? []) as List<dynamic>;

        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load sections: $e");
    }
  }

  Future<void> fetchClasses() async {
    try {
      final response = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(response.body));
        listDataa.value =
            parsed.listData?.where((e) => e.action == "1").toList() ??
                <ListDataa>[];
        selectedClass.value = null;
      }
    } catch (e) {
      Get.snackbar("Error", "Error fetching classes: $e");
    }
  }

  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final current = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );

          sessionList.add(current);
          selectedSession.value = current;
          session.value = current.session ?? '';
        } else if (jsonData['listData'] != null) {
          final List<dynamic> data = jsonData['listData'] as List<dynamic>;
          sessionList.value =
              data.map((e) => session_model.sListDdata.fromJson(e)).toList();

          if (sessionList.isNotEmpty) {
            selectedSession.value = sessionList.first;
            session.value = sessionList.first.session ?? '';
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load sessions: $e");
    }
  }
}