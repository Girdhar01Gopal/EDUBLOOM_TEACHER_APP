import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/SubjectClassAssignModel.dart';
import '../models/class_list_model.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/sectionmodel.dart';
import '../models/viewsectionmodel.dart';
import '../models/subject_model.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel (Notes jaisa)
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse (Notes jaisa)

class SubjectClassAssignController extends GetxController {
  String schoolId = "";
  String token = "";
  String session = "";
  String userId = "";

  // =========================
  // 🆕 ROLE / TEACHER-TYPE DETECTION (Notes controller jaisa hi)
  // =========================
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  // =========================
  // DROPDOWNS
  // =========================
  // Class -> notification's ClassData model (UI same)
  final classList = <ClassData>[].obs;
  final selectedClass = Rx<ClassData?>(null);

  // Section -> notification's stListData model (UI same)
  final sectionList = <stListData>[].obs;
  final selectedSection = Rx<stListData?>(null);

  final subjectList = <ListDaataa>[].obs;
  final selectedSubject = Rx<ListDaataa?>(null);

  // =========================
  // VIEW LIST
  // =========================
  final subjectClassAssignList = <SubjectClassAssignData>[].obs;

  // =========================
  // LOADERS
  // =========================
  final isPageLoading = false.obs;
  final isSaving = false.obs;
  final isListLoading = false.obs;

  // =========================
  // URLs
  // =========================
  // Normal-teacher class/section/subject APIs (Notes jaisa)
  String get _classUrl =>
      '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=$session&userId=$userId';

  String get _sectionUrl =>
      '${AppUrl.base_url}${AppUrl.getSectionTeacher}?schoolId=$schoolId&Session=$session&userId=$userId';

  String get _subjectUrl =>
      '${AppUrl.base_url}${AppUrl.get_subject_teacher}?schoolId=$schoolId&Session=$session&userId=$userId';

  String get _subjectClassAssignListUrl =>
      '${AppUrl.base_url}api/MasterApp/GetAllClassSubjectAsyncApp/$schoolId';

  String get _saveUrl =>
      '${AppUrl.base_url}api/MasterApp/PostClassBindSubjectApp';

  Map<String, String> get _headers {
    final h = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    if (token.trim().isNotEmpty) {
      h["Authorization"] = "Bearer $token";
    }
    return h;
  }

