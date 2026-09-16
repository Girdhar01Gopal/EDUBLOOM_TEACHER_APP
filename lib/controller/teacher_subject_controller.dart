import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/teacher list model.dart';
import '../models/session_model.dart' as session_model;
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart'; // must contain ListDaataa
import '../models/teachersubjectmodel.dart'; // TeacherSubjectModel, TeacherSubjectItem
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse

class TeacherSubjectController extends GetxController {
  String schoolId = "";
  String token = "";
  String userId = ""; // 🆕 naya

  // =========================
  // SESSION
  // =========================
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // =========================
  // DROPDOWNS
  // =========================
  final teacherList = <TeacherModel>[].obs;
  final selectedTeacher = Rx<TeacherModel?>(null);

  final classList = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final sectionList = <ListDatta>[].obs;
  final selectedSection = Rx<ListDatta?>(null);

  final subjectList = <ListDaataa>[].obs;
  final selectedSubject = Rx<ListDaataa?>(null);

  // =========================
  // VIEW LIST
  // =========================
  final teacherSubjectList = <TeacherSubjectItem>[].obs;

  // loaders
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isListLoading = false.obs;

  // 🆕 Notes wali logic ke liye alag loading flags
  final isClassLoading = false.obs;
  final isSectionLoading = false.obs;
  final isSubjectLoading = false.obs;

  // 🆕 Class Teacher filter
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var isClassTeacherLogin = false.obs;

  // 🆕 Role / Teacher-type detection (Notes wali hi logic)
  var isStaffLogin = false.obs; // true => "schoolstaff" role

  // =========================
  // URLs
  // =========================
  String get _sessionUrl => '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

  // 🆕 STAFF URLs (Notes wali hi logic)
  String get _classStaffUrl => '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
  String get _sectionStaffUrl => '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';
  String get _subjectStaffUrl => '${AppUrl.base_url}api/MasterApp/ViewSubjectApp/$schoolId';

