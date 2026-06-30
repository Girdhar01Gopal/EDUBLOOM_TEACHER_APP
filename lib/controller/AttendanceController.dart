import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/AttendanceModel.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/session_model.dart' as session_model;
import '../res/app_url.dart';

class AttendanceController extends GetxController {
  // ── Observables ────────────────────────────────────────────────────────────
  RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);
  var session = ''.obs;

  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rx<ListDatta?>(null);

  var students = <ListData>[].obs;

  var isLoading = false.obs;
  var isSubmitting = false.obs;

  // ── Search ─────────────────────────────────────────────────────────────────
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  // ── Already-submitted date keys ────────────────────────────────────────────
  final Set<String> _submittedKeys = {};

  // FIX #4: Sirf tab true karo jab API se already-marked data aaye (special flag)
  var isAttendanceAlreadyMarked = false.obs;

  String schoolId = "";
  String token = "";

  TextEditingController dateController = TextEditingController();
  var selectedRawDate = ''.obs;

  static const List<String> validStatuses = [
    "Present",
    "Absent",
    "WeekOff",
    "Halfday",
  ];

  String get _currentKey =>
      "${selectedClass.value?.classId}-"
          "${selectedSection.value?.sectionId}-"
          "${selectedRawDate.value.trim()}";

  List<ListData> get filteredStudents {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return students;
    return students
        .where((s) => (s.studentName ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onClose() {
    searchController.dispose();
    dateController.dispose();
    super.onClose();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
      searchController.clear();
    }
  }

  void onSearchChanged(String value) => searchQuery.value = value;
  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    try {
      schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
      token = await PrefManager().readValue(key: PrefConst.token) ?? "";
      await Future.wait([fetchSessions(), fetchClasses(), fetchSections()]);
    } catch (e) {
      _snack("Error", "Initialization failed: $e", color: Colors.red.shade600);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSessions() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        sessionList.clear();
        if (json['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: json['currentSession']['currentSessionId'],
            session: json['currentSession']['currentSession'],
            action: json['currentSession']['action'],
            schoolId: json['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
          session.value = cs.session ?? "";
        }
      } else {
        _snack("Error", "Session load failed (${res.statusCode})",
            color: Colors.red.shade600);
      }
    } catch (e) {
      _snack("Error", "Sessions error: $e", color: Colors.red.shade600);
    }
  }

  Future<void> fetchClasses() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
      );
      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        listDataa.value =
            parsed.listData?.where((e) => e.action == "1").toList() ?? [];
        selectedClass.value = null;
      } else {
        _snack("Error", "Classes load failed (${res.statusCode})",
            color: Colors.red.shade600);
      }
    } catch (e) {
      _snack("Error", "Classes error: $e", color: Colors.red.shade600);
    }
  }

  Future<void> fetchSections() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId'),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        List<dynamic> data = decoded['listData'] ?? decoded['data'] ?? [];
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      } else {
        _snack("Error", "Sections load failed (${res.statusCode})",
            color: Colors.red.shade600);
      }
    } catch (e) {
      _snack("Error", "Sections error: $e", color: Colors.red.shade600);
    }
  }

  void setSelectedSection(ListDatta? s) => selectedSection.value = s;
  void setSelectedClass(ListDataa? c) => selectedClass.value = c;
  void setSelectedSession(session_model.sListDdata? s) {
    selectedSession.value = s;
    session.value = s?.session ?? '';
  }

  bool _validateFilters() {
    if (schoolId.isEmpty) {
      _snack("Validation", "School ID not found",
          color: Colors.orange.shade700, icon: Icons.warning_amber_rounded);
      return false;
    }
    if ((selectedSession.value?.session ?? "").isEmpty) {
      _snack("Validation", "Please select a session",
          color: Colors.orange.shade700, icon: Icons.warning_amber_rounded);
      return false;
    }
    if (selectedClass.value?.classId == null ||
        selectedClass.value!.classId == 0) {
      _snack("Validation", "Please select a class",
          color: Colors.orange.shade700, icon: Icons.warning_amber_rounded);
      return false;
    }
    if (selectedSection.value?.sectionId == null ||
        selectedSection.value!.sectionId == 0) {
      _snack("Validation", "Please select a section",
          color: Colors.orange.shade700, icon: Icons.warning_amber_rounded);
      return false;
    }
    if (selectedRawDate.value.trim().isEmpty) {
      _snack("Validation", "Please select a date",
          color: Colors.orange.shade700, icon: Icons.warning_amber_rounded);
      return false;
    }
    return true;
  }

  Future<void> viewStudent() async {
    if (!_validateFilters()) return;

    clearSearch();
    isSearching.value = false;
    isAttendanceAlreadyMarked.value = false;

    isLoading.value = true;
    students.clear();

    try {
      final url = Uri.parse(
          '${AppUrl.base_url}api/StudentApp/ViewStudentAttendenceApp');

      final body = {
        "session": selectedSession.value?.session ?? session.value,
        "classId": selectedClass.value?.classId,
        "sectionId": selectedSection.value?.sectionId,
        "date": selectedRawDate.value.trim(),
        "schoolId": schoolId,
      };

      debugPrint("🔹 viewStudent POST => $url");
      debugPrint("📦 Body => ${jsonEncode(body)}");

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint("📥 Code => ${res.statusCode}");
      debugPrint("📥 Body => ${res.body}");

      if (res.statusCode == 200) {
        final parsed = attendencestudent.fromJson(jsonDecode(res.body));
        final List<ListData> loaded = parsed.listData ?? [];

        // ── FIX #4: Sirf tab already marked mano jab submitted key ho ──
        // Ya API se koi NON-default status aaya ho (Absent/WeekOff/Halfday)
        bool alreadyMarked = _submittedKeys.contains(_currentKey);

        if (!alreadyMarked && loaded.isNotEmpty) {
          // Sirf tab already-marked mano jab koi student Absent/WeekOff/Halfday ho
          // (agar sabka "Present" hai toh ye fresh list bhi ho sakti hai)
          alreadyMarked = loaded.any(
                (s) =>
            s.action == "Absent" ||
                s.action == "WeekOff" ||
                s.action == "Halfday",
          );
        }

        // ── Normalise action field ──────────────────────────────────────
        for (final s in loaded) {
          if (!validStatuses.contains(s.action ?? "")) {
            s.action = "Present";
          }
        }

        students.assignAll(loaded);
        isAttendanceAlreadyMarked.value = alreadyMarked;

        if (students.isEmpty) {
          _snack("Info", "No students found for selected filters",
              color: Colors.orange.shade600, icon: Icons.info_outline);
        } else if (alreadyMarked) {
          _snack(
            "Attendance Already Marked",
            "Attendance for this date has already been submitted.",
            color: Colors.blue.shade600,
            icon: Icons.event_available_rounded,
            duration: const Duration(seconds: 4),
          );
        } else {
          _snack(
            "Students Loaded",
            "${students.length} students loaded — select status & submit",
            color: Colors.green.shade600,
            icon: Icons.check_circle,
          );
        }
      } else {
        _snack("Error", "Failed to load students (${res.statusCode})",
            color: Colors.red.shade600);
      }
    } catch (e) {
      _snack("Error", "Something went wrong: $e", color: Colors.red.shade600);
    } finally {
      isLoading.value = false;
    }
  }

  // ── FIX #1 & #2: classId/sectionId properly set karo, date parse safely karo
  Future<bool> _saveOneStudent(ListData student) async {
    final String status = validStatuses.contains(student.action ?? "")
        ? student.action!
        : "Present";

    // FIX #1: Controller se classId/sectionId lo — model mein nahi hote
    final int classId =
        student.classId ?? selectedClass.value?.classId ?? 0;
    final int sectionId =
        student.sectionId ?? selectedSection.value?.sectionId ?? 0;

    // FIX #2: Date parse safely karo
    int month = DateTime.now().month;
    try {
      if (selectedRawDate.value.trim().isNotEmpty) {
        month = DateTime.parse(selectedRawDate.value.trim()).month;
      }
    } catch (_) {
      debugPrint("⚠️ Date parse error — using current month");
    }

    try {
      final url =
      Uri.parse('${AppUrl.base_url}api/StudentApp/SaveAttendenceApp');

      final body = <String, dynamic>{
        "studentId": student.studentID,
        "status": status,
        "months": month,
        "session": selectedSession.value?.session ?? session.value,
        "classId": classId,
        "sectionId": sectionId,
        "adate": selectedRawDate.value.trim(),
        "schoolId": schoolId,
        "userAttendance": "Admin",
      };

      debugPrint(
          "📤 [${student.studentName}] status=$status classId=$classId sectionId=$sectionId => ${jsonEncode(body)}");

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint(
          "📥 Save [${student.studentID}] => ${res.statusCode} | ${res.body}");

      // FIX #3: Kuch APIs 201 ya 204 bhi deti hain success ke liye
      return res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204;
    } catch (e) {
      debugPrint("⚠️ Error saving [${student.studentID}]: $e");
      return false;
    }
  }

  Future<void> manageAttendance() async {
    if (!_validateFilters()) return;

    if (students.isEmpty) {
      _snack(
        "Error",
        "No students loaded — tap 'Manage Attendance' first",
        color: Colors.red.shade600,
        icon: Icons.error_outline,
      );
      return;
    }

    if (_submittedKeys.contains(_currentKey)) {
      _snack(
        "Already Submitted",
        "Attendance for this date is already marked.\nChange the date or class/section to submit again.",
        color: Colors.blue.shade600,
        icon: Icons.event_available_rounded,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (isSubmitting.value) return;
    isSubmitting.value = true;

    _snack(
      "Submitting…",
      "Saving attendance for ${students.length} students",
      color: Colors.teal.shade700,
      icon: Icons.cloud_upload_outlined,
      duration: const Duration(seconds: 2),
    );

    try {
      // FIX: Ek baar mein sab parallel mat karo — agar server rate limit kare
      // toh 5-5 ke batches mein bhejo
      final List<bool> results = [];
      const batchSize = 5;
      final studentList = students.toList();

      for (int i = 0; i < studentList.length; i += batchSize) {
        final batch = studentList.sublist(
          i,
          i + batchSize > studentList.length
              ? studentList.length
              : i + batchSize,
        );
        final batchResults = await Future.wait(batch.map(_saveOneStudent));
        results.addAll(batchResults);
        // Thoda ruko batches ke beech mein
        if (i + batchSize < studentList.length) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      final int successCount = results.where((r) => r).length;
      final int failCount = results.where((r) => !r).length;

      if (failCount == 0) {
        _submittedKeys.add(_currentKey);
        isAttendanceAlreadyMarked.value = true;

        _snack(
          "Attendance Submitted",
          "Saved for all $successCount students successfully ✓",
          color: Colors.green.shade600,
          icon: Icons.check_circle_outline,
          duration: const Duration(seconds: 3),
        );
        await Future.delayed(const Duration(milliseconds: 900));
        Get.back();
      } else if (successCount > 0) {
        _snack(
          "Partial Success",
          "$successCount saved, $failCount failed — please retry",
          color: Colors.orange.shade600,
          icon: Icons.warning_amber_rounded,
        );
      } else {
        _snack(
          "Submit Failed",
          "Could not save attendance. Check connection & retry.\n(Check debug logs for details)",
          color: Colors.red.shade600,
          icon: Icons.error_outline,
        );
      }
    } catch (e) {
      _snack("Error", "Unexpected error: $e", color: Colors.red.shade600);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _snack(
      String title,
      String message, {
        Color? color,
        IconData? icon,
        Duration duration = const Duration(seconds: 3),
      }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color ?? Colors.teal.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      borderRadius: 14,
      margin: const EdgeInsets.all(12),
      duration: duration,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      icon: icon != null ? Icon(icon, color: Colors.white, size: 24) : null,
    );
  }
}