import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/viewsectionmodel.dart';
import '../res/app_url.dart';

class Sectioncontroller extends GetxController {
  final TextEditingController sessionController = TextEditingController();
  var schoolId;
  var session;   // 👈 naya - Session param ke liye
  var userId;    // 👈 naya - userId param ke liye

  final sessionData = sectionmodel().obs;
  var isLoading = true.obs;

  @override
  void onInit() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session = await PrefManager().readValue(key: PrefConst.session); // ✅ apna actual key confirm kar lena
    userId = await PrefManager().readValue(key: PrefConst.Userid);   // ✅ apna actual key confirm kar lena
    // TODO: implement onInit
    await fetchSessionData();

    print(schoolId);
    super.onInit();
  }

  Future<void> postSession() async {
    final url = Uri.parse("${AppUrl.base_url}${AppUrl.postSection}");
    print(url);

    final Map<String, dynamic> payload = {
      "sectionId": 0,
      "section": sessionController.text,
      "action": "1",
      "schoolId": schoolId
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      print(url);
      print(response.body);
      print('Request was successful: ${response.body}');
      sessionController.clear();
      ShortMessage.toast(title: "Request was successful:");
      await fetchSessionData(); // list turant refresh ho jaye add karne ke baad
    } else {
      ShortMessage.toast(title: "Request was Not successful:");
      print('Request failed with status: ${response.statusCode}');
    }
  }

  // =========================================================
  // ✅ EDIT UI + UPDATE API (POST API SAME)
  // =========================================================

  void openEditSectionDialog(dynamic item) {
    final TextEditingController editCtrl =
    TextEditingController(text: (item.section ?? "").toString());

    Get.defaultDialog(
      title: "Edit Section",
      content: Column(
        children: [
          TextField(
            controller: editCtrl,
            decoration: const InputDecoration(
              hintText: "Enter Section (e.g., A, B, C)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading.value
                    ? null
                    : () async {
                  final newSection = editCtrl.text.trim();
                  if (newSection.isEmpty) {
                    Get.snackbar("Validation", "Section cannot be empty");
                    return;
                  }

                  await updateSection(
                    sectionId: item.sectionId,
                    section: newSection,
                  );
                },
                child: isLoading.value
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("Update"),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> updateSection({
    required int sectionId,
    required String section,
  }) async {
    try {
      isLoading(true);

      final url = Uri.parse("${AppUrl.base_url}${AppUrl.postSection}");

      final Map<String, dynamic> payload = {
        "sectionId": sectionId,
        "section": section,
        "action": "2",
        "schoolId": schoolId
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        Get.back();
        ShortMessage.toast(title: "Updated successfully");
        await fetchSessionData();
      } else {
        ShortMessage.toast(title: "Update failed: ${response.statusCode}");
      }
    } catch (e) {
      ShortMessage.toast(title: "Update error: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSessionData() async {
    try {
      isLoading(true);

      // 👇 naya API endpoint with query params
      final url = Uri.parse(
          '${AppUrl.base_url}${AppUrl.getSectionTeacher}?schoolId=$schoolId&Session=$session&userId=$userId');
      print(url);

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        print(url);
        print(response.body);
        final Map<String, dynamic> data = json.decode(response.body);
        sessionData.value = sectionmodel.fromJson(data);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } finally {
      isLoading(false);
    }
  }
}