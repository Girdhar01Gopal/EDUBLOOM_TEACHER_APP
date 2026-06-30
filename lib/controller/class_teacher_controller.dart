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
import '../res/app_url.dart';

// ✅ your response model (keep your file name/class name as-is)
import '../models/classteachermodel.dart';

class ClassTeacherController extends GetxController {
  String schoolId = "";
  String token = "";
  String prefSession = "";

  // Session
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  // Dropdowns
  final teacherList = <TeacherModel>[].obs;
  final selectedTeacher = Rx<TeacherModel?>(null);

  final classList = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final sectionList = <ListDatta>[].obs;
  final selectedSection = Rx<ListDatta?>(null);

  // ✅ REAL View list from API
  final classTeacherList = <Data>[].obs;

  // loaders
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isListLoading = false.obs;

  // URLs
  String get _sessionUrl => '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
  String get _classUrl => '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
  String get _sectionUrl => '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

  // Teacher list API (your backend uses Session param)
  // String get _teacherUrl {
  //   final sess = _currentSession();
  //   return '${AppUrl.base_url}api/TeacherApp/GetAllTeachersAsyncApp'
  //       '?schoolId=$schoolId&Session=${Uri.encodeComponent(sess)}';
  // }
  String get _teacherUrl {
    final session = selectedSession.value?.session ?? "";
    return '${AppUrl.base_url}api/TeacherApp/GetAllTeachersAsyncApp'
        '?schoolId=$schoolId&currentSession=${Uri.encodeComponent(session)}';
  }
  // ✅ Save API
  String get _saveUrl => '${AppUrl.base_url}api/TeacherApp/PostAddClassTeacherApp';

  // ✅ Get list API (you gave it)
  // Query form:
  String get _getListUrlQuery {
    final sess = _currentSession();
    return '${AppUrl.base_url}api/TeacherApp/GetAllClassTeacherAsyncApp'
        '?schoolId=$schoolId&Session=${Uri.encodeComponent(sess)}';
  }

  // Body form (you also gave this): {schoolId, session}
  String get _getListUrlBody => '${AppUrl.base_url}api/TeacherApp/GetAllClassTeacherAsyncApp';

