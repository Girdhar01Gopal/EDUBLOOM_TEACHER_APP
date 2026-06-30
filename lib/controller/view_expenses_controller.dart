import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../models/view_expenses_model.dart';

class ViewExpensesController extends GetxController {
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate   = DateTime.now().obs;
  final RxBool isLoading       = false.obs;
  final RxList<ViewExpensesItem> items = <ViewExpensesItem>[].obs;

  String? schoolId;


  String get _currentSession {
    final y = DateTime.now().year;
    return "$y-${(y + 1).toString().substring(2)}";
  }

  static const String _baseUrl =
      "https://playschool.edubloom.in/api/ExpensesApp/AddExpensesViewApp";

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

  // ── Totals ────────────────────────────────────────────────────────────────
  double get grandTotal => items.fold(0.0, (s, e) => s + e.amount);

  // ── Date helpers ──────────────────────────────────────────────────────────
  /// yyyy-MM-dd  (API format)
  String _fmtYmd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.day.toString().padLeft(2, '0')}";

  /// dd-MM-yyyy  (UI display)
  String fmtUi(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}-"
          "${d.month.toString().padLeft(2, '0')}-"
          "${d.year}";

  // ── Date pickers ──────────────────────────────────────────────────────────
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

  // ── Fetch ─────────────────────────────────────────────────────────────────
  Future<void> fetchExpenses() async {
    isLoading.value = true;
    items.clear();

    try {
      // Re-read schoolId if missing
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

      // ── Build exact request body (matches Postman) ──────────────────────
      final body = jsonEncode({
        "startDate": _fmtYmd(startDate.value),
        "endDate":   _fmtYmd(endDate.value),
        "schoolId":  schoolId,
        "session":   _currentSession,
      });

      debugPrint("► POST $_baseUrl");
      debugPrint("► Body: $body");

      final res = await http
          .post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept":       "application/json",
        },
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      debugPrint("◄ Status : ${res.statusCode}");
      debugPrint("◄ Response: ${res.body}");

      if (res.statusCode != 200) {
        Get.snackbar(
          "Error", "Server returned ${res.statusCode}",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // ── Parse response  {"listData": [...]} ────────────────────────────
      final decoded = jsonDecode(res.body);

      if (decoded is! Map<String, dynamic>) {
        Get.snackbar(
          "Error", "Unexpected response format",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final model = ViewExpensesModel.fromJson(decoded);
      items.assignAll(model.listData);

      if (items.isEmpty) {
        Get.snackbar(
          "Info", "No expenses found for selected date range",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e, st) {
      debugPrint("fetchExpenses error: $e\n$st");
      Get.snackbar(
        "Error", "Something went wrong: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}