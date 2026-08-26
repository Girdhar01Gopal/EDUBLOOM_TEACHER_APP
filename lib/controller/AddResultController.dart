import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/addresultmodel1.dart';
import '../models/class_list_model.dart';   // 🔄 classmodel.dart ki jagahimport '../models/descriptors_model.dart';
import '../models/grade_list_model.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/session_model.dart';
import '../models/subject_model.dart';
import '../models/terms_result_model.dart';
import '../models/viewsectionmodel.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse

class AddResultController extends GetxController {
  String schoolId = "";
  String token = "";
  String session = "";
  String userId = "";


  // =========================
  // TAB INDEX
  // =========================
  final RxInt currentTab = 0.obs;
  final RxString searchQuery = "".obs;


  // =========================
  // DROPDOWNS
  // =========================
  final RxList<ClassData> classList = <ClassData>[].obs;        // 🔄
  final Rx<ClassData?> selectedClass = Rx<ClassData?>(null);     // 🔄

  final RxList<ListDaataa> subjectList = <ListDaataa>[].obs;
  final Rx<ListDaataa?> selectedSubject = Rx<ListDaataa?>(null);

  final RxList<dynamic> sectionList = <dynamic>[].obs;
  final Rx<dynamic> selectedSection = Rx<dynamic>(null);

  final RxList<TermData> termList = <TermData>[].obs;
  final Rx<TermData?> selectedTerm = Rx<TermData?>(null);

  // =========================
  // STUDENT LIST + GRADE MAP
  // =========================
  final RxList<AddResultShow> studentList = <AddResultShow>[].obs;
  final Map<int, RxString> gradeMap = {};

  // ✅ Sirf track karne ke liye — kaunse students already submitted hain
  // GetResult API HATA DI — yeh set sirf POST success pe populate hoga
  final Set<int> submittedStudentIds = {};

  // =========================
  // LOADERS
  // =========================
  final RxBool isPageLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSubmitting = false.obs;

  // =========================
  // GRADE OPTIONS — ✅ ab API se dynamic aayenge
  // =========================
  final RxList<String> gradeOptions = <String>[].obs;

  // 🆕 Class Teacher filter
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var isClassTeacherLogin = false.obs;

  // =========================
  // URLs
  // =========================
  String get _classUrl =>
      '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=$session&userId=$userId';


  String get _subjectUrl =>
      '${AppUrl.base_url}${AppUrl.get_subject_teacher}?schoolId=$schoolId&Session=$session&userId=$userId';

  String get _sectionUrl =>
      '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher?schoolId=$schoolId&Session=$session&userId=$userId';

  String get _termUrl =>
      '${AppUrl.base_url}api/Result/ViewTerm/$schoolId/$session';

  // ✅ Grade API URL
  String get _gradeUrl =>
      '${AppUrl.base_url}api/Result/ViewGradeActive/$schoolId';

  // 🆕 Class Teacher filter URL
  String get _classTeacherFilterUrl =>
      '${AppUrl.base_url}api/TeacherApp/ClassTeacher?schoolId=$schoolId&Session=$session&userId=$userId';

  // 🆕 SectionTeacher URL (for class teacher login)
  String get _sectionTeacherUrl =>
      '${AppUrl.base_url}api/TeacherApp/SectionTeacher?schoolId=$schoolId&Session=$session&userId=$userId';

  String get _studentByClassUrl {
    final classId = selectedClass.value?.classId ?? 0;
    final subjectId = selectedSubject.value?.subjectId ?? 0;
    final term = Uri.encodeComponent(selectedTerm.value?.term ?? "");
    final sectionId = selectedSection.value?.sectionId ?? 0;
    return '${AppUrl.base_url}api/Result/ViewStudentbyClass/$classId/$subjectId/$term/$sectionId/$session/$schoolId';
  }