  Map<String, String> get _headers {
    final h = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };
    if (token.trim().isNotEmpty) h["Authorization"] = "Bearer $token";
    return h;
  }

  String _currentSession() {
    final s = selectedSession.value?.session?.trim();
    if (s != null && s.isNotEmpty) return s;
    if (prefSession.trim().isNotEmpty) return prefSession.trim();
    return "";
  }

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    prefSession = await PrefManager().readValue(key: PrefConst.session) ?? "";

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
        fetchClassTeacherList(), // ✅ real list
      ]);
    } finally {
      isPageLoading(false);
    }
  }

  // ---------------- Session ----------------
  Future<void> fetchSessions() async {
    try {
      final res = await http.get(Uri.parse(_sessionUrl), headers: _headers);
      if (res.statusCode != 200) return;

      final jsonData = jsonDecode(res.body);

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
      } else {
        selectedSession.value = null;
      }
    } catch (e) {
      debugPrint("Session error: $e");
    }
  }

  // ---------------- Teachers ----------------
  Future<void> fetchTeachers() async {
    final session = selectedSession.value?.session;
    if (session == null || session.trim().isEmpty) {
      teacherList.clear();
      return;
    }

    try {
      final res = await http.get(Uri.parse(_teacherUrl), headers: _headers);
      if (res.statusCode != 200) {
        teacherList.clear();
        return;
      }

      final parsed = TeacherListResponse.fromJson(jsonDecode(res.body));

      if (parsed.isSuccess == true) {
        teacherList.assignAll(parsed.data);
      } else {
        teacherList.clear();
        Get.snackbar("Failed", (parsed.messages ?? "Teacher fetch failed").toString());
      }

      selectedTeacher.value = null;
    } catch (_) {}
  }

  // ---------------- Classes ----------------
  Future<void> fetchClasses() async {
    try {
      final res = await http.get(Uri.parse(_classUrl), headers: _headers);
      if (res.statusCode != 200) return;

      final parsed = ClassItem.fromJson(jsonDecode(res.body));
      classList.assignAll(parsed.listData?.where((e) => e.action == "1").toList() ?? []);
      selectedClass.value = null;
    } catch (e) {
      debugPrint("Class error: $e");
    }
  }

  // ---------------- Sections ----------------
  Future<void> fetchSections() async {
    try {
      final res = await http.get(Uri.parse(_sectionUrl), headers: _headers);
      if (res.statusCode != 200) return;

      final decoded = jsonDecode(res.body);
      final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];
      sectionList.assignAll((list as List).map<ListDatta>((e) => ListDatta.fromJson(e)).toList());
      selectedSection.value = null;
    } catch (e) {
      debugPrint("Section error: $e");
    }
  }

  // ---------------- ✅ GET LIST (real) ----------------
  Future<void> fetchClassTeacherList() async {
    final sess = _currentSession();
    if (sess.isEmpty) {
      classTeacherList.clear();
      return;
    }

    try {
      isListLoading(true);

      // First try BODY form (you provided body)
      final body = {"schoolId": schoolId, "session": sess};

      http.Response res = await http.post(
        Uri.parse(_getListUrlBody),
        headers: _headers,
        body: jsonEncode(body),
      );

      // If backend actually wants query GET, fallback:
      if (res.statusCode != 200) {
        res = await http.get(Uri.parse(_getListUrlQuery), headers: _headers);
      }

      if (res.statusCode != 200) {
        Get.snackbar("Error", "List API failed: ${res.statusCode}\n${res.body}");
        return;
      }

      final decoded = jsonDecode(res.body);
      final model = classteachermodel.fromJson(decoded);

      if (model.isSuccess == true) {
        classTeacherList.assignAll(model.data ?? []);
      } else {
        classTeacherList.clear();
        Get.snackbar("Failed", (model.messages ?? "List fetch failed").toString());
      }
    } catch (e) {
      Get.snackbar("Error", "List error: $e");
    } finally {
      isListLoading(false);
    }
  }

Future<void> saveClassTeacher() async {
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

  final sess = _currentSession();
  if (sess.isEmpty) {
    Get.snackbar("Validation", "Session missing");
    return;
  }

  final t = selectedTeacher.value!;
  final c = selectedClass.value!;
  final s = selectedSection.value!;
  final nowIso = DateTime.now().toUtc().toIso8601String();

  final payload = {
    "id": 0,
    "session": sess,
    "sectionId": s.sectionId ?? 0,
    "classId": c.classId ?? 0,
    "action": "1",
    "createDate": nowIso,
    "updateDate": nowIso,
    "createBy": "SchoolAdmin",
    "updateBy": "",
    "schoolId": schoolId,
    "userId": t.id ?? 0,
  };

  try {
    isSaving(true);

    final res = await http.post(
      Uri.parse(_saveUrl),
      headers: _headers,
      body: jsonEncode(payload),
    );

    debugPrint("[SAVE CLASS TEACHER] STATUS: ${res.statusCode}");
    debugPrint("[SAVE CLASS TEACHER] RESP: ${res.body}");

    // ✅ Try to parse message even for 409/400 etc.
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }

    final apiMessage = decoded?["messages"]?.toString();
    final isSuccess = decoded?["isSuccess"] == true;

    // ✅ If backend says success, do success flow
    if (isSuccess) {
      Get.snackbar("Success", isSuccess == true
          ? apiMessage!
          : "Class Teacher Saved");

      Get.back();                 // close add screen
      await fetchClassTeacherList(); // refresh view
      return;
    }

    // ❌ Failure flow: show EXACT server response message
    // (e.g. "The Teacher is already assigned...")
    if (apiMessage != null && apiMessage.isNotEmpty) {
      Get.snackbar("Failed", apiMessage);
    } else {
      // fallback if response isn't JSON or has no message
      Get.snackbar("Failed", "Save failed (${res.statusCode})");
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isSaving(false);
  }
}

  void clearForm() {
    selectedTeacher.value = null;
    selectedClass.value = null;
    selectedSection.value = null;
  }
}
