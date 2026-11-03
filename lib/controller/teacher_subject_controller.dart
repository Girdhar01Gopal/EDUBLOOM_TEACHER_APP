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
import '../models/new model teacher section attendance.dart'; // SectionForAttendanceModel
import '../res/app_url.dart';
import '../utils/app_snackbar.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData;

/// Non-200 response ko status code ke saath throw karne ke liye, taaki
/// user ko raw "HTTP 500" nahi, friendly line dikhe.
class _HttpStatusException implements Exception {
  final int statusCode;
  const _HttpStatusException(this.statusCode);
}

class TeacherSubjectController extends GetxController {
  String schoolId = "";
  String token = "";
  String userId = "";

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
  final isClassLoading = false.obs;
  final isSectionLoading = false.obs;
  final isSubjectLoading = false.obs;

  // Class Teacher filter
  final classTeacherList = <ClassTeacherFilterData>[].obs;
  final isClassTeacherLogin = false.obs;

  // true => "schoolstaff" role
  final isStaffLogin = false.obs;

  // =========================
  // URLs
  // =========================
  String get _session => selectedSession.value?.session ?? "";
  String get _encodedSession => Uri.encodeComponent(_session);
  String get _base => AppUrl.base_url;

  // Teacher APIs ka common query string
  String get _teacherQuery => '?schoolId=$schoolId&Session=$_encodedSession&userId=$userId';

  String get _sessionUrl => '${_base}api/MasterApp/ViewSessionApp/$schoolId';

  // STAFF URLs
  String get _classStaffUrl => '${_base}api/MasterApp/ViewClass/$schoolId';
  String get _sectionStaffUrl => '${_base}api/MasterApp/ViewSectionApp/$schoolId';
  String get _subjectStaffUrl => '${_base}api/MasterApp/ViewSubjectApp/$schoolId';

  // NORMAL TEACHER URLs
  String get _classTeacherUrl => '${_base}api/TeacherApp/GetClassTeacher$_teacherQuery';
  String get _sectionGetTeacherUrl => '${_base}api/TeacherApp/GetSectionTeacher$_teacherQuery';
  String get _subjectTeacherUrl => '$_base${AppUrl.get_subject_teacher}$_teacherQuery';

  // Class Teacher login URLs
  String get _classTeacherFilterUrl => '${_base}api/TeacherApp/ClassTeacher$_teacherQuery';
  String get _sectionTeacherUrl => '${_base}api/TeacherApp/SectionTeacher$_teacherQuery';

  String get _teacherUrl =>
      '${_base}api/TeacherApp/GetAllTeachersAsyncApp'
          '?schoolId=$schoolId&currentSession=$_encodedSession';

  String get _saveUrl => '${_base}api/TeacherApp/PostTeacherSubjectAssign';

  // List API: POST body {schoolId, session}
  String get _listUrl => '${_base}api/TeacherApp/ViewTeacherSubjectAssignApp';

  Map<String, String> get _headers => {
    "Accept": "application/json",
    "Content-Type": "application/json",
    if (token.trim().isNotEmpty) "Authorization": "Bearer $token",
  };

  // =========================
  // HELPERS
  // =========================
  // Raw exception / API text kabhi nahi dikhta — sirf friendly line.
  void _showError(Object e) => AppSnackbar.error(
    e is _HttpStatusException
        ? AppSnackbar.friendlyMessage(null, statusCode: e.statusCode)
        : AppSnackbar.friendlyMessage(e),
  );

  dynamic _safeDecodeResponse(http.Response res, {required String label}) {
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    final body = res.body;
    final preview = body.substring(0, body.length > 200 ? 200 : body.length);

    debugPrint("[$label] ${res.request?.url} | STATUS: ${res.statusCode} | CT: $ct | BODY(200): $preview");

    if (preview.toLowerCase().contains("<!doctype html") || ct.contains("text/html")) {
      // Server ne HTML bheja (redirect/login/wrong URL).
      throw const FormatException("Server returned HTML");
    }
    if (res.statusCode != 200) throw _HttpStatusException(res.statusCode);

    return jsonDecode(body);
  }

  /// GET + safe decode ek hi call me.
  Future<dynamic> _get(String url, String label) async =>
      _safeDecodeResponse(await http.get(Uri.parse(url), headers: _headers), label: label);

  /// Response se pehli available list nikalta hai (keys ke order me) aur model me map karta hai.
  List<T> _parseList<T>(dynamic decoded, List<String> keys, T Function(dynamic) fromJson) {
    if (decoded is! Map<String, dynamic>) return <T>[];
    for (final k in keys) {
      final v = decoded[k];
      if (v is List) return v.map<T>(fromJson).toList();
    }
    return <T>[];
  }

  session_model.sListDdata _sessionFrom(Map m, String idKey, String nameKey) =>
      session_model.sListDdata(
        sessionId: m[idKey],
        session: m[nameKey],
        action: m['action'],
        schoolId: m['schoolId'],
      );

