import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/classmodel.dart';
import '../models/galerycategoeymodel.dart';
import '../models/sectionmodel.dart';
import '../models/session_model.dart';      // ✅ ADD
import '../res/app_url.dart';

class Galaryvidevconroller extends GetxController {
  var schoolId = "";
  var token = "";

  var isLoading = true.obs;

  var galleryCategories = <ListData1>[].obs;
  var selectedCategoryIds = <int>[].obs;

  TextEditingController imageheaderController = TextEditingController();

  var classList = <ListDataa>[].obs;
  var selectedClassId = 0.obs;

  var sectionList = <ListDatta>[].obs;
  var selectedSectionId = 0.obs;

  var session = "".obs;

  // ✅ CHANGE 1: sessionList add karo
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  TextEditingController dateController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  var selectedImages = <File>[].obs;

  TextEditingController videoUrlController = TextEditingController();

  // ─── Snackbar Helpers ───────────────────────────────────────────────────────

  void _showSuccess(String message) {
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF2E7D32),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFC62828),
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────

  @override
  void onInit() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    // ✅ CHANGE 2: hardcoded line hatao, fetchSessionList add karo
    await fetchSessionList();

    fetchGalleryCategories();
    fetchClasses();
    fetchSections();
    super.onInit();
  }

  // ✅ CHANGE 3: naya method add karo
  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final url = Uri.parse(
        "${AppUrl.base_url}${AppUrl.view_session}$schoolId",
      );
      final res = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final model = SessionModel.fromJson(data);
        final list = model.listData ?? [];

        sessionList.value = list
            .map((s) => s.session ?? '')
            .where((s) => s.isNotEmpty)
            .toList();

        final current = model.currentSession?.session?.trim();
        if (current != null && current.isNotEmpty) {
          session.value = current;
        } else if (sessionList.isNotEmpty) {
          session.value = sessionList.first;
        }
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    } finally {
      isSessionLoading(false);
    }
  }

  // ══════════════════════════════════════════
  // BAAKI SAB EXACT SAME — EK LINE NAHI BADI
  // ══════════════════════════════════════════

  Future<void> fetchGalleryCategories() async {
    try {
      isLoading(true);
      final url = Uri.parse(
          "https://playschool.edubloom.in/api/Gallery/ViewAddGalleryCategory/$schoolId");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        galleryCategories.value =
            GalleryCategory.fromJson(jsonData).listData1 ?? [];
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchClasses() async {
    try {
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final classItem = ClassItem.fromJson(jsonDecode(response.body));

        classList.value = classItem.listData
            ?.where((e) => e.action == "1")
            .toList() ?? [];

        if (classList.isNotEmpty) {
          selectedClassId.value = classList.first.classId ?? 0;
        } else {
          selectedClassId.value = 0;
        }
      }
    } catch (e) {
      print("⚠️ Error fetching classes: $e");
    }
  }

  Future<void> fetchSections() async {
    try {
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        sectionList.value = (jsonDecode(response.body)['listData'] as List)
            .map((e) => ListDatta.fromJson(e))
            .toList();

        if (sectionList.isNotEmpty) {
          selectedSectionId.value = sectionList.first.sectionId!;
        }
      }
    } finally {}
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      selectedImages.value = picked.map((e) => File(e.path)).toList();
    }
  }

  Future<void> uploadGalleryImages() async {
    try {
      if (selectedImages.isEmpty) {
        _showError("Please select images first");
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final url = Uri.parse(
        "https://playschool.edubloom.in/api/Gallery/PostUploadImage",
      );

      var request = http.MultipartRequest("POST", url);

      request.fields['ImageHeading'] = imageheaderController.text.trim();
      request.fields['SchoolId'] = schoolId;
      request.fields['Session'] = session.value;
      request.fields['CreateBy'] = "Admin";

      request.fields['Date'] = DateTime.parse(
        dateController.text.trim(),
      ).toIso8601String();

      for (var img in selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath("UploadImagePaths", img.path),
        );
      }

      print("📤 Sending Multipart Request...");

      var response = await request.send();

      Navigator.of(Get.context!, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        print("📥 SUCCESS");
        _showSuccess("Images Uploaded Successfully");

        selectedImages.clear();
        imageheaderController.clear();
        dateController.clear();
      } else {
        print("❌ FAILED ${response.statusCode}");
        _showError("Upload Failed (${response.statusCode})");
      }
    } catch (e) {
      Navigator.of(Get.context!, rootNavigator: true).pop();
      print("❌ Exception: $e");
      _showError("Something went wrong");
    }
  }

  Future<void> uploadVideo() async {
    if (selectedClassId.value == 0 ||
        selectedSectionId.value == 0 ||
        videoUrlController.text.trim().isEmpty) {
      _showError("Class, Section & Video URL are required!");
      return;
    }

    final url = Uri.parse(
      "https://playschool.edubloom.in/api/Gallery/PostVideo",
    );

    final body = {
      "videoId": 0,
      "class": selectedClassId.value,
      "section": selectedSectionId.value,
      "videoUrl": videoUrlController.text.trim(),
      "action": "1",
      "createBy": "Admin",
      "updateBy": "Admin",
      "session": session.value,
      "schoolId": schoolId,
    };

    print("📤 Sending Video => $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      _showSuccess("Video Uploaded Successfully");
      videoUrlController.clear();
    } else {
      print("❌ Response: ${response.body}");
      _showError("Failed to upload video");
    }
  }
}