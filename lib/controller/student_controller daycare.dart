import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/session_model.dart' as session_model show sListDdata;
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/daycareaddstudentmodel.dart';
import '../models/sectionmodel.dart';
import '../res/app_url.dart';

class StudentControllerdaycare extends GetxController {
  var sessionList = <session_model.sListDdata>[].obs;
  var selectedSession = Rx<session_model.sListDdata?>(null);

  var classes = <ClassItem>[].obs;
  var selectedClass = Rx<ClassItem?>(null);

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rxn<ListDatta>();

  var studentId = ''.obs;
  var studentName = ''.obs;
  var gender = ''.obs;
  var dateOfBirth = ''.obs;

  final TextEditingController dob = TextEditingController();
  final TextEditingController admissionDateController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  var bloodGroup = ''.obs;
  var religion = ''.obs;
  var email = ''.obs;
  var studentClass = ''.obs;
  var section = ''.obs;
  var phone = ''.obs;
  var admissionDate = ''.obs;
  var fatherOccupation = ''.obs;
  var fatherName = ''.obs;
  var motherName = ''.obs;
  var session = ''.obs;
  var fromTime = ''.obs;
  var toTime = ''.obs;
  var password = ''.obs;
  var createDate = ''.obs;
  var whatsappNo = ''.obs;
  var emergencyNo = ''.obs;
  var actionStatus = '1'.obs;

  final formKey = GlobalKey<FormState>();

  var fileImage = Rx<File?>(null);
  var fatherPic = Rx<File?>(null);
  var motherPic = Rx<File?>(null);
  var guardianImage = Rx<File?>(null);

  var listData = <DaycareStudentData>[].obs;
  var filteredData = <DaycareStudentData>[].obs;

  var isLoading = false.obs;
  var token = "";
  var schoolId = "";

  var isClassEnabled = true.obs;
  var isSectionEnabled = true.obs;

  final ImagePicker picker = ImagePicker();

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? ""; // ✅ token fix
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? "";

