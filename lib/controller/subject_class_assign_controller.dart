import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/SubjectClassAssignModel.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';
import '../res/app_url.dart';

class SubjectClassAssignController extends GetxController {
  String schoolId = "";
  String token = "";

  // =========================
  // DROPDOWNS
  // =========================
  final classList = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final sectionList = <ListDatta>[].obs;
  final selectedSection = Rx<ListDatta?>(null);

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
  String get _classUrl => '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
  String get _sectionUrl => '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';
  String get _subjectUrl => '${AppUrl.base_url}api/MasterApp/ViewSubjectApp/$schoolId';

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

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await loadAll();
  }

  Future<void> loadAll() async {
    try {
      isPageLoading(true);
      await Future.wait([
        fetchClasses(),
        fetchSections(),
        fetchSubjects(),
        fetchSubjectClassAssignList(),
      ]);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isPageLoading(false);
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
      classList.assignAll(
        parsed.listData?.where((e) => e.action == "1").toList() ?? [],
      );
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

      final list = (decoded is Map<String, dynamic>)
          ? (decoded['listData'] ?? [])
          : [];

      sectionList.assignAll(
        (list as List).map<ListDatta>((e) => ListDatta.fromJson(e)).toList(),
      );
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

      final list = (decoded is Map<String, dynamic>)
          ? (decoded['listData'] ?? [])
          : [];

      subjectList.assignAll(
        (list as List).map<ListDaataa>((e) => ListDaataa.fromJson(e)).toList(),
      );
      selectedSubject.value = null;
    } catch (e) {
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
        "classId": selectedClass.value?.classId ?? 0,
        "subjectId": selectedSubject.value?.subjectId ?? 0,
        "sectionId": selectedSection.value?.sectionId ?? 0,
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