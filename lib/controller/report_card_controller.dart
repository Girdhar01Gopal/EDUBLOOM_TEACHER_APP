import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/session_model.dart' as session_model; // ✅ fixed: relative import
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/ReportCardData1.dart';
import '../models/classmodel.dart';
// ❌ removed: import '../models/session_model.dart';  -> this caused duplicate import / type-mismatch
import '../models/terms_result_model.dart';
import '../models/viewsectionmodel.dart';
import '../res/app_url.dart';

class ReportCardController extends GetxController {
  // =========================
  // DATA
  // =========================
  // Raw full list from API
  final RxList<ReportCardData1> reportCardList = <ReportCardData1>[].obs;

  // Unique students (grouped by studentId) for display
  final RxList<ReportCardData1> uniqueStudentList = <ReportCardData1>[].obs;

  // =========================
  // DROPDOWNS
  // =========================
  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs; // ✅ fixed type
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null); // ✅ fixed type
  var session = ''.obs;

  // Section
  final RxList<dynamic> sectionList = <dynamic>[].obs;
  final Rx<dynamic> selectedSection = Rx<dynamic>(null);

  // Term
  RxList<TermData> termList = <TermData>[].obs;
  Rx<TermData?> selectedTerm = Rx<TermData?>(null);

  // =========================
  // LOADERS
  // =========================
  var isLoading = true.obs;
  var isSearching = false.obs;

  // =========================
  // CREDENTIALS
  // =========================
  String token = "";
  String schoolId = "";

  // =========================
  // URLs
  // =========================
  String get _classUrl =>
      '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';

  String get _sessionUrl =>
      '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

  String get _sectionUrl =>
      '${AppUrl.base_url}${AppUrl.view_section}$schoolId';

  String get _termUrl =>
      '${AppUrl.base_url}api/Result/ViewTerm/$schoolId/${session.value}';

  // ViewStudentRePortCard/{classId}/{session}/{term}/{schoolId}/{sectionId}
  String get _reportCardUrl {
    final classId = selectedClass.value?.classId ?? 0;
    final sectionId = selectedSection.value?.sectionId ?? 0;
    final termVal = Uri.encodeComponent(selectedTerm.value?.term ?? "");
    final sessionVal = Uri.encodeComponent(session.value);
    return '${AppUrl.base_url}api/Result/ViewStudentRePortCard/$classId/$sessionVal/$termVal/$schoolId/$sectionId';
  }

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

    debugPrint("[$label] STATUS: ${res.statusCode}");
    debugPrint("[$label] BODY(300): $preview");

    if (preview.toLowerCase().contains("<!doctype html") ||
        ct.contains("text/html")) {
      throw Exception("[$label] Server returned HTML.");
    }
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("[$label] HTTP ${res.statusCode}");
    }
    if (body.trim().isEmpty) return null;
    return jsonDecode(body);
  }

  void _showSnack(String title, String message,
      {Color bg = Colors.red, Color textColor = Colors.white}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: bg,
      colorText: textColor,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
      borderRadius: 8,
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

    if (schoolId.trim().isEmpty) {
      _showSnack("Error", "School ID not found. Please login again.");
      return;
    }

    await loadInitialData();
  }

  // =========================
  // LOAD ALL DROPDOWNS
  // =========================
  Future<void> loadInitialData() async {
    try {
      isLoading(true);
      // Session pehle fetch karo — term URL mein session chahiye
      await fetchSessions();
      await Future.wait([
        fetchClasses(),
        fetchSections(),
        fetchTerms(),
      ]);
    } catch (e) {
      _showSnack("Error", "Failed to load data: $e");
    } finally {
      isLoading(false);
    }
  }

  // =========================
  // FETCH CLASSES
  // =========================
  Future<void> fetchClasses() async {
    try {
      final res =
      await http.get(Uri.parse(_classUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Classes");
      final ClassItem parsed = ClassItem.fromJson(decoded);
      listDataa.assignAll(
        parsed.listData?.where((e) => e.action == "1").toList() ?? [],
      );
      selectedClass.value = null;
    } catch (e) {
      listDataa.clear();
      _showSnack("Error", "Class fetch failed: $e");
    }
  }

  // =========================
  // FETCH SESSIONS
  // =========================
  Future<void> fetchSessions() async {
    try {
      final res =
      await http.get(Uri.parse(_sessionUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "Sessions");
      if (decoded == null) return;

      sessionList.clear();

      // Current session
      if (decoded['currentSession'] != null) {
        final cs = session_model.sListDdata(
          sessionId: decoded['currentSession']['currentSessionId'],
          session: decoded['currentSession']['currentSession'],
          action: decoded['currentSession']['action'],
          schoolId: decoded['currentSession']['schoolId'],
        );
        sessionList.add(cs);
        // Auto-select current session
        selectedSession.value = cs;
        session.value = cs.session ?? '';
      }

      // All sessions from listData
      if (decoded['listData'] != null && decoded['listData'] is List) {
        final extra = (decoded['listData'] as List)
            .map((e) => session_model.sListDdata.fromJson(e))
            .toList();
        for (final item in extra) {
          final bool exists =
          sessionList.any((x) => x.session == item.session);
          if (!exists) sessionList.add(item);
        }
      }
    } catch (e) {
      _showSnack("Error", "Session fetch failed: $e");
    }
  }

  // =========================
  // FETCH SECTIONS
  // =========================
  Future<void> fetchSections() async {
    try {
      final res =
      await http.get(Uri.parse(_sectionUrl), headers: _headers);
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

  // =========================
  // FETCH TERMS
  // =========================
  Future<void> fetchTerms() async {
    try {
      final res =
      await http.get(Uri.parse(_termUrl), headers: _headers);
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
  // SEARCH REPORT CARDS
  // API: ViewStudentRePortCard/{classId}/{session}/{term}/{schoolId}/{sectionId}
  // =========================
  Future<void> searchReportCards() async {
    if (selectedClass.value == null) {
      _showSnack("Validation", "Please select a Class",
          bg: Colors.orange.shade600);
      return;
    }
    if (selectedSession.value == null) {
      _showSnack("Validation", "Please select a Session",
          bg: Colors.orange.shade600);
      return;
    }
    if (selectedSection.value == null) {
      _showSnack("Validation", "Please select a Section",
          bg: Colors.orange.shade600);
      return;
    }
    if (selectedTerm.value == null) {
      _showSnack("Validation", "Please select a Term",
          bg: Colors.orange.shade600);
      return;
    }

    try {
      isSearching(true);
      reportCardList.clear();
      uniqueStudentList.clear();

      debugPrint("REPORT CARD URL => $_reportCardUrl");

      final res = await http.get(Uri.parse(_reportCardUrl), headers: _headers);
      final decoded = _safeDecodeResponse(res, label: "ReportCard");

      if (decoded == null) {
        _showSnack("Info", "No data found.", bg: Colors.blue.shade600);
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
            bg: Colors.blue.shade600);
        return;
      }

      final List<ReportCardData1> allRecords =
      ReportCardData1.fromJsonList(jsonList);
      reportCardList.assignAll(allRecords);

      // ── Unique students by studentId (first occurrence) ──
      final seen = <int>{};
      final unique = <ReportCardData1>[];
      for (final r in allRecords) {
        if (!seen.contains(r.studentId)) {
          seen.add(r.studentId);
          unique.add(r);
        }
      }
      uniqueStudentList.assignAll(unique);

      _showSnack(
        "Success",
        "${unique.length} student(s) found.",
        bg: Colors.green,
      );
    } catch (e) {
      reportCardList.clear();
      uniqueStudentList.clear();
      _showSnack("Error", "Search failed: $e");
    } finally {
      isSearching(false);
    }
  }

  void setSelectedClass(ListDataa? val) => selectedClass.value = val;
}