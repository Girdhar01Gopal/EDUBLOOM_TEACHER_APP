import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Route;
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pre school student teach stu filter api model.dart';
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
import '../utils/app_snackbar.dart';

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
  var admissionNo = ''.obs;
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
  var isSubmitting = false.obs;
  final isStoppageLoading = false.obs;

  // 🆕 Role / Teacher-type detection (class & section dropdown ke liye) — Attendance jaisa
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true agar ClassTeacher API se data mile

  // 🆕 Class Teacher filter (jo classes teacher ko assigned hain)
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var allowedClassNames = <String>[].obs;

  // 🆕 Section filter (jo sections teacher ko assigned hain) — GetSectionTeacher se hi milta hai
  var allowedSectionNames = <String>[].obs;


  @override
  void onInit() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session.value = await PrefManager().readValue(key: PrefConst.session);

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role = ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    print("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    await fetchSessions();

    if (!isStaffLogin.value) {
      await fetchClassTeacherFilter(); // 🆕 teacher ke allowed classes le lo
    }

    await fetchClasses();
    await fetchSections();
    await fetchVStudents();          // fir students filter honge
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

  // 🆕 Logged-in teacher ke assigned classes fetch karo
  Future<void> fetchClassTeacherFilter() async {
    try {
      isLoading(true);

      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
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

      print('ClassTeacher status: ${response.statusCode}');
      print('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];

        allowedClassNames.value = classTeacherList
            .map((e) => (e.className ?? '').trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList();

        // 🆕 Agar ClassTeacher API se class data mila, to matlab ye class teacher hai
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      } else {
        AppSnackbar.apiError('ClassTeacher API failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isLoading(false);
    }
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
        final allStudents = students.data ?? [];

        // 🆕 Staff => complete students dikhao (no filter)
        // 🆕 Teacher (class-teacher / normal) => sirf assigned class AND section ke students
        if (isStaffLogin.value) {
          listData.value = allStudents;
          filteredData.value = allStudents;
        } else {
          final filtered = allStudents.where((s) {
            final cName = (s.className ?? '').trim().toLowerCase();
            final sName = (s.sectionName ?? '').trim().toLowerCase();

            final classMatch = allowedClassNames.contains(cName);
            final sectionMatch = allowedSectionNames.contains(sName);

            return classMatch && sectionMatch;
          }).toList();

          listData.value = filtered;
          filteredData.value = filtered;
        }
      } else {
        AppSnackbar.apiError('GetAllStudentAsynsApp failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
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
      } else {
        AppSnackbar.apiError('GetRouteApp failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
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

  /// Route picked in a dropdown: remember it, clear the old stoppage and
  /// load this route's stoppages.
  void selectRoute(RouteData r) {
    if (routeNo.value == r.routeNo.toString()) return;
    routeNo.value = r.routeNo.toString();
    stoppage.value = '';
    stoppageList.clear();
    fetchPickupPoints(r.routeNo);
  }

  /// Fills the transport fields from a saved student (edit dialog).
  void loadTransportFrom(StudentData s) {
    final t = (s.transportUser ?? '').trim().toLowerCase();
    transportUser.value = t == 'yes' ? 'Yes' : (t == 'no' ? 'No' : '');
    final route = (s.routeNo ?? '').toString().trim();
    routeNo.value = route == '0' ? '' : route;
    final point = (s.pickupPoint ?? '').trim();
    stoppage.value =
    point.toLowerCase() == 'no stoppages available' ? '' : point;
    stoppageList.clear();
    final r = int.tryParse(routeNo.value);
    if (r != null) fetchPickupPoints(r);
  }

  /// Null when OK, otherwise what is missing in the transport section.
  String? transportError() {
    if (transportUser.value.trim().toLowerCase() != 'yes') return null;
    if (routeNo.value.trim().isEmpty) return "Please select the Route No.";
    if (stoppageList.isNotEmpty && stoppage.value.trim().isEmpty) {
      return "Please select the Stoppage";
    }
    return null;
  }

  /// TransportUser / RouteNo / PickupPoint for the update request.
  void _putTransportFields(http.MultipartRequest request) {
    final isUser = transportUser.value.trim().toLowerCase() == 'yes';
    request.fields['TransportUser'] = transportUser.value.trim();
    if (isUser) {
      request.fields['RouteNo'] = routeNo.value.trim();
      request.fields['PickupPoint'] = stoppage.value.trim();
    } else {
      request.fields.remove('RouteNo');
      request.fields.remove('PickupPoint');
    }
  }

  Future<void> fetchPickupPoints(int routeNo) async {
    try {
      isStoppageLoading(true);

      final url = Uri.parse(
        'https://playschool.edubloom.in/api/StudentApp/GetPikPointApp/$schoolId/$routeNo',
      );

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        AppSnackbar.apiError('GetPikPointApp failed: ${response.body}',
            statusCode: response.statusCode);
        return;
      }

      final jsonResponse = json.decode(response.body);
      final routePointResponse = RoutePoint.fromJson(jsonResponse);

      final points = (routePointResponse.data ?? [])
          .map((e) => (e.pickupPoint ?? '').trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();

      // Ignore a late answer for a route that is no longer selected.
      if (this.routeNo.value != routeNo.toString()) return;

      // Empty list => UI shows "No stoppages for this route".
      stoppageList.assignAll(points);
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isStoppageLoading(false);
    }
  }

  Future<void> registerStudent() async {
    if (isSubmitting.value) return; // ✅ already submitting, ignore extra taps
    isSubmitting.value = true;
    try {
      final uri = Uri.parse("${AppUrl.base_url}api/StudentApp/PostStudentApp");
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['StudentName'] = studentName.value;
      request.fields['FatherName'] = fatherName.value;
      request.fields['MotherName'] = motherName.value;
      request.fields['AdmissionNo'] = admissionNo.value.trim();
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
      request.fields['AdmissionNo'] = admissionNo.value.trim();
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
          AppSnackbar.error(popup.toString());
        }
      } else {
        AppSnackbar.apiError('PostStudentApp failed: $body',
            statusCode: responseBody.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isSubmitting.value = false;
    }
  }

  // 🆕 Purani image download karke wapas upload karta hai, taaki backend null na kare.
  // Nayi image pick hui ho to wahi bhejta hai.
  Future<void> _attachImage(
      http.MultipartRequest request,
      String field,
      String folder,
      String? oldName,
      Rx<File?> picked,
      ) async {
    if (picked.value != null) {
      request.files
          .add(await http.MultipartFile.fromPath(field, picked.value!.path));
      return;
    }
    final name = (oldName ?? '').trim();
    if (name.isEmpty || name.toLowerCase() == 'null') return;
    try {
      final res = await http.get(Uri.parse(
          'https://playschool.edubloom.in/Upload/$folder/images/$name'));
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        request.files.add(http.MultipartFile.fromBytes(field, res.bodyBytes,
            filename: name));
      } else {
        print('⚠️ old image not found: $folder/$name (${res.statusCode})');
      }
    } catch (e) {
      print('⚠️ old image download failed: $folder/$name => $e');
    }
  }

  // EditStudentApp poora record overwrite karta hai, isliye har update me
  // student ke purane saare values bhejne padte hain; caller phir sirf
  // edited fields override karta hai. (Admin app jaisa)
  void _putExistingStudentFields(http.MultipartRequest request, StudentData s) {
    void put(String key, dynamic value) {
      final v = value?.toString().trim() ?? '';
      if (v.isNotEmpty && v != 'null') request.fields[key] = v;
    }

    request.fields['StudentId'] = s.studentID.toString();
    request.fields['SchoolId'] = schoolId;
    request.fields['Session'] = (s.session ?? session.value).trim();
    request.fields['Action'] =
    (s.action ?? '').trim().isEmpty ? '1' : s.action!.trim();

    put('StudentName', s.studentName);
    put('FatherName', s.fatherName);
    put('MotherName', s.motherName);
    put('FatherOccupation', s.fatherOccupation);
    put('Gender', s.gender);
    put('DateOfBirth', s.dateOfBirth);
    put('BloodGroup', s.bloodGroup);
    put('Religion', s.religion);
    put('Phone', s.phone);
    put('WhatsAppNo', s.whatsAppNo);
    put('EmergencyNo', s.emergencyNo);
    put('Email', s.email);
    put('Roll', s.rollNo);
    put('AdmissionNo', s.admissionNo);
    put('RegistrationNo', s.registrationNo);
    put('Address', s.address);
    put('AAdharNo', s.aAdharNo);
    put('ParentID', s.parentId);
    put('AdmissionDate', s.admissionDate);
    put('CreateDate', s.createDate);
    put('Password', s.ppassword);
    put('Remark', s.remark);

    put('FromTime', s.fromTime);
    put('ToTime', s.toTime);
    put('AddDaycare', s.addDaycare);
    put('IsDayCare', s.isDaycare);
    put('DaycareDurations', s.daycareDurations);
    put('TransportUser', s.transportUser);
    put('TransportType', s.transportType);
    put('RouteNo', s.routeNo);
    put('PickupPoint', s.pickupPoint);

    // Class/Section hamesha bhejna zaroori hai, warna student list se gayab ho jata hai
    if ((s.classId ?? 0) > 0 && (s.sectionId ?? 0) > 0) {
      request.fields['Status'] = "0";
      request.fields['Class'] = s.classId.toString();
      request.fields['Section'] = s.sectionId.toString();
    }

    // 🆕 Raw record ki baaki sab keys bhi bhejo (jo model me nahi hain),
    // taaki backend koi bhi field null na kare
    const skip = {
      'studentpic', 'fatherpic', 'motherpic', 'guardianimage', 'file',
      'classname', 'sectionname', 'classid', 'sectionid',
      'schoolname', 'affiliated', 'schooladdress', 'schoolphone',
      'schoolemail', 'schoolwebsite', 'logo', 'logowithname',
    };
    s.raw?.forEach((k, v) {
      if (v == null || v is Map || v is List) return;
      final val = v.toString().trim();
      if (val.isEmpty || val == 'null') return;
      if (skip.contains(k.toLowerCase())) return;
      final key = k[0].toUpperCase() + k.substring(1);
      final already = request.fields.keys
          .any((e) => e.toLowerCase() == key.toLowerCase());
      if (!already) request.fields[key] = val;
    });
  }

  // Backend kabhi isSuccess:true ke saath bhi save reject kar deta hai
  // (e.g. "A student with the same name and parents already exists").
  bool _saveRefused(Map data) {
    final msg = (data['messages'] ?? data['popupMessage'] ?? '').toString();
    return msg.toLowerCase().contains('already exists');
  }

  // ✅ Admin app jaisa update — ab EditStudentApp API use hoti hai
  Future<void> updateStudentByPostApi({required StudentData student}) async {
    if (isSubmitting.value) return; // double tap guard

    final transportMissing = transportError();
    if (transportMissing != null) {
      AppSnackbar.error(transportMissing);
      return;
    }

    isSubmitting.value = true;
    try {
      // 🆕 PostStudentApp nayi entry banata hai, update ke liye EditStudentApp
      final uri =
      Uri.parse("${AppUrl.base_url}api/StudentApp/EditStudentApp");
      final request = http.MultipartRequest('POST', uri);

      // 1) Start from the full existing record, then apply the edited fields
      _putExistingStudentFields(request, student);

      // 2) Edited fields: sirf tab override jab nayi value empty na ho
      //    (khali value se purana data overwrite nahi hoga)
      void setIf(String key, String v) {
        final t = v.trim();
        if (t.isNotEmpty) request.fields[key] = t;
      }

      setIf('StudentName', studentName.value);
      setIf('FatherName', fatherName.value);
      setIf('MotherName', motherName.value);
      setIf('FatherOccupation', fatherOccupation.value);
      setIf('Roll', rollNo.value);
      setIf('AdmissionNo', admissionNo.value);
      setIf('WhatsAppNo', whatsappNo.value);
      setIf('EmergencyNo', emergencyNo.value);
      setIf('Gender', gender.value);
      setIf('DateOfBirth', dob.text);
      setIf('BloodGroup', bloodGroup.value);
      setIf('Religion', religion.value);
      setIf('Phone', phone.value);
      setIf('Email', emailController.text);
      setIf('AAdharNo', aAdharNo.value);
      setIf('Address', address.value);
      setIf('Action', actionStatus.value);
      _putTransportFields(request);

      // 3) Images: nayi mili to nayi, nahi to purani wapas upload
      await _attachImage(
          request, 'File', 'student', student.studentPic, fileImage);
      await _attachImage(
          request, 'FatherPic', 'father', student.fatherPic, fatherPic);
      await _attachImage(
          request, 'MotherPic', 'mother', student.motherPic, motherPic);
      await _attachImage(request, 'GuardianImage', 'guardian',
          student.guardianImage, guardianImage);

      // 🔍 DEBUG
      print('UPDATE URL: $uri');
      print('UPDATE FIELDS: ${request.fields}');
      print('UPDATE FILES: ${request.files.map((f) => f.field).toList()}');

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      print('UPDATE STATUS: ${responseBody.statusCode}');
      print('UPDATE BODY: ${responseBody.body}');

      if (responseBody.statusCode == 200) {
        final data = jsonDecode(responseBody.body);
        if (data['isSuccess'] == true && !_saveRefused(data)) {
          // Edit ke baad Add Student form me purani transport values na dikhein
          transportUser.value = '';
          routeNo.value = '';
          stoppage.value = '';
          stoppageList.clear();

          // Reload first so the list shows the updated student on return
          await fetchVStudents();
          Get.until((route) => route.settings.name == RouteName.student_screen);
          AppSnackbar.success("Student updated successfully!");
        } else {
          final errorMessage =
              data['popupMessage'] ?? data['messages'] ?? "Unknown error";
          AppSnackbar.error(errorMessage.toString());
        }
      } else {
        AppSnackbar.apiError('Update student failed: ${responseBody.body}',
            statusCode: responseBody.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> toggleStudentStatus(StudentData s) async {
    try {
      if (s.studentID == null) {
        AppSnackbar.apiError('toggleStudentStatus: StudentID missing');
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
        AppSnackbar.apiError('StudentActiveandInactive failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isLoading(false);
    }
  }

  /// ---------------------- FETCH CLASSES (3-way, no fallback) ----------------------
  // 1️⃣ STAFF -> ViewClass API | 2️⃣ CLASS TEACHER -> ClassTeacher API (mapped)
  // | 3️⃣ NORMAL TEACHER -> GetClassTeacher API
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchClassesStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — class dropdown ClassTeacher API ke data se hi banao
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
        classes.value = classTeacherList.map((e) {
          return ClassItem(
            classId: e.classId ?? 0,
            className: e.className ?? 'Unknown',
            studentClassId: e.studentClassId?.toString() ?? 'N/A',
          );
        }).toList();
        selectedClass.value = classes.isNotEmpty ? classes.first : null;

        // allowedClassNames already set in fetchClassTeacherFilter(), no change needed here
      } catch (e, st) {
        AppSnackbar.apiError(e, stackTrace: st);
        classes.value = [];
        selectedClass.value = null;
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API (existing)
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

      print('GetClassTeacher status: ${response.statusCode}');
      print('GetClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['data'] != null) {
          List<dynamic> data = jsonResponse['data'] ?? [];

          // ❌ action filter hata diya — GetClassTeacher me action null aata hai
          classes.value = data.map((e) => ClassItem.fromJson(e)).toList();

          // 🆕 FIX: teacher ko jo classes assigned hain unke naam allowedClassNames me daalo
          allowedClassNames.value = classes
              .map((e) => e.className.trim().toLowerCase())
              .where((s) => s.isNotEmpty)
              .toList();

          if (classes.isNotEmpty) {
            selectedClass.value = classes.first;
          } else {
            selectedClass.value = null;
          }
        } else {
          classes.value = [];
          selectedClass.value = null;
          allowedClassNames.value = []; // 🆕 stale data clear
        }
      } else {
        AppSnackbar.apiError('GetClassTeacher failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isLoading(false);
    }
  }

  // 🔁 Staff-only path (no fallback)
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);

      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      print('ViewClass (staff) status: ${response.statusCode}');
      print('ViewClass (staff) body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['listData'] ?? [];

        final activeData = data
            .where((e) => (e['action']?.toString().trim() ?? '') == '1')
            .toList();

        classes.value = activeData.map((e) => ClassItem.fromJson(e)).toList();
        selectedClass.value = classes.isNotEmpty ? classes.first : null;
      } else {
        AppSnackbar.apiError('ViewClass (staff) failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
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
      } else {
        AppSnackbar.apiError('ViewSessionApp failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSession(session_model.sListDdata session) {
    selectedSession.value = session;
  }

  /// ---------------------- FETCH SECTIONS (3-way, no fallback) ----------------------
  // 1️⃣ STAFF -> ViewSectionApp API | 2️⃣ CLASS TEACHER -> SectionTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetSectionTeacher API
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

        print('SectionTeacher status: ${response.statusCode}');
        print('SectionTeacher body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final List<dynamic> data = decoded['data'] ?? [];

          sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
          if (sectionList.isNotEmpty) {
            selectedSection.value = sectionList.first;
          } else {
            selectedSection.value = null;
          }

          allowedSectionNames.value = sectionList
              .map((e) => (e.section ?? '').trim().toLowerCase())
              .where((s) => s.isNotEmpty)
              .toList();
        } else {
          AppSnackbar.apiError('SectionTeacher failed: ${response.body}',
              statusCode: response.statusCode);
        }
      } catch (e, st) {
        AppSnackbar.apiError(e, stackTrace: st);
      } finally {
        isLoading(false);
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetSectionTeacher API (existing)
    try {
      isLoading(true);

      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher'
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

      print('GetSectionTeacher status: ${response.statusCode}');
      print('GetSectionTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        List<dynamic> data = decoded['data'] ?? decoded['listData'] ?? [];
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        if (sectionList.isNotEmpty) {
          selectedSection.value = sectionList.first;
        } else {
          selectedSection.value = null;
        }

        // 🆕 teacher ko jo sections assigned hain unke naam nikal lo (student filter ke liye)
        allowedSectionNames.value = sectionList
            .map((e) => (e.section ?? '').trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        AppSnackbar.apiError('GetSectionTeacher failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
    } finally {
      isLoading(false);
    }
  }

  // 🔁 Staff-only path (no fallback)
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);

      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      print('ViewSectionApp (staff) status: ${response.statusCode}');
      print('ViewSectionApp (staff) body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['listData'] ?? [];

        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = sectionList.isNotEmpty ? sectionList.first : null;

        allowedSectionNames.value = sectionList
            .map((e) => (e.section ?? '').trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        AppSnackbar.apiError('ViewSectionApp (staff) failed: ${response.body}',
            statusCode: response.statusCode);
      }
    } catch (e, st) {
      AppSnackbar.apiError(e, stackTrace: st);
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