  // 🆕 NORMAL TEACHER URLs
  String get _classTeacherUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
        '?schoolId=$schoolId&Session=${Uri.encodeComponent(session)}&userId=$userId';
  }

  String get _sectionGetTeacherUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher'
        '?schoolId=$schoolId&Session=${Uri.encodeComponent(session)}&userId=$userId';
  }

  String get _subjectTeacherUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}${AppUrl.get_subject_teacher}'
        '?schoolId=$schoolId&Session=${Uri.encodeComponent(session)}&userId=$userId';
  }

  // 🆕 Class Teacher filter URL
  String get _classTeacherFilterUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
        '?schoolId=$schoolId&Session=${Uri.encodeComponent(session)}&userId=$userId';
  }

  // 🆕 SectionTeacher URL (for class teacher login)
  String get _sectionTeacherUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
        '?schoolId=$schoolId&Session=${Uri.encodeComponent(session)}&userId=$userId';
  }

  String get _teacherUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}api/TeacherApp/GetAllTeachersAsyncApp'
        '?schoolId=$schoolId&currentSession=${Uri.encodeComponent(session)}';
  }

  // ✅ SAVE endpoint (your existing)
  String get _saveUrl => '${AppUrl.base_url}api/TeacherApp/PostTeacherSubjectAssign';

  // ✅ LIST endpoint (FIXED: remove the stray `}`)
  // This controller assumes the list API expects POST body: {schoolId, session}
  String get _listUrl => '${AppUrl.base_url}api/TeacherApp/ViewTeacherSubjectAssignApp';

  Map<String, String> get _headers {
    final h = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    if (token.trim().isNotEmpty) h["Authorization"] = "Bearer $token";
    return h;
  }

  // =========================
  // SAFE JSON DECODER
  // =========================
  dynamic _safeDecodeResponse(http.Response res, {required String label}) {
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    final body = res.body;

    final preview = body.substring(0, body.length > 200 ? 200 : body.length);
    debugPrint("[$label] URL: ${res.request?.url}");
    debugPrint("[$label] STATUS: ${res.statusCode}");
    debugPrint("[$label] CONTENT-TYPE: $ct");
    debugPrint("[$label] BODY(200): $preview");

    if (preview.toLowerCase().contains("<!doctype html") || ct.contains("text/html")) {
      throw Exception("[$label] Server returned HTML (redirect/login/wrong URL).");
    }

    if (res.statusCode != 200) {
      throw Exception("[$label] HTTP ${res.statusCode}");
    }

    return jsonDecode(body);
  }

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? ""; // 🆕 naya

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await loadAll();
  }

  Future<void> loadAll() async {
    try {
      isPageLoading(true);

      await fetchSessions();

      // 🆕 Notes jaisa hi flow — pehle ClassTeacher filter (agar teacher hai)
      if (!isStaffLogin.value) {
        await fetchClassTeacherFilter(); // 🆕 pehle — flag set ho jaye
      }

      await Future.wait([
        fetchTeachers(),
        fetchClasses(),
        fetchSections(),
        fetchSubjects(),
        fetchTeacherSubjectList(),
      ]);
    } finally {
      isPageLoading(false);
    }
  }

  // =========================
  // SESSIONS
  // =========================
  Future<void> fetchSessions() async {
    try {
      final res = await http.get(Uri.parse(_sessionUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Session");

      sessionList.clear();

      if (decoded is Map<String, dynamic>) {
        if (decoded['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: decoded['currentSession']['currentSessionId'],
            session: decoded['currentSession']['currentSession'],
            action: decoded['currentSession']['action'],
            schoolId: decoded['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
          return;
        }

        if (decoded['listData'] is List && (decoded['listData'] as List).isNotEmpty) {
          final first = decoded['listData'][0];
          final cs = session_model.sListDdata(
            sessionId: first['sessionId'],
            session: first['session'],
            action: first['action'],
            schoolId: first['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
          return;
        }
      }

      selectedSession.value = null;
    } catch (e) {
      Get.snackbar("Error", "Session error: $e");
    }
  }

  // =========================
  // TEACHERS
  // =========================
  Future<void> fetchTeachers() async {
    final session = selectedSession.value?.session;
    if (session == null || session.trim().isEmpty) {
      teacherList.clear();
      selectedTeacher.value = null;
      return;
    }

    try {
      final res = await http.get(Uri.parse(_teacherUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Teachers");

      final parsed = TeacherListResponse.fromJson(decoded);
      if (parsed.isSuccess == true) {
        teacherList.assignAll(parsed.data);
      } else {
        teacherList.clear();
        Get.snackbar("Failed", (parsed.messages ?? "Teacher fetch failed").toString());
      }

      selectedTeacher.value = null;
    } catch (e) {
      Get.snackbar("Error", "Teacher fetch error: $e");
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

  /// ---------------------- CLASSES (3-way) ----------------------
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
        classList.value = classTeacherList.map((e) {
          return ListDataa.fromJson({
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

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      final res = await http.get(Uri.parse(_classTeacherUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Classes");

      if (decoded is Map<String, dynamic> && decoded['data'] != null) {
        final List<dynamic> data = decoded['data'] ?? [];
        // GetClassTeacher me action null aata hai, isliye filter nahi lagayenge
        classList.assignAll(data.map((e) => ListDataa.fromJson(e)).toList());
      } else {
        classList.value = [];
      }
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

      final parsed = ClassItem.fromJson(decoded);
      classList.assignAll(parsed.listData?.where((e) => e.action == "1").toList() ?? []);
      selectedClass.value = null;
    } catch (e) {
      Get.snackbar("Error", "Class fetch error (staff): $e");
    } finally {
      isClassLoading(false);
    }
  }

  /// ---------------------- SECTIONS (3-way) ----------------------
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
        final res =
        await http.get(Uri.parse(_sectionTeacherUrl), headers: _headers);
        final decoded = _safeDecodeResponse(res, label: "SectionTeacher");
        final model = SectionForAttendanceModel.fromJson(decoded);
        sectionList.assignAll(
          (model.data ?? []).map((e) {
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
          }).toList(),
        );
        selectedSection.value = null;
      } catch (e) {
        sectionList.clear();
        selectedSection.value = null;
        Get.snackbar("Error", "Section fetch error: $e");
      }

      if (sectionList.isEmpty) {
        debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
        await _fetchSectionsStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetSectionTeacher API
    try {
      final res = await http.get(Uri.parse(_sectionGetTeacherUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Sections");

      final list = (decoded is Map<String, dynamic>)
          ? (decoded['data'] ?? decoded['listData'] ?? [])
          : [];
      sectionList.assignAll((list as List).map<ListDatta>((e) => ListDatta.fromJson(e)).toList());
      selectedSection.value = null;
    } catch (e) {
      Get.snackbar("Error", "Section fetch error: $e");
      sectionList.value = [];
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
      final res = await http.get(Uri.parse(_sectionStaffUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "SectionsStaff");

      final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];
      sectionList.assignAll((list as List).map<ListDatta>((e) => ListDatta.fromJson(e)).toList());
      selectedSection.value = null;
    } catch (e) {
      Get.snackbar("Error", "Section fetch error (staff): $e");
    } finally {
      isSectionLoading(false);
    }
  }

  /// ---------------------- SUBJECTS (2-way) ----------------------
  // 1️⃣ STAFF -> ViewSubjectApp API | 2️⃣ TEACHER -> GetSubjectTeacher API
  // fallback -> staff API
  Future<void> fetchSubjects() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchSubjectsStaffApi();
      return;
    }

    // 2️⃣ TEACHER
    try {
      final res = await http.get(Uri.parse(_subjectTeacherUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Subjects");

      final list = (decoded is Map<String, dynamic>)
          ? (decoded['data'] ?? decoded['listData'] ?? [])
          : [];
      subjectList.assignAll((list as List).map<ListDaataa>((e) => ListDaataa.fromJson(e)).toList());
      selectedSubject.value = null;
    } catch (e) {
      Get.snackbar("Error", "Subject fetch error: $e");
      subjectList.value = [];
    }

    if (subjectList.isEmpty) {
      debugPrint("↩️ Teacher subjects empty — falling back to staff API");
      await _fetchSubjectsStaffApi();
    }
  }

  // 🆕 Staff subject API (Notes wali hi logic)
  Future<void> _fetchSubjectsStaffApi() async {
    try {
      isSubjectLoading(true);
      final res = await http.get(Uri.parse(_subjectStaffUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "SubjectsStaff");

      // Adjust if your subject API shape differs.
      final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];
      subjectList.assignAll((list as List).map<ListDaataa>((e) => ListDaataa.fromJson(e)).toList());
      selectedSubject.value = null;
    } catch (e) {
      Get.snackbar("Error", "Subject fetch error (staff): $e");
    } finally {
      isSubjectLoading(false);
    }
  }

  // =========================
  // LIST (POST body: schoolId + session)
  // =========================
  Future<void> fetchTeacherSubjectList() async {
    final session = selectedSession.value?.session?.trim() ?? "";
    if (session.isEmpty) {
      teacherSubjectList.clear();
      return;
    }

    try {
      isListLoading(true);

      final body = {
        "schoolId": schoolId,
        "session": session,
      };

      final res = await http.post(
        Uri.parse(_listUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      final decoded = _safeDecodeResponse(res, label: "TeacherSubjectList");
      final model = TeacherSubjectModel.fromJson(decoded);

      teacherSubjectList.assignAll(model.listData);
    } catch (e) {
      Get.snackbar("Error", "List error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // =========================
  // DUPLICATE CHECK
  // =========================
  bool _alreadyAssigned() {
    final teacherId = selectedTeacher.value?.id;
    final classId = selectedClass.value?.classId;
    final sectionId = selectedSection.value?.sectionId;
    final subjectId = selectedSubject.value?.subjectId;
    final session = selectedSession.value?.session?.trim();

    if (teacherId == null || classId == null || sectionId == null || subjectId == null || session == null) {
      return false;
    }

    // Best case: list returns teacherId (it doesn't in your model).
    // So we do a pragmatic match: class+section+subject+session and teacherName match.
    // If your API returns teacherId somewhere, change this to compare IDs.
    final teacherName = selectedTeacher.value?.name?.trim() ?? "";

    return teacherSubjectList.any((x) {
      final sameSession = (x.session?.trim() ?? "") == session;
      final sameClass = x.classId == classId;
      final sameSection = x.sectionId == sectionId;
      final sameSubject = x.subjectId == subjectId;

      final listTeacherName = (x.teacherName?.trim() ?? "");
      final sameTeacher = teacherName.isNotEmpty && listTeacherName == teacherName;

      return sameSession && sameClass && sameSection && sameSubject && sameTeacher;
    });
  }

  Future<void> saveTeacherSubjectAssign() async {
    if (selectedTeacher.value == null) {
      Get.snackbar("Validation", "Select Teacher");
      return;
    }
    if (selectedClass.value == null) {
      Get.snackbar("Validation", "Select Class");
      return;
    }
    if (selectedSection.value == null) {
      Get.snackbar("Validation", "Select Section");
      return;
    }
    if (selectedSubject.value == null) {
      Get.snackbar("Validation", "Select Subject");
      return;
    }

    final session = selectedSession.value?.session?.trim() ?? "";
    if (session.isEmpty) {
      Get.snackbar("Validation", "Session missing");
      return;
    }

    final t = selectedTeacher.value!;
    final c = selectedClass.value!;
    final s = selectedSection.value!;
    final sub = selectedSubject.value!;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    try {
      isSaving(true);

      final uri = Uri.parse(_saveUrl);
      final request = http.MultipartRequest("POST", uri);

      // ✅ IMPORTANT: do NOT set Content-Type manually
      request.headers.addAll({
        "Accept": "application/json",
        if (token.trim().isNotEmpty)
          "Authorization": "Bearer $token",
      });

      // ✅ multipart fields MUST be strings
      request.fields.addAll({
        "Id": "0",
        "UserId": (t.id ?? 0).toString(),
        "Session": session,
        "ClassId": (c.classId ?? 0).toString(),
        "SectionId": (s.sectionId ?? 0).toString(),
        "SubjectId": (sub.subjectId ?? 0).toString(),
        "Action": "1",
        "CreateDate": nowIso,
        "UpdateDate": nowIso,
        "CreateBy": "SchoolAdmin",
        "UpdateBy": "",
        "SchoolId": schoolId,
      });

      debugPrint("[FORMDATA SAVE] URL: $_saveUrl");
      debugPrint("[FORMDATA SAVE] FIELDS: ${request.fields}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("[FORMDATA SAVE] STATUS: ${response.statusCode}");
      debugPrint("[FORMDATA SAVE] RESP: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        Get.snackbar(
          "Error",
          "Save failed: ${response.statusCode}\n${response.body}",
        );
        return;
      }

      String msg = "Saved";
      final ct = (response.headers['content-type'] ?? '').toLowerCase();
      if (ct.contains("application/json") && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          msg = decoded['messages'] ??
              decoded['message'] ??
              decoded['Messages'] ??
              decoded['Message'] ??
              msg;
        }
      }

      Get.snackbar("Success", msg.toString());

      clearForm();
      await fetchTeacherSubjectList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSaving(false);
    }
  }

  bool get isDuplicateSelection {
    final t = selectedTeacher.value;
    final c = selectedClass.value;
    final s = selectedSection.value;
    final sub = selectedSubject.value;
    final session = selectedSession.value?.session?.trim() ?? "";

    if (t == null || c == null || s == null || sub == null || session.isEmpty) return false;

    final teacherName = t.name?.trim() ?? "";
    if (teacherName.isEmpty) return false;

    return teacherSubjectList.any((x) =>
    (x.session?.trim() ?? "") == session &&
        x.classId == c.classId &&
        x.sectionId == s.sectionId &&
        x.subjectId == sub.subjectId &&
        (x.teacherName?.trim() ?? "") == teacherName);
  }


  void clearForm() {
    selectedTeacher.value = null;
    selectedClass.value = null;
    selectedSection.value = null;
    selectedSubject.value = null;
  }

  void openEditDialog(BuildContext context, TeacherSubjectItem row) {
    Get.snackbar("Info", "Edit pending (ID: ${row.id ?? 0})");
  }
}