  // ✅ Sirf AddResult POST — GetResult URL completely remove
  String get _addResultUrl => '${AppUrl.base_url}api/Result/AddResult';

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
      throw Exception("[$label] Server returned HTML instead of JSON.");
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("[$label] HTTP ${res.statusCode}");
    }

    if (body.trim().isEmpty) return null;

    return jsonDecode(body);
  }

  // =========================
  // SNACKBARS
  // =========================
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
      colorText: colorText ?? Colors.black87,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      borderRadius: 8,
      icon: _snackIcon(title),
    );
  }

  // ✅ Already submitted snackbar
  void _showAlreadySubmittedSnack() {
    Get.snackbar(
      "Already Submitted",
      "This result is already submitted.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.amber.shade700,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      borderRadius: 8,
      icon: const Icon(Icons.info_outline, color: Colors.white),
    );
  }

  Widget? _snackIcon(String title) {
    switch (title.toLowerCase()) {
      case "success":
        return const Icon(Icons.check_circle, color: Colors.white);
      case "error":
        return const Icon(Icons.error, color: Colors.red);
      case "validation":
        return const Icon(Icons.warning_amber_rounded, color: Colors.orange);
      case "info":
        return const Icon(Icons.info, color: Colors.blue);
      default:
        return null;
    }
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


    if (schoolId.trim().isEmpty) {
      _showSnack("Error", "School ID not found. Please login again.");
      return;
    }

    await loadInitialData();
  }

  // =========================
  // SESSION
  // =========================
  Future<void> _fetchCurrentSession() async {
    try {
      final url =
      Uri.parse('${AppUrl.base_url}${AppUrl.view_session}$schoolId');
      final res = await http.get(url, headers: _headers);
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final sessionModel = SessionModel.fromJson(decoded);
        session =
            sessionModel.currentSession?.session?.toString().trim() ?? "";
        debugPrint("Session fetched: $session");
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    }
  }

  // =========================
  // LOAD DROPDOWNS
  // =========================
  Future<void> loadInitialData() async {
    try {
      isPageLoading(true);
      await _fetchCurrentSession();
      await fetchClassTeacherFilter(); // 🆕 pehle — flag set ho jaye
      await Future.wait([
        fetchClasses(),
        fetchSubjects(),
        fetchSections(),
        fetchTerms(),
        fetchGrades(),
      ]);
    } catch (e) {
      _showSnack("Error", "Failed to load data: $e");
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

  Future<void> fetchClasses() async {
    // 🆕 Class teacher login → ClassTeacher API data se hi banao
    if (isClassTeacherLogin.value) {
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
      selectedClass.value = null;
      return;
    }

    // 🔁 Normal teacher — existing
    try {
      final res = await http.get(Uri.parse(_classUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Classes");
      final ClassListModel parsed = ClassListModel.fromJson(decoded);
      // GetClassTeacher me action null aata hai, isliye filter nahi lagayenge
      classList.assignAll(parsed.listData);
      selectedClass.value = null;
    } catch (e) {
      Get.snackbar("Error", "Class fetch error: $e");
    }
  }

  Future<void> fetchSubjects() async {
    try {
      final res = await http.get(Uri.parse(_subjectUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Subjects");
      final List<dynamic> list = (decoded is Map<String, dynamic>)
          ? (decoded['data'] ?? [])
          : [];
      subjectList.assignAll(
        list.map<ListDaataa>((e) => ListDaataa.fromJson(e)).toList(),
      );
      selectedSubject.value = null;
    } catch (e) {
      subjectList.clear();
      _showSnack("Error", "Subject fetch failed: $e");
    }
  }

  Future<void> fetchSections() async {
    // 🆕 Class teacher login → SectionTeacher API
    if (isClassTeacherLogin.value) {
      try {
        final res =
        await http.get(Uri.parse(_sectionTeacherUrl), headers: _headers);
        final decoded = _safeDecodeResponse(res, label: "SectionTeacher");
        if (decoded == null) {
          sectionList.clear();
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
        _showSnack("Error", "Section fetch failed: $e");
      }
      return;
    }

    // 🔁 Normal teacher — existing
    try {
      final res = await http.get(Uri.parse(_sectionUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Sections");
      if (decoded == null || decoded is! Map<String, dynamic>) {
        sectionList.clear();
        return;
      }
      final sectionModelData = sectionmodel.fromJson(decoded);
      sectionList.assignAll(
        (sectionModelData.listData ?? [])
            .where((e) => (e.action ?? "1") == "1")
            .toList(),
      );
      selectedSection.value = null;
    } catch (e) {
      sectionList.clear();
      selectedSection.value = null;
      _showSnack("Error", "Section fetch failed: $e");
    }
  }

  Future<void> fetchTerms() async {
    try {
      if (session.trim().isEmpty) await _fetchCurrentSession();
      final res = await http.get(Uri.parse(_termUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Terms");
      if (decoded == null) return;
      final TermsResultModel parsed =
      TermsResultModel.fromJson(decoded as Map<String, dynamic>);
      termList.assignAll(
        (parsed.listData ?? [])
            .where((e) => (e.action ?? "1") == "1")
            .toList(),
      );
      selectedTerm.value = null;
    } catch (e) {
      termList.clear();
      selectedTerm.value = null;
      _showSnack("Error", "Term fetch failed: $e");
    }
  }

  // =========================
  // GRADES — ✅ API: ViewGradeActive/{schoolId}
  // =========================
  Future<void> fetchGrades() async {
    try {
      final res = await http.get(Uri.parse(_gradeUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Grades");

      if (decoded == null || decoded is! List) {
        gradeOptions.clear();
        return;
      }

      final GradeListModel parsed = GradeListModel.fromJson(decoded);
      gradeOptions.assignAll(
        parsed.grades
            .where((g) => g.action == "1")
            .map((g) => g.grade)
            .toList(),
      );
    } catch (e) {
      gradeOptions.clear();
      _showSnack("Error", "Grade fetch failed: $e");
    }
  }

  // =========================
  // SEARCH — ViewStudentbyClass
  // ✅ GetResult API call NAHI hogi — sirf students load honge
  // =========================
  Future<void> searchStudents() async {
    if (selectedClass.value == null) {
      _showSnack("Validation", "Please select a Class",
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (selectedSubject.value == null) {
      _showSnack("Validation", "Please select a Subject",
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (selectedSection.value == null) {
      _showSnack("Validation", "Please select a Section",
          backgroundColor: Colors.orange.shade100);
      return;
    }
    if (selectedTerm.value == null) {
      _showSnack("Validation", "Please select a Term",
          backgroundColor: Colors.orange.shade100);
      return;
    }

    try {
      isSearching(true);
      studentList.clear();
      searchQuery.value = "";
      gradeMap.clear();
      submittedStudentIds.clear(); // ✅ Fresh search pe submitted IDs reset

      // ✅ Agar grade list abhi tak load nahi hui to ek baar try kar lo
      if (gradeOptions.isEmpty) {
        await fetchGrades();
      }

      debugPrint("SEARCH URL => $_studentByClassUrl");

      final res = await http.get(
        Uri.parse(_studentByClassUrl),
        headers: _headers,
      );

      final decoded = _safeDecodeResponse(res, label: "ViewStudentbyClass");

      if (decoded == null) {
        _showSnack("Info", "No students found for selected filters.",
            backgroundColor: Colors.blue.shade100, colorText: Colors.black87);
        return;
      }

      List<dynamic> jsonList = [];
      if (decoded is List) {
        jsonList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        jsonList = decoded['data'] ?? decoded['listData'] ?? [];
      }

      if (jsonList.isEmpty) {
        _showSnack("Info", "No students found for selected filters.",
            backgroundColor: Colors.blue.shade100, colorText: Colors.black87);
        return;
      }

      final List<AddResultShow> parsed = AddResultShow.fromJsonList(jsonList);
      studentList.assignAll(parsed);

      // ✅ Default grade = first option (API se) — no GetResult call
      gradeMap.clear();
      for (final s in parsed) {
        gradeMap[s.studentId] =
            RxString(gradeOptions.isNotEmpty ? gradeOptions.first : "");
      }

      _showSnack(
        "Success",
        "${parsed.length} students loaded successfully.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      currentTab.value = 1;
    } catch (e) {
      studentList.clear();
      gradeMap.clear();
      _showSnack("Error", "Search failed: $e");
    } finally {
      isSearching(false);
    }
  }

  // =========================
  // SUBMIT — AddResult POST only
  // ✅ Logic:
  //   - Agar saare students already submitted hain → "Already Submitted" snackbar
  //   - Agar kuch naye hain → sirf unhe POST karo
  //   - POST success ke baad studentId ko submittedStudentIds mein daalo
  // =========================
  Future<void> submitGrades() async {
    if (studentList.isEmpty) {
      _showSnack("Warning", "No students to submit.",
          backgroundColor: Colors.orange.shade100);
      return;
    }

    // ✅ Check: kya saare students already submit ho chuke hain?
    final List<AddResultShow> pendingStudents = studentList
        .where((s) => !submittedStudentIds.contains(s.studentId))
        .toList();

    if (pendingStudents.isEmpty) {
      // Sab already submitted — alag snackbar
      _showAlreadySubmittedSnack();
      return;
    }

    try {
      isSubmitting(true);

      int successCount = 0;
      int failCount = 0;

      for (final s in pendingStudents) {
        try {
          final grade = gradeMap[s.studentId]?.value ??
              (gradeOptions.isNotEmpty ? gradeOptions.first : "");

          final Map<String, dynamic> body = {
            "id": 0, // ✅ Hamesha 0 — server khud handle karega insert/update
            "studentId": s.studentId,
            "studentName": s.studentName,
            "registrationNo": s.registrationNo,
            "class": s.className,
            "fatherName": s.fatherName,
            "classId": s.classId,
            "sectionId": s.sectionId,
            "section": s.section ??
                (selectedSection.value?.section ?? "").toString().trim(),
            "subjectId": s.subjectId,
            "subject": s.subject,
            "term": s.term,
            "grade": grade,
            "session": session,
            "schoolId": schoolId,
            "createBy": "Admin",
          };

          debugPrint(
              "POST AddResult [studentId=${s.studentId}] => ${jsonEncode(body)}");

          final res = await http.post(
            Uri.parse(_addResultUrl),
            headers: _headers,
            body: jsonEncode(body),
          );

          if (res.statusCode == 200 || res.statusCode == 201) {
            successCount++;
            // ✅ Successfully submitted — ID track karo
            submittedStudentIds.add(s.studentId);
          } else {
            failCount++;
            debugPrint(
                "❌ AddResult failed for studentId=${s.studentId}: ${res.statusCode} | ${res.body}");
          }
        } catch (e) {
          failCount++;
          debugPrint("❌ AddResult error for studentId=${s.studentId}: $e");
        }
      }

      // ✅ Result snackbars
      if (failCount == 0) {
        _showSnack(
          "Success",
          "Grades submitted successfully for $successCount student(s).",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (successCount > 0) {
        _showSnack(
          "Warning",
          "$successCount submitted, $failCount failed. Please retry.",
          backgroundColor: Colors.orange.shade200,
          colorText: Colors.black87,
        );
      } else {
        _showSnack(
            "Error", "All submissions failed ($failCount). Please try again.");
      }
    } catch (e) {
      _showSnack("Error", "Submit failed: $e");
    } finally {
      isSubmitting(false);
    }
  }

  // =========================
  // HELPERS
  // =========================
  void clearForm() {
    selectedClass.value = null;
    selectedSubject.value = null;
    selectedSection.value = null;
    selectedTerm.value = null;
    studentList.clear();
    gradeMap.clear();
    submittedStudentIds.clear();
  }

  Future<void> refreshDropdowns() async {
    await _fetchCurrentSession();
    await Future.wait([
      fetchClasses(),
      fetchSubjects(),
      fetchSections(),
      fetchTerms(),
      fetchGrades(),
    ]);
  }
}

