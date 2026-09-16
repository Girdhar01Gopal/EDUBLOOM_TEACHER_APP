import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/classmodel.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';
import '../models/viewsectionmodel.dart';
import '../models/home_work_model.dart' as homework_model;
import '../models/new model teacher section attendance.dart';
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse

class HomeworkController extends GetxController {
  var homeworkList = <homework_model.Data>[].obs; // ✅ fixed type

  var isLoading = false.obs;

  var token = "";
  var schoolId = "";

  var homeworkName = ''.obs;
  var homeworkClass = ''.obs;

  var homeworkDate = DateTime.now().obs;

  var description = ''.obs;
  var homeworkPlace = ''.obs;

  var file = ''.obs;
  var pdfFile = Rx<File?>(null);

  var session = "".obs;

  // ✅ CHANGED: single select -> multi select (Note jaisa hi)
  var selectedClassIds = <int>[].obs;
  var selectedSectionIds = <int>[].obs;
  var selectedSubjectIds = <int>[].obs;

  var classes = <ClassItem>[].obs;
  var listDataa = <ListDataa>[].obs;
  var sectionList = <stListData>[].obs;
  var subjectlist = <ListDaataa>[].obs;

  final subjectdata = SubjectModel().obs;

  // 🆕 Role / Teacher-type detection (class & section & subject fetch ke liye)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session.value = await PrefManager().readValue(key: PrefConst.session);

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
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

