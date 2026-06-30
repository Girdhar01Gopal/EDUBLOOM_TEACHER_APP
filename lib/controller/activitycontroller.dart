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
          activityList.value =
              (jsonBody["data"] as List).map((e) => vData.fromJson(e)).toList();
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

  // -----------------------
  // ✅ POST ACTIVITY
  // -----------------------
  Future<bool> postActivityToApi(int studentId) async {
    if (studentId == 0) {
      debugPrint("❌ studentId = 0. Aborting.");
      Get.snackbar(
        "Error",
        "Invalid student selected. Please re-select the student.",
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
      return false;
    }

    if (activityController.text.trim().isEmpty) {
      Get.snackbar("Validation", "Please enter activity description.");
      return false;
    }

    if (fromTime.value.isEmpty || toTime.value.isEmpty) {
      Get.snackbar("Validation", "Please select From and To time.");
      return false;
    }

    const url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/PostActivitiesApp";

    final body = {
      "activityId": 0,
      "activity": activityController.text.trim(),
      "fromTime": fromTime.value,
      "toTime": toTime.value,
      "action": "1",
      "createDate": DateTime.now().toIso8601String(),
      "updateDate": DateTime.now().toIso8601String(),
      "createBy": "admin",
      "updateBy": "admin",
      "schoolId": schoolId.value,
      "studentId": studentId,
      "startTime": fromTime.value,
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
        activityController.clear();
        fromTime.value = "";
        toTime.value = "";
        selectedStudent.clear();
        selectedStudentIds.clear();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Post activity error => $e");
      return false;
    }
  }
}