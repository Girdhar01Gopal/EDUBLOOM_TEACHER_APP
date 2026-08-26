import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/activitystudentmodel.dart';
import '../models/class_list_model.dart';   // 🔄 naya import (classmodel.dart hata diya)
import '../models/mealactivitymodel.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/viewactivitymodel.dart';
import '../res/app_url.dart';
import 'student_controller.dart' show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 ClassTeacherFilterModel / ClassTeacherFilterData reuse ke liye

class Mealcontroller extends GetxController {

  // -----------------------
  // OBSERVABLE STATE
  // -----------------------

  RxString selecttype = "".obs;
  var listDataa = <ClassData>[].obs;              // 🔄
  var selectedClass = Rx<ClassData?>(null);        // 🔄

  RxList<Data> selectedStudent = <Data>[].obs;
  RxList<int> selectedStudentIds = <int>[].obs;
  RxList<Data> studentList = <Data>[].obs;

  TextEditingController activityController = TextEditingController();

  RxString fromTime = "".obs;
  RxString toTime = "".obs;
  var isLoading = true.obs;
  var schoolId = "".obs;
  var session = "".obs;
  var userId = "".obs;   // ✅ naya

  // 🆕 Class Teacher filter (jo classes teacher ko assigned hain)
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var isClassTeacherLogin = false.obs; // 🆕 true agar ClassTeacher API se data mile

  // -----------------------
  // VIEW ACTIVITY LIST
  // -----------------------
  RxList<MData> activityList = <MData>[].obs;

  @override
  void onInit() async{
    super.onInit();

    schoolId.value =await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session.value =await PrefManager().readValue(key: PrefConst.session) ?? "";
    userId.value =await PrefManager().readValue(key: PrefConst.Userid) ?? "";   // ✅ naya

    await fetchClassTeacherFilter(); // 🆕 teacher ke allowed classes/sections check ke liye — sabse pehle
    fetchClasses();  // Load classes on screen open
    fetchStudents();  // Initial fetch (if needed)
    fetchActivityList();   // Load view activity on screen open
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo (access filter ke liye)
  Future<void> fetchClassTeacherFilter() async {
    try {
      if (userId.value.trim().isEmpty) {
        print("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId.value)}'
            '&Session=${Uri.encodeComponent(session.value)}'
            '&userId=${Uri.encodeComponent(userId.value)}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      print('ClassTeacher status: ${response.statusCode}');
      print('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];

        // 🆕 Agar ClassTeacher API se class data mila, to matlab ye class teacher hai
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      print("Error loading ClassTeacher filter: $e");
    }
  }

  Future<void> fetchClasses() async {
    isLoading(true); // 🆕 sabse pehle set karo

    // 🆕 Agar class teacher login hai, to class dropdown ClassTeacher API ke
    // data se hi banao — GetClassTeacher API call hi nahi lagegi
    if (isClassTeacherLogin.value) {
      listDataa.value = classTeacherList.map((e) {
        return ClassData.fromJson({
          'classId': e.classId,
          'class': e.className,
          'studentClassId': e.studentClassId,
          'action': e.action,
          'createDate': e.createDate,
          'updateDate': e.updateDate,
          'createBy': e.createBy,
          'updateBy': e.updateBy,
          'schoolId': e.schoolId,
          'sqno': e.sqno,
        });
      }).toList();

      // Set empty selection so dropdown shows "Select Class"
      selectedClass.value = null;
      isLoading(false); // 🆕 yahan bhi false karna zaroori hai
      return;
    }

    // 🔁 Otherwise — normal teacher — jo API pehle se lagi hui hai wahi chalegi
    if (session.value.isEmpty) {
      print("Session not found, skipping fetchClasses");
      isLoading(false); // 🆕 isko bhi false karo warna yahan se bhi stuck reh jayega
      return;
    }

    try {
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