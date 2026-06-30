// ============================================================
// dob_certificate_controller.dart
// ============================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/DOB print certificacte model.dart';
import '../models/student_model.dart';
import '../res/app_url.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';

const String kDobImageBaseUrl = 'https://playschool.edubloom.in/StudentImages/';

class StudentListController extends GetxController {

  var isLoading     = false.obs;
  var isCertLoading = false.obs;

  List<StudentData> allStudents = <StudentData>[];
  var students = <StudentData>[].obs;

  String schoolId   = '';
  String session    = '';
  String schoolCode = '';

  @override
  void onInit() {
    super.onInit();
    _loadPrefsAndFetch();
  }

  Future<void> _loadPrefsAndFetch() async {
    // Exact same keys as StudentController
    schoolId   = await PrefManager().readValue(key: PrefConst.schollId);
    session    = await PrefManager().readValue(key: PrefConst.session);
    schoolCode = schoolId;

    debugPrint(
        '🔑 [DOB] schoolId=$schoolId | session=$session | schoolCode=$schoolCode');
    await fetchStudents();
  }

  // ── API 1: Get All Students ─────────────────────────────────
  Future<void> fetchStudents() async {
    try {
      isLoading(true);
      final url = Uri.parse(
          '${AppUrl.base_url}api/StudentApp/GetAllStudentAsynsApp');
      final body = {'schoolId': schoolId, 'currentSession': session};

      debugPrint('🔹 [DOB] POST => $url | body=$body');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint('📥 [DOB] Status => ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        final model   = StudentModel.fromJson(jsonMap);

        if (model.isSuccess == true) {
          allStudents = List<StudentData>.from(model.data ?? []);
          students.assignAll(allStudents);
          debugPrint('✅ [DOB] Students: ${students.length}');
        } else {
          _showError(model.messages ?? 'Failed to fetch students');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [DOB] fetchStudents: $e');
      _showError('Could not fetch students.');
    } finally {
      isLoading(false);
    }
  }

  // ── API 2: Get DOB Certificate ──────────────────────────────
  Future<PrintCertificateData?> fetchDobCertificate(
      StudentData student) async {
    try {
      isCertLoading(true);

      final studentId = student.studentID ?? 0;
      final url = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/GetDobCertificate'
            '/$studentId/$session/$schoolCode',
      );

      debugPrint('📜 [DOB] GET => $url');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('📥 [DOB] Cert Status => ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        final model   = PrintCertificateModel.fromJson(jsonMap);

        if (model.isSuccess == true && model.data != null) {
          return model.data;
        } else {
          _showError(model.messages ?? 'Certificate not found');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [DOB] fetchDobCertificate: $e');
      _showError('Could not fetch certificate. Please retry.');
    } finally {
      isCertLoading(false);
    }
    return null;
  }

  // ── Search ──────────────────────────────────────────────────
  void searchStudents(String query) {
    if (query.trim().isEmpty) {
      students.assignAll(allStudents);
      return;
    }
    final q = query.trim().toLowerCase();
    students.assignAll(allStudents.where((s) {
      return (s.registrationNo ?? '').toLowerCase().contains(q) ||
          (s.studentName       ?? '').toLowerCase().contains(q) ||
          (s.className         ?? '').toLowerCase().contains(q) ||
          (s.phone             ?? '').contains(q);
    }).toList());
  }

  static String buildImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    return '$kDobImageBaseUrl${path.trim()}';
  }

  void _showError(String msg) {
    Get.snackbar('Error', msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900);
  }
}