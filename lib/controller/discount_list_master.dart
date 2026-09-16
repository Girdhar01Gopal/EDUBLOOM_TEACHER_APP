import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../models/class_list_model.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/session_model.dart' as session_model;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/FeeDetailsModel.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel (Notes jaisa)
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse (Notes jaisa)

class DiscountListMasterController extends GetxController {
  RxList<FeeDetailsDiscount> discountList = <FeeDetailsDiscount>[].obs;

  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null);
  var session = ''.obs;

  var listDataa = <ClassData>[].obs;
  var selectedClass = Rx<ClassData?>(null);

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rxn<ListDatta>();

  var isLoading = false.obs;

  String token = "";
  String schoolId = "";
  String userId = ""; // ✅ naya

  // 🆕 ROLE / TEACHER-TYPE DETECTION (Notes controller jaisa hi)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  // 🔍 Search ke liye naye variables
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? ""; // ✅ naya

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff" (Notes jaisa)
    final role = ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    await fetchSessions();   // pehle session set hoga

    // 🆕 FIX: Notes jaisa hi — staff ke liye direct classes+sections,
    // teacher ke liye pehle ClassTeacher filter, phir classes+sections.
    if (isStaffLogin.value) {
      await fetchClasses();    // ab session.value available rahega
      await fetchSections();
    } else {
      await fetchClassTeacherFilter();
      await fetchClasses();
      await fetchSections();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Filtered list — name, father name, registration no etc se search karne ke liye
  List<FeeDetailsDiscount> get filteredDiscountList {
    if (searchQuery.value.trim().isEmpty) return discountList;
    final query = searchQuery.value.trim().toLowerCase();
    return discountList.where((s) {
      return (s.studentName ?? '').toLowerCase().contains(query) ||
          (s.fatherName ?? '').toLowerCase().contains(query) ||
          (s.registrationNo ?? '').toLowerCase().contains(query) ||
          (s.className ?? '').toLowerCase().contains(query) ||
          (s.sectionName ?? '').toLowerCase().contains(query) ||
          (s.feeTypeName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> fetchDiscountData() async {
    if (selectedSession.value == null ||
        selectedClass.value == null ||
        selectedSection.value == null) {
      Get.snackbar('Error', 'Please select session, class and section');
      return;
    }

    final String url =
        '${AppUrl.base_url}api/DiscountApp/ViewStudentDiscountApp';

    try {
      isLoading(true);
      discountList.clear();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "schoolId": schoolId,
          "classId": selectedClass.value!.classId,
          "sectionId": selectedSection.value!.sectionId,
          "session": selectedSession.value!.session,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = FeeDetailsDiscountModel.fromJson(decoded);
        discountList.value = model.listData1 ?? [];

        if (discountList.isEmpty) {
          Get.snackbar('Info', 'No data found');
        } else {
          Get.snackbar('Success', 'Data fetched successfully');
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load data. Status Code: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
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
            '?schoolId=$schoolId&Session=${session.value}&userId=$userId',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
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
        isLoading(true);

        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=$schoolId&Session=${session.value}&userId=$userId',
        );

        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
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
      } finally {
        isLoading(false);
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

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = decoded['data'] ?? decoded['listData'] ?? [];

        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      } else {
        Get.snackbar('Error', 'Failed to load sections');
        sectionList.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception loading sections: $e');
      sectionList.value = [];
    } finally {
      isLoading(false);
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
          session.value = cs.session ?? '';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSection(ListDatta? value) {
    selectedSection.value = value;
  }

  void setSelectedSession(session_model.sListDdata? value) {
    selectedSession.value = value;
    session.value = value?.session ?? '';
  }
}