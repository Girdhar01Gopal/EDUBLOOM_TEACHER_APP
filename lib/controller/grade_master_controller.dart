import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/grade_master_model.dart';

class GradeMasterController extends GetxController {
  final TextEditingController gradeController = TextEditingController();

  final isPosting = false.obs;
  final isLoading = false.obs;

  final grades = <MasterGradeModel>[].obs;
  final searchText = "".obs;

  String schoolId = "";
  String session = "";

  final String postUrl =
      "https://playschool.edubloom.in/api/Result/PostAddGrade";

  final String getBaseUrl =
      "https://playschool.edubloom.in/api/Result/ViewGrade/";

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";
    await fetchGrades();
  }

  @override
  void onClose() {
    gradeController.dispose();
    super.onClose();
  }

  Future<void> saveGrade() async {
    final gradeValue = gradeController.text.trim();

    if (gradeValue.isEmpty) {
      Get.snackbar("Validation", "Please enter Grade");
      return;
    }
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    final now = DateTime.now().toIso8601String();

    final body = {
      "id": 0,
      "grade": gradeValue,
      "action": "1",
      "createDate": now,
      "updateDate": now,
      "createBy": "Admin",
      "updateBy": "Admin",
      "schoolId": schoolId,
      "session": session,
    };

    try {
      isPosting(true);

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonRes = jsonDecode(res.body);
        final msg = (jsonRes["messages"] ?? "").toString();
        final ok = jsonRes["isSuccess"] == true;

        if (ok) {
          Get.snackbar("Success", msg.isEmpty ? "Grade added" : msg);
          gradeController.clear();
          await fetchGrades(showLoader: false);
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Not saved" : msg);
        }
      } else {
        Get.snackbar("Error", "API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Save failed: $e");
    } finally {
      isPosting(false);
    }
  }

  Future<void> updateGrade({
    required int gradeId,
    required String grade,
  }) async {
    final gradeValue = grade.trim();

    if (gradeValue.isEmpty) {
      Get.snackbar("Validation", "Grade cannot be empty");
      return;
    }
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    // existing record ki original values preserve karo
    final existing = grades.firstWhereOrNull((e) => e.id == gradeId);

    final now = DateTime.now().toIso8601String();

    final body = {
      "id": gradeId,
      "grade": gradeValue,
      "action": "1",
      "createDate": existing?.createDate.toIso8601String() ?? now,
      "updateDate": now,
      "createBy": existing?.createBy ?? "Admin",
      "updateBy": "Admin",
      "schoolId": schoolId,
      "session": existing?.session ?? session,
    };

    try {
      isPosting(true);

      final res = await http.post(
        Uri.parse(postUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final jsonRes = jsonDecode(res.body);
        final msg = (jsonRes["messages"] ?? "").toString();
        final ok = jsonRes["isSuccess"] == true;

        if (ok) {
          Get.back();
          Get.snackbar("Success", msg.isEmpty ? "Updated" : msg);
          await fetchGrades(showLoader: false);
        } else {
          Get.snackbar("Failed", msg.isEmpty ? "Update failed" : msg);
        }
      } else {
        Get.snackbar("Error", "Update API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Update failed: $e");
    } finally {
      isPosting(false);
    }
  }

  Future<void> fetchGrades({bool showLoader = true}) async {
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found in storage");
      return;
    }

    final url = "$getBaseUrl$schoolId";

    try {
      if (showLoader) isLoading(true);

      final res = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        final list = MasterGradeModel.fromJsonList(jsonRes as List<dynamic>);
        grades.assignAll(list);
      } else {
        Get.snackbar("Error", "Fetch failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch failed: $e");
    } finally {
      if (showLoader) isLoading(false);
    }
  }

  List<MasterGradeModel> get filteredList {
    final q = searchText.value.trim().toLowerCase();
    if (q.isEmpty) return grades;

    return grades.where((e) {
      return e.grade.toLowerCase().contains(q) ||
          e.id.toString().contains(q);
    }).toList();
  }
}