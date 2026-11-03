// controller/daycare_feepayment_view_controller.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/daycarefeespaymentmodel.dart';
import '../res/app_url.dart';

class DaycareFeePaymentviewController extends GetxController {
  // 🆕 Screen pe sirf ye safe message dikhega (asli error console me print hoga)
  static const String _genericError =
      'Something went wrong. Please try again.';

  final isLoading = false.obs;
  final error     = "".obs;
  final payments  = <TransactionItem>[].obs;

  final RxString registrationNo = ''.obs;
  final RxString session        = ''.obs;
  final RxString schoolId       = ''.obs;
  final RxInt    studentId      = 0.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};

    registrationNo.value = args['registrationNo']?.toString() ?? '';
    session.value        = args['session']?.toString()        ?? '';
    schoolId.value       = args['schoolId']?.toString()       ?? '';

    // Safe int parse — handles both int and String from caller
    final rawId = args['studentId'];
    studentId.value = (rawId is int)
        ? rawId
        : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    fetchPayments(
      registrationNo: registrationNo.value,
      session:        session.value,
      schoolId:       schoolId.value,
    );
  }

  Future<void> fetchPayments({
    required String registrationNo,
    required String session,
    required String schoolId,
  }) async {
    try {
      isLoading.value = true;
      error.value     = "";

      final apiUrl =
          "${AppUrl.base_url}api/DaycareFeePaymentApp/"
          "DaycarestudentFeePaidAndUpaid/$registrationNo/$session/$schoolId";

      final res = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept":        "application/json",
        },
      );

      if (res.statusCode != 200) {
        payments.clear();
        debugPrint("DaycareFeePaymentView HTTP ${res.statusCode}: ${res.body}");
        error.value = _genericError; // 🔄 raw status/body nahi dikhega
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        payments.clear();
        debugPrint("DaycareFeePaymentView: invalid response format");
        error.value = _genericError; // 🔄
        return;
      }

      final parsed = ViewTransactionNewModel.fromJson(decoded);
      payments.assignAll(parsed.listData);

      // ✅ If controller studentId is 0 but first item has it, use that
      if (studentId.value == 0 && payments.isNotEmpty) {
        final idFromItem = payments.first.studentId;
        if (idFromItem != null && idFromItem > 0) {
          studentId.value = idFromItem;
        }
      }
    } catch (e, s) {
      payments.clear();
      debugPrint("DaycareFeePaymentView fetch failed: $e\n$s");
      error.value = _genericError; // 🔄 URL / exception nahi dikhega
    } finally {
      isLoading.value = false;
    }
  }
}