    await fetchClasses();
    await fetchSessions();
    await fetchSections();
    await fetchVStudents();
  }

  @override
  void onClose() {
    dob.dispose();
    admissionDateController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void toggleClassSelection(bool value) {
    isClassEnabled(value);
    if (!value) selectedClass.value = null;
  }

  void toggleSectionSelection(bool value) {
    isSectionEnabled(value);
    if (!value) selectedSection.value = null;
  }

  Future<void> fetchVStudents() async {
    try {
      isLoading(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/GetAllDaycareStudentsAsyncApp?schoolId=$schoolId&currentSession=${session.value}',
      );

      final response = await http.get(url);

      debugPrint("GET => $url");
      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final students = DaycareStudentResponse.fromJson(jsonResponse);

        listData.assignAll(students.data);
        filteredData.assignAll(students.data);

        debugPrint("✅ Daycare students fetched: ${listData.length}");
      } else {
        Get.snackbar("Error", "Failed to fetch daycare students");
      }
    } catch (e) {
      debugPrint("⚠️ fetchVStudents error => $e");
      Get.snackbar("Error", "An error occurred while fetching daycare students");
    } finally {
      isLoading(false);
    }
  }

  void filterStudents(String query) {
    if (query.trim().isEmpty) {
      filteredData.assignAll(listData);
      return;
    }

    final q = query.toLowerCase().trim();

    filteredData.assignAll(
      listData.where((s) {
        return (s.studentName?.toLowerCase().contains(q) ?? false) ||
            (s.registrationNo?.toLowerCase().contains(q) ?? false) ||
            (s.phone?.toLowerCase().contains(q) ?? false) ||
            (s.fatherName?.toLowerCase().contains(q) ?? false) ||
            (s.motherName?.toLowerCase().contains(q) ?? false);
      }).toList(),
    );
  }

  Future<void> registerStudent() async {
    try {
      final uri = Uri.parse("${AppUrl.base_url}api/StudentApp/PostDaycareStudentApp");
      final request = http.MultipartRequest('POST', uri);

      request.fields['StudentName'] = studentName.value.trim();
      request.fields['FatherName'] = fatherName.value.trim();
      request.fields['MotherName'] = motherName.value.trim();
      request.fields['Gender'] = gender.value.trim();
      request.fields['DateOfBirth'] = dob.text.trim();
      request.fields['BloodGroup'] = bloodGroup.value.trim();
      request.fields['Religion'] = religion.value.trim();
      request.fields['Phone'] = phone.value.trim();
      request.fields['WhatsAppNo'] = whatsappNo.value.trim();
      request.fields['EmergencyNo'] = emergencyNo.value.trim();
      request.fields['FatherOccupation'] = fatherOccupation.value.trim();
      request.fields['CreateDate'] = DateTime.now().toIso8601String();

      request.fields['AdmissionDate'] = admissionDateController.text.trim().isEmpty
          ? DateTime.now().toIso8601String()
          : admissionDateController.text.trim();

      final emailTxt = emailController.text.trim();
      request.fields['Email'] = emailTxt;
      request.fields['email'] = emailTxt;
      request.fields['EmailId'] = emailTxt;
      request.fields['emailId'] = emailTxt;

      request.fields['SchoolId'] = schoolId;
      request.fields['Session'] = session.value;
      request.fields['IsDaycare'] = 'true';
      request.fields['Action'] =
      actionStatus.value.trim().isEmpty ? '1' : actionStatus.value.trim();

      request.fields['From Time'] = fromTime.value.trim();
      request.fields['To Time'] = toTime.value.trim();

      if (fileImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('File', fileImage.value!.path));
      }
      if (fatherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath('FatherPic', fatherPic.value!.path));
      }
      if (motherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath('MotherPic', motherPic.value!.path));
      }
      if (guardianImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('GuardianImage', guardianImage.value!.path));
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      debugPrint("REGISTER STATUS => ${responseBody.statusCode}");
      debugPrint("REGISTER BODY => ${responseBody.body}");

      if (responseBody.statusCode == 200) {
        final data = jsonDecode(responseBody.body);

        if (data['isSuccess'] == true) {
          ShortMessage.toast(title: "Student Added Successfully");
          await fetchVStudents();
          Get.offAllNamed(RouteName.dashboard_screen);
        } else {
          final popup = data['popupMessage'] ?? data['messages'] ?? "Unknown error";
          Get.snackbar(
            "Error",
            popup.toString(),
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
          );
        }
      } else {
        ShortMessage.toast(title: "Failed to Add Student");
      }
    } catch (e) {
      debugPrint("registerStudent error => $e");
      ShortMessage.toast(title: "An error occurred while adding student.");
    }
  }

  Future<void> updateStudentByPostApi({required int studentId}) async {
    try {
      final uri = Uri.parse("${AppUrl.base_url}api/StudentApp/PostDaycareStudentApp");
      final request = http.MultipartRequest('POST', uri);

      request.fields['StudentId'] = studentId.toString();
      request.fields['Action'] =
      actionStatus.value.trim().isEmpty ? '1' : actionStatus.value.trim();

      request.fields['StudentName'] = studentName.value.trim();
      request.fields['FatherName'] = fatherName.value.trim();
      request.fields['MotherName'] = motherName.value.trim();
      request.fields['Gender'] = gender.value.trim();
      request.fields['DateOfBirth'] = dob.text.trim();
      request.fields['BloodGroup'] = bloodGroup.value.trim();
      request.fields['Religion'] = religion.value.trim();
      request.fields['Phone'] = phone.value.trim();
      request.fields['WhatsAppNo'] = whatsappNo.value.trim();
      request.fields['EmergencyNo'] = emergencyNo.value.trim();
      request.fields['FatherOccupation'] = fatherOccupation.value.trim();
      request.fields['AdmissionDate'] = admissionDateController.text.trim();

      final emailTxt = emailController.text.trim();
      request.fields['Email'] = emailTxt;
      request.fields['email'] = emailTxt;
      request.fields['EmailId'] = emailTxt;
      request.fields['emailId'] = emailTxt;

      request.fields['SchoolId'] = schoolId;
      request.fields['Session'] = session.value;
      request.fields['IsDaycare'] = 'true';

      request.fields['From Time'] = fromTime.value.trim();
      request.fields['To Time'] = toTime.value.trim();

      if (fileImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('File', fileImage.value!.path));
      }
      if (fatherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath('FatherPic', fatherPic.value!.path));
      }
      if (motherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath('MotherPic', motherPic.value!.path));
      }
      if (guardianImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath('GuardianImage', guardianImage.value!.path));
      }

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      debugPrint("UPDATE STATUS => ${resp.statusCode}");
      debugPrint("UPDATE BODY => ${resp.body}");

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        if (data['isSuccess'] == true) {
          ShortMessage.toast(title: "Student Updated Successfully");
          await fetchVStudents();
          Get.back();
        } else {
          final msg = data['popupMessage'] ?? data['messages'] ?? "Update failed";
          Get.snackbar(
            "Error",
            msg.toString(),
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Update failed: ${resp.statusCode}",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("updateStudentByPostApi error => $e");
      Get.snackbar(
        "Error",
        "Update error: $e",
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);

      final url = '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['listData'] != null) {
          List<dynamic> data = jsonResponse['listData'] ?? [];
          data = data.where((e) => e['action'].toString() == "1").toList();

          classes.value = data.map((e) => ClassItem.fromJson(e)).toList();

          if (classes.isNotEmpty) {
            selectedClass.value = classes.first;
          }
        }
      }
    } catch (e) {
      debugPrint("⚠️ fetchClasses error => $e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ClassItem? classItem) {
    selectedClass.value = classItem;
  }

  Future<void> fetchSessions() async {
    final String apiUrl = '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        sessionList.clear();

        // ✅ poori list daalo (pehle sirf currentSession add ho rahi thi)
        if (jsonData['listData'] != null) {
          final List<dynamic> listRaw = jsonData['listData'];
          sessionList.addAll(
            listRaw.map((e) => session_model.sListDdata.fromJson(e)).toList(),
          );
        }

        // ✅ currentSession ko list mein se match karke select karo
        if (jsonData['currentSession'] != null) {
          final currentId = jsonData['currentSession']['currentSessionId'];
          session_model.sListDdata? matched;
          for (final s in sessionList) {
            if (s.sessionId == currentId) {
              matched = s;
              break;
            }
          }
          selectedSession.value = matched;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata sessionData) {
    selectedSession.value = sessionData;
  }

  Future<void> fetchSections() async {
    final String url = '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> data = decoded['listData'] ?? decoded['data'] ?? [];

        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();

        if (sectionList.isNotEmpty) {
          selectedSection.value = sectionList.first;
        }
      }
    } catch (e) {
      debugPrint("⚠️ fetchSections error => $e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSection(ListDatta? sectionData) {
    selectedSection.value = sectionData;
  }

  Future<void> pickImage({
    required Rx<File?> target,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? picked = await picker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (picked != null) {
        target.value = File(picked.path);
      }
    } catch (e) {
      debugPrint("pickImage error => $e");
    }
  }

  void clearImage(Rx<File?> target) {
    target.value = null;
  }
}

class ClassItem {
  final int classId;
  final String className;
  final String studentClassId;

  ClassItem({
    required this.classId,
    required this.className,
    required this.studentClassId,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      classId: json['classId'] ?? 0,
      className: json['class'] ?? 'Unknown',
      studentClassId: json['studentClassId']?.toString() ?? 'N/A',
    );
  }
}