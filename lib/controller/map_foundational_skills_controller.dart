import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/class_list_model.dart';   // 🔄 classmodel.dart ki jagahimport '../models/descriptors_model.dart';
import '../models/foundational_skills_model.dart';
import '../models/map_foundational_skills_model.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/session_model.dart';
import '../models/viewsectionmodel.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse

class MapFoundationalSkillsController extends GetxController {
  String schoolId = "";
  String token = "";
  String session = "";
  String userId = "";


  // =========================
  // DROPDOWNS
  // =========================
  final RxList<ClassData> classList = <ClassData>[].obs;        // 🔄
  final Rx<ClassData?> selectedClass = Rx<ClassData?>(null);     // 🔄

  // ✅ Section dropdown
  final RxList<dynamic> sectionList = <dynamic>[].obs;
  final Rx<dynamic> selectedSection = Rx<dynamic>(null);

  // ✅ Foundational Skills dropdown — from ViewFoundationalSkills API
  final RxList<FoundationalSkillItem> foundationalSkillList =
      <FoundationalSkillItem>[].obs;
  final Rx<FoundationalSkillItem?> selectedSkill =
  Rx<FoundationalSkillItem?>(null);

  // Level text field
  final TextEditingController levelController = TextEditingController();

  // =========================
  // VIEW LIST
  // =========================
  final RxList<FoundationalSkillData> mapFoundationalSkillList =
      <FoundationalSkillData>[].obs;

  // =========================
  // LOADERS
  // =========================
  final RxBool isPageLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isListLoading = false.obs;

  // 🆕 Notes wali logic ke liye alag loading flags
  final RxBool isClassLoading = false.obs;
  final RxBool isSectionLoading = false.obs;

  // 🆕 Class Teacher filter
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var isClassTeacherLogin = false.obs;

  // 🆕 Role / Teacher-type detection (Notes wali hi logic)
  var isStaffLogin = false.obs; // true => "schoolstaff" role

  // =========================
  // URLs
  // =========================
  String get _classUrl =>
      '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=$session&userId=$userId';


  String get _sectionUrl =>
      '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher?schoolId=$schoolId&Session=$session&userId=$userId';

  // 🆕 Class Teacher filter URL
  String get _classTeacherFilterUrl =>
      '${AppUrl.base_url}api/TeacherApp/ClassTeacher?schoolId=$schoolId&Session=$session&userId=$userId';

  // 🆕 SectionTeacher URL (for class teacher login)
  String get _sectionTeacherUrl =>
      '${AppUrl.base_url}api/TeacherApp/SectionTeacher?schoolId=$schoolId&Session=$session&userId=$userId';

  // 🆕 STAFF URLs (Notes wali hi logic)
  String get _classStaffUrl =>
      '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';

  String get _sectionStaffUrl =>
      '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

  // ✅ Same pattern as FoundationalSkillsController — needs session
  String get _foundationalSkillsUrl =>
      '${AppUrl.base_url}api/Result/ViewFoundationalSkills/$schoolId/$session';

  // ✅ NEW view API with session
  String get _viewUrl =>
      '${AppUrl.base_url}api/Result/GetFoundationalSkillsAsync/$schoolId/$session';

  // ✅ NEW post API
  String get _postUrl =>
      '${AppUrl.base_url}api/Result/PostMapFoundationalSkills';

  Map<String, String> get _headers => {
    "Accept": "application/json",
    "Content-Type": "application/json",
    if (token.trim().isNotEmpty) "Authorization": "Bearer $token",
  };

  // =========================
  // SAFE DECODE
  // =========================
  dynamic _safeDecodeResponse(http.Response res, {required String label}) {
    final String ct = (res.headers['content-type'] ?? '').toLowerCase();
    final String body = res.body;
    final String preview =
    body.substring(0, body.length > 300 ? 300 : body.length);

    debugPrint("[$label] URL: ${res.request?.url}");
    debugPrint("[$label] STATUS: ${res.statusCode}");
    debugPrint("[$label] BODY(300): $preview");

    if (preview.toLowerCase().contains("<!doctype html") ||
        ct.contains("text/html")) {
      throw Exception("[$label] Server returned HTML instead of JSON");
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("[$label] HTTP ${res.statusCode} - ${res.body}");
    }

    if (body.trim().isEmpty) return null;

    return jsonDecode(body);
  }

