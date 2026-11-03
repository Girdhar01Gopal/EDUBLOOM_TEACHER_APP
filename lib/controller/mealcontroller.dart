import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/activitystudentmodel.dart';
import '../models/class_list_model.dart';   // 🔄 Naya import correct classes ke saath
import '../models/mealactivitymodel.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/viewactivitymodel.dart';
import '../res/app_url.dart';
import '../utils/app_snackbar.dart'; // 🆕 ADDED: common snackbar
import 'student_controller.dart' show ClassTeacherFilterModel, ClassTeacherFilterData;

class Mealcontroller extends GetxController {
  // -----------------------
  // OBSERVABLE STATE
  // -----------------------

  RxString selecttype = "".obs;
  var listDataa = <ClassData>[].obs;             // ✅ Fixed Type to ClassData
  var selectedClass = Rx<ClassData?>(null);      // ✅ Fixed Type to ClassData
  RxList<Data> selectedStudent = <Data>[].obs;
  RxList<int> selectedStudentIds = <int>[].obs;
  RxList<Data> studentList = <Data>[].obs;

  TextEditingController activityController = TextEditingController();

  RxString fromTime = "".obs;
  RxString toTime = "".obs;
  RxString searchQuery = "".obs;

  // ── Raw picked hour/minute, needed to build a real ISO DateTime for fromTime/toTime ──
  TimeOfDay? _fromTimeOfDay;
  TimeOfDay? _toTimeOfDay;

  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var schoolId = "".obs;
  var session = "".obs;

  // 🆕 NEW: userId + roleName (GET aur POST dono me chahiye)
  var userId = "".obs;
  var roleName = "".obs;

  // -----------------------
  // VIEW ACTIVITY LIST
  // -----------------------
  RxList<MData> activityList = <MData>[].obs;
  List<MData> get filteredActivityList {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return activityList;
    return activityList.where((act) {
      final name = (act.studentName ?? "").toLowerCase();
      final date = (act.createDate ?? "").toLowerCase();
      final text = (act.meal ?? "").toLowerCase();
      return name.contains(q) || date.contains(q) || text.contains(q);
    }).toList();
  }

