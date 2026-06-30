import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/daily_collection_class_wise_model.dart';

class FeeCollectionClassWiseController extends GetxController {
  final Rx<DateTime> startDate    = DateTime.now().obs;
  final Rx<DateTime> endDate      = DateTime.now().obs;
  final RxBool isLoading          = false.obs;
  final RxList<Payment> items     = <Payment>[].obs;

  // ✅ Dynamic columns — API se jo bhi keys aaye (TotalAmount last mein)
  final RxList<String> dynamicColumns = <String>[].obs;

  String? schoolId;
  final String baseUrl =
      "https://playschool.edubloom.in/api/ReportApp/ViewGetDailyCollectionClassWiseApp";

  @override
  void onInit() {
    super.onInit();
    _loadSchoolId();
  }

  Future<void> _loadSchoolId() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    if (schoolId == null || schoolId!.trim().isEmpty) {
      Get.snackbar(
        "Error", "SchoolId not found in storage",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ── Dynamic column total ─────────────────────────────────────
  double columnTotal(String key) =>
      items.fold(0.0, (s, e) => s + (e.paymentModeAmounts[key] ?? 0.0));

  double get grandTotal =>
      items.fold(0.0, (s, e) => s + e.rowTotal);

  // ── Date helpers ─────────────────────────────────────────────
  String _fmtYmd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')}";

  String fmtUi(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.year}";

  // ── Date pickers ─────────────────────────────────────────────
  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    startDate.value = picked;
    if (endDate.value.isBefore(picked)) endDate.value = picked;
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    endDate.value = picked;
  }

  // ── API call ─────────────────────────────────────────────────
  Future<void> fetchDailyCollection() async {
    isLoading.value = true;
    items.clear();
    dynamicColumns.clear();

    try {
      if (schoolId == null || schoolId!.trim().isEmpty) {
        schoolId = await PrefManager().readValue(key: PrefConst.schollId);
      }

      if (schoolId == null || schoolId!.trim().isEmpty) {
        Get.snackbar(
          "Error", "School ID is missing",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final from = _fmtYmd(startDate.value);
      final to   = _fmtYmd(endDate.value);
      final uri  = Uri.parse("$baseUrl/$from/$to/$schoolId");
      debugPrint("ClassWise API: $uri");

      final res = await http
          .get(uri, headers: const {"Accept": "application/json"})
          .timeout(const Duration(seconds: 25));

      debugPrint("Status: ${res.statusCode}");
      debugPrint("Body: ${res.body}");

      if (res.statusCode != 200) {
        Get.snackbar("Error", "Failed (${res.statusCode})",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! List) {
        Get.snackbar("Error", "Unexpected response format",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return;
      }

      final parsed = decoded
          .whereType<Map>()
          .map((e) => Payment.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      items.assignAll(parsed);

      // ✅ Saari rows se unique keys collect karo
      // TotalAmount ko end mein rakho, baaki keys pehle
      final colSet = <String>{};
      for (final item in items) {
        for (final key in item.paymentModeAmounts.keys) {
          if (key != "TotalAmount") colSet.add(key);
        }
      }
      final cols = colSet.toList();
      // TotalAmount exist karta hai to end mein add karo
      final hasTotalAmount = items.any(
            (e) => e.paymentModeAmounts.containsKey("TotalAmount"),
      );
      if (hasTotalAmount) cols.add("TotalAmount");
      dynamicColumns.assignAll(cols);

      if (items.isEmpty) {
        Get.snackbar("Info", "No data found",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}