    await fetchsubjectdata();
    fetchHomework();
  }

  String getDisplayDate() {
    return DateFormat('dd-MM-yyyy').format(homeworkDate.value);
  }

  String getFormattedDate() {
    return DateFormat('yyyy-MM-dd').format(homeworkDate.value);
  }

  void pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: homeworkDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != homeworkDate.value) {
      homeworkDate.value = pickedDate;
    }
  }

  /// ---------------------- MULTI-SELECT TOGGLES ----------------------
  void toggleClassSelection(int classId) {
    if (selectedClassIds.contains(classId)) {
      selectedClassIds.remove(classId);
    } else {
      selectedClassIds.add(classId);
    }
  }

  void toggleSectionSelection(int sectionId) {
    if (selectedSectionIds.contains(sectionId)) {
      selectedSectionIds.remove(sectionId);
    } else {
      selectedSectionIds.add(sectionId);
    }
  }

  void toggleSubjectSelection(int subjectId) {
    if (selectedSubjectIds.contains(subjectId)) {
      selectedSubjectIds.remove(subjectId);
    } else {
      selectedSubjectIds.add(subjectId);
    }
  }

  // ✅ UPDATED API: TeacherGetHomeworkAsyncApp
  // Ab UserId bhi query param me bhej rahe hai jaise naye endpoint me required hai.
  Future<void> fetchHomework() async {
    try {
      isLoading(true);

      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        'https://playschool.edubloom.in/api/CommumicationApp/TeacherGetHomeworkAsyncApp'
            '?currentSession=${Uri.encodeComponent(session.value)}'
            '&schoolId=${Uri.encodeComponent(schoolId)}'
            '&UserId=${Uri.encodeComponent(userId ?? '')}',
      );
      print("Fetching homework from URL: $url");

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

      debugPrint('TeacherGetHomeworkAsyncApp status: ${response.statusCode}');
      debugPrint('TeacherGetHomeworkAsyncApp body: ${response.body}');

      if (response.statusCode == 200) {
        final homeworkModel =
        homework_model.HomeworkModel.fromJson(jsonDecode(response.body)); // ✅ fixed
        homeworkList.value = homeworkModel.data ?? [];
      } else {
        Get.snackbar('Error', 'Failed to fetch homework');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: Failed to fetch homework');
    } finally {
      isLoading(false);
    }
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo
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
            '?schoolId=${Uri.encodeComponent(schoolId)}'
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
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] ?? [];

          // ❌ action filter hata diya — GetClassTeacher me action null aata hai
          listDataa.value = data.map((e) => ListDataa.fromJson(e)).toList();
        } else {
          listDataa.value = [];
        }
      } else {
        listDataa.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetClassTeacher classes: $e");
      listDataa.value = [];
    } finally {
      isLoading(false);
    }

    if (listDataa.isEmpty) {
      debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
      await _fetchClassesStaffApi();
    }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final classItem = ClassItem.fromJson(jsonDecode(response.body));

        listDataa.value = classItem.listData
            ?.where((e) => e.action == "1")
            .toList() ?? [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  /// ---------------------- FETCH SECTIONS (3-way) ----------------------
  // 1️⃣ STAFF -> ViewSectionApp API | 2️⃣ CLASS TEACHER -> SectionTeacher API
  // | 3️⃣ NORMAL TEACHER -> getSectionTeacher API | fallback -> staff API
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

        debugPrint('SectionTeacher status: ${response.statusCode}');
        debugPrint('SectionTeacher body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final model = SectionForAttendanceModel.fromJson(decoded);

          sectionList.value = (model.data ?? []).map((e) {
            return stListData.fromJson({
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

      if (sectionList.isEmpty) {
        debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
        await _fetchSectionsStaffApi();
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

      debugPrint('GetSectionTeacher status: ${response.statusCode}');
      debugPrint('GetSectionTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final sectionModel = sectionmodel.fromJson(jsonResponse);

        sectionList.value = sectionModel.listData ?? [];
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetSectionTeacher sections: $e");
      sectionList.value = [];
    } finally {
      isLoading(false);
    }

    if (sectionList.isEmpty) {
      debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
      await _fetchSectionsStaffApi();
    }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        sectionList.value = (jsonDecode(response.body)['listData'] as List)
            .map((e) => stListData.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
    } finally {
      isLoading(false);
    }
  }

  /// ---------------------- FETCH SUBJECTS (2-way: teacher -> staff fallback) ----------------------
  Future<void> fetchsubjectdata() async {
    // 1️⃣ STAFF — direct staff API
    if (isStaffLogin.value) {
      await _fetchSubjectsStaffApi();
      return;
    }

    // 2️⃣ TEACHER — existing teacher subject API
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.get_subject_teacher}'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session.value)}'
            '&userId=${Uri.encodeComponent(userId ?? '')}',
      );
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      debugPrint('GetSubjectTeacher status: ${response.statusCode}');
      debugPrint('GetSubjectTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final subjectWrapper = SubjectModel.fromJson(jsonDecode(response.body));
        subjectdata.value = subjectWrapper;
        subjectlist.value = subjectWrapper.listData ?? [];
      } else {
        subjectlist.value = [];
      }
    } catch (e) {
      debugPrint('Error loading teacher subjects: $e');
      subjectlist.value = [];
    } finally {
      isLoading(false);
    }

    // 🆕 FALLBACK: teacher API empty aaya to staff wali API try karo
    if (subjectlist.isEmpty) {
      debugPrint("↩️ Teacher subjects empty — falling back to staff API");
      await _fetchSubjectsStaffApi();
    }
  }

  // 🆕 Staff subject API (admin project se liya gaya URL pattern)
  Future<void> _fetchSubjectsStaffApi() async {
    try {
      isLoading(true);
      final url = '${AppUrl.base_url}${AppUrl.view_subject}$schoolId';

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      debugPrint('ViewSubject (staff) status: ${response.statusCode}');
      debugPrint('ViewSubject (staff) body: ${response.body}');

      if (response.statusCode == 200) {
        final subjectWrapper = SubjectModel.fromJson(jsonDecode(response.body));
        subjectdata.value = subjectWrapper;
        subjectlist.value = subjectWrapper.listData ?? [];
      }
    } catch (e) {
      debugPrint('Error loading staff subjects: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickFile(Rx<File?> pdfFile) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      pdfFile.value = File(result.files.single.path!);
      file.value = result.files.single.name;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FIX (400-type error prevention): backend har request me sirf 1
  // class + 1 section + 1 subject expect karta hai (index-wise
  // pairing), ek saath multiple values array me nahi. Isliye ab har
  // class-section-subject COMBINATION ke liye ek ALAG request bheji
  // jaati hai — parallel (Future.wait) taaki speed slow na ho. Har
  // request me hamesha 1 class + 1 section + 1 subject hota hai.
  // ─────────────────────────────────────────────────────────────
  Future<void> registerHomework() async {
    if (pdfFile.value == null) {
      ShortMessage.toast(title: "Please select a file.");
      return;
    }

    if (description.value.isEmpty) {
      ShortMessage.toast(title: "Please enter Description.");
      return;
    }

    if (selectedClassIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one class.");
      return;
    }

    if (selectedSectionIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one section.");
      return;
    }

    if (selectedSubjectIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one subject.");
      return;
    }

    isLoading(true);

    int successCount = 0;
    int failCount = 0;

    try {
      // ✅ Saari class-section-subject combinations ek saath (parallel)
      // bheji jaati hain, taaki total time sabse slowest single request
      // jitna hi lage.
      final futures = <Future<bool>>[];
      for (final classId in selectedClassIds) {
        for (final sectionId in selectedSectionIds) {
          for (final subjectId in selectedSubjectIds) {
            futures.add(
              _postSingleHomework(
                classId: classId,
                sectionId: sectionId,
                subjectId: subjectId,
              ),
            );
          }
        }
      }

      final results = await Future.wait(futures);
      for (final ok in results) {
        if (ok) {
          successCount++;
        } else {
          failCount++;
        }
      }

      debugPrint(
          "📊 POST HOMEWORK MULTI-SUBMIT DONE -> success:$successCount fail:$failCount");

      if (successCount > 0 && failCount == 0) {
        ShortMessage.toast(
            title: successCount == 1
                ? "Homework Added Successfully"
                : "$successCount Homeworks Added Successfully");
      } else if (successCount > 0 && failCount > 0) {
        ShortMessage.toast(
            title:
            "$successCount added, $failCount failed. Please check and retry.");
      } else {
        ShortMessage.toast(
            title: "Failed to add homework(s). Please try again.");
      }

      if (successCount > 0) {
        // ✅ Reset selections after at least one success
        selectedClassIds.clear();
        selectedSectionIds.clear();
        selectedSubjectIds.clear();
        description.value = '';
        pdfFile.value = null;
        file.value = '';

        await fetchHomework();
        Get.back();
      }
    } finally {
      isLoading(false);
    }
  }

  /// Helper: posts ONE homework for one class+section+subject combination.
  /// Returns true on success (status 200), false otherwise.
  Future<bool> _postSingleHomework({
    required int classId,
    required int sectionId,
    required int subjectId,
  }) async {
    try {
      final url =
      Uri.parse("${AppUrl.base_url}api/CommumicationApp/InsertHomeworkApp");

      final request = http.MultipartRequest('POST', url);

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll({
        'HomeworkID': "",
        'Remark': description.value,
        'SubjectId': subjectId.toString(),
        'SectionId': sectionId.toString(),
        'ClassID': classId.toString(),
        'CreateDate': getDisplayDate(),
        'UpdateDate': "",
        'Session': session.value,
        'SchoolId': schoolId,
        'schoolId': schoolId,
        'CreateBy': 'Admin',
        'UpdateBy': "",
        'Action': "1",
        'action': "1",
      });

      // ✅ FILE VERIFICATION — confirm file exists before attaching
      if (pdfFile.value != null) {
        final f = pdfFile.value!;
        final exists = await f.exists();
        final length = exists ? await f.length() : 0;

        debugPrint("📎 [C:$classId S:$sectionId Sub:$subjectId] File path: ${f.path}");
        debugPrint("📎 [C:$classId S:$sectionId Sub:$subjectId] Exists: $exists | size: $length bytes");

        final multipartFile = await http.MultipartFile.fromPath(
          'file',
          f.path,
          filename: f.path.split('/').last,
        );
        request.files.add(multipartFile);

        debugPrint("📎 [C:$classId S:$sectionId Sub:$subjectId] Attached 'file' -> filename: ${multipartFile.filename}, length: ${multipartFile.length}");
      }

      debugPrint("📤 POST HOMEWORK -> Class:$classId Section:$sectionId Subject:$subjectId");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("📥 [C:$classId S:$sectionId Sub:$subjectId] Status: ${response.statusCode}");
      debugPrint("📥 [C:$classId S:$sectionId Sub:$subjectId] Body: $responseBody");

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [C:$classId S:$sectionId Sub:$subjectId] Exception: $e');
      return false;
    }
  }
}