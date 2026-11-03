import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/fee_payment_details_model.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

class FeePaymentDetailsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMsg = ''.obs;
  final RxList<FeePaymentModel> payments = <FeePaymentModel>[].obs;

  final RxString searchText = ''.obs;

  final RxString schoolCode = ''.obs;
  final RxString session = ''.obs; // ← dynamic

  final String baseUrl =
      "https://playschool.edubloom.in/api/ReportApp/GetPaymentReciptNoApp";

  @override
  void onInit() async {
    super.onInit();

    schoolCode.value =
        await PrefManager().readValue(key: PrefConst.schollId) ?? "";

    if (schoolCode.value.trim().isEmpty) {
      errorMsg.value =
      "SchoolId not found in storage. not saved after login.";
      return;
    }

    await _fetchSession();

    fetchPaymentDetails();
  }

  Future<void> _fetchSession() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/${schoolCode.value}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        session.value =
            jsonData['currentSession']?['currentSession']?.toString() ?? "";
      } else {
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "Session fetch failed: ${res.statusCode} : ${res.body}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    }
  }

  List<FeePaymentModel> get filteredPayments {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return payments;

    return payments.where((p) {
      return p.studentName.toLowerCase().contains(q) ||
          p.registrationNo.toLowerCase().contains(q) ||
          p.receiptNo.toLowerCase().contains(q) ||
          p.feeMonth.toLowerCase().contains(q) ||
          p.paymentMode.toLowerCase().contains(q) ||
          p.feetype.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> fetchPaymentDetails() async {
    if (session.value.trim().isEmpty) {
      AppSnackbar.error("Session not available");
      return;
    }

    isLoading.value = true;
    errorMsg.value = '';
    payments.clear();

    try {
      final uri = Uri.parse(
        "$baseUrl/${Uri.encodeComponent(session.value)}/${Uri.encodeComponent(schoolCode.value)}",
      );

      final res = await http.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode != 200) {
        // User ko sirf "Something went wrong", asli error console me
        AppSnackbar.apiError(
          "Failed (${res.statusCode}) : ${res.body}",
          statusCode: res.statusCode,
        );
        return;
      }

      final decoded = jsonDecode(res.body);

      if (decoded is! List) {
        throw Exception(
          "Unexpected API response: List expected but got ${decoded.runtimeType}",
        );
      }

      final list = decoded
          .map((e) => FeePaymentModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      payments.assignAll(list);

      // ✅ Success / Info snackbar
      if (payments.isEmpty) {
        AppSnackbar.error("No data found", title: "Info");
      } else {
        AppSnackbar.success("Data loaded successfully");
      }
    } catch (e, s) {
      // ✅ Screen ke _errorBox me bhi raw error / URL na dikhe
      errorMsg.value = "Something went wrong. Please try again.";

      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String v) => searchText.value = v;
  void clearSearch() => searchText.value = '';
}