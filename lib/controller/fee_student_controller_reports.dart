import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/pre school student teach stu filter api model.dart';
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
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse (Notes wali logic)

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

  // 🆕 Notes wali logic ke liye alag loading flags (taaki class/section dropdown
  // ka spinner ek dusre ko disturb na kare)
  var isClassLoading = false.obs;
  var isSectionLoading = false.obs;

  String token = "";
  String schoolId = "";
  String userId = ""; // ✅ naya

  // 🆕 Role / Teacher-type detection (Notes wali hi logic)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  get grandTotal => null;

  @override
  void onInit() async {
    // TODO: implement onInit
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? ""; // ✅ naya

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    await fetchSessions();   // pehle session set hoga

    // 🆕 Notes jaisa hi 3-way flow
    if (isStaffLogin.value) {
      // 🟢 STAFF — direct staff APIs, parallel-safe
      await Future.wait([
        fetchClasses(),
        fetchSections(),
      ]);
    } else {
      // 🟡 TEACHER — pehle ClassTeacher filter check, phir uske hisaab se class/section
      await fetchClassTeacherFilter();
      await Future.wait([
        fetchClasses(),
        fetchSections(),
      ]);
    }
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

  // 🆕 Logged-in teacher ke assigned classes fetch karo (Notes wali hi logic)
  Future<void> fetchClassTeacherFilter() async {
    try {
      if (userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session.value)}'
            '&userId=${Uri.encodeComponent(userId)}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('ClassTeacher status: ${response.statusCode}');
      debugPrint('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  /// ---------------------- FETCH CLASSES (3-way) ----------------------
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
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        listDataa.value = [];
      }

      if (listDataa.isEmpty) {
        debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
        await _fetchClassesStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    if (session.value.isEmpty) {
      // session abhi tak select/available nahi hai
      Get.snackbar('Error', 'Session not found');
      return;
    }

    final String url =
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=${session.value}&userId=$userId';

    try {
      isLoading(true);
      isClassLoading(true);

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
        listDataa.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Error fetching classes: $e');
      listDataa.value = [];
    } finally {
      isLoading(false);
      isClassLoading(false);
    }

    if (listDataa.isEmpty) {
      debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
      await _fetchClassesStaffApi();
    }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);
      isClassLoading(true);
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      debugPrint('ViewClass (staff) status: ${response.statusCode}');
      debugPrint('ViewClass (staff) body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> rawList = decoded['listData'] ?? [];

        listDataa.value = rawList
            .map((e) => ClassData.fromJson(e))
            .where((e) => e.action == "1")
            .toList();

        selectedClass.value = null;
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching classes (staff): $e");
    } finally {
      isLoading(false);
      isClassLoading(false);
    }
  }

  void setSelectedClass(ClassData? value) {   // 🔄 type change
    selectedClass.value = value;
  }

  /// ---------------------- FETCH SECTIONS (3-way) ----------------------
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
        isLoading(true);
        isSectionLoading(true);

        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=${Uri.encodeComponent(schoolId)}'
              '&Session=${Uri.encodeComponent(session.value)}'
              '&userId=${Uri.encodeComponent(userId)}',
        );

        final response = await http.get(
          url,
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        );

        debugPrint('SectionTeacher status: ${response.statusCode}');
        debugPrint('SectionTeacher body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
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
      } finally {
        isLoading(false);
        isSectionLoading(false);
      }

      if (sectionList.isEmpty) {
        debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
        await _fetchSectionsStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetSectionTeacher API
    final String url =
        '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher?schoolId=$schoolId&Session=${session.value}&userId=$userId';

    try {
      isLoading(true);
      isSectionLoading(true);

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
        sectionList.value = [];
      }
    } catch (e) {
      print("⚠️ Exception loading sections: $e");
      sectionList.value = [];
    } finally {
      isLoading(false);
      isSectionLoading(false);
    }

    if (sectionList.isEmpty) {
      debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
      await _fetchSectionsStaffApi();
    }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);
      isSectionLoading(true);
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      debugPrint('ViewSectionApp (staff) status: ${response.statusCode}');
      debugPrint('ViewSectionApp (staff) body: ${response.body}');

      if (response.statusCode == 200) {
        sectionList.value = (jsonDecode(response.body)['listData'] as List)
            .map((e) => ListDatta.fromJson(e))
            .toList();

        selectedSection.value = null;
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
    } finally {
      isLoading(false);
      isSectionLoading(false);
    }
  }

  // Method to set selected section
  void setSelectedSection(ListDatta? section) {
    selectedSection.value = section;
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