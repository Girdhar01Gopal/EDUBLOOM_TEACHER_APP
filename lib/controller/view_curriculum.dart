import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/view_curriculum.dart';

class ViewCurriculumController extends GetxController {
  RxBool isLoading = false.obs;
  RxString schoolId = ''.obs;

  RxList<ViewCurriculumModel> curriculumList = <ViewCurriculumModel>[].obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId.value =
        await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    fetchCurriculum();
  }

  Future<void> fetchCurriculum() async {
    try {
      isLoading.value = true;

      final url = Uri.parse(
        "https://playschool.edubloom.in/api/CommumicationApp/GetCurriculumsApp?schoolId=${schoolId.value}",
      );

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final result = ViewCurriculumResponse.fromJson(jsonData);

        if (result.data != null && result.data!.isNotEmpty) {
          curriculumList.assignAll(result.data!);
        } else {
          curriculumList.clear();
        }
      } else {
        curriculumList.clear();
        Get.snackbar(
          "Error",
          "Failed to load data: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      curriculumList.clear();
      print("ERROR fetching curriculum => $e");
      Get.snackbar(
        "Error",
        "Something went wrong while fetching curriculum",
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onDownloadTap(ViewCurriculumModel item) async {
    try {
      if (item.curriculumId == null || item.curriculumId == 0) {
        Get.snackbar(
          "Error",
          "CurriculumId not available",
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String downloadUrl =
          "https://playschool.edubloom.in/api/Communcation/DownloadCurriculum/${item.curriculumId}";

      final Uri uri = Uri.parse(downloadUrl);

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        Get.snackbar(
          "Error",
          "Unable to open download file",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("ERROR downloading curriculum => $e");
      Get.snackbar(
        "Error",
        "Download failed",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}