import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/activitystudentmodel.dart';
import '../models/behaviourmodel.dart';
import '../models/class_list_model.dart';   // 🔄 naya import
import '../models/viewactivitymodel.dart';
import '../res/app_url.dart';

class Behaviourcontroller extends GetxController {

  var listDataa = <ClassData>[].obs;              // 🔄 ClassItem/ListDataa hata diya
  var selectedClass = Rx<ClassData?>(null);        // 🔄

  RxString selecttype = "".obs;

  RxList<Data> selectedStudent = <Data>[].obs;
  RxList<int> selectedStudentIds = <int>[].obs;
  RxList<Data> studentList = <Data>[].obs;

  TextEditingController activityController = TextEditingController();

  RxString fromTime = "".obs;
  RxString toTime = "".obs;
  var isLoading = true.obs;
  var schoolId = "".obs;
  var session = "".obs;
  var userId = "".obs;    // ✅ naya

  // -----------------------
  // VIEW ACTIVITY LIST
  // -----------------------
  RxList<beData> activityList = <beData>[].obs;

  @override
  void onInit() async {
    super.onInit();

    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? "";
    userId.value = await PrefManager().readValue(key: PrefConst.Userid) ?? ""; // ✅ naya

    fetchClasses();        // Load classes on screen open
    fetchStudents();       // Initial fetch (if needed)
    fetchActivityList();   // Load view activity on screen open
  }

  Future<void> fetchClasses() async {
    if (session.value.isEmpty) {
      print("Session not found, skipping fetchClasses");
      return;
    }

    try {
      isLoading(true);

      final url =
          '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=${schoolId.value}&Session=${session.value}&userId=${userId.value}';

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200) {
        final parsed = ClassListModel.fromJson(jsonDecode(res.body));

        // GetClassTeacher me action null aata hai, isliye filter nahi lagayenge
        listDataa.value = parsed.listData;

        // Set empty selection so dropdown shows "Select Class"
        selectedClass.value = null;
      }
    } catch (e) {
      print("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  // Function to set selected class
  void setSelectedClass(ClassData? value) {   // 🔄 type change
    selectedClass.value = value;
  }

  Future<void> fetchStudents() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllStudentAsynsApp?schoolId=${schoolId.value}&session=${session.value}";
    print("Fetching Students: $url");

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonBody = jsonDecode(res.body);

      studentList.value =
          (jsonBody["data"] as List).map((e) => Data.fromJson(e)).toList();

      print("Fetched ${studentList.length} students");
    } else {
      Get.snackbar("Error", "Unable to load students: ${res.statusCode}");
    }
  }

  // -----------------------
  // FETCH ALL ACTIVITIES (VIEW ACTIVITY)
  // -----------------------
  Future<void> fetchActivityList() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllBehaviourAsyncApp?schoolId=${schoolId}&session=${session}";

    print("Fetching All Activities: $url");

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonBody = jsonDecode(res.body);

      if (jsonBody["data"] != null) {
        activityList.value =
            (jsonBody["data"] as List).map((e) => beData.fromJson(e)).toList();
      }
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
    }
  }

  // ==========================
  // SEND ACTIVITY TO API (Multiple Student IDs)
  // ==========================
  Future<bool> postActivityToApi(List<int> studentIds) async {
    const url = "https://playschool.edubloom.in/api/DailyActiviesApp/PostBehaviourApp";

    bool allSuccess = true;

    for (int studentId in studentIds) {
      final body = {
        "behaviourId": 0,
        "behaviour": activityController.text,
        "fromTime": fromTime.value,
        "toTime": toTime.value,
        "action": "1",
        "createDate": DateTime.now().toIso8601String(),
        "updateDate": DateTime.now().toIso8601String(),
        "createBy": "admin",
        "updateBy": "admin",
        "schoolId": schoolId.value,
        "studentId": studentId,
        "admissionNo": "",
        "startTime": fromTime.value,
        "endTime": toTime.value,
        "session": session.value
      };

      try {
        final res = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        if (res.statusCode == 200) {
          print("✔ Activity posted for student $studentId");
          Get.back();
        } else {
          print("❌ Failed for student $studentId → ${res.body}");
          allSuccess = false;
        }
      } catch (e) {
        print("❌ Exception while posting for student $studentId → $e");
        allSuccess = false;
      }
    }

    return allSuccess;
  }
}