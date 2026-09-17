import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/class_list_model.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/session_model.dart' as session_model; // ✅ fixed: relative import

import '../models/FeeTypeReportmodel.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart'; // ✅ now contains ClassListModel / ClassData (GetClassTeacher)
import '../models/fee_type_model.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse (Notes wali logic)

class FeeTypeReportController extends GetxController {
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  final feeTypeList = <fData>[].obs;
  final selectedFeeType = Rx<fData?>(null);

  final listDataa = <ClassData>[].obs; // ✅ now ClassData instead of ListDataa
  final selectedClass = Rx<ClassData?>(null); // ✅ type updated

  final feeReportList = <fListData>[].obs;

  final isPageLoading = false.obs;
  final isSearching = false.obs;

  // 🆕 Notes wali logic ke liye alag class-loading flag
  final isClassLoading = false.obs;

  String schoolId = '';
  String token = '';

  // ✅ added for GetClassTeacher API — adjust PrefConst keys if names differ
  String session = '';
  String userId = '';

  // 🆕 Role / Teacher-type detection (Notes wali hi logic)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session = await PrefManager().readValue(key: PrefConst.session); // ✅ adjust key if needed
    userId = await PrefManager().readValue(key: PrefConst.Userid); // ✅ adjust key if needed

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    // 🆕 Notes jaisa hi flow — pehle ClassTeacher filter (agar teacher hai)
    if (!isStaffLogin.value) {
      await fetchClassTeacherFilter();
    }

    await Future.wait([
      fetchClasses(),
      fetchSessions(),
      fetchFeeType(),
    ]);
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo (Notes wali hi logic)
  Future<void> fetchClassTeacherFilter() async {
    try {
      if (userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        'https://playschool.edubloom.in/api/TeacherApp/ClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session)}'
            '&userId=${Uri.encodeComponent(userId)}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('ClassTeacher status: ${response.statusCode}');
      debugPrint('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  /// ---------------------- FETCH CLASSES (3-way) ----------------------
  // 1️⃣ STAFF -> ViewClass API | 2️⃣ CLASS TEACHER -> ClassTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetClassTeacher API | fallback -> staff API
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchClassesStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
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
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        listDataa.value = [];
      }

      // if (listDataa.isEmpty) {
      //   debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
      //   await _fetchClassesStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      isPageLoading(true);
      isClassLoading(true);
      final res = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=$session&userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed = ClassListModel.fromJson(jsonDecode(res.body));
        // ⚠️ GetClassTeacher sends "action": null for most rows, so the
        // old ".where((e) => e.action == '1')" filter would empty the list.
        listDataa.assignAll(parsed.listData);
      } else {
        Get.snackbar('Error', 'Class API failed: ${res.statusCode}');
        listDataa.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Class API error: $e');
      listDataa.value = [];
    } finally {
      isPageLoading(false);
      isClassLoading(false);
    }

    // if (listDataa.isEmpty) {
    //   debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
    //   await _fetchClassesStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isPageLoading(true);
      isClassLoading(true);
      final url =
      Uri.parse("https://playschool.edubloom.in/api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      debugPrint('ViewClass (staff) status: ${response.statusCode}');
      debugPrint('ViewClass (staff) body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> rawList = decoded['listData'] ?? [];

        listDataa.value = rawList
            .map((e) => ClassData.fromJson(e))
            .where((e) => e.action == "1")
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching classes (staff): $e");
    } finally {
      isPageLoading(false);
      isClassLoading(false);
    }
  }

  Future<void> fetchFeeType() async {
    try {
      isPageLoading(true);
      final response = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/FeeMasterApp/ViewFeeTypeApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = FeeTypeModel.fromJson(jsonData);
        feeTypeList.assignAll(model.listData ?? []);
      } else {
        Get.snackbar('Error', 'FeeType API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'FeeType API error: $e');
    } finally {
      isPageLoading(false);
    }
  }

  Future<void> fetchSessions() async {
    try {
      isPageLoading(true);
      final response = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
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
      } else {
        Get.snackbar('Error', 'Session API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Session API error: $e');
    } finally {
      isPageLoading(false);
    }
  }

  void setSelectedClass(ClassData? val) => selectedClass.value = val; // ✅ type updated

  void setSelectedFeeType(fData? val) => selectedFeeType.value = val;

  void setSelectedSession(session_model.sListDdata? val) =>
      selectedSession.value = val;

  Future<void> searchReport() async {
    if (selectedSession.value == null) {
      Get.snackbar('Missing', 'Select Session first');
      return;
    }
    if (selectedFeeType.value == null) {
      Get.snackbar('Missing', 'Select Fee Type first');
      return;
    }
    if (selectedClass.value == null) {
      Get.snackbar('Missing', 'Select Class first');
      return;
    }

    final body = {
      "class": "",
      "session": selectedSession.value!.session,
      "feeType": selectedFeeType.value!.feeType,
      "classId": selectedClass.value!.classId.toString(),
      "schoolId": schoolId,
    };

    try {
      isSearching(true);
      feeReportList.clear();

      final response = await http.post(
        Uri.parse(
            'https://playschool.edubloom.in/api/ReportApp/ViewGetFeeTypeReportApp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final report = FeeReport.fromJson(jsonData);
        feeReportList.assignAll(report.listData ?? []);
      } else {
        Get.snackbar('Error', 'Report api failed : ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Report API error: $e');
    } finally {
      isSearching(false);
    }
  }
}