  @override
  void onInit() async {
    super.onInit();

    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? "";
    // 🆕 NEW: userId + roleName prefs se
    userId.value = await PrefManager().readValue(key: PrefConst.Userid) ?? "";
    roleName.value = await PrefManager().readValue(key: PrefConst.RName) ?? "";
    fetchClasses();
    fetchStudents();
    fetchActivityList();
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);

      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/${schoolId.value}'),
      );

      if (res.statusCode == 200) {
        // ✅ Fixed: Using ClassListModel from class_list_model.dart
        final parsed = ClassListModel.fromJson(jsonDecode(res.body));
        listDataa.value =
            parsed.listData.where((e) => e.action == "1").toList();
        selectedClass.value = null;
      }
    } catch (e, stack) {
      debugPrint("Error fetching classes: $e");
      // 🆕 ADDED: user ko "Something went wrong", console me asli error
      AppSnackbar.apiError(e, stackTrace: stack);
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ClassData? studentClassId) {
    selectedClass.value = studentClassId;
  }

  // -----------------------
  // SELECT ALL STUDENTS
  // -----------------------
  bool get isAllStudentsSelected =>
      studentList.isNotEmpty &&
          selectedStudentIds.length == studentList.length;

  void toggleSelectAllStudents(bool selectAll) {
    if (selectAll) {
      selectedStudent.value = List<Data>.from(studentList);
      selectedStudentIds.value =
          studentList.map((e) => e.studentId!).toList();
    } else {
      selectedStudent.clear();
      selectedStudentIds.clear();
    }
  }

  Future<void> fetchStudents() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllStudentAsynsApp?schoolId=${schoolId.value}&session=${session.value}";

    debugPrint("📥 Fetching Students: $url");

    try {
      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        studentList.value =
            (jsonBody["data"] as List).map((e) => Data.fromJson(e)).toList();

        debugPrint("✅ Fetched ${studentList.length} students");
      } else {
        // 🆕 CHANGED: raw message nahi, sirf "Something went wrong" dikhega
        AppSnackbar.apiError(
          "Unable to load students: ${res.statusCode}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, stack) {
      debugPrint("❌ fetchStudents error => $e");
      // 🆕 CHANGED: user ko "Something went wrong", console me asli error
      AppSnackbar.apiError(e, stackTrace: stack);
    }
  }

  // -----------------------
  // FETCH ALL ACTIVITIES (VIEW ACTIVITY)
  // 🆕 UPDATED URL: ...GetAllMealAsyncApp?schoolId=..&session=..&UserId=..&RoleName=..
  // -----------------------
  Future<void> fetchActivityList() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllMealAsyncApp"
        "?schoolId=${schoolId.value}&session=${session.value}"
        "&UserId=${userId.value}&RoleName=${roleName.value}";

    debugPrint("📥 Fetching All Meal Activities: $url");

    try {
      final res = await http.get(Uri.parse(url));
      debugPrint("Meal GET STATUS: ${res.statusCode}");

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        if (jsonBody["data"] != null) {
          activityList.value = (jsonBody["data"] as List)
              .map((e) => MData.fromJson(e))
              .toList();
        }
      } else {
        // 🆕 ADDED: user ko "Something went wrong", console me asli error
        AppSnackbar.apiError(
          "Meal GET failed: ${res.statusCode}",
          statusCode: res.statusCode,
        );
      }
    } catch (e, stack) {
      debugPrint("❌ fetchActivityList error => $e");
      // 🆕 ADDED: user ko "Something went wrong", console me asli error
      AppSnackbar.apiError(e, stackTrace: stack);
    }
  }

  // -----------------------
  // PICK TIME
  // -----------------------
  Future<void> pickTime(RxString target) async {
    TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formattedTime = DateFormat("hh:mm a")
          .format(DateTime(2025, 1, 1, picked.hour, picked.minute));

      target.value = formattedTime;

      if (identical(target, fromTime)) {
        _fromTimeOfDay = picked;
      } else if (identical(target, toTime)) {
        _toTimeOfDay = picked;
      }
    }
  }

  // ── Combines today's date with the picked time into a full ISO DateTime string ──
  String? _isoDateTimeFor(TimeOfDay? t) {
    if (t == null) return null;
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute, 0);
    return dt.toIso8601String();
  }

  // 🆕 NEW: TimeOfDay ko 24-hour "HH:mm" string me badalta hai (e.g. "10:00")
  String _to24h(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  void resetForm() {
    activityController.clear();
    fromTime.value = "";
    toTime.value = "";
    _fromTimeOfDay = null;
    _toTimeOfDay = null;
    selectedStudent.clear();
    selectedStudentIds.clear();
  }

  // ==========================
  // SEND MEAL ACTIVITY TO API
  // ==========================
  Future<bool> postActivityToApi(List<int> studentIds) async {
    // 🆕 UPDATED URL (test server)
    const url = "https://playschool.edubloom.in/api/DailyActiviesApp/PostMealApp";

    if (studentIds.isEmpty) {
      // 🆕 CHANGED: Get.snackbar -> AppSnackbar
      AppSnackbar.error("Please select at least one student.");
      return false;
    }

    if (studentIds.any((id) => id == 0)) {
      // 🆕 CHANGED: Get.snackbar -> AppSnackbar
      AppSnackbar.error("Invalid student selected. Please re-select the student.");
      return false;
    }

    if (activityController.text.trim().isEmpty) {
      // 🆕 CHANGED: Get.snackbar -> AppSnackbar
      AppSnackbar.error("Please describe the meal activity.");
      return false;
    }

    if (fromTime.value.isEmpty || toTime.value.isEmpty) {
      // 🆕 CHANGED: Get.snackbar -> AppSnackbar
      AppSnackbar.error("Please select From and To time.");
      return false;
    }

    final fromIso = _isoDateTimeFor(_fromTimeOfDay);
    final toIso = _isoDateTimeFor(_toTimeOfDay);

    if (fromIso == null || toIso == null) {
      // 🆕 CHANGED: Get.snackbar -> AppSnackbar
      AppSnackbar.error("Please pick both From Time and To Time again.");
      return false;
    }

    // 🆕 24-hour "HH:mm" format (API body me yahi expected hai)
    final from24 = _to24h(_fromTimeOfDay!);
    final to24 = _to24h(_toTimeOfDay!);

    final nowIso = DateTime.now().toUtc().toIso8601String();

    final body = {
      "mealId": 0,
      "meal": activityController.text.trim(),
      "fromTime": from24,
      "toTime": to24,
      "action": "1",
      "createDate": nowIso,
      "updateDate": nowIso,
      "createBy": "Admin",
      "updateBy": "Admin",
      "schoolId": schoolId.value,
      "studentId": studentIds,
      "startTime": from24,
      "endTime": to24,
      "session": session.value,
      "classID": <int>[],                            // 🆕 NEW (class select nahi hoti, isliye khali list)
      "userId": int.tryParse(userId.value) ?? 0,     // 🆕 NEW
      "roleName": roleName.value,                    // 🆕 NEW
    };

    debugPrint("📤 POST Meal Activity => $url");
    debugPrint("📦 Body => ${jsonEncode(body)}");

    try {
      isSubmitting(true);

      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("Meal POST STATUS: ${res.statusCode}");
      debugPrint("Meal POST BODY: ${res.body}");

      if (res.statusCode == 200) {
        await fetchActivityList();
        resetForm();
        return true;
      } else {
        debugPrint("❌ Meal post failed => ${res.body}");
        // 🆕 ADDED: user ko "Something went wrong", console me asli error
        AppSnackbar.apiError(
          "Meal post failed: ${res.body}",
          statusCode: res.statusCode,
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint("❌ Exception while posting meal => $e");
      // 🆕 ADDED: user ko "Something went wrong", console me asli error
      AppSnackbar.apiError(e, stackTrace: stack);
      return false;
    } finally {
      isSubmitting(false);
    }
  }
}