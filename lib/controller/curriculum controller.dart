import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/classmodel.dart';
import '../models/curriculum model.dart';
import '../models/viewsectionmodel.dart';
import '../models/session_model.dart' as session_model;

import '../res/app_url.dart';

class CurriculumController extends GetxController {
  final curriculumList = <CurriculumData>[].obs;
  final isLoading = false.obs;

  // ── Fields ─────────────────────────────────────────────────────────
  final curriculumName = ''.obs; // maps to "CurriculumName" in API
  final description = ''.obs; // maps to "Description" in API

  final file = ''.obs;
  final pdfFile = Rx<File?>(null);

  // set when editing an existing record, null when creating a new one
  final editingCurriculumId = Rx<int?>(null);

  final listDataa = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final selectedSection = Rx<stListData?>(null);
  final sectionList = <stListData>[].obs;

  // ── Session (Dynamic API) ─────────────────────────────────────────
  RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);
  var session = ''.obs;

  // ── Auth ───────────────────────────────────────────────────────────
  String token = "";
  String schoolId = "";

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";

    await fetchSessions(); // session pehle load hogi
    fetchCurriculum();
    fetchClasses();
    fetchSections();
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
  // GET https://playschool.edubloom.in/api/MasterApp/ViewCurriculum/{schoolId}/{session}
  Future<void> fetchCurriculum() async {
    try {
      isLoading(true);

      final sessionValue = selectedSession.value?.session ?? session.value;
      if (schoolId.isEmpty || sessionValue.trim().isEmpty) {
        curriculumList.value = [];
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/MasterApp/ViewCurriculum/$schoolId/$sessionValue',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final model = CurriculumModel.fromJson(jsonDecode(response.body));
        curriculumList.value = model.data ?? [];
      } else {
        Get.snackbar("Error", "Failed to load curriculum");
      }
    } catch (e) {
      // handle silently as before
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchClasses() async {
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

        sectionList.assignAll(sectionModel.listData ?? []);

        selectedSection.value = null;
      } else {
        Get.snackbar('Error', 'Failed to load sections');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sections');
    } finally {
      isLoading(false);
    }
  }

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

  void resetForm() {
    pdfFile.value = null;
    file.value = "";
    curriculumName.value = "";
    description.value = "";
    selectedClass.value = null;
    selectedSection.value = null;
    editingCurriculumId.value = null;
  }

  // ── Register / Update Curriculum ────────────────────────────────────
  // POST https://playschool.edubloom.in/api/MasterApp/PostCurriculum
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
    if (selectedClass.value == null) {
      ShortMessage.toast(title: "Please select Class.");
      return;
    }
    if (selectedSection.value == null) {
      ShortMessage.toast(title: "Please select Section.");
      return;
    }
    final sessionValue =
    (selectedSession.value?.session ?? session.value).trim();
    if (sessionValue.isEmpty) {
      ShortMessage.toast(title: "Please select Session.");
      return;
    }

    final classId = selectedClass.value?.classId?.toString() ?? '';
    final sectionId = selectedSection.value?.sectionId?.toString() ?? '';
    final className = selectedClass.value?.className ?? '';
    final sectionName = selectedSection.value?.section ?? '';

    if (classId.isEmpty || sectionId.isEmpty) {
      ShortMessage.toast(title: "Please select Class and Section.");
      return;
    }

    try {
      isLoading(true);

      final url =
      Uri.parse('${AppUrl.base_url}api/MasterApp/PostCurriculum');
      final request = http.MultipartRequest('POST', url);

      final pickedFileName = pdfFile.value!.path.split('/').last;
      // auto label used for "PdfFileName" text field (without extension)
      final pdfLabel = pickedFileName.contains('.')
          ? pickedFileName.substring(0, pickedFileName.lastIndexOf('.'))
          : pickedFileName;

      request.fields.addAll({
        'CurriculumId': (editingCurriculumId.value ?? 0).toString(),
        'CurriculumName': curriculumName.value.trim(),
        'ClassName': className,
        'Section': sectionName,
        'ClassId': classId,
        'SectionId': sectionId,
        'Session': sessionValue,
        'Description': description.value.trim(),
        'SchoolId': schoolId,
        'Action': "1",
        'CreateBy': 'Admin',
        'PdfFileName': pdfLabel,
      });

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

      final streamed = await request.send();
      final resBody = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        Map<String, dynamic> decoded = {};
        try {
          decoded = jsonDecode(resBody);
        } catch (_) {}

        final success = decoded['isSuccess'] == true;
        if (success) {
          ShortMessage.toast(
            title: decoded['messages']?.toString() ??
                "Curriculum Added Successfully",
          );

          resetForm();
          await fetchCurriculum();
          Get.back();
        } else {
          ShortMessage.toast(
            title: decoded['messages']?.toString() ?? "Submit failed",
          );
        }
      } else {
        ShortMessage.toast(title: "Submit failed (${streamed.statusCode})");
        print("Server Response: $resBody");
      }
    } catch (e) {
      ShortMessage.toast(title: "Something went wrong while submitting");
    } finally {
      isLoading(false);
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
        // API returns a plain array — parsed here in case you need
        // the immediate updated record, otherwise we just refetch below.
        try {
          CurriculumStatusModel.fromJson(jsonDecode(response.body));
        } catch (_) {}

        ShortMessage.toast(title: "Status updated successfully");

        // refresh list via ViewCurriculum/{schoolId}/{session}
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