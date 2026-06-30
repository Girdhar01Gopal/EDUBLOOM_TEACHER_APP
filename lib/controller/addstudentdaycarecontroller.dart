import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/daycareaddstudentmodel.dart';
import '../res/app_url.dart';

class StudentScreen2Controller extends GetxController {
  var sessionList = <Session>[].obs;
  var selectedSession = Rx<Session?>(null);

  var studentId = ''.obs;
  var studentName = ''.obs;
  var gender = ''.obs;
  var dateOfBirth = ''.obs;
  final TextEditingController dob = TextEditingController();

  var bloodGroup = ''.obs;
  var religion = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var admissionDate = ''.obs;
  var fatherOccupation = ''.obs;
  var fatherName = ''.obs;
  var motherName = ''.obs;
  var session = ''.obs;
  var password = ''.obs;
  var createDate = ''.obs;
  var whatsappNo = ''.obs;
  var emergencyNo = ''.obs;
  var actionStatus = '1'.obs;

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  var fileImage = Rx<File?>(null);
  var fatherPic = Rx<File?>(null);
  var motherPic = Rx<File?>(null);
  var guardianImage = Rx<File?>(null);

  var listData = <DaycareStudentData>[].obs;
  var filteredData = <DaycareStudentData>[].obs;

  var isLoading = false.obs;
  String token = "";
  String schoolId = "";

  final ImagePicker picker = ImagePicker();

  @override
  void onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session.value = await PrefManager().readValue(key: PrefConst.session) ?? "";

    await fetchSessions();
    await fetchVStudents();
  }

  @override
  void onClose() {
    dob.dispose();
    emailController.dispose();
    super.onClose();
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
        final Map<String, dynamic> jsonResponse =
        json.decode(response.body) as Map<String, dynamic>;

        final students = DaycareStudentResponse.fromJson(jsonResponse);

        listData.assignAll(students.data);
        filteredData.assignAll(students.data);

        debugPrint("✅ Students fetched: ${listData.length}");
      } else {
        Get.snackbar("Error", "Failed to fetch students");
      }
    } catch (e) {
      debugPrint("⚠️ Fetch error: $e");
      Get.snackbar("Error", "An error occurred while fetching students");
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
      listData.where((student) {
        return (student.studentName?.toLowerCase().contains(q) ?? false) ||
            (student.registrationNo?.toLowerCase().contains(q) ?? false) ||
            (student.phone?.toLowerCase().contains(q) ?? false) ||
            (student.fatherName?.toLowerCase().contains(q) ?? false) ||
            (student.motherName?.toLowerCase().contains(q) ?? false);
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
      request.fields['AdmissionDate'] = DateTime.now().toIso8601String();

      final emailText = emailController.text.trim().isNotEmpty
          ? emailController.text.trim()
          : email.value.trim();

      request.fields['Email'] = emailText;
      request.fields['email'] = emailText;
      request.fields['EmailId'] = emailText;
      request.fields['emailId'] = emailText;

      request.fields['SchoolId'] = schoolId;
      request.fields['Session'] = session.value;
      request.fields['IsDaycare'] = 'true';
      request.fields['Action'] =
      actionStatus.value.trim().isEmpty ? '1' : actionStatus.value.trim();

      if (fileImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('File', fileImage.value!.path),
        );
      }

      if (fatherPic.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('FatherPic', fatherPic.value!.path),
        );
      }

      if (motherPic.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('MotherPic', motherPic.value!.path),
        );
      }

      if (guardianImage.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'GuardianImage',
            guardianImage.value!.path,
          ),
        );
      }

      debugPrint("📤 Sending registration request to: $uri");
      debugPrint("🧾 Fields: ${request.fields}");

      final streamedResponse = await request.send();
      final responseBody = await http.Response.fromStream(streamedResponse);

      debugPrint("📥 Response: ${responseBody.statusCode}");
      debugPrint("📄 Response Body: ${responseBody.body}");

      if (responseBody.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(responseBody.body) as Map<String, dynamic>;

        if (data['isSuccess'] == true) {
          ShortMessage.toast(title: "Student Added Successfully");
          await fetchVStudents();
          Get.offAllNamed(RouteName.dashboard_screen);
        } else {
          final message =
              data['popupMessage']?.toString() ??
                  data['messages']?.toString() ??
                  "Failed to Add Student";

          Get.snackbar("Error", message);
        }
      } else {
        ShortMessage.toast(title: "Failed to Add Student");
        debugPrint("⚠️ Error ${responseBody.statusCode}: ${responseBody.body}");
      }
    } catch (e) {
      debugPrint("⚠️ Exception: $e");
      ShortMessage.toast(title: "An error occurred while adding student.");
    }
  }

  Future<void> fetchSessions() async {
    final String apiUrl = '${AppUrl.base_url}api/EduagentPlaysSchool/SessionBind/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("SESSION URL => $apiUrl");
      debugPrint("SESSION STATUS => ${response.statusCode}");
      debugPrint("SESSION BODY => ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData =
        json.decode(response.body) as Map<String, dynamic>;

        final sessions = List<Session>.from(
          (jsonData['listData'] ?? jsonData['data'] ?? [])
              .map((data) => Session.fromJson(data as Map<String, dynamic>)),
        );

        sessionList.assignAll(sessions);

        if (sessions.isNotEmpty) {
          selectedSession.value = sessions.first;

          if (session.value.trim().isEmpty) {
            session.value = sessions.first.session;
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to load sessions (${response.statusCode})');
      }
    } catch (e) {
      debugPrint("⚠️ Session error: $e");
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSession(Session selected) {
    selectedSession.value = selected;
    session.value = selected.session;
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

class Session {
  final int sessionId;
  final String session;
  final String action;
  final String createDate;
  final String updatedate;
  final String createBy;
  final String updateBy;
  final String schoolId;

  Session({
    required this.sessionId,
    required this.session,
    required this.action,
    required this.createDate,
    required this.updatedate,
    required this.createBy,
    required this.updateBy,
    required this.schoolId,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: _toInt(json['sessionId']),
      session: json['session']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      createDate: json['createDate']?.toString() ?? '',
      updatedate: json['updatedate']?.toString() ?? '',
      createBy: json['createBy']?.toString() ?? '',
      updateBy: json['updateBy']?.toString() ?? '',
      schoolId: json['schoolId']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}