import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/Daycaremodel.dart';
import '../models/activitystudentmodel.dart';
import '../models/viewactivitymodel.dart';

class Activitycontroller extends GetxController {

  // -----------------------
  // OBSERVABLE STATE
  // -----------------------
  RxString selecttype = "".obs;

  RxList<Data> selectedStudent = <Data>[].obs;
  RxList<int> selectedStudentIds = <int>[].obs;
  RxList<Data> studentList = <Data>[].obs;

  TextEditingController activityController = TextEditingController();

  RxString fromTime = "".obs;
  RxString toTime = "".obs;

  var schoolId = "".obs;
  var session = "".obs;

  // -----------------------
  // VIEW ACTIVITY LIST
  // -----------------------
  RxList<vData> activityList = <vData>[].obs;

  RxBool saveAsDailyActivity = false.obs;


  RxString searchQuery = "".obs;

  List<vData> get filteredActivityList {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return activityList;
    return activityList.where((act) {
      final name = (act.studentName ?? "").toLowerCase();
      final date = (act.createDate ?? "").toLowerCase();
      final text = (act.activity ?? "").toLowerCase();
      return name.contains(q) || date.contains(q) || text.contains(q);
    }).toList();
  }

  @override
  void onInit() async {
    super.onInit();
    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session.value  = await PrefManager().readValue(key: PrefConst.session)  ?? "";
    fetchActivityList();
  }

  // -----------------------
  // FETCH STUDENTS
  // -----------------------
  Future<void> fetchStudents() async {
    studentList.clear();
    selectedStudent.clear();
    selectedStudentIds.clear();

    if (selecttype.value == "Day Care") {
      await _fetchDaycareStudents();
    } else {
      await _fetchPreSchoolStudents();
    }
  }

