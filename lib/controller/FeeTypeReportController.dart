import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/session_model.dart' as session_model; // ✅ fixed: relative import

import '../models/FeeTypeReportmodel.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/fee_type_model.dart';

class FeeTypeReportController extends GetxController {
  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  final feeTypeList = <fData>[].obs;
  final selectedFeeType = Rx<fData?>(null);

  final listDataa = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  final feeReportList = <fListData>[].obs;

  final isPageLoading = false.obs;
  final isSearching = false.obs;

  String schoolId = '';
  String token = '';

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    await Future.wait([
      fetchClasses(),
      fetchSessions(),
      fetchFeeType(),
    ]);
  }

  Future<void> fetchClasses() async {
    try {
      isPageLoading(true);
      final res = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/MasterApp/ViewClass/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final parsed = ClassItem.fromJson(jsonDecode(res.body));
        listDataa.assignAll(
            parsed.listData?.where((e) => e.action == "1").toList() ?? []);
      } else {
        Get.snackbar('Error', 'Class API failed: ${res.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Class API error: $e');
    } finally {
      isPageLoading(false);
    }
  }

  Future<void> fetchFeeType() async {
    try {
      isPageLoading(true);
      final response = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/FeeMasterApp/ViewFeeTypeApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final model = FeeTypeModel.fromJson(jsonData);
        feeTypeList.assignAll(model.listData ?? []);
      } else {
        Get.snackbar('Error', 'FeeType API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'FeeType API error: $e');
    } finally {
      isPageLoading(false);
    }
  }

  Future<void> fetchSessions() async {
    try {
      isPageLoading(true);
      final response = await http.get(
        Uri.parse(
            'https://playschool.edubloom.in/api/MasterApp/ViewSessionApp/$schoolId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
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
        Get.snackbar('Error', 'Session API failed: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Session API error: $e');
    } finally {
      isPageLoading(false);
    }
  }

  void setSelectedClass(ListDataa? val) => selectedClass.value = val;

  void setSelectedFeeType(fData? val) => selectedFeeType.value = val;

  void setSelectedSession(session_model.sListDdata? val) =>
      selectedSession.value = val;

  Future<void> searchReport() async {
    if (selectedSession.value == null) {
      Get.snackbar('Missing', 'Select Session first');
      return;
    }
    if (selectedFeeType.value == null) {
      Get.snackbar('Missing', 'Select Fee Type first');
      return;
    }
    if (selectedClass.value == null) {
      Get.snackbar('Missing', 'Select Class first');
      return;
    }

    final body = {
      "class": "",
      "session": selectedSession.value!.session,
      "feeType": selectedFeeType.value!.feeType,
      "classId": selectedClass.value!.classId.toString(),
      "schoolId": schoolId,
    };

    try {
      isSearching(true);
      feeReportList.clear();

      final response = await http.post(
        Uri.parse(
            'https://playschool.edubloom.in/api/ReportApp/ViewGetFeeTypeReportApp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final report = FeeReport.fromJson(jsonData);
        feeReportList.assignAll(report.listData ?? []);
      } else {
        Get.snackbar('Error', 'Report api failed : ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Report API error: $e');
    } finally {
      isSearching(false);
    }
  }
}