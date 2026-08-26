import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/activitystudentmodel.dart';
import '../models/classmodel.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/viewsectionmodel.dart';
import '../models/subject_model.dart';
import '../models/syllabus_model.dart' as syllabus_model; // ✅ aliased to avoid Data clash
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse

class SyllabusController extends GetxController {
  final syllabusList = <syllabus_model.Data>[].obs; // ✅ fixed type
  final isLoading = false.obs;

  // Fields
  final syllabusDate = DateTime.now().obs;
  final description = ''.obs;
  final syllabusPlace = ''.obs;
  final syllabusName = ''.obs;
  var section = ''.obs;

  final file = ''.obs;
  final pdfFile = Rx<File?>(null);

  final subject = 0.obs;

  final listDataa = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final selectedSection = Rx<stListData?>(null);
  final sectionList = <stListData>[].obs;

  final subjectlist = <ListDaataa>[].obs;
  final subjectdata = SubjectModel().obs;

  // auth/session
  String token = "";
  String schoolId = "";
  final session = "".obs;

  // 🆕 Class Teacher filter
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var isClassTeacherLogin = false.obs;

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session.value = await PrefManager().readValue(key: PrefConst.session);

    await fetchClassTeacherFilter(); // 🆕 pehle
    fetchSyllabus();
    fetchClasses();
    fetchSections();
    fetchsubjectdata();
  }

  String getDisplayDate() => DateFormat('dd-MM-yyyy').format(syllabusDate.value);
  String getFormattedDate() => DateFormat('yyyy-MM-dd').format(syllabusDate.value);

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: syllabusDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      syllabusDate.value = pickedDate;
    }
  }

  Future<void> fetchSyllabus() async {
    try {
      isLoading(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/CommumicationApp/GetSyllabusAsyncApp'
            '?schoolId=$schoolId&currentSession=${session.value}',
      );

      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final model = syllabus_model.SyllabusModel.fromJson(jsonDecode(response.body)); // ✅ fixed
        syllabusList.value = model.data ?? [];
      } else {
        // showSnackSafe('Error', 'Failed to fetch syllabus (${response.statusCode})', isError: true);
      }
    } catch (e) {
      //showSnackSafe('Error', 'Exception: Failed to fetch syllabus', isError: true);
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
          'accept': '/',
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

  Future<void> fetchClasses() async {
    // 🆕 Class teacher login → ClassTeacher API data se hi banao
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

      if (listDataa.isNotEmpty) {
        selectedClass.value = listDataa.first;
      } else {
        selectedClass.value = null;
      }
      return;
    }

    // 🔁 Normal teacher — existing
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
          'accept': '/',
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

          if (listDataa.isNotEmpty) {
            selectedClass.value = listDataa.first;
          } else {
            selectedClass.value = null;
          }
        } else {
          listDataa.value = [];
          selectedClass.value = null;
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch classes: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSections() async {
    // 🆕 Class teacher login → SectionTeacher API
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
            'accept': '/',
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

          selectedSection.value = null;
          section.value = '';
        } else {
          Get.snackbar('Error', 'Failed to load sections');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to load sections');
      } finally {
        isLoading(false);
      }
      return;
    }

    // 🔁 Normal teacher — existing
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
          'accept': '/',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GetSectionTeacher status: ${response.statusCode}');
      debugPrint('GetSectionTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final sectionModel = sectionmodel.fromJson(jsonResponse);

        sectionList.assignAll(sectionModel.listData ?? []);

        // ✅ IMPORTANT: keep dropdown unselected by default
        selectedSection.value = null;
        section.value = ''; // optional: clear saved sectionId too
      } else {
        Get.snackbar('Error', 'Failed to load sections');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sections');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchsubjectdata() async {
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

      if (response.statusCode == 200) {
        final subjectWrapper = SubjectModel.fromJson(jsonDecode(response.body));
        subjectdata.value = subjectWrapper;
        subjectlist.value = subjectWrapper.listData ?? [];
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } finally {
      isLoading(false);
    }
  }

  void setsubject(ListDaataa? s) => subject.value = s?.subjectId ?? 0;
  void setSelectedClass(ListDataa? c) => selectedClass.value = c;
  void setSelectedSection(stListData? s) => selectedSection.value = s;

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

  Future<void> registerSyllabus() async {
    if (pdfFile.value == null) {
      ShortMessage.toast(title: "Please select a PDF file.");
      return;
    }
    if(description.value.isEmpty){
      ShortMessage.toast(title: "Please enter Description.");
      return;
    }
    if(subject.value == 0){
      ShortMessage.toast(title: "Please select Subject.");
      return;}
    if(selectedClass.value == null){
      ShortMessage.toast(title: "Please select Class.");}
    final sectionId = selectedSection.value?.sectionId ?? 0;
    final classId = selectedClass.value?.classId.toString() ?? '';

    if (sectionId == 0 || subject.value == 0 || classId.isEmpty) {
      ShortMessage.toast(title: "Please select Class, Section and Subject.");
      return;
    }

    try {
      isLoading(true);

      final url = Uri.parse("${AppUrl.base_url}api/CommumicationApp/InsertSyllabusApp");
      final request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'SyllabusId': "0",
        'Remark': description.value,
        'SubjectId': subject.value.toString(),
        'SectionId': sectionId.toString(),
        'ClassID': classId,
        'CreateDate': getFormattedDate(),
        'Session': session.value,
        'SchoolId': schoolId,
        'Action': "1",
        'action': "1",
        'CreateBy': 'Admin',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          pdfFile.value!.path,
          filename: pdfFile.value!.path.split('/').last,
        ),
      );

      final streamed = await request.send();

      if (streamed.statusCode == 200) {
        ShortMessage.toast(title: "Syllabus Added Successfully");

        pdfFile.value = null;
        file.value = "";
        description.value = "";

        await fetchSyllabus();
        Get.back();
      } else {
        final body = await streamed.stream.bytesToString();
        ShortMessage.toast(title: "Failed: ${streamed.statusCode}");
        print('Error response: $body');
      }
    } catch (e) {
      ShortMessage.toast(title: "Error: $e");
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }
}
