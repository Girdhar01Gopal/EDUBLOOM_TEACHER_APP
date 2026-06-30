import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart';
import '../res/app_url.dart';

class Feedetailsstudentreportscontroller extends GetxController {
  RxList<String> sessionList = <String>[].obs;      // ✅ dynamic
  RxString selectedSession = ''.obs;
  RxBool isSessionLoading = false.obs;              // ✅ new
  TextEditingController registrationNoController = TextEditingController();
  RxList<FeeData> paidFeeList = <FeeData>[].obs;
  RxList<FeeData> unpaidFeeList = <FeeData>[].obs;
  RxBool isLoading = false.obs;

  double totalUnpaidAmount = 0.0;

  @override
  void onInit() {
    super.onInit();
    fetchSessionList();                              // ✅ load on start
  }

  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final schoolId = await PrefManager().readValue(key: PrefConst.schollId);
      final url = Uri.parse("${AppUrl.base_url}${AppUrl.view_session}$schoolId");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = SessionModel.fromJson(data);
        final list = model.listData ?? [];

        sessionList.value = list
            .map((s) => s.session ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

        if (sessionList.isNotEmpty) {
          selectedSession.value = sessionList.first;
        }
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    } finally {
      isSessionLoading(false);
    }
  }

  // Fetch student fee data
  Future<void> fetchFeeData() async {
    isLoading(true);
    paidFeeList.clear();
    unpaidFeeList.clear();

    // Simulate fetching paid and unpaid fee data
    await Future.delayed(Duration(seconds: 2));

    // Example data for paid and unpaid fees
    paidFeeList.add(FeeData(sNo: "1", payDate: "2025-08-01", amount: "1200"));
    unpaidFeeList.add(FeeData(sNo: "1", feeType: "EXAM FEE", amount: "800"));
    unpaidFeeList.add(FeeData(sNo: "2", feeType: "TUITION FEE", amount: "1000"));

    // Calculate total unpaid amount
    totalUnpaidAmount = unpaidFeeList.fold(0.0, (sum, fee) => sum + double.parse(fee.amount));

    isLoading(false);
  }
}

class FeeData {
  final String sNo;
  final String feeType;
  final String payDate;
  final String amount;

  FeeData({
    required this.sNo,
    this.feeType = '',
    this.payDate = '',
    required this.amount,
  });
}
