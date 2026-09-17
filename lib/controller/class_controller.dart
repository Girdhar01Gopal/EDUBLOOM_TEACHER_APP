import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';

class ClassController extends GetxController {
  final TextEditingController classID = TextEditingController();
  final TextEditingController clas = TextEditingController();

  final isLoading = false.obs;
  final isPosting = false.obs;

  String? schoolId;

  final classList = ClassItem(listData: []).obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    if (schoolId != null) {
      await fetchClasses();
    }
  }

  String formatDDMMYYYY(dynamic d) {
    if (d == null || d.toString().isEmpty) return "-";
    try {
      DateTime? date = d is DateTime ? d : DateTime.tryParse(d.toString());
      if (date == null) return "-";
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (e) {
      return "-";
    }
  }

  Future<void> fetchClasses() async {
    try {
      isLoading(true);
      if (schoolId == null) return;
      final url = Uri.parse("https://playschool.edubloom.in/api/MasterApp/ViewClass/${schoolId!.trim()}");
      final response = await http.get(url);
      if (response.statusCode == 200) {
        classList.value = ClassItem.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      debugPrint("Fetch error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> postClass({required String className}) async {
    try {
      isPosting(true);
      final url = Uri.parse("https://playschool.edubloom.in/api/MasterApp/PostClassApp");
      final body = jsonEncode({
        "classId": "0",
        "class": className.trim(),
        "action": "1",
        "schoolId": schoolId,
      });
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
      if (response.statusCode == 200) {
        clas.clear();
        await fetchClasses();
        Get.snackbar("Success", "Class added", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } finally {
      isPosting(false);
    }
  }

  Future<void> updateClass({required int classId, required String className}) async {
    try {
      isPosting(true);
      final url = Uri.parse("https://playschool.edubloom.in/api/MasterApp/PostClassApp");
      final body = jsonEncode({
        "classId": classId.toString(),
        "class": className.trim(),
        "action": "1",
        "schoolId": schoolId,
      });
      final response = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
      if (response.statusCode == 200) {
        Get.back();
        await fetchClasses();
        Get.snackbar("Success", "Class updated", backgroundColor: Colors.green, colorText: Colors.white);
      }
    } finally {
      isPosting(false);
    }
  }

  void openEditClassDialog(BuildContext context, ListDataa item) {
    final editCtrl = TextEditingController(text: item.className);
    Get.dialog(
      AlertDialog(
        title: const Text("Edit Class"),
        content: TextField(controller: editCtrl, decoration: const InputDecoration(labelText: "Class Name")),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => updateClass(classId: item.classId ?? 0, className: editCtrl.text.trim()),
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}