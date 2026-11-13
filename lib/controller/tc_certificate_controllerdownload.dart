import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/classmodel.dart';
import '../models/session_model.dart' as session_model;
import '../models/tc_certificate_modeldownload.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart'; // 🆕 ADDED: common snackbar

const Map<String, String> _jsonHeaders = <String, String>{
  'Content-Type': 'application/json',
};

class TcCertificateController extends GetxController {
  // ✅ TcStudentData — koi conflict nahi
  final Rx<TcStudentData?> studentDetail = Rx<TcStudentData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs; // ── Save button loader

  late int studentId;
  late String schoolId;
  late String currentSession;

  // ── Session Dropdown ────────────────────────────────────────
  final RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  final Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);

  // ── Class Dropdown ──────────────────────────────────────────
  final RxList<ListDataa> classList = <ListDataa>[].obs;
  final Rx<ListDataa?> selectedClass = Rx<ListDataa?>(null);

  final TextEditingController srNoController = TextEditingController();
  final TextEditingController registrationNoController =
  TextEditingController();
  final TextEditingController studentNameController =
  TextEditingController();
  final TextEditingController motherNameController =
  TextEditingController();
  final TextEditingController fatherNameController =
  TextEditingController();
  final TextEditingController admissionDateController =
  TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController feesPaidController =
  TextEditingController();
  final TextEditingController dateOfIssueController =
  TextEditingController();
  final TextEditingController reasonController =
  TextEditingController();
  final TextEditingController remarksController =
  TextEditingController();

  // ---------------- Common helpers (repeat hone wala code) ----------------

  /// API fail (non-200) pe user ko "Something went wrong", asli error console me
  void _apiFailed(String apiName, int statusCode) {
    AppSnackbar.apiError(
      '$apiName failed: $statusCode',
      statusCode: statusCode,
    );
  }

  /// dd-mm-yyyy
  String _formatDate(DateTime dt) {
    return "${dt.day.toString().padLeft(2, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-"
        "${dt.year}";
  }

  /// API ki date string parse karke field me dd-mm-yyyy set karta hai
  void _setDateField(TextEditingController field, String? rawDate) {
    if (rawDate != null) {
      final DateTime? dt = DateTime.tryParse(rawDate);
      if (dt != null) {
        field.text = _formatDate(dt);
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args =
    Get.arguments as Map<String, dynamic>;
    studentId = args['studentId'];
    schoolId = args['schoolId'];
    currentSession = args['currentSession'];
    Future.wait([
      fetchSessions(),
      fetchClasses(),
      fetchStudentDetails(),
    ]);
  }

  // ── Fetch Sessions ──────────────────────────────────────────
  Future<void> fetchSessions() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _jsonHeaders,
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        sessionList.clear();
        final current = jsonData['currentSession'];
        if (current != null) {
          final cs = session_model.sListDdata(
            sessionId: current['currentSessionId'],
            session: current['currentSession'],
            action: current['action'],
            schoolId: current['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
        }
      } else {
        // 🆕 ADDED: API fail pe snackbar
        _apiFailed('ViewSessionApp', response.statusCode);
      }
    } catch (e, stack) {
      // 🆕 CHANGED: raw error (URL wagairah) user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: stack);
    }
  }

  // ── Fetch Classes ───────────────────────────────────────────
  Future<void> fetchClasses() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        classList.value =
            parsed.listData?.where((e) => e.action == "1").toList() ??
                [];
      } else {
        // 🆕 ADDED: API fail pe snackbar
        _apiFailed('ViewClass', res.statusCode);
      }
    } catch (e, stack) {
      // 🆕 CHANGED: raw error nahi dikhega
      AppSnackbar.apiError(e, stackTrace: stack);
    }
  }

  // ── Fetch Student Details ───────────────────────────────────
  Future<void> fetchStudentDetails() async {
    final String url =
        '${AppUrl.base_url}api/StudentApp/GetStudentDetailsIdCardApp'
        '?studentIds=$studentId&schoolId=$schoolId&currentSession=$currentSession';

    try {
      isLoading(true);

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final TcCertificateModel model =
        TcCertificateModel.fromJson(jsonData);

        if (model.data != null && model.data!.isNotEmpty) {
          studentDetail.value = model.data!.first;
          _populateFields(model.data!.first);
        } else {
          // 🆕 CHANGED: Get.snackbar -> AppSnackbar.error
          AppSnackbar.error('No student data found.');
        }
      } else {
        // 🆕 CHANGED: status code user ko nahi dikhega, sirf console me
        AppSnackbar.apiError(
          'Failed to load. Status: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stack) {
      // 🆕 CHANGED: raw error nahi dikhega
      AppSnackbar.apiError(e, stackTrace: stack);
    } finally {
      isLoading(false);
    }
  }

  // ── Populate Fields ─────────────────────────────────────────
  void _populateFields(TcStudentData student) {
    registrationNoController.text = student.registrationNo ?? "";
    studentNameController.text = student.studentName ?? "";
    motherNameController.text = student.motherName ?? "";
    fatherNameController.text = student.fatherName ?? "";

    // Session — match from sessionList by session string
    if (student.session != null && sessionList.isNotEmpty) {
      final matched = sessionList.firstWhereOrNull(
            (s) => s.session == student.session,
      );
      selectedSession.value = matched ?? sessionList.first;
    }

    // Class — match from classList by className
    if (student.className != null && classList.isNotEmpty) {
      final matched = classList.firstWhereOrNull(
            (c) => c.className == student.className,
      );
      selectedClass.value = matched;
    }

    _setDateField(admissionDateController, student.admissionDate);
    _setDateField(dobController, student.dateOfBirth);
  }

  // ── Save TC Certificate (POST) ──────────────────────────────
  Future<void> saveTcCertificate() async {
    const String url =
        'https://playschool.edubloom.in/api/StudentApp/SaveTcCertificate';

    // ── Basic validation ────────────────────────────────────
    final String studentName = studentNameController.text.trim();

    if (studentName.isEmpty) {
      // 🆕 CHANGED: Get.snackbar -> AppSnackbar.error
      AppSnackbar.error('Student name is required.', title: 'Validation');
      return;
    }

    final TcStudentData? student = studentDetail.value;
    final String remarks = remarksController.text.trim();

    // ── Build request body ──────────────────────────────────
    final Map<String, dynamic> body = {
      "tcId": 0,
      "stuId": studentId,
      "session": selectedSession.value?.session ?? currentSession,
      "schoolId": schoolId,
      "studentName": studentName,
      "fatherName": fatherNameController.text.trim(),
      "motherName": motherNameController.text.trim(),
      "nationality": student?.nationality ?? "Indian",
      "class": selectedClass.value?.className ?? student?.className ?? "",
      "section": "",
      "dob": dobController.text.trim(),
      "month14": feesPaidController.text.trim(),
      "conduct20": remarks,
      "issue22": dateOfIssueController.text.trim(),
      "reasons23": reasonController.text.trim(),
      "admissionDate": admissionDateController.text.trim(),
      "remark": remarks,
      "createBy": "admin",
      "sNo": int.tryParse(srNoController.text.trim()) ?? 0,
    };

    try {
      isSaving(true);

      final response = await http.post(
        Uri.parse(url),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );

      final Map<String, dynamic> jsonResponse =
      jsonDecode(response.body);

      final bool isSuccess = jsonResponse['isSuccess'] ?? false;
      final String message =
          jsonResponse['messages'] ?? 'Something went wrong.';

      if (response.statusCode == 200 && isSuccess) {
        // ── Success ───────────────────────────────────────
        // 🆕 CHANGED: Get.snackbar -> AppSnackbar.success
        AppSnackbar.success(
          message.isNotEmpty
              ? message
              : 'Certificate saved successfully for ${studentNameController.text}',
        );
      } else {
        // ── API returned failure (e.g. TC already exists) ─
        // 🆕 CHANGED: Get.snackbar -> AppSnackbar.error
        // (technical / lamba text apne aap hide ho jata hai)
        AppSnackbar.error(message, title: 'Failed');
      }
    } catch (e, stack) {
      // 🆕 CHANGED: raw error nahi dikhega, sirf "Something went wrong"
      AppSnackbar.apiError(e, stackTrace: stack);
    } finally {
      isSaving(false);
    }
  }

  void setSelectedSession(session_model.sListDdata val) {
    selectedSession.value = val;
  }

  void setSelectedClass(ListDataa val) {
    selectedClass.value = val;
  }

  @override
  void onClose() {
    srNoController.dispose();
    registrationNoController.dispose();
    studentNameController.dispose();
    motherNameController.dispose();
    fatherNameController.dispose();
    admissionDateController.dispose();
    dobController.dispose();
    feesPaidController.dispose();
    dateOfIssueController.dispose();
    reasonController.dispose();
    remarksController.dispose();
    super.onClose();
  }
}