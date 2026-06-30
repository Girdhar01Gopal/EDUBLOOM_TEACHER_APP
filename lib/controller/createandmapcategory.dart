import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/galerycategoeymodel.dart';
import '../models/student_model.dart';
import '../res/app_url.dart';

class Createandmapcategorycontroller extends GetxController {

var galleryCategory = ''.obs;
final TextEditingController galleryCategoryController = TextEditingController();
var galleryCategories = <ListData1>[].obs;


var listData = <StudentData>[].obs;
  var isLoading = true.obs;
  var token = "";
  var schoolId = "";

  var isClassEnabled = true.obs;
  var isSectionEnabled = true.obs;

  final ImagePicker picker = ImagePicker();

  @override
  void onInit() async {
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
   await fetchGalleryCategories(); // ADD THIS
  }

 
Future<void> postGalleryCategory() async {
  try {
    final url = Uri.parse("${AppUrl.base_url}Gallery/PostAddGalleryCategory");

    final payload = {
      "addCategoryId": 0,
      "category": galleryCategoryController.text,
      "action": "1",
      "createDate": DateTime.now().toIso8601String(),
      "updateDate": DateTime.now().toIso8601String(),
      "createBy": "Admin",
      "updateBy": "Admin",
      "schoolId": schoolId
    };

    print("📤 POST => $url");
    print("📦 Body => $payload");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    print("📥 Response => ${response.statusCode}");
    print("📄 Body => ${response.body}");

    if (response.statusCode == 200) {
      ShortMessage.toast(title: "Category Added Successfully!");
      galleryCategoryController.clear();
    } else {
      ShortMessage.toast(title: "Failed to Add Category");
    }
  } catch (e) {
    print("⚠️ Category Add Error => $e");
  }
}

Future<void> fetchGalleryCategories() async {
  try {
    isLoading(true);

    final url = Uri.parse("https://playschool.edubloom.in/api/Gallery/ViewAddGalleryCategory/$schoolId");

    print("🔹 GET => $url");

    final response = await http.get(url);

    print("📥 Response => ${response.statusCode}");
    print("📄 Body => ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final data = GalleryCategory.fromJson(jsonResponse);

      galleryCategories.value = data.listData1 ?? [];

      print("✅ Categories Loaded: ${galleryCategories.length}");
    } else {
      Get.snackbar("Error", "Failed to load gallery categories");
    }
  } catch (e) {
    print("⚠️ Fetch Category Error => $e");
  } finally {
    isLoading(false);
  }
}

}