  // ✅ Day Care — DaycareStudentModel (ListdData) use karo
  Future<void> _fetchDaycareStudents() async {
    const apiPath =
        "api/DaycareFeePaymentApp/ViewDaycareFeeStudentApp";
    final url = Uri.parse("https://playschool.edubloom.in/$apiPath");

    final body = jsonEncode({
      "session": session.value,
      "schoolId": schoolId.value,
    });

    debugPrint("📥 Day Care Students POST => $url");
    debugPrint("📦 Body => $body");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("Day Care STATUS: ${res.statusCode}");
      debugPrint("Day Care BODY: ${res.body}");

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        final parsed = DaycareStudentModel.fromJson(jsonBody);
        final list = parsed.listData ?? [];

        // ✅ ListdData.studentID → Data.studentId (capital ID fix)
        studentList.value = list.map((s) {
          return Data(
            studentId: s.studentID ?? 0,       // ← capital ID
            studentName: s.studentName ?? "Unknown",
          );
        }).toList();

        debugPrint("✅ Day Care students loaded: ${studentList.length}");

        final zeroIds = studentList.where((s) => (s.studentId ?? 0) == 0).length;
        if (zeroIds > 0) {
          debugPrint("⚠️ $zeroIds students have studentId=0");
        }
      } else {
        Get.snackbar("Error", "Unable to load Day Care students: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Day Care fetch error => $e");
      Get.snackbar("Error", "Failed to fetch Day Care students");
    }
  }

  // ✅ Pre School students
  Future<void> _fetchPreSchoolStudents() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllDailyActivityAsynsApp"
        "?type=${selecttype.value}&schoolId=${schoolId.value}&session=${session.value}";

    debugPrint("📥 Pre School Students => $url");

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        studentList.value =
            (jsonBody["data"] as List).map((e) => Data.fromJson(e)).toList();
        debugPrint("✅ Pre School students loaded: ${studentList.length}");
      } else {
        Get.snackbar("Error", "Unable to load Pre School students: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Pre School fetch error => $e");
      Get.snackbar("Error", "Failed to fetch Pre School students");
    }
  }

  // -----------------------
  // FETCH ALL ACTIVITIES
  // -----------------------
  Future<void> fetchActivityList() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllDailyActivityAsynsApp"
        "/${schoolId.value}/${session.value}";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        if (jsonBody["data"] != null) {
          final list =
          (jsonBody["data"] as List).map((e) => vData.fromJson(e)).toList();

          // 🆕 ADDED: latest activity sabse upar dikhe — createDate ke
          // hisaab se descending sort (jo abhi add hua wo top pe).
          list.sort((a, b) {
            final dateA = DateTime.tryParse(a.createDate ?? '') ?? DateTime(1970);
            final dateB = DateTime.tryParse(b.createDate ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });

          activityList.value = list;
        }
      }
    } catch (e) {
      debugPrint("fetchActivityList error => $e");
    }
  }

  // -----------------------
  // PICK TIME
  // -----------------------
  Future<void> pickTime(RxString target) async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      target.value = DateFormat("hh:mm a")
          .format(DateTime(2025, 1, 1, picked.hour, picked.minute));
    }
  }

  // ── NEW: clear the "Add Activity" form after a successful post ──
  void resetForm() {
    activityController.clear();
    fromTime.value = "";
    toTime.value = "";
    selectedStudent.clear();
    selectedStudentIds.clear();
  }

  // -----------------------
  // ✅ POST ACTIVITY (multiple students — Day Care ho ya Pre School,
  // dono ke liye same multi-select post logic, Meal ke
  // postActivityToApi jaisa)
  // -----------------------
  Future<bool> postActivityToApi(List<int> studentIds) async {
    if (studentIds.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please select at least one student.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return false;
    }

    if (studentIds.any((id) => id == 0)) {
      debugPrint("❌ One or more studentId = 0. Aborting.");
      Get.snackbar(
        "Error",
        "Invalid student selected. Please re-select the student.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return false;
    }

    if (activityController.text.trim().isEmpty) {
      Get.snackbar(
        "Validation",
        "Please enter activity description.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return false;
    }

    if (fromTime.value.isEmpty || toTime.value.isEmpty) {
      Get.snackbar(
        "Validation",
        "Please select From and To time.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return false;
    }

    const url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/PostActivitiesApp";

    // ── Combine today's date with the picked "hh:mm a" time so
    // fromTime/toTime match the working format seen in GET response
    // (e.g. "2026-09-09T07:55:00") instead of a bare "06:53 AM" string. ──
    DateTime? _combineTodayWithTime(String timeStr) {
      try {
        final parsed = DateFormat("hh:mm a").parse(timeStr);
        final now = DateTime.now();
        return DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
      } catch (e) {
        debugPrint("⚠️ Time parse failed for '$timeStr' => $e");
        return null;
      }
    }

    final fromDateTime = _combineTodayWithTime(fromTime.value);
    final toDateTime = _combineTodayWithTime(toTime.value);

    final nowIso = DateTime.now().toIso8601String(); // matches existing records (no Z)

    // ✅ studentId sent as a LIST — this is what the backend model
    // binder actually expects (confirmed by the earlier 400 error:
    // "could not be converted to List<Int32>").
    final body = {
      "activityId": 0,
      "activity": activityController.text.trim(),
      "fromTime": fromDateTime?.toIso8601String() ?? fromTime.value,
      "toTime": toDateTime?.toIso8601String() ?? toTime.value,
      "action": "1",
      "createDate": nowIso,
      "updateDate": nowIso,
      "createBy": "admin",
      "updateBy": "admin",
      "schoolId": schoolId.value,
      "studentId": studentIds,          // ✅ List<int>, single batched call
      "startTime": fromTime.value,      // keep original "hh:mm a" display strings too
      "endTime": toTime.value,
      "session": session.value,
    };

    debugPrint("📤 POST Activity => $url");
    debugPrint("📦 Body => ${jsonEncode(body)}");

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("POST STATUS: ${res.statusCode}");
      debugPrint("POST BODY: ${res.body}");

      if (res.statusCode == 200) {
        await fetchActivityList();
        resetForm();
        return true;
      } else {
        debugPrint("❌ Failed => ${res.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Post activity error => $e");
      return false;
    }
  }
}