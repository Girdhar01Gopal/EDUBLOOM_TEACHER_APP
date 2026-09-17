import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../models/pre school student teach stu filter api model.dart';
import '../models/session_model.dart' as session_model; // ✅ fixed: relative import

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/class_list_model.dart';   // 🔄 classmodel.dart ki jagah
import '../models/sectionmodel.dart';
// ❌ removed: import '../models/session_model.dart';  -> this caused duplicate import / type-mismatch
import '../models/stationary_student_fee_list.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel (Notes jaisa)
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse (Notes jaisa)

class StationaryFeeStudentController extends GetxController {
  RxList<StudentListData> studentList = <StudentListData>[].obs;

  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs; // ✅ fixed type
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null); // ✅ fixed type
  var session = ''.obs;

  var listDataa = <ClassData>[].obs;              // 🔄
  var selectedClass = Rx<ClassData?>(null);        // 🔄

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rx<ListDatta?>(null);

  var isLoading = false.obs;

  String token = "";
  String schoolId = "";
  String userId = "";   // ✅ naya

  // 🆕 ROLE / TEACHER-TYPE DETECTION (Notes controller jaisa hi)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? "";   // ✅ naya

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff" (Notes jaisa)
    final role = ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    await initData();
  }

  Future<void> initData() async {
    isLoading.value = true;
    try {
      await fetchSessions();   // 🔄 pehle session fetch, taaki GetClassTeacher ko session mile

      // 🆕 FIX: Notes jaisa hi — staff ke liye direct class+section,
      // teacher ke liye pehle ClassTeacher filter, phir class+section.
      if (isStaffLogin.value) {
        await Future.wait([
          fetchClasses(),
          fetchSections(),
        ]);
      } else {
        await fetchClassTeacherFilter();
        await Future.wait([
          fetchClasses(),
          fetchSections(),
        ]);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to initialize data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void setSelectedClass(ClassData? value) {   // 🔄 type change
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

  // 🆕 Logged-in teacher ke assigned classes fetch karo (Notes jaisa hi)
  Future<void> fetchClassTeacherFilter() async {
    try {
      if (userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=$schoolId&Session=${session.value}&userId=$userId',
      );

      final response = await http.get(
        url,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      debugPrint('ClassTeacher status: ${response.statusCode}');
      debugPrint('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = ClassTeacherFilterModel.fromJson(decoded);

        classTeacherList.value = model.data ?? [];
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  // =========================
  // SECTIONS (3-way, Notes jaisa hi)
  // =========================
  // 1️⃣ STAFF -> ViewSectionApp API | 2️⃣ CLASS TEACHER -> SectionTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetSectionTeacher API | fallback -> staff API
  Future<void> fetchSections() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchSectionsStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — SectionTeacher API
    if (isClassTeacherLogin.value) {
      try {
        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=$schoolId&Session=${session.value}&userId=$userId',
        );

        final response = await http.get(
          url,
          headers: {
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        );

        debugPrint('SectionTeacher status: ${response.statusCode}');
        debugPrint('SectionTeacher body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final model = SectionForAttendanceModel.fromJson(decoded);

          sectionList.value = (model.data ?? []).map((e) {
            return ListDatta.fromJson({
              'sectionId': e.sectionId,
              'section': e.section,
              'action': e.action,
              'createDate': e.createDate,
              'updateDate': e.updateDate,
              'createBy': e.createBy,
              'updateBy': e.updateBy,
              'schoolId': e.schoolId,
            });
          }).toList();

          selectedSection.value = null;
        } else {
          sectionList.value = [];
        }
      } catch (e) {
        debugPrint("⚠️ Error fetching SectionTeacher sections: $e");
        sectionList.value = [];
      }

      // if (sectionList.isEmpty) {
      //   debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
      //   await _fetchSectionsStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetSectionTeacher API
    if (session.value.isEmpty) {
      print("Session not found, skipping fetchSections");
      return;
    }

    final String url =
        '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher?schoolId=$schoolId&Session=${session.value}&userId=$userId';

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
        (decoded['data'] ?? decoded['listData'] ?? []) as List<dynamic>;

        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load sections: $e");
      sectionList.value = [];
    }

    // if (sectionList.isEmpty) {
    //   debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
    //   await _fetchSectionsStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];

        sectionList.value =
            (list as List).map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
    }
  }

  // =========================
  // CLASSES (3-way, Notes jaisa hi)
  // =========================
  // 1️⃣ STAFF -> ViewClass API | 2️⃣ CLASS TEACHER -> ClassTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetClassTeacher API | fallback -> staff API
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchClassesStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
        listDataa.value = classTeacherList.map((e) {
          return ClassData.fromJson({
            'classId': e.classId,
            'class': e.className,
            'className': e.className,
            'studentClassId': e.studentClassId,
            'action': e.action,
            'createDate': e.createDate,
            'updateDate': e.updateDate,
            'createBy': e.createBy,
            'updateBy': e.updateBy,
            'schoolId': e.schoolId,
            'sqno': e.sqno,
          });
        }).toList();

        selectedClass.value = null;
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        listDataa.value = [];
      }

      // if (listDataa.isEmpty) {
      //   debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
      //   await _fetchClassesStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    if (session.value.isEmpty) {
      print("Session not found, skipping fetchClasses");
      return;
    }

    try {
      final String url =
          '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=${session.value}&userId=$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final parsed = ClassListModel.fromJson(jsonDecode(response.body));
        // GetClassTeacher me action null aata hai, isliye filter nahi lagayenge
        listDataa.value = parsed.listData;
        selectedClass.value = null;
      } else {
        listDataa.value = [];
      }
    } catch (e) {
      Get.snackbar("Error", "Error fetching classes: $e");
      listDataa.value = [];
    }

    // if (listDataa.isEmpty) {
    //   debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
    //   await _fetchClassesStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final list =
        (jsonResponse is Map<String, dynamic>) ? (jsonResponse['listData'] ?? []) : [];

        listDataa.value =
            (list as List).map((e) => ClassData.fromJson(e)).toList();
        selectedClass.value = null;
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching classes (staff): $e");
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