  void _showSnack(
      String title,
      String message, {
        Color? backgroundColor,
        Color? colorText,
      }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? Colors.red.shade100,
      colorText: colorText ?? Colors.black,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  // =========================
  // INIT
  // =========================
  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? "";   // ✅ naya

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    if (schoolId.trim().isEmpty) {
      _showSnack("Error", "SchoolId not found");
      return;
    }

    await loadInitialData();
  }

  @override
  void onClose() {
    levelController.dispose();
    super.onClose();
  }

  // =========================
  // SESSION FETCH
  // =========================
  Future<void> _fetchCurrentSession() async {
    try {
      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.view_session}$schoolId',
      );
      final res = await http.get(url, headers: _headers);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final sessionModel = SessionModel.fromJson(decoded);
        session =
            sessionModel.currentSession?.session?.toString().trim() ?? "";
        debugPrint("Current Session: $session");
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    }
  }

  // =========================
  // LOAD ALL
  // ✅ Session pehle — URLs mein session chahiye
  // =========================
  Future<void> loadInitialData() async {
    try {
      isPageLoading(true);

      // ✅ Session pehle fetch karo
      await _fetchCurrentSession();

      // 🆕 Notes jaisa hi flow — pehle ClassTeacher filter (agar teacher hai)
      if (!isStaffLogin.value) {
        await fetchClassTeacherFilter(); // 🆕 pehle — flag set ho jaye
      }

      // ✅ Baaki parallel
      await Future.wait([
        fetchClasses(),
        fetchSections(),
        fetchFoundationalSkillsDropdown(),
        fetchMapFoundationalSkills(),
      ]);
    } catch (e) {
      _showSnack("Error", e.toString());
    } finally {
      isPageLoading(false);
    }
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo
  Future<void> fetchClassTeacherFilter() async {
    try {
      if (userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final res =
      await http.get(Uri.parse(_classTeacherFilterUrl), headers: _headers);

      debugPrint('ClassTeacher status: ${res.statusCode}');
      debugPrint('ClassTeacher body: ${res.body}');

      if (res.statusCode == 200) {
        final jsonResponse = json.decode(res.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  // =========================
  // CLASS API (3-way)
  // 1️⃣ STAFF -> ViewClass API | 2️⃣ CLASS TEACHER -> ClassTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetClassTeacher API | fallback -> staff API
  // =========================
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchClassesStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
        classList.value = classTeacherList.map((e) {
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
        classList.value = [];
      }
      selectedClass.value = null;

      if (classList.isEmpty) {
        debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
        await _fetchClassesStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — existing
    try {
      final res = await http.get(Uri.parse(_classUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Classes");
      final ClassListModel parsed = ClassListModel.fromJson(decoded);
      // GetClassTeacher me action null aata hai, isliye filter nahi lagayenge
      classList.assignAll(parsed.listData);
      selectedClass.value = null;
    } catch (e) {
      Get.snackbar("Error", "Class fetch error: $e");
      classList.value = [];
    }

    if (classList.isEmpty) {
      debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
      await _fetchClassesStaffApi();
    }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isClassLoading(true);
      final res = await http.get(Uri.parse(_classStaffUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "ClassesStaff");

      final List<dynamic> rawList =
      (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];

      classList.value = rawList
          .map((e) => ClassData.fromJson(e))
          .where((e) => e.action == "1")
          .toList();
      selectedClass.value = null;
    } catch (e) {
      Get.snackbar("Error", "Class fetch error (staff): $e");
    } finally {
      isClassLoading(false);
    }
  }

  // =========================
  // SECTION API (3-way)
  // 1️⃣ STAFF -> ViewSectionApp API | 2️⃣ CLASS TEACHER -> SectionTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetSectionTeacher API | fallback -> staff API
  // =========================
  Future<void> fetchSections() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchSectionsStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — SectionTeacher API
    if (isClassTeacherLogin.value) {
      try {
        final res =
        await http.get(Uri.parse(_sectionTeacherUrl), headers: _headers);
        final decoded = _safeDecodeResponse(res, label: "SectionTeacher");
        if (decoded == null) {
          sectionList.clear();
          if (sectionList.isEmpty) {
            debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
            await _fetchSectionsStaffApi();
          }
          return;
        }
        final model = SectionForAttendanceModel.fromJson(decoded);
        sectionList.assignAll(
          (model.data ?? []).map((e) {
            return stListData.fromJson({
              'sectionId': e.sectionId,
              'section': e.section,
              'action': e.action,
              'createDate': e.createDate,
              'updateDate': e.updateDate,
              'createBy': e.createBy,
              'updateBy': e.updateBy,
              'schoolId': e.schoolId,
            });
          }).toList(),
        );
        selectedSection.value = null;
      } catch (e) {
        sectionList.clear();
        selectedSection.value = null;
        _showSnack("Error", "Section fetch error: $e");
      }

      if (sectionList.isEmpty) {
        debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
        await _fetchSectionsStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — existing
    try {
      final res = await http.get(Uri.parse(_sectionUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Sections");
      if (decoded == null || decoded is! Map<String, dynamic>) {
        sectionList.clear();
      } else {
        final sectionModelData = sectionmodel.fromJson(decoded);
        sectionList.assignAll(
          (sectionModelData.listData ?? [])
              .where((e) => (e.action ?? "1") == "1")
              .toList(),
        );
        selectedSection.value = null;
      }
    } catch (e) {
      sectionList.clear();
      selectedSection.value = null;
      _showSnack("Error", "Section fetch error: $e");
    }

    if (sectionList.isEmpty) {
      debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
      await _fetchSectionsStaffApi();
    }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isSectionLoading(true);
      final res =
      await http.get(Uri.parse(_sectionStaffUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "SectionsStaff");

      final List<dynamic> rawList =
      (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];

      sectionList.assignAll(
        rawList.map((e) => stListData.fromJson(e)).toList(),
      );
      selectedSection.value = null;
    } catch (e) {
      _showSnack("Error", "Section fetch error (staff): $e");
    } finally {
      isSectionLoading(false);
    }
  }

  // =========================
  // FOUNDATIONAL SKILLS DROPDOWN
  // ✅ ViewFoundationalSkills — same as FoundationalSkillsController
  // =========================
  Future<void> fetchFoundationalSkillsDropdown() async {
    try {
      final res =
      await http.get(Uri.parse(_foundationalSkillsUrl), headers: _headers);
      final decoded =
      _safeDecodeResponse(res, label: "FoundationalSkillsDropdown");
      if (decoded == null || decoded is! Map<String, dynamic>) {
        foundationalSkillList.clear();
        selectedSkill.value = null;
        return;
      }
      final FoundationalSkillsResponse parsed =
      FoundationalSkillsResponse.fromJson(decoded);
      foundationalSkillList.assignAll(
        parsed.listData.where((e) => e.action.trim() == "1").toList(),
      );
      selectedSkill.value = null;
    } catch (e) {
      foundationalSkillList.clear();
      selectedSkill.value = null;
      _showSnack("Error", "Foundational skill fetch error: $e");
    }
  }

  // =========================
  // VIEW API — GetFoundationalSkillsAsync
  // =========================
  Future<void> fetchMapFoundationalSkills() async {
    try {
      isListLoading(true);

      if (session.trim().isEmpty) await _fetchCurrentSession();

      final res = await http.get(Uri.parse(_viewUrl), headers: _headers);
      final decoded =
      _safeDecodeResponse(res, label: "MapFoundationalSkillsView");

      if (decoded == null) {
        mapFoundationalSkillList.clear();
        return;
      }

      final MapFoundationalSkillsResponse parsed =
      MapFoundationalSkillsResponse.fromJson(decoded);

      if (parsed.isSuccess == true) {
        mapFoundationalSkillList.assignAll(
          parsed.data.where((e) => (e.action ?? "").trim() == "1").toList(),
        );
      } else {
        mapFoundationalSkillList.clear();
        _showSnack("Error", parsed.messages?.toString() ?? "Unable to load data");
      }
    } catch (e) {
      mapFoundationalSkillList.clear();
      _showSnack("Error", "List fetch error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // =========================
  // DUPLICATE CHECK
  // =========================
  bool get isDuplicateSelection {
    final c = selectedClass.value;
    final s = selectedSkill.value;
    final sec = selectedSection.value;
    final level = levelController.text.trim().toLowerCase();

    if (c == null || s == null || sec == null) return false;

    return mapFoundationalSkillList.any(
          (x) =>
      (x.classId ?? 0) == (c.classId ?? 0) &&
          x.sectionId == (sec.sectionId as int?) &&
          (x.foundationalSkills ?? "").trim().toLowerCase() ==
              s.foundationalSkills.trim().toLowerCase() &&
          (x.level ?? "").trim().toLowerCase() == level,
    );
  }

  // =========================
  // SAVE — POST API
  // ✅ Body includes sectionId, section, session
  // =========================
  Future<void> saveMapFoundationalSkill() async {
    if (selectedClass.value == null) {
      _showSnack("Validation", "Select Class",
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (selectedSection.value == null) {
      _showSnack("Validation", "Select Section",
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (selectedSkill.value == null) {
      _showSnack("Validation", "Select Foundational Skill",
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (levelController.text.trim().isEmpty) {
      _showSnack("Validation", "Enter Level",
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (isDuplicateSelection) {
      _showSnack("Warning",
          "This class, section, foundational skill and level is already mapped",
          backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isSaving(true);

      final Map<String, dynamic> body = {
        "id": 0,
        "classId": selectedClass.value?.classId ?? 0,
        "className": selectedClass.value?.className ?? "",
        "sectionId": selectedSection.value?.sectionId ?? 0,
        "section": (selectedSection.value?.section ?? "").toString(),
        "foundationalSkills": selectedSkill.value?.foundationalSkills ?? "",
        "action": "1",
        "createDate": DateTime.now().toUtc().toIso8601String(),
        "updateDate": DateTime.now().toUtc().toIso8601String(),
        "createBy": "admin",
        "updateBy": "admin",
        "schoolId": schoolId,
        "level": levelController.text.trim(),
        "session": session,
      };

      debugPrint("POST URL => $_postUrl");
      debugPrint("POST BODY => ${jsonEncode(body)}");

      final res = await http.post(
        Uri.parse(_postUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      final decoded =
      _safeDecodeResponse(res, label: "PostMapFoundationalSkills");

      if (decoded is Map<String, dynamic>) {
        final bool isSuccess = decoded["isSuccess"] == true;
        final String message =
            decoded["messages"]?.toString() ?? "Saved successfully";

        if (isSuccess) {
          _showSnack("Success", message,
              backgroundColor: Colors.green, colorText: Colors.white);
          clearForm();
          await fetchMapFoundationalSkills();
        } else {
          _showSnack("Error", message);
        }
      } else {
        _showSnack("Success", "Saved successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        clearForm();
        await fetchMapFoundationalSkills();
      }
    } catch (e) {
      _showSnack("Error", "Save failed: $e");
    } finally {
      isSaving(false);
    }
  }

  // =========================
  // HELPERS
  // =========================
  Future<void> refreshViewList() async {
    await _fetchCurrentSession();
    await fetchMapFoundationalSkills();
  }

  void clearForm() {
    selectedClass.value = null;
    selectedSection.value = null;
    selectedSkill.value = null;
    levelController.clear();
  }
}