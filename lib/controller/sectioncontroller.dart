import 'dart:convert';
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
  var session;
  var userId;

  // Rx variable for UI updates
  final sessionData = sectionmodel().obs;
  var isLoading = false.obs;

  // ADDED: search query for filtering sections
  final searchQuery = ''.obs;

  // ADDED: filtered list based on search query
  List get filteredSessionList {
    final list = sessionData.value.listData;
    if (list == null) return [];
    if (searchQuery.value.trim().isEmpty) return list;
    final q = searchQuery.value.trim().toLowerCase();
    return list.where((item) => (item.section ?? '').toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    session = await PrefManager().readValue(key: PrefConst.session);
    userId = await PrefManager().readValue(key: PrefConst.Userid);

    await fetchSessionData();
  }

  // ✅ Fetch Sections using ViewSectionApp API
  Future<void> fetchSessionData() async {
    try {
      isLoading(true);

      // URL: api/MasterApp/ViewSectionApp/$schoolId
      final url = Uri.parse('${AppUrl.base_url}${AppUrl.view_section}$schoolId');
      debugPrint("Fetching Sections from: $url");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        sessionData.value = sectionmodel.fromJson(data);

        if(sessionData.value.listData == null || sessionData.value.listData!.isEmpty) {
          debugPrint("No sections found in API response");
        }
      } else {
        debugPrint('Request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching sections: $e');
    } finally {
      isLoading(false);
    }
  }

  // ✅ Add New Section
  Future<void> postSession() async {
    if (sessionController.text.trim().isEmpty) {
      ShortMessage.toast(title: "Please enter section name");
      return;
    }

    try {
      isLoading(true);
      final url = Uri.parse("${AppUrl.base_url}${AppUrl.postSection}");

      final Map<String, dynamic> payload = {
        "sectionId": 0,
        "section": sessionController.text.trim(),
        "action": "1",
        "schoolId": schoolId
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        sessionController.clear();
        ShortMessage.toast(title: "Section added successfully");
        await fetchSessionData();
      } else {
        ShortMessage.toast(title: "Failed to add section");
      }
    } catch (e) {
      ShortMessage.toast(title: "Error: $e");
    } finally {
      isLoading(false);
    }
  }

  // ✅ Update Section
  Future<void> updateSection({required int sectionId, required String section}) async {
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
        ShortMessage.toast(title: "Update failed");
      }
    } catch (e) {
      ShortMessage.toast(title: "Update error: $e");
    } finally {
      isLoading(false);
    }
  }

  // Edit Dialog UI
  void openEditSectionDialog(dynamic item) {
    final TextEditingController editCtrl = TextEditingController(text: item.section ?? "");
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => updateSection(
                sectionId: item.sectionId,
                section: editCtrl.text.trim(),
              ),
              child: const Text("Update"),
            ),
          ),
        ],
      ),
    );
  }
}