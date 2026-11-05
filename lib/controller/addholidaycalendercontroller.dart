import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/holiday_model.dart';
import '../models/vevent_model.dart' as vevent;
import '../models/vnote_model.dart' as vnote;
import '../res/app_url.dart';
import '../utils/app_snackbar.dart';

/// Calendar par dikhne wali extra entries (Note / Event).
enum CalendarEntryType { note, event }

class CalendarEntry {
  final CalendarEntryType type;
  final String title; // Note => remarks, Event => eventName
  final DateTime date; // sirf date (time 00:00)
  final String? place;
  final String? description;
  final String? createdBy;

  /// "Class - Section" ki list (same note/event multiple class me ho sakta hai)
  final Set<String> classSections = {};

  CalendarEntry({
    required this.type,
    required this.title,
    required this.date,
    this.place,
    this.description,
    this.createdBy,
  });
}

class AddHolidayCalendarController extends GetxController {
  String schoolId = "";
  String session = "";
  String userName = "";
  String userId = "";
  String roleName = "";

  // Month currently shown in the calendar (always the 1st of that month).
  final focusedMonth = DateTime(DateTime.now().year, DateTime.now().month).obs;

  final holidayList = <Holiday>[].obs;
  final notesList = <CalendarEntry>[].obs;
  final eventsList = <CalendarEntry>[].obs;
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
    userId =
        (await PrefManager().readValue(key: PrefConst.Userid))?.toString() ??
            "";
    roleName =
        (await PrefManager().readValue(key: PrefConst.RName))?.toString() ??
            "";

    if (schoolId.trim().isEmpty) {
      AppSnackbar.error("SchoolId not found");
      return;
    }

    await fetchAll();
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

  /// Us date ke saare Events.
  List<CalendarEntry> eventsOn(DateTime date) =>
      eventsList.where((e) => isSameDay(e.date, date)).toList();

  /// Us date ke saare Notes.
  List<CalendarEntry> notesOn(DateTime date) =>
      notesList.where((n) => isSameDay(n.date, date)).toList();

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
  /// Holiday + Notes + Events teeno ek saath fetch.
  Future<void> fetchAll() async {
    await Future.wait([
      fetchHolidays(),
      fetchNotes(),
      fetchEvents(),
    ]);
  }

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
        AppSnackbar.apiError(
          "Failed to load holidays: ${res.statusCode}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isListLoading(false);
    }
  }

  DateTime? _parseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    final d = DateTime.tryParse(s.trim());
    if (d == null) return null;
    return DateTime(d.year, d.month, d.day);
  }

  String _classSection(String? cls, String? sec) {
    final c = (cls ?? '').trim();
    final s = (sec ?? '').trim();
    if (c.isEmpty && s.isEmpty) return '';
    if (s.isEmpty) return c;
    if (c.isEmpty) return s;
    return '$c - $s';
  }

  /// Notes — calendar par "remarks" dikhega, note ki createDate wali date par.
  Future<void> fetchNotes() async {
    if (schoolId.trim().isEmpty) return;

    try {
      final uri = Uri.parse(
        AppUrl.testViewNoteApp(schoolId, session, userId, roleName),
      );
      final res = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      });

      final body = res.body.trim();
      final looksLikeJson = body.startsWith('{') || body.startsWith('[');

      if (res.statusCode == 200 && looksLikeJson) {
        final model = vnote.VNoteModel.fromJson(
            jsonDecode(body) as Map<String, dynamic>);

        final Map<String, CalendarEntry> merged = {};

        for (final n in (model.listData ?? [])) {
          final date = _parseDate(n.createDate);
          if (date == null) continue;

          var title = (n.remarks ?? '').trim();
          if (title.isEmpty) title = 'Note';

          final key = '$title|${date.toIso8601String()}';
          final entry = merged.putIfAbsent(
            key,
                () => CalendarEntry(
              type: CalendarEntryType.note,
              title: title,
              date: date,
            ),
          );

          final cs = _classSection(n.className, n.sectionName);
          if (cs.isNotEmpty) entry.classSections.add(cs);
        }

        notesList.assignAll(merged.values.toList());
      } else {
        debugPrint(
            "⚠️ Calendar notes: unexpected response (${res.statusCode})");
        notesList.clear();
      }
    } catch (e) {
      debugPrint("⚠️ Calendar notes error: $e");
      notesList.clear();
    }
  }

  /// Events — calendar par "eventName" dikhega, eventDate wali date par.
  Future<void> fetchEvents() async {
    if (schoolId.trim().isEmpty) return;

    try {
      final uri = Uri.parse(
        'https://playschool.edubloom.in/api/CommumicationApp/ViewEventApp/$schoolId',
      ).replace(queryParameters: {
        'session': session,
        'UserId': userId,
        'RoleName': roleName,
      });

      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final model = vevent.VEventResponse.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>);

        final Map<String, CalendarEntry> merged = {};

        for (final e in (model.listData ?? [])) {
          final date = _parseDate(e.eventDate);
          if (date == null) continue;

          var title = (e.eventName ?? '').trim();
          if (title.isEmpty) title = 'Event';

          final key = '$title|${date.toIso8601String()}';
          final entry = merged.putIfAbsent(
            key,
                () => CalendarEntry(
              type: CalendarEntryType.event,
              title: title,
              date: date,
              place: (e.eventPlace ?? '').trim(),
              description: (e.description ?? '').trim(),
              createdBy: (e.createBy ?? '').trim(),
            ),
          );

          final cs = _classSection(e.className, e.sectionName);
          if (cs.isNotEmpty) entry.classSections.add(cs);
        }

        eventsList.assignAll(merged.values.toList());
      } else {
        debugPrint("⚠️ Calendar events: unexpected response (${res.statusCode})");
        eventsList.clear();
      }
    } catch (e) {
      debugPrint("⚠️ Calendar events error: $e");
      eventsList.clear();
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
      AppSnackbar.error("Please select a date", title: "Validation");
      return false;
    }
    final occasion = occasionController.text.trim();
    if (occasion.isEmpty) {
      AppSnackbar.error("Please enter the occasion", title: "Validation");
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
        AppSnackbar.success(
            (message != null && message.isNotEmpty)
                ? message
                : editingHdId.value == 0
                ? "Holiday added successfully"
                : "Holiday updated successfully");
        resetForm();
        await fetchHolidays();
        return true;
      } else {
        // error() hides technical / long text automatically
        // and shows "Something went wrong" instead.
        AppSnackbar.error(message ?? "Save failed. Please try again.");
        return false;
      }
    } catch (e, st) {
      debugPrint("══════ ADD HOLIDAY ERROR ══════");
      debugPrint("$e\n$st");
      AppSnackbar.apiError(e, stackTrace: st);
      return false;
    } finally {
      isSaving(false);
    }
  }
}