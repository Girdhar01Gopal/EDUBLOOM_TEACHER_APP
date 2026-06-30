import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/fee_payment_details_model.dart';

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
      "SchoolId not found in storage. Login ke baad save nahi ho raha.";
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
        Get.snackbar("Error", "Session fetch failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Session fetch failed: $e");
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
      Get.snackbar("Error", "Session not available",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
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
        Get.snackbar(
          "Error",
          "Failed (${res.statusCode})",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
    } catch (e) {
      errorMsg.value = e.toString();

      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String v) => searchText.value = v;
  void clearSearch() => searchText.value = '';
}