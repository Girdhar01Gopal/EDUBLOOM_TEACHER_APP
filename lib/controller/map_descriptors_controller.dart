import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/descriptors_model.dart';
import '../models/map_descriptor_model.dart';
import '../models/session_model.dart';
import '../models/subject_model.dart';
import '../models/viewsectionmodel.dart';
import '../res/app_url.dart';

class MapDescriptorsController extends GetxController {
  String schoolId = "";
  String token = "";
  String session = "";

  // =========================
  // DROPDOWNS
  // =========================
  final RxList<ListDataa> classList = <ListDataa>[].obs;
  final Rx<ListDataa?> selectedClass = Rx<ListDataa?>(null);

  final RxList<ListDaataa> subjectList = <ListDaataa>[].obs;
  final Rx<ListDaataa?> selectedSubject = Rx<ListDaataa?>(null);

  final RxList<SubjectProgressItem> descriptorList =
      <SubjectProgressItem>[].obs;
  final Rx<SubjectProgressItem?> selectedDescriptor =
  Rx<SubjectProgressItem?>(null);

  // ✅ Section dropdown
  final RxList<dynamic> sectionList = <dynamic>[].obs;
  final Rx<dynamic> selectedSection = Rx<dynamic>(null);

  // =========================
  // VIEW LIST
  // =========================
  final RxList<SubjectData> mapDescriptorList = <SubjectData>[].obs;

  // =========================
  // LOADERS
  // =========================
  final RxBool isPageLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isListLoading = false.obs;

  // =========================
  // URLs
  // =========================
  String get _classUrl =>
      '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';

  String get _subjectUrl =>
      '${AppUrl.base_url}api/MasterApp/ViewSubjectApp/$schoolId';

  // ✅ FIXED: Same API as DescriptorsController — needs session
  String get _descriptorUrl =>
      '${AppUrl.base_url}api/Result/ViewDescriptors/$schoolId/$session';

  String get _sectionUrl =>
      '${AppUrl.base_url}${AppUrl.view_section}$schoolId';

  // ✅ View API with session
  String get _mapDescriptorViewUrl =>
      '${AppUrl.base_url}api/Result/GetAllMapDescriptorsAsync/$schoolId/$session';

  String get _postMapDescriptorUrl =>
      '${AppUrl.base_url}api/Result/PostMapDescriptors';

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

    if (body.trim().isEmpty) return <String, dynamic>{};

