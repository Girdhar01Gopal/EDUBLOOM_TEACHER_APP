import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Route;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/session_model.dart' as session_model;
import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/route_model_points.dart';
import '../models/routeno.dart';
import '../models/sectionmodel.dart';
import '../models/student_model.dart';
import '../res/app_url.dart';

class StudentController extends GetxController {
  var sessionList = <session_model.sListDdata>[].obs;
  var selectedSession = Rx<session_model.sListDdata?>(null);

  var routes = <RouteData>[].obs;
  var stoppages = <RoutePoint>[].obs;
  var stoppageList = <String>[].obs;

  var classes = <ClassItem>[].obs;
  var selectedClass = Rx<ClassItem?>(null);

  var address = ''.obs;
  var addDaycareStudent = ''.obs;
  var stoppage = ''.obs;
  var rollNo = ''.obs;
  var actionStatus = ''.obs;

  var studentId = ''.obs;
  var studentName = ''.obs;
  var aAdharNo = ''.obs;
  var gender = ''.obs;
  var dateOfBirth = ''.obs;
  TextEditingController dob = TextEditingController();
  var bloodGroup = ''.obs;
  var religion = ''.obs;
  var email = ''.obs;
  var studentClass = ''.obs;
  var section = ''.obs;
  var phone = ''.obs;
  var guardianPhone = ''.obs;
  var admissionDate = ''.obs;
  var fatherOccupation = ''.obs;
  var fatherName = ''.obs;
  var motherName = ''.obs;
  var session = ''.obs;
  var password = ''.obs;
  var createDate = ''.obs;
  var whatsappNo = ''.obs;
  var emergencyNo = ''.obs;

  var sectionList = <ListDatta>[].obs;
  var selectedSection = Rxn<ListDatta>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  var fileImage = Rx<File?>(null);
  var fatherPic = Rx<File?>(null);
  var motherPic = Rx<File?>(null);
  var guardianImage = Rx<File?>(null);

  var token = "";
  var schoolId = "";

  var isClassEnabled = true.obs;
  var isSectionEnabled = true.obs;

  final ImagePicker picker = ImagePicker();

  var transportUser = ''.obs;
  var routeNo = ''.obs;

