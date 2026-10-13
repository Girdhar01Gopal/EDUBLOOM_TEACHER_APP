import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/holiday_model.dart';
import '../res/app_url.dart';

class AddHolidayCalendarController extends GetxController {
  String schoolId = "";
  String session = "";
  String userName = "";

  // Month currently shown in the calendar (always the 1st of that month).
  final focusedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  final holidayList = <Holiday>[].obs;
  final isListLoading = false.obs;
  final isSaving = false.obs;

  // Add / edit form
  final selectedDate = Rx<DateTime?>(null);
  final occasionController = TextEditingController();
  final isActive = true.obs;
  // 0 while adding; set to the row's hdId while editing.
  final editingHdId = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    userName =
        await PrefManager().readValue(key: PrefConst.UserName) ?? "Admin";

    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
      return;
    }

    await fetchHolidays();
  }

  @override
  void onClose() {
    occasionController.dispose();
    super.onClose();
  }

  // ── Calendar navigation ───────────────────────────────────────────────────
  void previousMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month - 1);
  }

  void nextMonth() {
    final m = focusedMonth.value;
    focusedMonth.value = DateTime(m.year, m.month + 1);
  }

  void goToToday() {
    final now = DateTime.now();
    focusedMonth.value = DateTime(now.year, now.month);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<Holiday> holidaysOn(DateTime date) =>
      holidayList.where((h) => isSameDay(h.dateHoliday, date)).toList();

  /// Holidays in the month shown on the calendar, sorted by date.
  List<Holiday> get monthHolidays {
    final m = focusedMonth.value;
    final list = holidayList
        .where((h) =>
            h.dateHoliday.year == m.year && h.dateHoliday.month == m.month)
        .toList()
      ..sort((a, b) => a.dateHoliday.compareTo(b.dateHoliday));
    return list;
  }

  /// Every holiday, sorted by date.
  List<Holiday> get allHolidays =>
      [...holidayList]..sort((a, b) => a.dateHoliday.compareTo(b.dateHoliday));

  // ── API ───────────────────────────────────────────────────────────────────
  Future<void> fetchHolidays() async {
    if (schoolId.trim().isEmpty) return;

    try {
      isListLoading(true);
      final url = Uri.parse('${AppUrl.base_url}${AppUrl.getHoliday}$schoolId');
      final res =
          await http.get(url, headers: {"Content-Type": "application/json"});

      if (res.statusCode == 200) {
        holidayList.assignAll(Holiday.listFromJson(jsonDecode(res.body)));
      } else {
        Get.snackbar("Error", "Failed to load holidays: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load holidays: $e");
    } finally {
      isListLoading(false);
    }
  }

  // ── Form ──────────────────────────────────────────────────────────────────
  void resetForm({DateTime? date}) {
    selectedDate.value = date;
    occasionController.clear();
    isActive.value = true;
    editingHdId.value = 0;
  }

  void loadForEdit(Holiday h) {
    editingHdId.value = h.hdId;
    selectedDate.value = h.day;
    occasionController.text = h.occasion;
    isActive.value = h.isActive;
  }

  Future<bool> saveHoliday() async {
    if (selectedDate.value == null) {
      Get.snackbar("Validation", "Please select a date");
      return false;
    }
    final occasion = occasionController.text.trim();
    if (occasion.isEmpty) {
      Get.snackbar("Validation", "Please enter the occasion");
      return false;
    }

    final existing = editingHdId.value == 0
        ? null
        : holidayList.firstWhereOrNull((h) => h.hdId == editingHdId.value);

    final holiday = Holiday(
      hdId: editingHdId.value,
      dateHoliday: selectedDate.value!,
      occasion: occasion,
      action: isActive.value ? 1 : 0,
      session: session,
      schoolId: schoolId,
      createBy: existing?.createBy ?? userName,
      createDate: existing?.createDate,
      updateBy: userName,
    );

    try {
      isSaving(true);
      final url = Uri.parse('${AppUrl.base_url}${AppUrl.addHoliday}');
      final requestBody = jsonEncode(holiday.toJson());
      debugPrint("══════ ADD HOLIDAY REQUEST ══════");
      debugPrint("URL  : $url");
      debugPrint("BODY : $requestBody");

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: requestBody,
      );

      debugPrint("══════ ADD HOLIDAY RESPONSE ══════");
      debugPrint("STATUS : ${res.statusCode}");
      debugPrint("BODY   : ${res.body}");

      // The API replies { isSuccess, messages, ... } — a 200 can still be a failure.
      Map<String, dynamic>? body;
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) body = decoded;
      } catch (_) {}
      final message = body?['messages']?.toString();

      if ((res.statusCode == 200 || res.statusCode == 201) &&
          body?['isSuccess'] != false) {
        Get.snackbar(
            "Success",
            (message != null && message.isNotEmpty)
                ? message
                : editingHdId.value == 0
                    ? "Holiday added successfully"
                    : "Holiday updated successfully");
        resetForm();
        await fetchHolidays();
        return true;
      } else {
        Get.snackbar("Error", message ?? "Save failed: ${res.statusCode}");
        return false;
      }
    } catch (e, st) {
      debugPrint("══════ ADD HOLIDAY ERROR ══════");
      debugPrint("$e\n$st");
      Get.snackbar("Error", "Save failed: $e");
      return false;
    } finally {
      isSaving(false);
    }
  }
}
