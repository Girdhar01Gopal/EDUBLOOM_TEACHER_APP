import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/paid fee model report.dart';
import '../models/unpaid fee report model.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

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

  // ✅ Dono APIs me se kisi me error aaya ya nahi (success snackbar ke liye)
  bool _hadError = false;

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
  Future<void> _fetchBothApis() async {
    _hadError = false;

    await Future.wait([
      fetchUnpaidFee(),
      fetchPaidFee(),
    ]);

    // ✅ Error nahi aaya tabhi success / info snackbar
    if (!_hadError) {
      if (unpaidFeeList.isEmpty && paidFeeList.isEmpty) {
        AppSnackbar.error('No data found', title: 'Info');
      } else {
        AppSnackbar.success('Data loaded successfully');
      }
    }
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
      _hadError = true;
      AppSnackbar.error('Student ID not found.');
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
        _hadError = true;
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          'Unpaid fee load failed: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
        print("Unpaid API Error: ${response.statusCode} => ${response.body}");
      }
    } catch (e, s) {
      _hadError = true;
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
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
        _hadError = true;
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          'Paid fee load failed: ${response.statusCode} : ${response.body}',
          statusCode: response.statusCode,
        );
        print("Paid API Error: ${response.statusCode} => ${response.body}");
      }
    } catch (e, s) {
      _hadError = true;
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
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