import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/classmodel.dart'; // ListDataa, ClassItem (Notification jaisa hi)
import '../models/pre school student teach stu filter api model.dart';
import '../models/sectionmodel.dart'; // ListDatta (Notification jaisa hi)
import '../models/new model teacher section attendance.dart'; // SectionForAttendanceModel (class teacher ke sections ke liye)
import '../models/curriculum model.dart';
import '../models/session_model.dart' as session_model;
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // ClassTeacherFilterModel / ClassTeacherFilterData reuse ke liye

class CurriculumController extends GetxController {
  final curriculumList = <CurriculumData>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // ── Fields ─────────────────────────────────────────────────────────
  final curriculumName = ''.obs; // maps to "CurriculumName" in API
  final description = ''.obs; // maps to "Description" in API

  final file = ''.obs;
  final pdfFile = Rx<File?>(null);

  // set when editing an existing record, null when creating a new one
  final editingCurriculumId = Rx<int?>(null);
  var classList = <ListDataa>[].obs;
  var selectedClasses = <ListDataa>[].obs;

  var sectionList = <ListDatta>[].obs;
  var selectedSections = <ListDatta>[].obs;

  // ── Session (Dynamic API) ─────────────────────────────────────────
  RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);
  var session = ''.obs;

  // ── Auth ───────────────────────────────────────────────────────────
  String token = "";
  String schoolId = "";

  // 🆕 teacher/staff APIs ke liye stored Session (PrefConst.session) — curriculum
  // ke dynamic "session" dropdown se alag, wahi Notification me use hota hai
  String prefSession = "";

  var roleName = "".obs;

  // 🆕 ViewCurriculum GET API ab userId/roleName bhi maangta hai
  String loggedInUserId = "";

  // 🆕 Role / Teacher-type detection (class & section fetch ke liye) — Notification jaisa hi
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";
    prefSession = await PrefManager().readValue(key: PrefConst.session) ?? "";
    loggedInUserId =
        (await PrefManager().readValue(key: PrefConst.Userid) ?? "")
            .toString();

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final rawRole =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim();
    roleName.value = rawRole;
    final role = rawRole.toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    if (isStaffLogin.value) {
      // 🟢 STAFF — direct staff APIs
      fetchClasses();
      fetchSections();
    } else {
      // 🟡 TEACHER — pehle ClassTeacher filter check, phir uske hisaab se class/section
      await fetchClassTeacherFilter();
      fetchClasses();
      fetchSections();
    }

    await fetchSessions(); // session pehle load hogi
    fetchCurriculum();
  }

  // ── Fetch Session List (Dynamic API) ────────────────────────────────
  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
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
          session.value = cs.session ?? "";
        }
      } else {
        Get.snackbar("Error", "Failed to load session");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load sessions: $e");
    }
  }

  void setSelectedSession(session_model.sListDdata? value) {
    selectedSession.value = value;
    session.value = value?.session ?? "";
    // refresh the list whenever the session changes
    fetchCurriculum();
  }

  // ── Fetch Curriculum List ───────────────────────────────────────────
  // GET https://playschool.edubloom.in/api/MasterApp/ViewCurriculum/{schoolId}/{session}/{userId}/{roleName}
  Future<void> fetchCurriculum() async {
    try {
      isLoading(true);

      final sessionValue = selectedSession.value?.session ?? session.value;
      if (schoolId.isEmpty || sessionValue.trim().isEmpty) {
        curriculumList.value = [];
        return;
      }

      final userIdSegment = loggedInUserId.isNotEmpty ? loggedInUserId : "0";
      final roleSegment =
      Uri.encodeComponent(roleName.value.isNotEmpty ? roleName.value : "");

      final url = Uri.parse(
        '${AppUrl.base_url}api/MasterApp/ViewCurriculum/$schoolId/$sessionValue/$userIdSegment/$roleSegment',
      );

      debugPrint("📥 ViewCurriculum URL: $url"); // 🆕 debug

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint("📥 ViewCurriculum status: ${response.statusCode}"); // 🆕 debug
      debugPrint("📥 ViewCurriculum body: ${response.body}"); // 🆕 debug

      if (response.statusCode == 200) {
        final model = CurriculumModel.fromJson(jsonDecode(response.body));
        curriculumList.value = model.data ?? [];
      } else {
        Get.snackbar("Error", "Failed to load curriculum");
      }
    } catch (e) {
      debugPrint("⚠️ fetchCurriculum exception: $e"); // 🆕 debug
    } finally {
      isLoading(false);
    }
  }

  // 🆕 3-way class fetch: Staff -> existing API | Class Teacher -> ClassTeacher API
  // | Normal Teacher -> GetClassTeacher API | fallback -> existing (staff) API
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchClassesStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
        classList.value = classTeacherList.map((e) {
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
        classList.value = [];
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(prefSession)}'
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
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] as List<dynamic>? ?? [];

        classList.value = data.map((e) => ListDataa.fromJson(e)).toList();
      } else {
        classList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetClassTeacher classes: $e");
      classList.value = [];
    } finally {
      isLoading(false);
    }
  }

  // 🔁 Ye wahi ViewClass API hai — Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final classItem = ClassItem.fromJson(json.decode(response.body));

        classList.value = classItem.listData
            ?.where((e) => e.action == "1")
            .toList() ??
            [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🆕 3-way section fetch: Staff -> existing API | Class Teacher -> SectionTeacher API
  // | Normal Teacher -> getSectionTeacher API | fallback -> existing (staff) API
  Future<void> fetchSections() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchSectionsStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — SectionTeacher API
    if (isClassTeacherLogin.value) {
      try {
        isLoading(true);
        final userId = await PrefManager().readValue(key: PrefConst.Userid);

        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=${Uri.encodeComponent(schoolId)}'
              '&Session=${Uri.encodeComponent(prefSession)}'
              '&userId=${Uri.encodeComponent(userId ?? '')}',
        );

        final response = await http.get(
          url,
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        );

        debugPrint('SectionTeacher status: ${response.statusCode}');
        debugPrint('SectionTeacher body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final model = SectionForAttendanceModel.fromJson(decoded);

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
        } else {
          sectionList.value = [];
        }
      } catch (e) {
        debugPrint("⚠️ Error fetching SectionTeacher sections: $e");
        sectionList.value = [];
      } finally {
        isLoading(false);
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — getSectionTeacher API
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.getSectionTeacher}'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(prefSession)}'
            '&userId=${Uri.encodeComponent(userId ?? '')}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GetSectionTeacher status: ${response.statusCode}');
      debugPrint('GetSectionTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final list = (jsonResponse['data'] as List<dynamic>?) ?? [];
        sectionList.value = list.map((e) => ListDatta.fromJson(e)).toList();
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetSectionTeacher sections: $e");
      sectionList.value = [];
    } finally {
      isLoading(false);
    }
  }

  // 🔁 Ye wahi ViewSectionApp API hai — Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);
      final url = Uri.parse(
          "${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        sectionList.value = (json.decode(response.body)['listData'] as List)
            .map((e) => ListDatta.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
    } finally {
      isLoading(false);
    }
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo (Notification wala hi logic)
  Future<void> fetchClassTeacherFilter() async {
    try {
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      if (userId == null || userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(prefSession)}'
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

        // 🆕 Agar ClassTeacher API se class data mila, to matlab ye class teacher hai
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  /// ---------------------- MULTI-SELECT TOGGLES ----------------------
  void toggleClassSelection(ListDataa item) {
    final exists = selectedClasses.any((c) => c.classId == item.classId);
    if (exists) {
      selectedClasses.removeWhere((c) => c.classId == item.classId);
    } else {
      selectedClasses.add(item);
    }
  }

  void toggleSectionSelection(ListDatta item) {
    final exists = selectedSections.any((s) => s.sectionId == item.sectionId);
    if (exists) {
      selectedSections.removeWhere((s) => s.sectionId == item.sectionId);
    } else {
      selectedSections.add(item);
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      pdfFile.value = File(result.files.single.path!);
      file.value = result.files.single.name;
      ShortMessage.toast(title: file.value);
    } else {
      ShortMessage.toast(title: "No file selected");
    }
  }

  void resetForm() {
    pdfFile.value = null;
    file.value = "";
    curriculumName.value = "";
    description.value = "";
    selectedClasses.clear();
    selectedSections.clear();
    editingCurriculumId.value = null;
  }

  /// 🆕 Ab poori multi-selection EK hi POST call mein jaati hai:
  /// ClassId[]/SectionId[] arrays ke roop me (naye PostCurriculum API ke hisaab se).
  Future<void> registerCurriculum() async {
    if (pdfFile.value == null) {
      ShortMessage.toast(title: "Please select an Image or PDF file.");
      return;
    }
    if (curriculumName.value.trim().isEmpty) {
      ShortMessage.toast(title: "Please enter Curriculum Name.");
      return;
    }
    if (description.value.trim().isEmpty) {
      ShortMessage.toast(title: "Please enter Description.");
      return;
    }
    if (selectedClasses.isEmpty) {
      ShortMessage.toast(title: "Please select at least one class.");
      return;
    }
    if (selectedSections.isEmpty) {
      ShortMessage.toast(title: "Please select at least one section.");
      return;
    }
    final sessionValue =
    (selectedSession.value?.session ?? session.value).trim();
    if (sessionValue.isEmpty) {
      ShortMessage.toast(title: "Please select Session.");
      return;
    }

    isSubmitting(true);
    isLoading(true);

    try {
      final ok = await _postCurriculum(sessionValue: sessionValue);

      if (ok) {
        ShortMessage.toast(title: "Curriculum Added Successfully");
        resetForm();
        await fetchCurriculum();
        Get.back();
      } else {
        ShortMessage.toast(title: "Failed to add curriculum. Please try again.");
      }
    } finally {
      isSubmitting(false);
      isLoading(false);
    }
  }

  /// Helper: posts ONE curriculum entry carrying ALL selected classes & sections
  /// as arrays (ClassId[0], ClassId[1]... / SectionId[0], SectionId[1]...).
  /// Returns true on success (statusCode 200 AND isSuccess == true), false otherwise.
  Future<bool> _postCurriculum({required String sessionValue}) async {
    try {
      final url = Uri.parse('${AppUrl.base_url}api/MasterApp/PostCurriculum');
      final request = http.MultipartRequest('POST', url);

      final pickedFileName = pdfFile.value!.path.split('/').last;
      // auto label used for "PdfFileName" text field (without extension)
      final pdfLabel = pickedFileName.contains('.')
          ? pickedFileName.substring(0, pickedFileName.lastIndexOf('.'))
          : pickedFileName;

      final classNamesJoined =
      selectedClasses.map((c) => c.className ?? '').join(', ');
      final sectionNamesJoined =
      selectedSections.map((s) => s.section ?? '').join(', ');

      request.fields.addAll({
        'CurriculumId': (editingCurriculumId.value ?? 0).toString(),
        'CurriculumName': curriculumName.value.trim(),
        'ClassName': classNamesJoined,
        'Section': sectionNamesJoined,
        'Session': sessionValue,
        'Description': description.value.trim(),
        'SchoolId': schoolId,
        'Action': "1",
        'CreateBy': 'Admin',
        'PdfFileName': pdfLabel,
        'UserId': loggedInUserId.isNotEmpty ? loggedInUserId : '0',
        'RoleName': roleName.value,
      });

      // 🆕 Arrays: ClassId[0], ClassId[1] ... / SectionId[0], SectionId[1] ...
      for (int i = 0; i < selectedClasses.length; i++) {
        final classId = selectedClasses[i].classId?.toString() ?? '';
        if (classId.isNotEmpty) {
          request.fields['ClassId[$i]'] = classId;
        }
      }
      for (int i = 0; i < selectedSections.length; i++) {
        final sectionId = selectedSections[i].sectionId?.toString() ?? '';
        if (sectionId.isNotEmpty) {
          request.fields['SectionId[$i]'] = sectionId;
        }
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'PdfFile',
          pdfFile.value!.path,
          filename: pickedFileName,
        ),
      );

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      debugPrint(
          "POST CURRICULUM -> Classes:${selectedClasses.map((c) => c.classId).toList()} Sections:${selectedSections.map((s) => s.sectionId).toList()}");

      final streamed = await request.send();
      final resBody = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        Map<String, dynamic> decoded = {};
        try {
          decoded = jsonDecode(resBody);
        } catch (_) {}

        final success = decoded['isSuccess'] == true;
        if (success) {
          debugPrint('✅ Success: ${decoded['messages'] ?? resBody}');
          return true;
        } else {
          debugPrint('❌ API returned failure: ${decoded['messages'] ?? resBody}');
          return false;
        }
      } else {
        debugPrint('❌ Error: ${streamed.statusCode}, $resBody');
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ Exception in _postCurriculum: $e');
      return false;
    }
  }

  // ── Toggle Active / Inactive ─────────────────────────────────────────
  // GET https://playschool.edubloom.in/api/MasterApp/ActiveInactiveCurriculum/{schoolId}/{curriculumId}
  Future<void> toggleCurriculumStatus(int curriculumId) async {
    if (schoolId.isEmpty || curriculumId == 0) {
      ShortMessage.toast(title: "Invalid curriculum record");
      return;
    }

    try {
      isLoading(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/MasterApp/ActiveInactiveCurriculum/$schoolId/$curriculumId',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        try {
          CurriculumStatusModel.fromJson(jsonDecode(response.body));
        } catch (_) {}

        ShortMessage.toast(title: "Status updated successfully");

        // refresh list via ViewCurriculum
        await fetchCurriculum();
      } else {
        Get.snackbar(
          "Error",
          "Failed to update status (${response.statusCode})",
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update status: $e");
    } finally {
      isLoading(false);
    }
  }
}