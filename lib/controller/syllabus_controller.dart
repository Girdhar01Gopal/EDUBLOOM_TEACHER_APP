import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/activitystudentmodel.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';
import '../models/syllabus_model.dart' as syllabus_model; // ✅ aliased to avoid Data clash
import '../res/app_url.dart';

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

  final selectedSection = Rx<ListDatta?>(null);
  final sectionList = <ListDatta>[].obs;

  final subjectlist = <ListDaataa>[].obs;
  final subjectdata = SubjectModel().obs;

  // auth/session
  String token = "";
  String schoolId = "";
  final session = "".obs;

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session.value = await PrefManager().readValue(key: PrefConst.session);

    fetchSyllabus();
    fetchClasses();
    fetchSections();
    fetchsubjectdata();
  }

  // ✅ SAFE snackbar (NO GetX snackbar -> no LateInitializationError)
  void showSnackSafe(String title, String message, {bool isError = false}) {
    final ctx = Get.context;
    if (ctx == null) return;

    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('$title: $message'),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
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

  void setsubject(ListDaataa? s) => subject.value = s?.subjectId ?? 0;
  void setSelectedClass(ListDataa? c) => selectedClass.value = c;
  void setSelectedSection(ListDatta? s) => selectedSection.value = s;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      pdfFile.value = File(result.files.single.path!);
      file.value = result.files.single.name;
      showSnackSafe("File Selected", file.value);
    } else {
      showSnackSafe("Error", "No file selected", isError: true);
    }
  }

  Future<void> registerSyllabus() async {
    if (pdfFile.value == null) {
      showSnackSafe('Error', "Please select a PDF file.", isError: true);
      return;
    }
    if(description.value.isEmpty){
      showSnackSafe('Error', "Please enter Description.", isError: true);
      return;
    }
    if(subject.value == 0){
      showSnackSafe('Error', "Please select Subject.", isError: true);
      return;}
    if(selectedClass.value == null){
      showSnackSafe('Error', "Please select Class.", isError: true);}
    final sectionId = selectedSection.value?.sectionId ?? 0;
    final classId = selectedClass.value?.classId.toString() ?? '';

    if (sectionId == 0 || subject.value == 0 || classId.isEmpty) {
      showSnackSafe('Error', "Please select Class, Section and Subject.", isError: true);
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
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        // ✅ CLOSE SCREEN FIRST, then show snackbar safely (no GetX bug)
        Get.back();

        Future.delayed(const Duration(milliseconds: 200), () {
          showSnackSafe('Success', "Syllabus Added Successfully");
        });

        pdfFile.value = null;
        file.value = "";
        description.value = "";

        fetchSyllabus();
      } else {
        showSnackSafe('Error', "Submit failed (${streamed.statusCode})", isError: true);
        // ignore: avoid_print
        print("Server Response: $body");
      }
    } catch (e) {
      showSnackSafe('Error', "Something went wrong while submitting", isError: true);
    } finally {
      isLoading(false);
    }
  }
}