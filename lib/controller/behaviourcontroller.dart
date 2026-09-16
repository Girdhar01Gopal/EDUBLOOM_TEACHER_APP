import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/Daycaremodel.dart';
import '../models/activitystudentmodel.dart';
import '../models/behaviourmodel.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/stationary_action1.dart';
import '../res/app_url.dart';
import '../infrastructures/routes/page_constants.dart';
import '../models/classmodel.dart' show ClassItem, ListDataa;

// ── EXTENSIONS USING EXPANDO TO DYNAMICALLY ADD FIELDS WITHOUT ALTERING THE MODEL FILES ──
extension DataClassFields on Data {
  static final _classIds = Expando<int>();
  static final _classNames = Expando<String>();

  int? get classId => _classIds[this];
  set classId(int? value) => _classIds[this] = value;

  String? get className => _classNames[this];
  set className(String? value) => _classNames[this] = value;
}

extension BeDataFields on beData {
  static final _classNames = Expando<String>();

  String? get className => _classNames[this];
  set className(String? value) => _classNames[this] = value;
}

class Behaviourcontroller extends GetxController {


  RxString selecttype = "".obs;

  var classes = <ClassItem>[].obs;
  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  // ── Multiple class selection (mirrors NotificationController /
  // Mealcontroller pattern) ──
  RxList<ListDataa> selectedClasses = <ListDataa>[].obs;

  RxList<Data> selectedStudent = <Data>[].obs;
  RxList<int> selectedStudentIds = <int>[].obs;

  // ── This is the list actually shown in the student picker. It is
  // recomputed from _allStudents whenever the type or the selected
  // class(es) change. ──
  RxList<Data> studentList = <Data>[].obs;

  // ── Full unfiltered student list for the currently selected type.
  // Pre School: filtered down into `studentList` based on
  // `selectedClasses`. Day Care: copied into `studentList` as-is
  // (no class concept for Day Care). ──
  final RxList<Data> _allStudents = <Data>[].obs;

  TextEditingController activityController = TextEditingController();

  RxString fromTime = "".obs;
  RxString toTime = "".obs;
  var isLoading = true.obs;
  var schoolId = "".obs;
  var session = "".obs;

  var isStaffLogin = false.obs;
  var isClassTeacherLogin = false.obs;
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  // -----------------------
  // VIEW ACTIVITY LIST
  // -----------------------
  RxList<beData> activityList = <beData>[].obs;

  // ── search box on the "View Behaviour" tab. Filters by student
  // name, class name, date, or the behaviour text (the card heading). ──
  RxString searchQuery = "".obs;

  List<beData> get filteredActivityList {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return activityList;
    return activityList.where((act) {
      final name = (act.studentName ?? "").toLowerCase();
      final className = (act.className ?? "").toLowerCase();
      final date = (act.createDate ?? "").toLowerCase();
      final text = (act.behaviour ?? "").toLowerCase();
      return name.contains(q) ||
          className.contains(q) ||
          date.contains(q) ||
          text.contains(q);
    }).toList();
  }

  @override
  void onInit() async {
    super.onInit();

    schoolId.value = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? "";

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    // (identical detection to NotificationController.onInit).
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    if (isStaffLogin.value) {
      // 🟢 STAFF — direct staff API
      fetchClasses();
    } else {
      // 🟡 TEACHER — pehle ClassTeacher filter check, phir uske hisaab se class
      await fetchClassTeacherFilter();
      fetchClasses();
    }

    fetchActivityList(); // Load view activity on screen open

    // ── NOTE: students are no longer fetched unconditionally here.
    // Student list now depends on the selected Student Type — see
    // onTypeChanged(). ──
  }

