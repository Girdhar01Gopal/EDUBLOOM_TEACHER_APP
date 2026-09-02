import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/session_model.dart' as session_model;

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import 'package:http/http.dart' as http;

import '../models/class_list_model.dart';
import '../models/sectionmodel.dart';
import '../models/student_fee_model.dart';
import '../res/app_url.dart';

class FeesController extends GetxController {
  var studentfee = StudentFeeModel().obs;
  RxList<session_model.sListDdata> sessionList = <session_model.sListDdata>[].obs;

// Rx object for currently selected session
  Rx<session_model.sListDdata?> selectedSession = Rx<session_model.sListDdata?>(null);

// String to store session name (optional)
  var session = ''.obs;
  var listDataa = <ClassData>[].obs; // Flattened list of classes
  var selectedClass = Rx<ClassData?>(null);

  var section = 0;
  var studentClass = ''.obs;

  var sectionList = <ListDatta>[].obs; // Observable list for dropdown
  var selectedSection = Rxn<ListDatta>(); // To store the selected section
  var isLoading = true.obs; // Loading state
  var isloading = false.obs; // Loading state

  var token = "";
  var schoolId = "";
  var userId = "";

  // 🔍 Search ke liye naye variables
  var isSearching = false.obs;
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  // 🆕 Auto-fetched (GetAllStudentAsynsApp) list + its loader
  var allStudents = <sdataData>[].obs;
  var isLoadingAll = false.obs;

  // 🆕 Tracks whether user has clicked Submit (Session/Class/Section flow).
  // Before submit -> show full auto-loaded list.
  // After submit -> always show the submitted (filtered) list, even if empty.
  var hasSubmitted = false.obs;

  // 🆕 Class Teacher filter (jo classes teacher ko assigned hain)
  var allowedClassNames = <String>[].obs;

  // 🆕 Section filter (jo sections teacher ko assigned hain) — GetSectionTeacher se hi milta hai
  var allowedSectionNames = <String>[].obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    userId = await PrefManager().readValue(key: PrefConst.Userid);