  dynamic _safeDecodeResponse(http.Response res, {required String label}) {
    final ct = (res.headers['content-type'] ?? '').toLowerCase();
    final body = res.body;

    final preview = body.substring(0, body.length > 300 ? 300 : body.length);
    debugPrint("[$label] URL: ${res.request?.url}");
    debugPrint("[$label] STATUS: ${res.statusCode}");
    debugPrint("[$label] CONTENT-TYPE: $ct");
    debugPrint("[$label] BODY(300): $preview");

    if (preview.toLowerCase().contains("<!doctype html") || ct.contains("text/html")) {
      throw Exception("[$label] Server returned HTML instead of JSON.");
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("[$label] HTTP ${res.statusCode}");
    }

    if (body.trim().isEmpty) {
      return {};
    }

    return jsonDecode(body);
  }

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    userId = await PrefManager().readValue(key: PrefConst.Userid) ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff" (Notes jaisa)
    final role = ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    await loadAll();
  }

  Future<void> loadAll() async {
    try {
      isPageLoading(true);

      // 🆕 FIX: Notes jaisa hi — staff ke liye direct classes+sections,
      // teacher ke liye pehle ClassTeacher filter, phir classes+sections.
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

      await fetchSubjects();
      await fetchSubjectClassAssignList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isPageLoading(false);
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
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session)}'
            '&userId=${Uri.encodeComponent(userId)}',
      );

      final response = await http.get(url, headers: _headers);

      debugPrint('ClassTeacher status: ${response.statusCode}');
      debugPrint('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = _safeDecodeResponse(response, label: "ClassTeacherFilter");
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
        classList.assignAll(classTeacherList.map((e) {
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
        }).toList());
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        classList.clear();
      }

      selectedClass.value = null;

      // if (classList.isEmpty) {
      //   debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
      //   await _fetchClassesStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      final response = await http.get(Uri.parse(_classUrl), headers: _headers);
      final decoded = _safeDecodeResponse(response, label: "GetClassTeacher");

      final list = (decoded is Map<String, dynamic>) ? (decoded['data'] ?? []) : [];

      classList.assignAll(
        (list as List).map<ClassData>((e) => ClassData.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint("⚠️ Error fetching GetClassTeacher classes: $e");
      classList.clear();
    }

    selectedClass.value = null;

    // if (classList.isEmpty) {
    //   debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
    //   await _fetchClassesStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url, headers: _headers);
      final decoded = _safeDecodeResponse(response, label: "ViewClass(staff)");

      final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];

      classList.assignAll(
        (list as List).map<ClassData>((e) => ClassData.fromJson(e)).toList(),
      );
      selectedClass.value = null;
    } catch (e) {
      debugPrint("⚠️ Error fetching classes (staff): $e");
      Get.snackbar("Error", "Class fetch error: $e");
    }
  }

  // =========================
  // SECTIONS (3-way, Notes jaisa hi)
  // =========================
  // 1️⃣ STAFF -> ViewSectionApp API | 2️⃣ CLASS TEACHER -> SectionTeacher API
  // | 3️⃣ NORMAL TEACHER -> getSectionTeacher API | fallback -> staff API
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
              '?schoolId=${Uri.encodeComponent(schoolId)}'
              '&Session=${Uri.encodeComponent(session)}'
              '&userId=${Uri.encodeComponent(userId)}',
        );

        final response = await http.get(url, headers: _headers);

        debugPrint('SectionTeacher status: ${response.statusCode}');
        debugPrint('SectionTeacher body: ${response.body}');

        final decoded = _safeDecodeResponse(response, label: "SectionTeacher");
        final model = SectionForAttendanceModel.fromJson(decoded);

        sectionList.assignAll((model.data ?? []).map((e) {
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
        }).toList());
      } catch (e) {
        debugPrint("⚠️ Error fetching SectionTeacher sections: $e");
        sectionList.clear();
      }

      selectedSection.value = null;

      // if (sectionList.isEmpty) {
      //   debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
      //   await _fetchSectionsStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — getSectionTeacher API
    try {
      final res = await http.get(Uri.parse(_sectionUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Sections");

      final sectionModel = sectionmodel.fromJson(decoded);

      sectionList.assignAll(sectionModel.listData ?? []);
    } catch (e) {
      debugPrint("⚠️ Error fetching GetSectionTeacher sections: $e");
      sectionList.clear();
    }

    selectedSection.value = null;

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
      final response = await http.get(url, headers: _headers);
      final decoded = _safeDecodeResponse(response, label: "ViewSectionApp(staff)");

      final list = (decoded is Map<String, dynamic>) ? (decoded['listData'] ?? []) : [];

      sectionList.assignAll(
        (list as List).map((e) => stListData.fromJson(e)).toList(),
      );
      selectedSection.value = null;
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
      Get.snackbar("Error", "Section fetch error: $e");
    }
  }

  // =========================
  // SUBJECTS (2-way: teacher -> staff fallback, Notes jaisa hi)
  // =========================
  Future<void> fetchSubjects() async {
    // 1️⃣ STAFF — direct staff API
    if (isStaffLogin.value) {
      await _fetchSubjectsStaffApi();
      return;
    }

    // 2️⃣ TEACHER — existing teacher subject API
    try {
      final res = await http.get(Uri.parse(_subjectUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Subjects");

      List<dynamic>? rawList;
      if (decoded is Map<String, dynamic>) {
        if (decoded['listData'] != null) {
          rawList = decoded['listData'] as List<dynamic>;
        } else if (decoded['data'] != null) {
          rawList = decoded['data'] as List<dynamic>;
        }
      }

      subjectList.assignAll(
        (rawList ?? []).map((e) => ListDaataa.fromJson(e)).toList(),
      );
    } catch (e) {
      debugPrint('Error loading teacher subjects: $e');
      subjectList.clear();
    }

    selectedSubject.value = null;

    // 🆕 FALLBACK: teacher API empty aaya to staff wali API try karo
    // if (subjectList.isEmpty) {
    //   debugPrint("↩️ Teacher subjects empty — falling back to staff API");
    //   await _fetchSubjectsStaffApi();
    // }
  }

  // 🆕 Staff subject API (Notes jaisa hi)
  Future<void> _fetchSubjectsStaffApi() async {
    try {
      final url = '${AppUrl.base_url}${AppUrl.view_subject}$schoolId';
      final response = await http.get(Uri.parse(url), headers: _headers);
      final decoded = _safeDecodeResponse(response, label: "ViewSubject(staff)");

      final subjectWrapper = SubjectModel.fromJson(decoded);
      subjectList.assignAll(subjectWrapper.listData ?? []);
      selectedSubject.value = null;
      debugPrint("📊 Staff subjectList length -> ${subjectList.length}");
    } catch (e) {
      debugPrint('Error loading staff subjects: $e');
      Get.snackbar("Error", "Subject fetch error: $e");
    }
  }

  // =========================
  // VIEW LIST
  // =========================
  Future<void> fetchSubjectClassAssignList() async {
    try {
      isListLoading(true);

      final res = await http.get(
        Uri.parse(_subjectClassAssignListUrl),
        headers: _headers,
      );

      final decoded = _safeDecodeResponse(res, label: "SubjectClassAssignList");
      final model = SubjectClassAssignModel.fromJson(decoded);

      if (model.isSuccess == true) {
        subjectClassAssignList.assignAll(model.data ?? []);
      } else {
        subjectClassAssignList.clear();
        Get.snackbar(
          "Failed",
          model.popupMessage ??
              ((model.messages != null && model.messages!.isNotEmpty)
                  ? model.messages!.join(", ")
                  : "No data found"),
        );
      }
    } catch (e) {
      subjectClassAssignList.clear();
      Get.snackbar("Error", "List fetch error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // =========================
  // FILTERED LIST FOR VIEW TAB
  // =========================
  List<SubjectClassAssignData> get filteredSubjectClassAssignList {
    return subjectClassAssignList.where((item) {
      final classOk = selectedClass.value == null ||
          item.classId == selectedClass.value?.classId;

      final sectionOk = selectedSection.value == null ||
          item.sectionId == selectedSection.value?.sectionId;

      final subjectOk = selectedSubject.value == null ||
          item.subjectId == selectedSubject.value?.subjectId;

      return classOk && sectionOk && subjectOk;
    }).toList();
  }

  // =========================
  // DUPLICATE CHECK
  // =========================
  bool get isDuplicateSelection {
    final c = selectedClass.value;
    final s = selectedSection.value;
    final sub = selectedSubject.value;

    if (c == null || s == null || sub == null) return false;

    return subjectClassAssignList.any((x) =>
    x.classId == c.classId &&
        x.sectionId == s.sectionId &&
        x.subjectId == sub.subjectId);
  }

  // =========================
  // SAVE
  // =========================
  Future<void> saveSubjectClassAssign() async {
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

    if (isDuplicateSelection) {
      Get.snackbar("Warning", "This class, section and subject is already assigned");
      return;
    }

    try {
      isSaving(true);

      final nowIso = DateTime.now().toUtc().toIso8601String();

      final body = {
        "id": 0,
        "classId": [selectedClass.value?.classId ?? 0],
        "subjectId": [selectedSubject.value?.subjectId ?? 0],
        "sectionId": [selectedSection.value?.sectionId ?? 0],
        "action": "1",
        "createDate": nowIso,
        "updateDate": nowIso,
        "createBy": "admin",
        "updateBy": "string",
        "schoolId": schoolId,
      };

      debugPrint("[SAVE SUBJECT CLASS ASSIGN] URL: $_saveUrl");
      debugPrint("[SAVE SUBJECT CLASS ASSIGN] BODY: ${jsonEncode(body)}");

      final res = await http.post(
        Uri.parse(_saveUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      final decoded = _safeDecodeResponse(res, label: "SaveSubjectClassAssign");

      String message = "Saved successfully";

      if (decoded is Map<String, dynamic>) {
        message = (decoded['message'] ??
            decoded['messages'] ??
            decoded['popupMessage'] ??
            "Saved successfully")
            .toString();
      }

      Get.snackbar("Success", message);

      clearForm();
      await fetchSubjectClassAssignList();
    } catch (e) {
      Get.snackbar("Error", "Save failed: $e");
    } finally {
      isSaving(false);
    }
  }

  void clearForm() {
    selectedClass.value = null;
    selectedSection.value = null;
    selectedSubject.value = null;
  }
}