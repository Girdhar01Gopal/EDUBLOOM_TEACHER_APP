import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/ClassWiseFeeStructureModel.dart';

class ClassWiseFeeStructureController extends GetxController {
  RxBool isLoading = false.obs;

  var schoolCode = "".obs;
  final session = "".obs;

  RxList<FeeData> raw = <FeeData>[].obs;
  RxList<FeeStructureTableRow> tableRows = <FeeStructureTableRow>[].obs;

  int get grandTotal => raw.fold(0, (s, e) => s + e.amountAsInt);

  String get apiUrl =>
      "https://playschool.edubloom.in/api/ReportApp/GetFeeStructureAppAsync/${Uri.encodeComponent(schoolCode.value)}/${session.value}";

  void _buildTable() {
    final list = List<FeeData>.from(raw);

    list.sort((a, b) {
      final c = a.classId.compareTo(b.classId);
      if (c != 0) return c;
      final t = a.feeTypeText.compareTo(b.feeTypeText);
      if (t != 0) return t;
      return a.durationText.compareTo(b.durationText);
    });

    final rows = <FeeStructureTableRow>[];
    int snoCounter = 0;
    int? lastClassId;

    for (final item in list) {
      final isFirst = item.classId != lastClassId;
      if (isFirst) snoCounter++;

      final amt = item.amountAsInt == 0 ? "" : item.amountAsInt.toString();

      rows.add(
        FeeStructureTableRow(
          sno: isFirst ? snoCounter.toString() : "",
          classBatch: isFirst ? item.classBatchText : "",
          feeType: item.feeTypeText,
          feeDuration: item.durationText,
          amount: amt,
        ),
      );

      lastClassId = item.classId;
    }

    tableRows.assignAll(rows);
  }

  Future<void> fetchFeeStructure() async {
    if (session.value.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Session not available",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;
    raw.clear();
    tableRows.clear();

    try {
      final res = await http.get(
        Uri.parse(apiUrl),
        headers: const {"Accept": "application/json"},
      );

      if (res.statusCode != 200) {
        Get.snackbar(
          "Error",
          "Failed (${res.statusCode})",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        Get.snackbar(
          "Error",
          "Invalid response format",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final obj = FeeResponse.fromJson(decoded);

      if (!obj.isSuccess) {
        Get.snackbar(
          "Error",
          obj.messages ?? "API returned isSuccess=false",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      raw.assignAll(obj.data);
      _buildTable();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    schoolCode.value =
        await PrefManager().readValue(key: PrefConst.schollId) ?? "";

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
}