import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/FeeDailyCollectionmodel.dart';
import '../utils/app_snackbar.dart'; // ✅ AppSnackbar

class FeeDailyCollectionController extends GetxController {
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate   = DateTime.now().obs;
  final RxBool isLoading       = false.obs;
  final RxList<FeeDailyCollectionItem> items = <FeeDailyCollectionItem>[].obs;

  // ✅ Dynamic columns — API se jo bhi keys aaye
  final RxList<String> dynamicColumns = <String>[].obs;

  String? schoolId;
  final String baseUrl =
      "https://playschool.edubloom.in/api/ReportApp/DailyCollection";

  @override
  void onInit() {
    super.onInit();
    _loadSchoolId();
  }

  Future<void> _loadSchoolId() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    if (schoolId == null || schoolId!.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found in storage");
    }
  }

  // ── Dynamic column totals ────────────────────────────────────
  // Kisi bhi column ka total nikalo by key name
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
        AppSnackbar.error("School ID is missing");
        return;
      }

      final from = _fmtYmd(startDate.value);
      final to   = _fmtYmd(endDate.value);
      final uri  = Uri.parse("$baseUrl/$from/$to/$schoolId");
      debugPrint("DailyCollection API: $uri");

      final res = await http
          .get(uri, headers: const {"Accept": "application/json"})
          .timeout(const Duration(seconds: 25));

      debugPrint("Status: ${res.statusCode}");
      debugPrint("Body: ${res.body}");

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
        AppSnackbar.apiError("Unexpected response format");
        return;
      }

      final parsed = decoded
          .whereType<Map>()
          .map((e) => FeeDailyCollectionItem.fromJson(
        Map<String, dynamic>.from(e),
      ))
          .toList();

      items.assignAll(parsed);
      if (items.isNotEmpty) {
        AppSnackbar.success("Data loaded successfully");
      }

      // ✅ Saari rows se unique column keys collect karo (order preserve)
      final colSet = <String>{};
      for (final item in items) {
        colSet.addAll(item.paymentModeAmounts.keys);
      }
      dynamicColumns.assignAll(colSet.toList());

      if (items.isEmpty) {
        AppSnackbar.error("No data found", title: "Info");
      }
    } catch (e, s) {
      // Net band / timeout / koi bhi exception: URL ya error user ko nahi dikhega
      AppSnackbar.apiError(e, stackTrace: s);
    } finally {
      isLoading.value = false;
    }
  }
}