    await fetchSessions();
    await fetchClasses();   // 🆕 await lagaya — allowedClassNames time pe milega
    await fetchSections();  // 🆕 await lagaya — allowedSectionNames time pe milega
    fetchAllStudentsAuto(); // 🆕 auto load ALL students on screen open
    // fetchStudentFeeData();
    super.onInit();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Filtered list — name, father name, registration no, phone no etc se search
  List<sdataData> get filteredStudents {
    // 🆕 Submit click hone ke baad hamesha submitted (filtered) list use hogi,
    // chahe wo khaali (0 results) hi kyun na ho — auto full list par fallback nahi hoga.
    // Submit se pehle poori auto-loaded (GetAllStudentAsynsApp) list dikhegi.
    final List<sdataData> sourceList =
    hasSubmitted.value ? students : allStudents;

    // 🆕 Latest added student sabse upar (highest studentID = sabse naya)
    final sortedList = List<sdataData>.from(sourceList)
      ..sort((a, b) => (b.studentID ?? 0).compareTo(a.studentID ?? 0));

    if (searchQuery.value.trim().isEmpty) return sortedList;
    final query = searchQuery.value.trim().toLowerCase();
    return sortedList.where((s) {
      return (s.studentName ?? '').toLowerCase().contains(query) ||
          (s.fatherName ?? '').toLowerCase().contains(query) ||
          (s.motherName ?? '').toLowerCase().contains(query) ||
          (s.registrationNo ?? '').toLowerCase().contains(query) ||
          (s.admissionNo ?? '').toLowerCase().contains(query) ||
          (s.fatherPhone ?? '').toLowerCase().contains(query) ||
          (s.className ?? '').toLowerCase().contains(query) ||
          (s.sectionName ?? '').toLowerCase().contains(query);
    }).toList();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchController.clear();
      searchQuery.value = '';
    }
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // fetch sections
  Future<void> fetchSections() async {
    try {
      isLoading(true);

      final String currentSession =
          selectedSession.value?.session ?? session.value;

      final String url =
          '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher?schoolId=$schoolId&Session=$currentSession&userId=$userId';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List<dynamic> data = decoded['data'] ?? decoded['listData'] ?? [];

        // update observable list
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();

        // 🆕 teacher ko jo sections assigned hain unke naam nikal lo (student filter ke liye)
        allowedSectionNames.value = sectionList
            .map((e) => (e.section ?? '').trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList();

        // ❌ STOP auto-selecting first section
        // selectedSection.value = sectionList.first;

        // ✔ Allow dropdown to show "Select Section"
        selectedSection.value = null;
      } else {
        print(" Failed to load sections: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ Exception loading sections: $e");
    } finally {
      isLoading(false);
    }
  }

  // Method to set selected section
  void setSelectedSection(ListDatta? section) {
    selectedSection.value = section;
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);

      final String currentSession =
          selectedSession.value?.session ?? session.value;

      final String apiUrl =
          '${AppUrl.base_url}api/TeacherApp/GetClassTeacher?schoolId=$schoolId&Session=$currentSession&userId=$userId';

      final res = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final parsed = ClassListModel.fromJson(jsonDecode(res.body));

        listDataa.value = parsed.listData;

        // 🆕 teacher ko jo classes assigned hain unke naam nikal lo (student filter ke liye)
        allowedClassNames.value = listDataa
            .map((e) => (e.className).trim().toLowerCase())
            .where((s) => s.isNotEmpty)
            .toList();

        // Set empty selection so dropdown shows "Select Class"
        selectedClass.value = null;
      }
    } catch (e) {
      print("Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ClassData? studentClassId) {
    selectedClass.value = studentClassId;
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

        // Purana sessionList ko clear karte hain
        sessionList.clear();

        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );

          sessionList.add(cs);

          // Default session ko select kar rahe hain
          selectedSession.value = cs;
          session.value = cs.session ??
              ''; // Ye line ensure karegi ki session default select ho
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

// Set the selected session
  void setSelectedSession(session_model.sListDdata session) {
    selectedSession.value = session;
  }

  var students = <sdataData>[].obs;

  Future<void> fetchStudents() async {
    try {
      isloading(true);
      hasSubmitted.value = true; // 🆕 mark that Submit flow is now active

      // 🆕 Clear any existing search so the full submitted list shows up
      // (otherwise old search text would keep filtering to just that 1 student)
      searchQuery.value = '';
      searchController.clear();

      var url =
      Uri.parse('${AppUrl.base_url}api/FeePaymentApp/ViewFeeStudentApp');
      Map<String, dynamic> body = {
        "session": session.value,
        "schoolId": schoolId,
        "classId": selectedClass.value?.classId,
        "sectionId": section,
      };
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      print(url);
      print(response.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Handle both cases: flat list or nested
        if (data['listData'] is List) {
          // If listData is a list of students (as objects)
          final List<sdataData> allStudents = [];
          for (var studentJson in data['listData']) {
            // If each studentJson contains a listData property (nested structure)
            if (studentJson is Map && studentJson.containsKey('listData')) {
              var nestedList = studentJson['listData'] as List;
              allStudents.addAll(nestedList.map((v) => sdataData.fromJson(v)));
            } else {
              // If flat
              allStudents.add(sdataData.fromJson(studentJson));
            }
          }
          students.value = allStudents;
        } else {
          students.clear();
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch students');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong');
    } finally {
      isloading(false);
    }
  }

  // 🆕 Auto fetch ALL students directly from GetAllStudentAsynsApp
  // (No session/class/section/submit needed — runs automatically on screen open)
  Future<void> fetchAllStudentsAuto() async {
    try {
      isLoadingAll(true);

      final url = Uri.parse(
        '${AppUrl.base_url}api/StudentApp/GetAllStudentAsynsApp',
      );

      final body = {
        "schoolId": schoolId,
        "currentSession": session.value,
      };

      print("🔹 [Fees] Auto Fetch All Students => $url");
      print("📦 [Fees] Body => $body");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print("📥 [Fees] Auto Fetch Status => ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // API list ya to 'data' key me hoti hai ya 'listData' me
        List<dynamic> data =
            jsonResponse['data'] ?? jsonResponse['listData'] ?? [];

        final allFetchedStudents = data.map((e) {
          return sdataData(
            studentID: e['studentID'],
            studentName: e['studentName'],
            fatherName: e['fatherName'],
            motherName: e['motherName'],
            classId: e['classId'],
            sectionId: e['sectionId'],
            className: e['className'],
            sectionName: e['sectionName'],
            createDate: e['createDate'],
            session: e['session'],
            action: e['action'],
            schoolId: e['schoolId'],
            fatherPhone: e['phone'] ?? e['fatherPhone'],
            registrationNo: e['registrationNo'],
            admissionNo: e['admissionNo'],
            pickupPoint: e['pickupPoint'],
            playAmount: e['playAmount'],
          );
        }).toList();

        // 🆕 sirf teacher ke assigned class AND section ke students dikhao
        if (allowedClassNames.isEmpty && allowedSectionNames.isEmpty) {
          // ❌ Teacher ko koi class ya section hi assign nahi hai — koi student mat dikhao
          allStudents.value = [];

          // ── 🗑️ PURANA FALLBACK LOGIC (comment kar diya) ──────────────
          // Pehle jab allowedClassNames aur allowedSectionNames dono empty
          // hote the, to saare students dikha diye jaate the (fallback).
          // Ab requirement change ho gayi hai — is condition me ab koi
          // student nahi dikhana, isliye neeche wala purana code comment
          // kar diya hai (future reference ke liye rakha hai):
          //
          // allStudents.value = allFetchedStudents;
        } else {
          final filtered = allFetchedStudents.where((s) {
            final cName = (s.className ?? '').trim().toLowerCase();
            final sName = (s.sectionName ?? '').trim().toLowerCase();

            final classMatch =
                allowedClassNames.isEmpty || allowedClassNames.contains(cName);
            final sectionMatch = allowedSectionNames.isEmpty ||
                allowedSectionNames.contains(sName);

            return classMatch && sectionMatch;
          }).toList();

          allStudents.value = filtered;
        }

        print("✅ [Fees] Auto-loaded students: ${allStudents.length}");
      } else {
        print(
            "❌ [Fees] Failed to auto-fetch all students: ${response.statusCode}");
      }
    } catch (e) {
      print("⚠️ [Fees] Exception auto-fetching all students: $e");
    } finally {
      isLoadingAll(false);
    }
  }

  Future<void> fetchStudentFeeData({
    required int studentId,
    required String pickupPoint,
    String? registrationNo,
    int? classId, // 🆕 student's own classId (preferred, works for auto-loaded list too)
    int? sectionId, // 🆕 student's own sectionId (preferred, works for auto-loaded list too)
  }) async {
    final String apiUrl = "${AppUrl.base_url}api/FeePayment/GetShowdata";

    // 🆕 Prefer the classId/sectionId passed in from the student card itself
    // (works whether the list came from auto-load OR Submit).
    // Falls back to the dropdown-selected values only if the student's own
    // class/section isn't available (keeps old Submit-flow behavior intact).
    final int? resolvedClassId = classId ?? selectedClass.value?.classId;
    final int resolvedSectionId = sectionId ?? section;

    if (resolvedClassId == null) {
      print("Class is not selected.");
      Get.snackbar("Error", "Class information missing for this student.");
      return;
    }

    final requestBody = {
      "session": session.value,
      "schoolId": schoolId,
      "classId": resolvedClassId,
      "sectionId": resolvedSectionId,
      "studentId": studentId,
      "pickupPoint": pickupPoint.trim(),
    };

    print("Request Body: $requestBody");
    print("API URL: $apiUrl");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print("Response Body: $jsonResponse");
        studentfee.value = StudentFeeModel.fromApi(jsonResponse);

        // Attach registrationNo only when the caller provides it.
        if (registrationNo != null && registrationNo.trim().isNotEmpty) {
          for (var item in studentfee.value.listData ?? []) {
            item.registrationNo = registrationNo.trim();
          }
        }

        print("Fee items loaded successfully.");
      } else {
        print("Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void filterAndNavigate(
      StudentFeeModel studentFeeModel,
      String registrationNo,
      int studentId,
      ) {
    final dataList = studentFeeModel.listData;

    if (dataList == null || dataList.isEmpty) {
      Get.snackbar("Error", "No fee data available for filtering.");
      return;
    }

    final inputRegNo = registrationNo.trim();

    // Filter based on injected registrationNo
    final filteredList = dataList.where((item) {
      final listRegNo = item.registrationNo?.trim() ?? '';
      return listRegNo == inputRegNo;
    }).toList();

    print("Input Registration No: $inputRegNo");
    print("Filtered List Length: ${filteredList.length}");

    if (filteredList.isEmpty) {
      Get.snackbar(
          "Error", "No matching data found for this registration number.");
      return;
    }

    // Remove duplicates
    final uniqueList = filteredList
        .fold<Map<String, ListData>>({}, (map, item) {
      map[item.className ?? ''] = item;
      return map;
    })
        .values
        .toList();

    print("Filtered List: $uniqueList");

    Get.toNamed(
      RouteName.submit_fee,
      arguments: {
        'feeItems': filteredList,
        'studentId': studentId,
      },
    );
  }
}

class Student {
  List<sdataData>? listData;

  Student({this.listData});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      listData: (json['listData'] as List<dynamic>?)
          ?.map((v) => sdataData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (listData != null)
        'listData': listData!.map((v) => v.toJson()).toList(),
    };
  }
}

class sdataData {
  final int? studentID;
  final String? studentName;
  final String? fatherName;
  final String? motherName;
  final int? classId;
  final int? sectionId;
  final String? className;
  final String? sectionName;
  final String? createDate;
  final String? session;
  final String? action;
  final String? schoolId;
  final String? fatherPhone;
  final String? registrationNo;
  final String? admissionNo;
  final String? pickupPoint;
  final String? playAmount;

  sdataData({
    this.studentID,
    this.studentName,
    this.fatherName,
    this.motherName,
    this.classId,
    this.sectionId,
    this.className,
    this.sectionName,
    this.createDate,
    this.session,
    this.action,
    this.schoolId,
    this.fatherPhone,
    this.registrationNo,
    this.admissionNo,
    this.pickupPoint,
    this.playAmount,
  });

  factory sdataData.fromJson(Map<String, dynamic> json) {
    return sdataData(
      studentID: json['studentID'],
      studentName: json['studentName'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      classId: json['classId'],
      sectionId: json['sectionId'],
      className: json['className'],
      sectionName: json['sectionName'],
      createDate: json['createDate'],
      session: json['session'],
      action: json['action'],
      schoolId: json['schoolId'],
      fatherPhone: json['fatherPhone'],
      registrationNo: json['registrationNo'],
      admissionNo: json['admissionNo'],
      pickupPoint: json['pickupPoint'],
      playAmount: json['playAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentID': studentID,
      'studentName': studentName,
      'fatherName': fatherName,
      'motherName': motherName,
      'classId': classId,
      'sectionId': sectionId,
      'className': className,
      'sectionName': sectionName,
      'createDate': createDate,
      'session': session,
      'action': action,
      'schoolId': schoolId,
      'fatherPhone': fatherPhone,
      'registrationNo': registrationNo,
      'admissionNo': admissionNo,
      'pickupPoint': pickupPoint,
      'playAmount': playAmount,
    };
  }
}