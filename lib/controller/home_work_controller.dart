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
import '../models/viewsectionmodel.dart';
import '../models/subject_model.dart';
import '../models/home_work_model.dart' as homework_model; // ✅ aliased to avoid Data clash
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
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
  var subject = 0.obs;

  var classes = <ClassItem>[].obs;
  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  var selectedSection = Rx<stListData?>(null);
  var sectionList = <stListData>[].obs;

  var subjectlist = <ListDaataa>[].obs;
  var section = ''.obs;

  final subjectdata = SubjectModel().obs;

  // 🆕 Class Teacher filter
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var isClassTeacherLogin = false.obs;

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session.value = await PrefManager().readValue(key: PrefConst.session);

    await fetchClassTeacherFilter(); // 🆕 pehle
    fetchHomework();
    fetchClasses();
    fetchSections();
    fetchsubjectdata();
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

  Future<void> fetchHomework() async {
    try {
      isLoading(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/CommumicationApp/GetHomeworkAsyncApp'
            '?currentSession=${session.value}&schoolId=$schoolId',
      );
      print("Fetching homework from URL: $url");

      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
      });

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

  Future<void> registerHomework({
    required String homeworkName,
    required int section,
    required String homeworkDate,
    required String homeworkPlace,
    required String description,
    required int homeworkClass,
  }) async {
    if (pdfFile.value == null) {
      ShortMessage.toast(title: "Please select a PDF file.");
      return;
    }

    if (description.isEmpty) {
      ShortMessage.toast(title: "Please enter Description.");
      return;
    }

    if (section == 0 || subject.value == 0 || homeworkClass == 0) {
      ShortMessage.toast(title: "Please select Class, Section, and Subject.");
      return;
    }

    try {
      final url =
      Uri.parse("${AppUrl.base_url}api/CommumicationApp/InsertHomeworkApp");

      final request = http.MultipartRequest('POST', url);

      if (token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll({
        'HomeworkID': "",
        'Remark': description,
        'SubjectId': subject.value.toString(),
        'SectionId': section.toString(),
        'ClassID': homeworkClass.toString(),
        'CreateDate': getFormattedDate(),
        'UpdateDate': "",
        'Session': session.value,
        'schoolId': schoolId,
        'CreateBy': 'Admin',
        'UpdateBy': "",
        'Action': "1",
        'action': "1",
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          pdfFile.value!.path,
          filename: pdfFile.value!.path.split('/').last,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        ShortMessage.toast(title: "Homework Added Successfully");
        await fetchHomework();
        Get.back();
      } else {
        final body = await response.stream.bytesToString();
        ShortMessage.toast(title: "Failed: ${response.statusCode}");
        print('Error response: $body');
      }
    } catch (e) {
      ShortMessage.toast(title: "Error: $e");
      print("Error: $e");
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

  void setsubject(ListDaataa? subjectId) {
    subject.value = subjectId?.subjectId ?? 0;
  }

  void setSelectedSection(stListData? val) {
    selectedSection.value = val;
    section.value = val?.section ?? '';
  }

  void setSelectedClass(ListDataa? val) {
    selectedClass.value = val;
  }
}
