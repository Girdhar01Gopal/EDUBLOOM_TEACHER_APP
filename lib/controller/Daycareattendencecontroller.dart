import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/Daycareattendencemodel.dart';
import '../models/session_model.dart' as session_model;
import '../res/app_url.dart';

class Daycareattendencecontroller extends GetxController {
  RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);

  var session = ''.obs;
  var students = <dListData>[].obs;

  var isLoading = false.obs;
  var isSubmitting = false.obs;

  String schoolId = "";
  String token = "";

  final TextEditingController dateController = TextEditingController();
  var selectedRawDate = ''.obs;

  final Set<String> _submittedKeys = {};

  String get _currentKey =>
      "${selectedSession.value?.session ?? session.value}-"
          "${selectedRawDate.value.trim()}";

  // ── Valid statuses ─────────────────────────────────────────────────────────
  static const List<String> _validStatuses = ["Present", "Absent"];

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    try {
      isLoading.value = true;
      schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
      token = await PrefManager().readValue(key: PrefConst.token) ?? "";
      await fetchSessions();
    } catch (e) {
      _showError("Initialization failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
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
          session.value = cs.session ?? "";
        }
      } else {
        _showError("Failed to load session");
      }
    } catch (e) {
      _showError("Failed to load sessions: $e");
    }
  }

  void setSelectedSession(session_model.sListDdata? value) {
    selectedSession.value = value;
    session.value = value?.session ?? "";
  }

  // ── Format TimeOfDay to 24hr "HH:mm" ──────────────────────────────────────
  String formatTime(TimeOfDay time) {
    final h = time.hour.toString(); // no padding
    final m = time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  // ── Normalize action — "1", null, empty → "Present" ───────────────────────
  String _normalizeStatus(String? raw) {
    if (raw == null || raw.trim().isEmpty || !_validStatuses.contains(raw.trim())) {
      return "Present";
    }
    return raw.trim();
  }

  bool validateBeforeLoad() {
    if ((selectedSession.value?.session ?? session.value).trim().isEmpty) {
      _showError("Please select session");
      return false;
    }
    if (selectedRawDate.value.trim().isEmpty) {
      _showError("Please select date");
      return false;
    }
    if (schoolId.trim().isEmpty) {
      _showError("School ID not found");
      return false;
    }
    return true;
  }

  bool validateBeforeSubmit() {
    if (!validateBeforeLoad()) return false;
    if (students.isEmpty) {
      _showError("No students to submit");
      return false;
    }
    for (final student in students) {
      final status = _normalizeStatus(student.action);
      if (status == "Present") {
        if ((student.fromTime ?? "").trim().isEmpty) {
          _showError(
              "Start Time missing for ${student.studentName ?? 'student'}");
          return false;
        }
        if ((student.toTime ?? "").trim().isEmpty) {
          _showError(
              "End Time missing for ${student.studentName ?? 'student'}");
          return false;
        }
        // ── Validate toTime > fromTime ─────────────────────────────────
        final from = _parseTime(student.fromTime ?? "");
        final to = _parseTime(student.toTime ?? "");
        if (from != null && to != null && !to.isAfter(from)) {
          _showError(
              "End Time must be after Start Time for ${student.studentName ?? 'student'}");
          return false;
        }
      }
    }
    return true;
  }

  // ── Parse "HH:mm" to DateTime for comparison ──────────────────────────────
  DateTime? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(":");
      if (parts.length != 2) return null;
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return DateTime(2000, 1, 1, h, m);
    } catch (_) {
      return null;
    }
  }

  Future<void> viewStudent() async {
    if (!validateBeforeLoad()) return;
    try {
      isLoading.value = true;
      final currentSession = selectedSession.value?.session ?? session.value;
      final url = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/GetAllDaycareStudentsAsyncApp'
            '?schoolId=$schoolId&currentSession=$currentSession',
      );
      debugPrint("📍 Calling URL => $url");
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final parsed = daycareattendance.fromJson(jsonData);
        students.value = parsed.data ?? [];
        for (var s in students) {
          // ── FIX: "1", null, empty, invalid → "Present" ────────────────
          s.action = _normalizeStatus(s.action);
          s.fromTime ??= "";
          s.toTime ??= "";
        }
        students.refresh();
        if (students.isEmpty) {
          _showError("No students found");
        } else {
          _showSuccess("Students loaded successfully");
        }
      } else {
        debugPrint("❌ Status ${response.statusCode}");
        debugPrint("❌ Body ${response.body}");
        _showError("Failed to load students");
      }
    } catch (e) {
      debugPrint("❌ Exception => $e");
      _showError("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }

  void updateAttendanceStatus(int index, String status) {
    students[index].action = status;
    if (status == "Absent") {
      students[index].fromTime = "";
      students[index].toTime = "";
    }
    students.refresh();
  }

  void updateStudentFromTime(int index, String value) {
    students[index].fromTime = value;
    students[index].action = "Present";
    students.refresh();
  }

  void updateStudentToTime(int index, String value) {
    students[index].toTime = value;
    students[index].action = "Present";
    students.refresh();
  }

  Future<bool> addAttendance({required dListData student}) async {
    try {
      final url = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/DaycareSaveAttendenceApp',
      );
      final currentSession = selectedSession.value?.session ?? session.value;
      final selectedDateStr = selectedRawDate.value.trim();
      final DateTime selectedDate = DateTime.parse(selectedDateStr);

      final String adate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
        DateTime.now().second,
      ).toUtc().toIso8601String();

      // ── FIX: always normalize status before sending ────────────────────
      final String status = _normalizeStatus(student.action);

      final body = {
        "sadId": 0,
        "studentId": student.studentID ?? 0,
        "status": status,
        "months": selectedDate.month,
        "session": currentSession,
        "fromTime": status == "Present" ? (student.fromTime ?? "") : "",
        "toTime": status == "Present" ? (student.toTime ?? "") : "",
        "day": selectedDate.day.toString(),
        "adate": adate,
        "action": "1",
        "schoolId": schoolId,
        "userAttendance": "Admin",
        "isSelected": true,
        "isPresent": status == "Present",
      };

      debugPrint("📦 Sending => ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      debugPrint("📥 CODE => ${response.statusCode}");
      debugPrint("📥 BODY => ${response.body}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded.containsKey("isSuccess")) {
            return decoded["isSuccess"] == true;
          }
          return true;
        } catch (_) {
          return true;
        }
      }
      return false;
    } catch (e, stack) {
      debugPrint("⚠️ EXCEPTION => $e");
      debugPrint("⚠️ STACK => $stack");
      return false;
    }
  }

  Future<void> manageAttendance() async {
    if (!validateBeforeSubmit()) return;
    if (isSubmitting.value) return;

    if (_submittedKeys.contains(_currentKey)) {
      Get.snackbar(
        "Already Submitted",
        "Attendance for this date is already marked.\nChange the date to submit again.",
        backgroundColor: Colors.blue.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        borderRadius: 14,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 4),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      int successCount = 0;
      int failCount = 0;

      for (final student in students) {
        final result = await addAttendance(student: student);
        if (result) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (successCount > 0 && failCount == 0) {
        _submittedKeys.add(_currentKey);
        _showSuccess("Attendance saved successfully");
        await viewStudent();
      } else if (successCount > 0 && failCount > 0) {
        Get.snackbar(
          "Partial Success",
          "$successCount saved, $failCount failed",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
        );
      } else {
        _showError("Attendance not saved");
      }
    } catch (e) {
      _showError("Submit failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    dateController.dispose();
    super.onClose();
  }
}