  // =========================
  // INIT
  // =========================
  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? "";

    // Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "").toString().trim().toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    if (schoolId.trim().isEmpty) {
      AppSnackbar.error('School information not found. Please login again.');
      return;
    }

    await loadAll();
  }

  Future<void> loadAll() async {
    try {
      isPageLoading(true);

      await fetchSessions();

      // Pehle ClassTeacher filter (agar teacher hai) — flag set ho jaye
      if (!isStaffLogin.value) await fetchClassTeacherFilter();

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
      final decoded = await _get(_sessionUrl, "Session");

      sessionList.clear();

      session_model.sListDdata? cs;
      if (decoded is Map<String, dynamic>) {
        final current = decoded['currentSession'];
        final list = decoded['listData'];
        if (current != null) {
          cs = _sessionFrom(current, 'currentSessionId', 'currentSession');
        } else if (list is List && list.isNotEmpty) {
          cs = _sessionFrom(list[0], 'sessionId', 'session');
        }
      }

      if (cs != null) sessionList.add(cs);
      selectedSession.value = cs;
    } catch (e) {
      _showError(e);
    }
  }

  // =========================
  // TEACHERS
  // =========================
  Future<void> fetchTeachers() async {
    if (_session.trim().isEmpty) {
      teacherList.clear();
      selectedTeacher.value = null;
      return;
    }

    try {
      final parsed = TeacherListResponse.fromJson(await _get(_teacherUrl, "Teachers"));
      if (parsed.isSuccess == true) {
        teacherList.assignAll(parsed.data);
      } else {
        teacherList.clear();
        // API ka message sanitize hoke dikhega (lamba / technical hua to generic line).
        AppSnackbar.error((parsed.messages ?? "Teacher fetch failed").toString(), title: 'Failed');
      }
      selectedTeacher.value = null;
    } catch (e) {
      _showError(e);
    }
  }

  // Logged-in teacher ke assigned classes fetch karo
  Future<void> fetchClassTeacherFilter() async {
    if (userId.trim().isEmpty) {
      debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
      return;
    }

    try {
      final res = await http.get(Uri.parse(_classTeacherFilterUrl), headers: _headers);
      debugPrint('ClassTeacher status: ${res.statusCode}');

      if (res.statusCode == 200) {
        final model = ClassTeacherFilterModel.fromJson(json.decode(res.body));
        classTeacherList.value = model.data ?? [];
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  // ---------------------- CLASSES ----------------------
  // 1) STAFF -> ViewClass | 2) CLASS TEACHER -> ClassTeacher | 3) NORMAL TEACHER -> GetClassTeacher
  Future<void> fetchClasses() async {
    if (isStaffLogin.value) return _fetchClassesStaffApi();

    // CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
        classList.value = classTeacherList
            .map((e) => ListDataa.fromJson({
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
        }))
            .toList();
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        classList.value = [];
      }
      selectedClass.value = null;
      return;
    }

    // NORMAL TEACHER — GetClassTeacher API (action null aata hai, isliye filter nahi)
    try {
      final decoded = await _get(_classTeacherUrl, "Classes");
      classList.assignAll(_parseList(decoded, ['data'], (e) => ListDataa.fromJson(e)));
      selectedClass.value = null;
    } catch (e) {
      _showError(e);
      classList.value = [];
    }
  }

  Future<void> _fetchClassesStaffApi() async {
    try {
      isClassLoading(true);
      final parsed = ClassItem.fromJson(await _get(_classStaffUrl, "ClassesStaff"));
      classList.assignAll(parsed.listData?.where((e) => e.action == "1").toList() ?? []);
      selectedClass.value = null;
    } catch (e) {
      _showError(e);
    } finally {
      isClassLoading(false);
    }
  }

  // ---------------------- SECTIONS ----------------------
  // 1) STAFF -> ViewSectionApp | 2) CLASS TEACHER -> SectionTeacher | 3) NORMAL TEACHER -> GetSectionTeacher
  Future<void> fetchSections() async {
    if (isStaffLogin.value) return _fetchSectionsStaffApi();

    // CLASS TEACHER — SectionTeacher API
    if (isClassTeacherLogin.value) {
      try {
        final model = SectionForAttendanceModel.fromJson(
            await _get(_sectionTeacherUrl, "SectionTeacher"));
        sectionList.assignAll(
          (model.data ?? [])
              .map((e) => ListDatta.fromJson({
            'sectionId': e.sectionId,
            'section': e.section,
            'action': e.action,
            'createDate': e.createDate,
            'updateDate': e.updateDate,
            'createBy': e.createBy,
            'updateBy': e.updateBy,
            'schoolId': e.schoolId,
          }))
              .toList(),
        );
      } catch (e) {
        sectionList.clear();
        _showError(e);
      }
      selectedSection.value = null;
      return;
    }

    // NORMAL TEACHER — GetSectionTeacher API
    try {
      final decoded = await _get(_sectionGetTeacherUrl, "Sections");
      sectionList.assignAll(
          _parseList(decoded, ['data', 'listData'], (e) => ListDatta.fromJson(e)));
      selectedSection.value = null;
    } catch (e) {
      _showError(e);
      sectionList.value = [];
    }
  }

  Future<void> _fetchSectionsStaffApi() async {
    try {
      isSectionLoading(true);
      final decoded = await _get(_sectionStaffUrl, "SectionsStaff");
      sectionList.assignAll(_parseList(decoded, ['listData'], (e) => ListDatta.fromJson(e)));
      selectedSection.value = null;
    } catch (e) {
      _showError(e);
    } finally {
      isSectionLoading(false);
    }
  }

  // ---------------------- SUBJECTS ----------------------
  // 1) STAFF -> ViewSubjectApp | 2) TEACHER -> GetSubjectTeacher
  Future<void> fetchSubjects() async {
    if (isStaffLogin.value) return _fetchSubjectsStaffApi();

    try {
      final decoded = await _get(_subjectTeacherUrl, "Subjects");
      subjectList.assignAll(
          _parseList(decoded, ['data', 'listData'], (e) => ListDaataa.fromJson(e)));
      selectedSubject.value = null;
    } catch (e) {
      _showError(e);
      subjectList.value = [];
    }
  }

  Future<void> _fetchSubjectsStaffApi() async {
    try {
      isSubjectLoading(true);
      final decoded = await _get(_subjectStaffUrl, "SubjectsStaff");
      subjectList.assignAll(_parseList(decoded, ['listData'], (e) => ListDaataa.fromJson(e)));
      selectedSubject.value = null;
    } catch (e) {
      _showError(e);
    } finally {
      isSubjectLoading(false);
    }
  }

  // =========================
  // LIST (POST body: schoolId + session)
  // =========================
  Future<void> fetchTeacherSubjectList() async {
    final session = _session.trim();
    if (session.isEmpty) {
      teacherSubjectList.clear();
      return;
    }

    try {
      isListLoading(true);

      final res = await http.post(
        Uri.parse(_listUrl),
        headers: _headers,
        body: jsonEncode({"schoolId": schoolId, "session": session}),
      );

      final model = TeacherSubjectModel.fromJson(
          _safeDecodeResponse(res, label: "TeacherSubjectList"));
      teacherSubjectList.assignAll(model.listData);
    } catch (e) {
      _showError(e);
    } finally {
      isListLoading(false);
    }
  }

  // =========================
  // SAVE
  // =========================
  Future<void> saveTeacherSubjectAssign() async {
    // Pehli missing selection ka validation message
    final selections = <String, Object?>{
      'teacher': selectedTeacher.value,
      'class': selectedClass.value,
      'section': selectedSection.value,
      'subject': selectedSubject.value,
    };

    String? missing;
    for (final e in selections.entries) {
      if (e.value == null) {
        missing = e.key;
        break;
      }
    }

    if (missing != null) {
      AppSnackbar.error('Please select a $missing', title: 'Validation');
      return;
    }
    final session = _session.trim();
    if (session.isEmpty) {
      AppSnackbar.error('Session not loaded. Please refresh and try again.', title: 'Validation');
      return;
    }

    final t = selectedTeacher.value!;
    final c = selectedClass.value!;
    final s = selectedSection.value!;
    final sub = selectedSubject.value!;
    final nowIso = DateTime.now().toUtc().toIso8601String();

    try {
      isSaving(true);

      // IMPORTANT: Content-Type manually set nahi karna (multipart)
      final request = http.MultipartRequest("POST", Uri.parse(_saveUrl))
        ..headers.addAll({
          "Accept": "application/json",
          if (token.trim().isNotEmpty) "Authorization": "Bearer $token",
        })
      // multipart fields strings hi hone chahiye
        ..fields.addAll({
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

      debugPrint("[FORMDATA SAVE] URL: $_saveUrl | FIELDS: ${request.fields}");

      final response = await http.Response.fromStream(await request.send());
      debugPrint("[FORMDATA SAVE] STATUS: ${response.statusCode} | RESP: ${response.body}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Raw status code / response body user ko nahi dikhana.
        _showError(_HttpStatusException(response.statusCode));
        return;
      }

      // API ka message nahi dikhana — fixed success line.
      AppSnackbar.success('Teacher subject assigned successfully');

      clearForm();
      await fetchTeacherSubjectList();
    } catch (e) {
      _showError(e);
    } finally {
      isSaving(false);
    }
  }

  bool get isDuplicateSelection {
    final t = selectedTeacher.value;
    final c = selectedClass.value;
    final s = selectedSection.value;
    final sub = selectedSubject.value;
    final session = _session.trim();

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
    // AppSnackbar me sirf success/error style hain, isliye info bhi
    // usi card me "Info" title ke saath dikhta hai.
    AppSnackbar.success('Edit is coming soon', title: 'Info');
  }
}