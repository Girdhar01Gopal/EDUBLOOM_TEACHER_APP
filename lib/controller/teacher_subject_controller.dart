import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/teacher list model.dart';
import '../models/session_model.dart' as session_model;
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart'; // must contain ListDaataa
import '../models/teachersubjectmodel.dart'; // TeacherSubjectModel, TeacherSubjectItem
import '../res/app_url.dart';

class TeacherSubjectController extends GetxController {
  String schoolId = "";
  String token = "";

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

  // =========================
  // URLs
  // =========================
  String get _sessionUrl => '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
  String get _classUrl => '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
  String get _sectionUrl => '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

  String get _teacherUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}api/TeacherApp/GetAllTeachersAsyncApp'
        '?schoolId=$schoolId&currentSession=${Uri.encodeComponent(session)}';
  }

  // ✅ SUBJECT endpoint (replace if yours is different)
  String get _subjectUrl => '${AppUrl.base_url}api/MasterApp/ViewSubjectApp/$schoolId';

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

  // =========================
  // CLASSES
  // =========================
  Future<void> fetchClasses() async {
    try {
      final res = await http.get(Uri.parse(_classUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Classes");

      final parsed = ClassItem.fromJson(decoded);
      classList.assignAll(parsed.listData?.where((e) => e.action == "1").toList() ?? []);
      selectedClass.value = null;
    } catch (e) {
      Get.snackbar("Error", "Class fetch error: $e");
    }
  }

  // =========================
  // SECTIONS
  // =========================
  Future<void> fetchSections() async {
    try {
      final res = await http.get(Uri.parse(_sectionUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Sections");

      final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];
      sectionList.assignAll((list as List).map<ListDatta>((e) => ListDatta.fromJson(e)).toList());
      selectedSection.value = null;
    } catch (e) {
      Get.snackbar("Error", "Section fetch error: $e");
    }
  }

  // =========================
  // SUBJECTS
  // =========================
  Future<void> fetchSubjects() async {
    try {
      final res = await http.get(Uri.parse(_subjectUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Subjects");

      // Adjust if your subject API shape differs.
      final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];
      subjectList.assignAll((list as List).map<ListDaataa>((e) => ListDaataa.fromJson(e)).toList());
      selectedSubject.value = null;
    } catch (e) {
      Get.snackbar("Error", "Subject fetch error: $e");
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
