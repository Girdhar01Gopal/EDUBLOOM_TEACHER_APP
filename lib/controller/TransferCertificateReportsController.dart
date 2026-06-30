import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:teacher_app_edubloom/models/session_model.dart' as session_model;
import 'package:teacher_app_edubloom/models/transfer_certificate1_model.dart'
as tc_model;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../res/app_url.dart';

class TransferCertificateReportsController extends GetxController {
  final RxList<tc_model.TCStudentData> studentList =
      <tc_model.TCStudentData>[].obs;

  final RxString searchQuery = ''.obs;

  List<tc_model.TCStudentData> get filteredStudentList {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return studentList;
    return studentList.where((s) {
      return (s.studentName ?? '').toLowerCase().contains(q) ||
          (s.registrationNo ?? '').toLowerCase().contains(q) ||
          (s.fatherName ?? '').toLowerCase().contains(q) ||
          (s.motherName ?? '').toLowerCase().contains(q);
    }).toList();
  }

  final RxList<session_model.sListDdata> sessionList =
      <session_model.sListDdata>[].obs;
  final Rx<session_model.sListDdata?> selectedSession =
  Rx<session_model.sListDdata?>(null);
  final RxString session = ''.obs;

  final RxList<ListDataa> listDataa = <ListDataa>[].obs;
  final Rx<ListDataa?> selectedClass = Rx<ListDataa?>(null);

  int section = 0;
  final RxList<ListDatta> sectionList = <ListDatta>[].obs;
  final Rxn<ListDatta> selectedSection = Rxn<ListDatta>();

  final RxBool isLoading = false.obs;

  String token = "";
  String schoolId = "";

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? '';
    await Future.wait([
      fetchSessions(),
      fetchClasses(),
      fetchSections(),
    ]);
  }

  Future<void> fetchStudentData() async {
    if (selectedSession.value == null) {
      Get.snackbar('Error', 'Please select a session.');
      return;
    }
    if (selectedClass.value == null) {
      Get.snackbar('Error', 'Please select a class.');
      return;
    }
    if (selectedSection.value == null) {
      Get.snackbar('Error', 'Please select a section.');
      return;
    }

    final String url =
        '${AppUrl.base_url}api/FeePaymentApp/ViewFeeStudentApp';

    try {
      isLoading(true);
      studentList.clear();
      searchQuery.value = '';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'session': selectedSession.value!.session,
          'schoolId': schoolId,
          'classId': selectedClass.value!.classId,
          'sectionId': selectedSection.value!.sectionId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final parsed = tc_model.TCTransferCertificateModel.fromJson(data);
        studentList.value = parsed.listData ?? [];
      } else {
        Get.snackbar(
            'Error', 'Failed to load data. Status: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSessions() async {
    final String url =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(url),
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
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sessions: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchClasses() async {
    final String url = '${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId';
    try {
      isLoading(true);
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        listDataa.value =
            parsed.listData?.where((e) => e.action == "1").toList() ?? [];
        selectedClass.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load classes: $e');
    } finally {
      isLoading(false);
    }
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
        final List<dynamic> data =
            decoded['listData'] ?? decoded['data'] ?? [];
        sectionList.value = data.map((e) => ListDatta.fromJson(e)).toList();
        selectedSection.value = null;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sections: $e');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ListDataa? val) => selectedClass.value = val;
  void setSelectedSection(ListDatta? val) => selectedSection.value = val;
  void setSelectedSession(session_model.sListDdata val) =>
      selectedSession.value = val;
}