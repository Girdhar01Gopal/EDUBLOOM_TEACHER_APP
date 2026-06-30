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
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';
import '../models/home_work_model.dart' as homework_model; // ✅ aliased to avoid Data clash
import '../res/app_url.dart';

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

  var selectedSection = Rx<ListDatta?>(null);
  var sectionList = <ListDatta>[].obs;

  var subjectlist = <ListDaataa>[].obs;
  var section = ''.obs;

  final subjectdata = SubjectModel().obs;

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session.value = await PrefManager().readValue(key: PrefConst.session);

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

  Future<void> fetchClasses() async {
    try {
      isLoading(true);

      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
      );

      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        listDataa.value = parsed.listData
            ?.where((e) => e.action?.toString() == "1")
            .toList() ??
            [];
      }
    } catch (e) {
      print("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSections() async {
    final url = '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['listData'] ?? [];

        final sections = data.map((e) => ListDatta.fromJson(e)).toList();

        sectionList.assignAll(sections);

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

      final url = Uri.parse('${AppUrl.base_url}${AppUrl.view_subject}$schoolId');
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

  void setSelectedSection(ListDatta? val) {
    selectedSection.value = val;
    section.value = val?.section ?? '';
  }

  void setSelectedClass(ListDataa? val) {
    selectedClass.value = val;
  }
}