  // Observables
  var listData = <StudentData>[].obs;
  var filteredData = <StudentData>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session.value = await PrefManager().readValue(key: PrefConst.session);
    await fetchClasses();
    await fetchSessions();
    await fetchSections();
    await fetchVStudents();
    await fetchRoutes();
    super.onInit();
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
        '${AppUrl.base_url}api/StudentApp/GetAllStudentAsynsApp',
      );

      final body = {
        "schoolId": schoolId,
        "currentSession": session.value,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final students = StudentModel.fromJson(jsonResponse);
        listData.value = students.data ?? [];
        filteredData.value = students.data ?? [];
      } else {
        Get.snackbar("Error", "Failed to fetch students");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred while fetching students");
    } finally {
      isLoading(false);
    }
  }

  void filterStudents(String query) {
    if (query.isEmpty) {
      filteredData.value = listData;
    } else {
      final q = query.toLowerCase();
      filteredData.value = listData.where((s) {
        return (s.studentName?.toLowerCase().contains(q) ?? false) ||
            (s.registrationNo?.toLowerCase().contains(q) ?? false) ||
            (s.phone?.toLowerCase().contains(q) ?? false) ||
            (s.className?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
  }

  Future<void> fetchRoutes() async {
    try {
      isLoading(true);

      final url = Uri.parse(
          '${AppUrl.base_url}api/StudentApp/GetRouteApp/$schoolId');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final routeResponse = RouteResponse.fromJson(jsonResponse);
        routes.value = routeResponse.data;
      }
    } catch (e) {
      print("Error loading routes: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> pickImage(ImageSource source, Rx<File?> imageVariable) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      imageVariable.value = File(pickedFile.path);
    }
  }

  Future<void> fetchPickupPoints(int routeNo) async {
    try {
      isLoading(true);

      final url = Uri.parse(
        'https://playschool.edubloom.in/api/StudentApp/GetPikPointApp/$schoolId/$routeNo',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        Get.snackbar("Error", "Failed to fetch pickup points");
        return;
      }

      final jsonResponse = json.decode(response.body);
      final routePointResponse = RoutePoint.fromJson(jsonResponse);

      final points = (routePointResponse.data ?? [])
          .map((e) => (e.pickupPoint ?? '').trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      stoppageList
        ..clear()
        ..addAll(points.isEmpty ? ["No Stoppages Available"] : points);
    } catch (e) {
      Get.snackbar("Error", "An error occurred while fetching pickup points");
    } finally {
      isLoading(false);
    }
  }

  Future<void> registerStudent() async {
    try {
      final uri = Uri.parse("${AppUrl.base_url}api/StudentApp/PostStudentApp");
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['StudentName'] = studentName.value;
      request.fields['FatherName'] = fatherName.value;
      request.fields['MotherName'] = motherName.value;
      request.fields['Gender'] = gender.value;
      request.fields['DateOfBirth'] = dob.text;
      request.fields['BloodGroup'] = bloodGroup.value;
      request.fields['Religion'] = religion.value;
      request.fields['Phone'] = phone.value;
      request.fields['GuardianPhone'] = guardianPhone.value;
      request.fields['WhatsAppNo'] = whatsappNo.value;
      request.fields['EmergencyNo'] = emergencyNo.value;
      request.fields['FatherOccupation'] = fatherOccupation.value;
      request.fields['CreateDate'] = DateTime.now().toIso8601String();
      request.fields['AdmissionDate'] = DateTime.now().toIso8601String();

      final emailTxt = emailController.text.trim();
      request.fields['Email'] = emailTxt;
      request.fields['email'] = emailTxt;
      request.fields['EmailId'] = emailTxt;
      request.fields['emailId'] = emailTxt;

      request.fields['SchoolId'] = schoolId;
      request.fields['Session'] = session.value;
      request.fields['Action'] =
      actionStatus.value.trim().isEmpty ? '1' : actionStatus.value.trim();
      request.fields['Roll'] = rollNo.value.trim();
      request.fields['Address'] = address.value;
      request.fields['AadharNo'] = aAdharNo.value;

      if (isClassEnabled.value && isSectionEnabled.value) {
        request.fields['Status'] = "0";
        request.fields['Class'] =
            selectedClass.value?.classId.toString() ?? '';
        request.fields['Section'] =
            selectedSection.value?.sectionId.toString() ?? '';
      } else {
        request.fields['Status'] = "1";
      }

      request.fields['TransportUser'] = transportUser.value;
      if (transportUser.value.trim().toLowerCase() == 'yes') {
        request.fields['RouteNo'] = routeNo.value;
        request.fields['PickupPoint'] = stoppage.value;
      }

      if (fileImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'File', fileImage.value!.path));
      }
      if (fatherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'FatherPic', fatherPic.value!.path));
      }
      if (motherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'MotherPic', motherPic.value!.path));
      }
      if (guardianImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'GuardianImage', guardianImage.value!.path));
      }

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      final body = responseBody.body;

      if (responseBody.statusCode == 200) {
        final data = jsonDecode(body);
        if (data['isSuccess'] == true) {
          ShortMessage.toast(title: "Student Added Successfully");
          Get.offAllNamed(RouteName.dashboard_screen);
        } else {
          final popup =
              data['popupMessage'] ?? data['messages'] ?? "Unknown error";
          Get.snackbar("Error", popup,
              backgroundColor: Colors.red.shade600, colorText: Colors.white);
        }
      } else {
        ShortMessage.toast(title: "Failed to Add Student");
      }
    } catch (e) {
      ShortMessage.toast(title: "An error occurred while adding student.");
    }
  }

  Future<void> updateStudentByPostApi({required int studentId}) async {
    try {
      final uri = Uri.parse("${AppUrl.base_url}api/StudentApp/PostStudentApp");
      final request = http.MultipartRequest('POST', uri);

      if (fileImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'File', fileImage.value!.path));
      }
      if (fatherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'FatherPic', fatherPic.value!.path));
      }
      if (motherPic.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'MotherPic', motherPic.value!.path));
      }
      if (guardianImage.value != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'GuardianImage', guardianImage.value!.path));
      }

      request.fields['StudentId'] = studentId.toString();
      request.fields['StudentName'] = studentName.value.trim();
      request.fields['FatherName'] = fatherName.value.trim();
      request.fields['MotherName'] = motherName.value.trim();
      request.fields['FatherOccupation'] = fatherOccupation.value.trim();
      request.fields['Roll'] = rollNo.value.trim();
      request.fields['WhatsAppNo'] = whatsappNo.value.trim();
      request.fields['EmergencyNo'] = emergencyNo.value.trim();
      request.fields['Gender'] = gender.value.trim();
      request.fields['DateOfBirth'] = dob.text.trim();
      request.fields['BloodGroup'] = bloodGroup.value.trim();
      request.fields['Religion'] = religion.value.trim();
      request.fields['Phone'] = phone.value.trim();
      request.fields['Email'] = emailController.text.trim();
      request.fields['AadharNo'] = aAdharNo.value;
      request.fields['SchoolId'] = schoolId;
      request.fields['Session'] = session.value;
      request.fields['Action'] =
      actionStatus.value.trim().isEmpty ? '1' : actionStatus.value.trim();


      request.fields['AdmissionDate'] = admissionDate.value.trim().isNotEmpty
          ? admissionDate.value.trim()
          : DateTime.now().toIso8601String();

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (responseBody.statusCode == 200) {
        final data = jsonDecode(responseBody.body);
        if (data['isSuccess'] == true) {
          Get.snackbar("Success", "Student updated successfully!");
          await fetchVStudents();
          Get.offAllNamed(RouteName.student_screen);
        } else {
          final errorMessage = data['popupMessage'] ?? "Unknown error";
          Get.snackbar("Error", errorMessage,
              backgroundColor: Colors.red.shade600, colorText: Colors.white);
        }
      } else {
        Get.snackbar("Error", "Failed to update student.",
            backgroundColor: Colors.red.shade600, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e",
          backgroundColor: Colors.red.shade600, colorText: Colors.white);
    }
  }

  Future<void> toggleStudentStatus(StudentData s) async {
    try {
      if (s.studentID == null) {
        Get.snackbar("Error", "StudentID missing",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final current = (s.action ?? '').trim().toLowerCase();
      final nextAction = (current == '1' || current == 'active') ? '0' : '1';

      isLoading(true);

      final uri = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/StudentActiveandInactive'
            '?SchoolId=$schoolId&sId=${s.studentID}',
      );

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final idx = listData.indexWhere((x) => x.studentID == s.studentID);
        if (idx != -1) {
          listData[idx].action = nextAction;
          listData.refresh();
        }
        final idx2 =
        filteredData.indexWhere((x) => x.studentID == s.studentID);
        if (idx2 != -1) {
          filteredData[idx2].action = nextAction;
          filteredData.refresh();
        }

        Get.snackbar(
          nextAction == '1' ? "✅ Activated" : "🔴 Inactivated",
          nextAction == '1'
              ? "Student has been activated successfully."
              : "Student has been inactivated successfully.",
          backgroundColor:
          nextAction == '1' ? const Color(0xFF43A047) : Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar("Error", "Failed to update status: ${response.statusCode}",
            backgroundColor: Colors.red.shade600,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12);
      }
    } catch (e) {
      Get.snackbar("Error", "Status update error: $e",
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12);
    } finally {
      isLoading(false);
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
          data = data.where((e) => e['action'] == "1").toList();
          classes.value = data.map((e) => ClassItem.fromJson(e)).toList();
          if (classes.isNotEmpty) {
            selectedClass.value = classes.first;
          }
        }
      }
    } catch (e) {
      print("Error loading classes: $e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ClassItem? classItem) {
    selectedClass.value = classItem;
  }

  Future<void> fetchSessions() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

    try {
      isLoading(true);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
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
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata session) {
    selectedSession.value = session;
  }

  Future<void> fetchSections() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';

    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = decoded['listData'] ?? decoded['data'] ?? [];
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        if (sectionList.isNotEmpty) {
          selectedSection.value = sectionList.first;
        }
      }
    } catch (e) {
      print("Error loading sections: $e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSection(ListDatta? section) {
    selectedSection.value = section;
  }
}

// ClassItem Model
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

// Session Model
class Session {
  int sessionId;
  String session;
  String action;
  String createDate;
  String updatedate;
  String createBy;
  String updateBy;
  String schoolId;

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
      sessionId: json['sessionId'] ?? 0,
      session: json['session'] ?? '',
      action: json['action'] ?? '',
      createDate: json['createDate'] ?? '',
      updatedate: json['updatedate'] ?? '',
      createBy: json['createBy'] ?? '',
      updateBy: json['updateBy'] ?? '',
      schoolId: json['schoolId'] ?? '',
    );
  }
}