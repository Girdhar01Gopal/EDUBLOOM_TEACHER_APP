import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:teacher_app_edubloom/models/session_model.dart' as session_model;
import 'package:teacher_app_edubloom/models/transfer_certificate1_model.dart'
as tc_model;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/class_list_model.dart';
import '../models/classmodel.dart'; // ✅ now contains ClassListModel / ClassData (GetClassTeacher)
import '../models/pre school student teach stu filter api model.dart';
import '../models/sectionmodel.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel (Notes jaisa)
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse (Notes jaisa)

class TransferCertificateReportsController extends GetxController {
  final RxList<tc_model.TCStudentData> studentList =
      <tc_model.TCStudentData>[].obs;

  final RxString searchQuery = ''.obs;

  List<tc_model.TCStudentData> get filteredStudentList {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return studentList;
    return studentList.where((s) {
      return (s.studentName ?? '').toLowerCase().contains(q) ||
          (s.registrationNo ?? '').toLowerCase().contains(q) ||
          (s.fatherName ?? '').toLowerCase().contains(q) ||
          (s.motherName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  final RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  final Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);
  final RxString session = ''.obs;

  final RxList<ClassData> listDataa = <ClassData>[].obs; // ✅ now ClassData instead of ListDataa
  final Rx<ClassData?> selectedClass = Rx<ClassData?>(null); // ✅ type updated

  int section = 0;
  final RxList<ListDatta> sectionList = <ListDatta>[].obs;
  final Rxn<ListDatta> selectedSection = Rxn<ListDatta>();

  final RxBool isLoading = false.obs;

  String token = "";
  String schoolId = "";

  // ✅ added for GetClassTeacher API — adjust PrefConst keys if names differ
  String classSession = '';
  String userId = '';

  // 🆕 ROLE / TEACHER-TYPE DETECTION (Notes controller jaisa hi)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    classSession = await PrefManager().readValue(key: PrefConst.session) ?? ''; // ✅ adjust key if needed
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? ''; // ✅ adjust key if needed

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff" (Notes jaisa)
    final role = ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    // 🆕 FIX: Notes jaisa hi — staff ke liye direct class+section,
    // teacher ke liye pehle ClassTeacher filter, phir class+section.
    if (isStaffLogin.value) {
      await Future.wait([
        fetchSessions(),
        fetchClasses(),
        fetchSections(),
      ]);
    } else {
      await fetchClassTeacherFilter();
      await Future.wait([
        fetchSessions(),
        fetchClasses(),
        fetchSections(),
      ]);
    }
  }

  Future<void> fetchStudentData() async {
    if (selectedSession.value == null) {
      Get.snackbar('Error', 'Please select a session.');
      return;
    }
    if (selectedClass.value == null) {
      Get.snackbar('Error', 'Please select a class.');
      return;
    }
    if (selectedSection.value == null) {
      Get.snackbar('Error', 'Please select a section.');
      return;
    }

    final String url =
        '${AppUrl.base_url}api/FeePaymentApp/ViewFeeStudentApp';

    try {
      isLoading(true);
      studentList.clear();
      searchQuery.value = '';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session': selectedSession.value!.session,
          'schoolId': schoolId,
          'classId': selectedClass.value!.classId,
          'sectionId': selectedSection.value!.sectionId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final parsed = tc_model.TCTransferCertificateModel.fromJson(data);
        studentList.value = parsed.listData ?? [];
      } else {
        Get.snackbar(
            'Error', 'Failed to load data. Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSessions() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        sessionList.clear();
        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
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
            '?schoolId=$schoolId&Session=$classSession&userId=$userId',
      );

      final response = await http.get(url);

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
    final String url =
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=$classSession&userId=$userId';
    try {
      isLoading(true);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final parsed = ClassListModel.fromJson(jsonDecode(res.body));
        // ⚠️ GetClassTeacher sends "action": null for most rows, so the
        // old ".where((e) => e.action == '1')" filter would empty the list.
        listDataa.value = parsed.listData;
        selectedClass.value = null;
      } else {
        listDataa.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load classes: $e');
      listDataa.value = [];
    } finally {
      isLoading(false);
    }

    // if (listDataa.isEmpty) {
    //   debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
    //   await _fetchClassesStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);
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
    } finally {
      isLoading(false);
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
        isLoading(true);

        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=$schoolId&Session=$classSession&userId=$userId',
        );

        final response = await http.get(url);

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
      } finally {
        isLoading(false);
      }

      // if (sectionList.isEmpty) {
      //   debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
      //   await _fetchSectionsStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetSectionTeacher API
    final String url =
        '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher?schoolId=$schoolId&Session=$classSession&userId=$userId';
    try {
      isLoading(true);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        // ⚠️ naya API "data" key me list bhejta hai (purana "listData" tha)
        final List<dynamic> data =
            decoded['data'] ?? decoded['listData'] ?? [];
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sections: $e');
      sectionList.value = [];
    } finally {
      isLoading(false);
    }

    // if (sectionList.isEmpty) {
    //   debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
    //   await _fetchSectionsStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);
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
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ClassData? val) => selectedClass.value = val; // ✅ type updated
  void setSelectedSection(ListDatta? val) => selectedSection.value = val;
  void setSelectedSession(session_model.sListDdata val) =>
      selectedSession.value = val;
}