import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/activitystudentmodel.dart';
import '../models/classmodel.dart';
import '../models/mealactivitymodel.dart';
import '../models/viewactivitymodel.dart';
import '../res/app_url.dart';

class Mealcontroller extends GetxController {

  // -----------------------
  // OBSERVABLE STATE
  // -----------------------

RxString selecttype = "".obs;
 var classes = <ClassItem>[].obs;
  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);
RxList<Data> selectedStudent = <Data>[].obs;
  RxList<int> selectedStudentIds = <int>[].obs;
  RxList<Data> studentList = <Data>[].obs;

  TextEditingController activityController = TextEditingController();

  RxString fromTime = "".obs;
  RxString toTime = "".obs;
  var isLoading = true.obs;
  var schoolId = "".obs;
  var session = "".obs;

  // -----------------------
  // VIEW ACTIVITY LIST
  // -----------------------
  RxList<MData> activityList = <MData>[].obs;

  @override
  void onInit() async{
    super.onInit();
    
    schoolId.value =await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session.value =await PrefManager().readValue(key: PrefConst.session) ?? "";
    fetchClasses();  // Load classes on screen open
   fetchStudents();  // Initial fetch (if needed)
    fetchActivityList();   // Load view activity on screen open
  }
  
Future<void> fetchClasses() async {
  try {
    isLoading(true);

    final res = await http.get(
      Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
    );

    if (res.statusCode == 200) {
      final parsed = ClassItem.fromJson(jsonDecode(res.body));

      // Filter the listData to include only classes where action == "1"
      listDataa.value = parsed.listData
          ?.where((e) => e.action == "1")
          .toList() ?? [];

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
  void setSelectedClass(ListDataa? studentClassId) {
    selectedClass.value = studentClassId;
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
    print("Student List: ${studentList.map((s) => '${s.studentName} (${s.studentId})').toList()}");
    print("Selected Type: ${studentList.map((s) => s.studentId).toSet().toList()}");
  } else {
    Get.snackbar("Error", "Unable to load students: ${res.statusCode}");
  }
}

  // -----------------------
  // FETCH ALL ACTIVITIES (VIEW ACTIVITY)
  // -----------------------
  Future<void> fetchActivityList() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllMealAsyncApp?schoolId=${schoolId.value}&session=${session.value}";

    print("Fetching All Activities: $url");

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonBody = jsonDecode(res.body);

      if (jsonBody["data"] != null) {
        activityList.value =
            (jsonBody["data"] as List).map((e) => MData.fromJson(e)).toList();
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

  // -----------------------
 
// ==========================
// SEND ACTIVITY TO API (Multiple Student IDs)
// ==========================
Future<bool> postActivityToApi(List<int> studentIds) async {
  const url = "https://playschool.edubloom.in/api/DailyActiviesApp/PostMealApp";

  bool allSuccess = true;  // Track if all requests are successful

  for (int studentId in studentIds) {
    final body = {
      "mealId": 0,
      "meal": activityController.text,
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
      "session": session.value
    };

    try {
      final res = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        print("✔ Meal Activity posted for student $studentId");
        Get.back();
      } else {
        print("❌ Failed for student $studentId → ${res.body}");
        allSuccess = false;  // Set false if any request fails
      }
    } catch (e) {
      print("❌ Exception while posting for student $studentId → $e");
      allSuccess = false;  // Set false if any request fails
    }
  }

  return allSuccess;  // Return true if all requests were successful
}
}