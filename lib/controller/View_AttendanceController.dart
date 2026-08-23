import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/new model teacher section attendance.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/sectionmodel.dart';
import '../models/session_model.dart' as session_model;
import '../models/viewattendancemodel.dart';
import '../res/app_url.dart';
import 'student_controller.dart'; // 🆕 ClassTeacherFilterModel / ClassTeacherFilterData reuse ke liye

class ViewAttendanceController extends GetxController {
  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null);

  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);
  var session = ''.obs;

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rx<ListDatta?>(null);

  final months = [
    {'name': 'January', 'id': 1},
    {'name': 'February', 'id': 2},
    {'name': 'March', 'id': 3},
    {'name': 'April', 'id': 4},
    {'name': 'May', 'id': 5},
    {'name': 'June', 'id': 6},
    {'name': 'July', 'id': 7},
    {'name': 'August', 'id': 8},
    {'name': 'September', 'id': 9},
    {'name': 'October', 'id': 10},
    {'name': 'November', 'id': 11},
    {'name': 'December', 'id': 12},
  ];

  var selectedMonth = Rx<Map<String, dynamic>?>(null);

  RxList<ListData> students = <ListData>[].obs;

  var isLoading = false.obs;
  var schoolId = "";
  var token = "";

  // 🆕 Class Teacher filter (jo classes teacher ko assigned hain)
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var allowedClassNames = <String>[].obs;
  var isClassTeacherLogin = false.obs; // 🆕 true agar ClassTeacher API se data mile

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";

    if (schoolId.trim().isEmpty) {
      Get.snackbar('Error', 'SchoolId not found in storage');
      return;
    }

    await fetchSessions();           // ✅ pehle session load hone do
    await fetchClassTeacherFilter(); // 🆕 teacher ke allowed classes le lo
    await fetchClasses();            // ✅ ab Session param sahi jayega
    fetchSections();
  }

  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        sessionList.clear();
        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata session) {
    selectedSession.value = session;
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo (access filter ke liye)
  Future<void> fetchClassTeacherFilter() async {
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      if (userId == null || userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(selectedSession.value?.session ?? '')}'
            '&userId=${Uri.encodeComponent(userId)}',
      );

      final res = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('ClassTeacher status: ${res.statusCode}');
      debugPrint('ClassTeacher body: ${res.body}');

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];

        allowedClassNames.value = classTeacherList
            .map((e) => (e.className ?? '').trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList();

        // 🆕 Agar ClassTeacher API se class data mila, to matlab ye class teacher hai
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchClasses() async {
    // 🆕 Agar class teacher login hai, to class dropdown ClassTeacher API ke
    // data se hi banao — GetClassTeacher API call hi nahi lagegi
    if (isClassTeacherLogin.value) {
      listDataa.value = classTeacherList.map((e) {
        return ListDataa.fromJson({
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
      selectedClass.value = null;
      return;
    }

    // 🔁 Otherwise — normal teacher — jo API pehle se lagi hui hai wahi chalegi
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      if (userId == null || userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(selectedSession.value?.session ?? '')}'
            '&userId=${Uri.encodeComponent(userId)}',
      );

      final res = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GetClassTeacher status: ${res.statusCode}');
      debugPrint('GetClassTeacher body: ${res.body}');

      if (res.statusCode == 200) {
        final jsonResponse = jsonDecode(res.body);

        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] ?? [];

          // ❌ action filter hata diya — GetClassTeacher me action null aata hai
          listDataa.value = data.map((e) => ListDataa.fromJson(e)).toList();
          selectedClass.value = null;
        } else {
          listDataa.value = [];
          selectedClass.value = null;
        }
      }
    } catch (e) {
      debugPrint("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🔁 Ab SectionTeacher API se sections fetch honge, SectionForAttendanceModel se parse karke
  Future<void> fetchSections() async {
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      if (userId == null || userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping section fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(selectedSession.value?.session ?? '')}'
            '&userId=${Uri.encodeComponent(userId)}',
      );

      final res = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('SectionTeacher status: ${res.statusCode}');
      debugPrint('SectionTeacher body: ${res.body}');

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final model = SectionForAttendanceModel.fromJson(decoded);

        // ✅ existing ListDatta type me hi map kar rahe hai taaki screen untouched rahe
        sectionList.value = (model.data ?? []).map((e) {
          return ListDatta.fromJson({
            'sectionId': e.sectionId,
            'section': e.section,
            'action': e.action,
            'createDate': e.createDate,
            'updateDate': e.updateDate,
            'createBy': e.createBy,
            'updateBy': e.updateBy,
            'schoolId': e.schoolId,
          });
        }).toList();

        selectedSection.value = null;
      }
    } catch (e) {
      debugPrint("Error fetching sections: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> searchAttendance() async {
    if (selectedSession.value == null ||
        selectedClass.value == null ||
        selectedSection.value == null ||
        selectedMonth.value == null) {
      Get.snackbar("Error", "Please select all fields");
      return;
    }
    try {
      isLoading(true);
      final url = Uri.parse(
          '${AppUrl.base_url}api/StudentApp/ViewStudentAttendanceDetailsApp');
      final body = {
        "session": selectedSession.value!.session,
        "classId": selectedClass.value!.classId,
        "sectionId": selectedSection.value!.sectionId,
        "month": selectedMonth.value!['id'],
        "schoolId": schoolId,
      };
      debugPrint("📤 Sending Body => $body");
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint("📥 Response => ${res.body}");
      if (res.statusCode == 200) {
        final parsed = viewattendence.fromJson(jsonDecode(res.body));
        final allStudents = parsed.listData ?? [];

        // 🆕 sirf teacher ke assigned class ke students ki attendance dikhao
        if (allowedClassNames.isNotEmpty) {
          final filtered = allStudents.where((s) {
            final cName = (s.className ?? '').trim().toLowerCase();
            return allowedClassNames.contains(cName);
          }).toList();

          students.value = filtered;
        } else {
          students.value = allStudents;
        }
      } else {
        Get.snackbar("Error", "Failed to load attendance");
      }
    } catch (e) {
      Get.snackbar("Error", "$e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedMonth(String monthName) {
    selectedMonth.value = months.firstWhere(
          (m) => m['name'] == monthName,
      orElse: () => months[0],
    );
  }

  int getYearFromSession() {
    final sessionStr = selectedSession.value?.session ?? "";
    if (sessionStr.contains("-")) {
      final parts = sessionStr.split("-");
      final parsed = int.tryParse(parts[0]);
      if (parsed != null) return parsed;
    }
    return DateTime.now().year;
  }

  Future<bool> editAttendance({
    required int studentId,
    required String status,
    required int day,
  }) async {
    final monthId = selectedMonth.value?['id'] as int? ?? 1;
    final year = getYearFromSession();
    final dateStr =
        "$year-${monthId.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

    try {
      final url =
      Uri.parse('${AppUrl.base_url}api/StudentApp/SaveAttendenceApp');
      final body = {
        "studentId": studentId,
        "status": status,
        "months": monthId,
        "session": selectedSession.value?.session ?? "",
        "classId": selectedClass.value?.classId,
        "sectionId": selectedSection.value?.sectionId,
        "adate": dateStr,
        "schoolId": schoolId,
        "userAttendance": "Admin",
      };
      debugPrint("📤 editAttendance => ${jsonEncode(body)}");
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      debugPrint("📥 editAttendance => ${res.statusCode} | ${res.body}");
      return res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 204;
    } catch (e) {
      debugPrint("⚠️ editAttendance error: $e");
      return false;
    }
  }
}