    return jsonDecode(body);
  }

  // =========================
  // INIT
  // =========================
  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await loadInitialData();
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
  // ✅ Session fetched first — descriptor & mapList URLs need it
  // =========================
  Future<void> loadInitialData() async {
    try {
      isPageLoading(true);

      // ✅ Session pehle — baaki URLs mein session chahiye
      await _fetchCurrentSession();

      // ✅ Baaki sab parallel
      await Future.wait([
        fetchClasses(),
        fetchSubjects(),
        fetchSections(),
        fetchDescriptorDropdown(),
        fetchMapDescriptors(),
      ]);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isPageLoading(false);
    }
  }

  // =========================
  // CLASS API
  // =========================
  Future<void> fetchClasses() async {
    try {
      final res = await http.get(Uri.parse(_classUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Classes");
      final ClassItem parsed = ClassItem.fromJson(decoded);
      classList.assignAll(
        parsed.listData?.where((e) => e.action == "1").toList() ?? [],
      );
      selectedClass.value = null;
    } catch (e) {
      Get.snackbar("Error", "Class fetch error: $e");
    }
  }

  // =========================
  // SUBJECT API
  // =========================
  Future<void> fetchSubjects() async {
    try {
      final res = await http.get(Uri.parse(_subjectUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Subjects");
      final List<dynamic> list = (decoded is Map<String, dynamic>)
          ? (decoded['listData'] ?? [])
          : [];
      subjectList.assignAll(
        list.map<ListDaataa>((e) => ListDaataa.fromJson(e)).toList(),
      );
      selectedSubject.value = null;
    } catch (e) {
      Get.snackbar("Error", "Subject fetch error: $e");
    }
  }

  // =========================
  // DESCRIPTOR DROPDOWN API
  // ✅ ViewDescriptors — same as DescriptorsController
  // =========================
  Future<void> fetchDescriptorDropdown() async {
    try {
      final res =
      await http.get(Uri.parse(_descriptorUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Descriptors");
      final SubjectProgressResponse parsed =
      SubjectProgressResponse.fromJson(decoded);
      descriptorList.assignAll(
        parsed.listData.where((e) => (e.action ?? "1") == "1").toList(),
      );
      selectedDescriptor.value = null;
    } catch (e) {
      descriptorList.clear();
      selectedDescriptor.value = null;
      Get.snackbar("Error", "Descriptor fetch error: $e");
    }
  }

  // =========================
  // SECTION DROPDOWN API
  // =========================
  Future<void> fetchSections() async {
    try {
      final res = await http.get(Uri.parse(_sectionUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Sections");
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
      Get.snackbar("Error", "Section fetch error: $e");
    }
  }

  // =========================
  // VIEW API — GetAllMapDescriptorsAsync
  // =========================
  Future<void> fetchMapDescriptors() async {
    try {
      isListLoading(true);

      if (session.trim().isEmpty) await _fetchCurrentSession();

      final res = await http.get(
        Uri.parse(_mapDescriptorViewUrl),
        headers: _headers,
      );
      final decoded =
      _safeDecodeResponse(res, label: "MapDescriptorsView");

      final SubjectResponse parsed = SubjectResponse.fromJson(decoded);

      if (parsed.isSuccess == true) {
        mapDescriptorList.assignAll(parsed.data ?? []);
      } else {
        mapDescriptorList.clear();
        Get.snackbar(
          "Error",
          parsed.messages ?? "Unable to load mapped descriptors",
        );
      }
    } catch (e) {
      mapDescriptorList.clear();
      Get.snackbar("Error", "View list fetch error: $e");
    } finally {
      isListLoading(false);
    }
  }

  // =========================
  // DUPLICATE CHECK
  // =========================
  bool get isDuplicateSelection {
    final c = selectedClass.value;
    final d = selectedDescriptor.value;
    final s = selectedSubject.value;
    final sec = selectedSection.value;

    if (c == null || d == null || s == null || sec == null) return false;

    return mapDescriptorList.any(
          (x) =>
      x.classId == c.classId &&
          x.subjectId == s.subjectId &&
          (x.descriptors ?? "").toLowerCase().trim() ==
              (d.descriptors ?? "").toLowerCase().trim() &&
          x.sectionId == (sec.sectionId as int?),
    );
  }

  // =========================
  // SAVE — POST API
  // =========================
  Future<void> saveMap() async {
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
    if (selectedDescriptor.value == null) {
      Get.snackbar("Validation", "Select Descriptor");
      return;
    }
    if (isDuplicateSelection) {
      Get.snackbar(
        "Warning",
        "This class, section, descriptor and subject is already mapped",
      );
      return;
    }

    try {
      isSaving(true);

      final Map<String, dynamic> body = {
        "id": 0,
        "classId": selectedClass.value?.classId ?? 0,
        "sectionId": selectedSection.value?.sectionId ?? 0,
        "subjectId": selectedSubject.value?.subjectId ?? 0,
        "descriptors": selectedDescriptor.value?.descriptors ?? "",
        "action": "1",
        "createDate": DateTime.now().toUtc().toIso8601String(),
        "updateDate": DateTime.now().toUtc().toIso8601String(),
        "createBy": "admin",
        "updateBy": "admin",
        "schoolId": schoolId,
        "session": session,
      };

      final res = await http.post(
        Uri.parse(_postMapDescriptorUrl),
        headers: _headers,
        body: jsonEncode(body),
      );

      final decoded =
      _safeDecodeResponse(res, label: "PostMapDescriptor");

      if (decoded is Map<String, dynamic>) {
        final bool isSuccess = decoded["isSuccess"] == true;
        final String message =
        (decoded["messages"] ?? "Mapped successfully").toString();

        if (isSuccess) {
          await fetchMapDescriptors();
          clearForm();
          Get.snackbar("Success", message);
        } else {
          Get.snackbar("Error", message);
        }
      } else {
        Get.snackbar("Error", "Invalid server response");
      }
    } catch (e) {
      Get.snackbar("Error", "Save failed: $e");
    } finally {
      isSaving(false);
    }
  }

  // =========================
  // HELPERS
  // =========================
  DateTime? parseDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  void clearForm() {
    selectedClass.value = null;
    selectedSection.value = null;
    selectedSubject.value = null;
    selectedDescriptor.value = null;
  }
}