  // 🆕 3-way class fetch: Staff -> existing ViewClass API | Class Teacher ->
  // ClassTeacher API | Normal Teacher -> GetClassTeacher API | fallback ->
  // existing (staff) API. Mirrors NotificationController.fetchClasses()
  // exactly, adapted to this controller's `listDataa` / `selectedClasses`
  // field names
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
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        listDataa.value = [];
      }

      // Reset selection so dropdown/chips show a clean state.
      selectedClass.value = null;
      selectedClasses.clear();

      if (listDataa.isEmpty) {
        debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
        await _fetchClassesStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId.value)}'
            '&Session=${Uri.encodeComponent(session.value)}'
            '&userId=${Uri.encodeComponent(userId ?? '')}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GetClassTeacher status: ${response.statusCode}');
      debugPrint('GetClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] as List<dynamic>? ?? [];

        listDataa.value = data.map((e) => ListDataa.fromJson(e)).toList();
      } else {
        listDataa.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetClassTeacher classes: $e");
      listDataa.value = [];
    } finally {
      isLoading(false);
    }

    selectedClass.value = null;
    selectedClasses.clear();

    if (listDataa.isEmpty) {
      debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
      await _fetchClassesStaffApi();
    }
  }

  // 🔁 Ye wahi ViewClass API hai — Staff ke liye main path, Teacher ke liye
  // fallback. (Was the original fetchClasses() body.)
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);

      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/${schoolId.value}'),
      );

      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));

        // Filter the listData to include only classes where action == "1"
        listDataa.value = parsed.listData
            ?.where((e) => e.action == "1")
            .toList() ?? [];
      } else {
        listDataa.value = [];
      }
    } catch (e) {
      debugPrint("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }

    // Set empty selection so dropdown/chips show a clean state.
    selectedClass.value = null;
    selectedClasses.clear();
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo (Notification wala
  // hi logic) — sets isClassTeacherLogin so fetchClasses() knows which
  // branch to take.
  Future<void> fetchClassTeacherFilter() async {
    try {
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      if (userId == null || userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId.value)}'
            '&Session=${Uri.encodeComponent(session.value)}'
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
        final jsonResponse = jsonDecode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];

        // 🆕 Agar ClassTeacher API se class data mila, to matlab ye class
        // teacher hai
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  // Function to set selected class
  void setSelectedClass(ListDataa? studentClassId) {
    selectedClass.value = studentClassId;
  }

  // ── Toggle a class in/out of the multi-selection (mirrors
  // NotificationController.toggleClassSelection) ──
  void toggleClassSelection(ListDataa classItem) {
    final exists =
    selectedClasses.any((c) => c.classId == classItem.classId);
    if (exists) {
      selectedClasses.removeWhere((c) => c.classId == classItem.classId);
    } else {
      selectedClasses.add(classItem);
    }
    // ── Re-apply the class filter to the student list every time the
    // class selection changes. Only meaningful for Pre School. ──
    _applyClassFilter();
  }

  // ── Clears all selected classes and re-applies the filter (so the
  // student list goes back to showing every Pre School student).
  // Use this from the view's "Clear" button instead of clearing
  // selectedClasses directly, so studentList stays in sync. ──
  void clearSelectedClasses() {
    selectedClasses.clear();
    _applyClassFilter();
  }

  // ── Comma separated selected class ids (mirrors
  // NotificationController.getSelectedClassIds) ──
  String getSelectedClassIds() {
    return selectedClasses
        .map((classItem) => classItem.classId.toString())
        .join(',');
  }

  // -----------------------
  // STUDENT TYPE CHANGE (mirrors Mealcontroller's type dropdown
  // onChanged: resets students/classes and fetches the right list) ──
  // -----------------------
  void onTypeChanged(String value) {
    selecttype.value = value;

    // Reset student & class selection whenever type changes
    selectedStudent.clear();
    selectedStudentIds.clear();
    studentList.clear();
    _allStudents.clear();
    selectedClasses.clear();
    selectedClass.value = null;

    if (value == "Day Care") {
      _fetchDaycareStudents();
    } else {
      // Pre School — class list should already be loaded from onInit,
      // but refresh in case it hasn't loaded yet / school changed.
      if (listDataa.isEmpty) {
        fetchClasses();
      }
      fetchStudents();
    }
  }

  // ✅ Day Care students — mirrors Mealcontroller._fetchDaycareStudents
  // word for word (same endpoint, same mapping into Data).
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
        _allStudents.value = list.map((s) {
          return Data(
            studentId: s.studentID ?? 0,       // ← capital ID
            studentName: s.studentName ?? "Unknown",
          );
        }).toList();

        // Day Care has no class concept — show list as-is.
        studentList.value = List<Data>.from(_allStudents);

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

  // ✅ Pre School students — api/StudentApp/GetAllStudentAsynsApp
  // (POST, same endpoint & body shape as StudentController.fetchVStudents()).
  // Returns classId/className per student, so class-based filtering works.
  Future<void> fetchStudents() async {
    final url = Uri.parse('${AppUrl.base_url}api/StudentApp/GetAllStudentAsynsApp');

    final body = {
      "schoolId": schoolId.value,
      "currentSession": session.value,
    };

    debugPrint("📥 Pre School Students POST => $url");
    debugPrint("📦 Body => ${jsonEncode(body)}");

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("Pre School Students STATUS: ${res.statusCode}");

      if (res.statusCode == 200) {
        final jsonBody = jsonDecode(res.body);
        final parsed = StudentModel.fromJson(jsonBody);
        final list = parsed.data ?? [];

        // Map StudentData (student_model.dart) → Data (this controller's
        // student type), carrying classId/className across so
        // _applyClassFilter() has something real to filter on.
        _allStudents.value = list.map((s) {
          final d = Data(
            studentId: s.studentID ?? 0,
            studentName: s.studentName ?? "Unknown",
          );
          d.classId = s.classId;
          d.className = s.className;
          return d;
        }).toList();

        debugPrint("✅ Pre School students loaded: ${_allStudents.length}");
        debugPrint(
            "Parsed classId per student: ${_allStudents.map((s) => '${s.studentName}=classId:${s.classId}').toList()}");

        // Apply whatever class filter is currently selected (none yet
        // right after a fresh fetch, so this just mirrors the full list).
        _applyClassFilter();
      } else {
        Get.snackbar("Error", "Unable to load students: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Pre School fetch error => $e");
      Get.snackbar("Error", "Failed to fetch students");
    }
  }

  // ── Recomputes `studentList` from `_allStudents` based on the
  // current type + selected class(es). Pre School with class(es)
  // selected → only students in those classes. Otherwise → full list. ──
  void _applyClassFilter() {
    if (selecttype.value == "Pre School" && selectedClasses.isNotEmpty) {
      final selectedIds = selectedClasses.map((c) => c.classId).toSet();
      studentList.value = _allStudents
          .where((s) => selectedIds.contains(s.classId))
          .toList();

      // 🔍 DEBUG: shows exactly what class filter is being matched
      // against and how many students it kept.
      debugPrint("🔍 Filtering by classIds=$selectedIds → matched ${studentList.length} of ${_allStudents.length} students");
    } else {
      studentList.value = List<Data>.from(_allStudents);
    }

    // Drop any previously selected students that fell out of the
    // now-visible list (e.g. class filter changed).
    selectedStudent.removeWhere((s) => !studentList.contains(s));
    selectedStudentIds.value =
        selectedStudent.map((s) => s.studentId!).toList();
  }

  // -----------------------
  // FETCH ALL ACTIVITIES (VIEW ACTIVITY)
  // -----------------------
  Future<void> fetchActivityList() async {
    final url =
        "https://playschool.edubloom.in/api/DailyActiviesApp/GetAllBehaviourAsyncApp?schoolId=${schoolId.value}&session=${session.value}";

    debugPrint("Fetching All Activities: $url");

    final res = await http.get(Uri.parse(url));

    if (res.statusCode == 200) {
      final jsonBody = jsonDecode(res.body);

      if (jsonBody["data"] != null) {
        activityList.value = (jsonBody["data"] as List).map((e) {
          final b = beData.fromJson(e);
          b.className = e['className']?.toString();
          return b;
        }).toList();
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

  // ── clear the "Add Behaviour" form after a successful post ──
  void resetForm() {
    activityController.clear();
    fromTime.value = "";
    toTime.value = "";
    selectedStudent.clear();
    selectedStudentIds.clear();
    selectedClasses.clear();
    selectedClass.value = null;
    // Class filter cleared → studentList goes back to showing every
    // student of the currently selected type.
    _applyClassFilter();
  }

  // -----------------------

// ==========================
// SEND ACTIVITY TO API (Multiple Student IDs)
// ==========================
  Future<bool> postActivityToApi(List<int> studentIds) async {
    const url = "https://playschool.edubloom.in/api/DailyActiviesApp/PostBehaviourApp";

    bool allSuccess = true;  // Track if all requests are successful

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
          debugPrint("✔ Behaviour posted for student $studentId");
        } else {
          debugPrint("❌ Failed for student $studentId → ${res.body}");
          allSuccess = false;  // Set false if any request fails
        }
      } catch (e) {
        debugPrint("❌ Exception while posting for student $studentId → $e");
        allSuccess = false;  // Set false if any request fails
      }
    }


    if (allSuccess) {
      await fetchActivityList();
      resetForm();
      Get.offNamed(RouteName.behaviour);
    }

    return allSuccess;  // Return true if all requests were successful
  }
}