import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/paid fee model report.dart';
import '../models/unpaid fee report model.dart';
import '../res/app_url.dart';

class StudentWiseFeeController extends GetxController {
  final TextEditingController regNoController = TextEditingController();

  // Student info
  var studentName = ''.obs;
  var studentClass = ''.obs;
  var studentSection = ''.obs;
  var registrationNo = ''.obs;
  var session = ''.obs;
  var studentId = 0.obs; // ← ADDED

  var schoolId = '';
  var token = '';

  // Separate loading states
  var isUnpaidLoading = false.obs;
  var isPaidLoading = false.obs;

  // Unpaid list — UnpaidData from UnpaidFeeModel
  RxList<UnpaidData> unpaidFeeList = <UnpaidData>[].obs;

  // Paid list — PaidData from PaidFeeModel
  RxList<PaidData> paidFeeList = <PaidData>[].obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    // FeeStudentReportsScreen se arguments aate hain
    final args = Get.arguments;
    if (args != null) {
      studentName.value = args['studentName'] ?? '';
      registrationNo.value = args['registrationNo'] ?? '';
      session.value = args['session'] ?? '';
      studentId.value = args['studentId'] ?? 0; // ← ADDED
      regNoController.text = registrationNo.value;

      // Screen open hote hi dono APIs fetch karo
      _fetchBothApis();
    }
  }

  /// Dono APIs ek saath call karo
  void _fetchBothApis() {
    fetchUnpaidFee();
    fetchPaidFee();
  }

  /// Search button press pe bhi dono call hogi
  void onSearchPressed() {
    _fetchBothApis();
  }

  // ─────────────────────────────────────────────
  // UNPAID FEE API
  // POST: api/ReportApp/UnpaidGetStudentWiseCollectionApp
  // Body: { "studentId": ..., "session": "...", "schoolId": "..." }
  // ─────────────────────────────────────────────
  Future<void> fetchUnpaidFee() async {
    if (studentId.value == 0) {
      Get.snackbar(
        'Error',
        'Student ID not found.',
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final String url =
        '${AppUrl.base_url}api/ReportApp/UnpaidGetStudentWiseCollectionApp';

    try {
      isUnpaidLoading(true);
      unpaidFeeList.clear();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'studentId': studentId.value, // ← CHANGED
          'session': session.value,
          'schoolId': schoolId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final UnpaidFeeModel model = UnpaidFeeModel.fromJson(data);
        final List<UnpaidData> list = model.unpaiddata ?? [];

        unpaidFeeList.value = list;

        // Student info update from unpaid list
        if (list.isNotEmpty) {
          studentName.value = list.first.studentName ?? studentName.value;
          studentClass.value = list.first.studentClass ?? '';
          studentSection.value = list.first.section ?? '';
        }
      } else {
        Get.snackbar(
          'Error',
          'Unpaid fee load failed: ${response.statusCode}',
          backgroundColor: Colors.red.shade100,
        );
        print("Unpaid API Error: ${response.statusCode} => ${response.body}");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unpaid fee error: $e',
        backgroundColor: Colors.red.shade100,
      );
      print("Unpaid Exception: $e");
    } finally {
      isUnpaidLoading(false);
    }
  }

  // ─────────────────────────────────────────────
  // PAID FEE API
  // POST: api/ReportApp/GetStudentPaidFeeApp
  // Body: { "studentId": ..., "session": "...", "schoolId": "..." }
  // ─────────────────────────────────────────────
  Future<void> fetchPaidFee() async {
    if (studentId.value == 0) return; // ← CHANGED

    final String url =
        '${AppUrl.base_url}api/ReportApp/GetStudentPaidFeeApp';

    try {
      isPaidLoading(true);
      paidFeeList.clear();

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'studentId': studentId.value, // ← CHANGED
          'session': session.value,
          'schoolId': schoolId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final PaidFeeModel model = PaidFeeModel.fromJson(data);
        final List<PaidData> list = model.listData ?? [];

        paidFeeList.value = list;

        // Student info update from paid list (agar unpaid se nahi mili thi)
        if (list.isNotEmpty && studentName.value.isEmpty) {
          studentName.value = list.first.studentName ?? '';
          studentClass.value = list.first.studentClass ?? '';
          studentSection.value = list.first.section ?? '';
        }
      } else {
        Get.snackbar(
          'Error',
          'Paid fee load failed: ${response.statusCode}',
          backgroundColor: Colors.red.shade100,
        );
        print("Paid API Error: ${response.statusCode} => ${response.body}");
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Paid fee error: $e',
        backgroundColor: Colors.red.shade100,
      );
      print("Paid Exception: $e");
    } finally {
      isPaidLoading(false);
    }
  }

  @override
  void onClose() {
    regNoController.dispose();
    super.onClose();
  }
}