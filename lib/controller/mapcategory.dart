import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


// ✅ Updated model import — replace path as per your project
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/viewphotosmodel.dart';         // GalleryPhotoModel, PhotoData
import '../models/Gallerymapcategorymodel.dart'; // videomodel, vData
import '../models/session_model.dart';           // SessionModel, sListDdata
import '../res/app_url.dart';

class Mapcategorycontroller extends GetxController {
  // ─── Observable Lists ───────────────────────────────────────
  final RxList<PhotoData> galleryCategories = <PhotoData>[].obs; // ✅ PhotoData
  final RxList<vData> mappedCategories = <vData>[].obs;
  final RxList<String> sessionList = <String>[].obs;

  // ─── Loading States ──────────────────────────────────────────
  final RxBool isLoading = false.obs;
  final RxBool isSessionLoading = false.obs;

  // ─── Local Variables ─────────────────────────────────────────
  String schoolId = "";
  String token = "";
  final RxString session = "".obs;

  // ─── Init ────────────────────────────────────────────────────
  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    token = await PrefManager().readValue(key: PrefConst.token) ?? "";

    debugPrint("🌐 base_url = ${AppUrl.base_url}");
    await fetchSessionList();    // ✅ pehle session load ho
    await fetchGalleryCategories(); // ✅ phir images
    fetchMappedCategories();     // ✅ phir videos
  }

  // ─── Session Fetch ───────────────────────────────────────────
  Future<void> fetchSessionList() async {
    isSessionLoading(true);
    try {
      final url = Uri.parse(
        "${AppUrl.base_url}${AppUrl.view_session}$schoolId",
      );
      debugPrint("📥 GET (Sessions) => $url");

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

        final current = model.currentSession?.session?.trim() ?? '';
        if (current.isNotEmpty) {
          session.value = current;
        } else if (sessionList.isNotEmpty) {
          session.value = sessionList.first;
        }

        debugPrint(
          "✅ Sessions Loaded: ${sessionList.length}, Current: ${session.value}",
        );
      } else {
        debugPrint("⚠️ Session API failed: ${res.statusCode}");
        Get.snackbar("Error", "Failed to load sessions");
      }
    } catch (e) {
      debugPrint("❌ Session fetch error: $e");
    } finally {
      isSessionLoading(false);
    }
  }

  // ─── Images Fetch ─────────────────────────────────────────────
  Future<void> fetchGalleryCategories() async {
    if (session.value.isEmpty) {
      debugPrint("⚠️ Session empty, skipping image fetch");
      return;
    }

    isLoading(true);
    try {
      // ✅ base_url ki trailing slash se safe — Uri directly build karo
      final baseClean = AppUrl.base_url.endsWith('/')
          ? AppUrl.base_url
          : "${AppUrl.base_url}/";

      final url = Uri.parse(
        "${baseClean}api/Gallery/GetAllUploadImagesAsyns/$schoolId/${session.value}",
      );
      debugPrint("📥 GET (Images) => $url");

      final response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("📡 Images Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // ✅ GalleryPhotoModel use kar rahe hain
        final parsed = GalleryPhotoModel.fromJson(jsonData);

        if (parsed.isSuccess == true && parsed.data != null) {
          final data = parsed.data!;

          // ✅ Date ke hisab se sort karo (latest pehle)
          data.sort((a, b) {
            final dateA = _parseDate(a.date);
            final dateB = _parseDate(b.date);
            return dateB.compareTo(dateA);
          });

          galleryCategories.value = data;
          debugPrint("📸 Images Loaded: ${galleryCategories.length}");
        } else {
          debugPrint("⚠️ API returned isSuccess=false: ${parsed.messages}");
          galleryCategories.value = [];
        }
      } else {
        debugPrint("⚠️ Images API failed: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load images (${response.statusCode})");
      }
    } catch (e, stack) {
      debugPrint("❌ Error Loading Images => $e");
      debugPrint("$stack");
    } finally {
      isLoading(false);
    }
  }

  // ─── Videos Fetch ────────────────────────────────────────────
  Future<void> fetchMappedCategories() async {
    if (session.value.isEmpty) {
      debugPrint("⚠️ Session empty, skipping video fetch");
      return;
    }

    isLoading(true);
    try {
      final baseClean = AppUrl.base_url.endsWith('/')
          ? AppUrl.base_url
          : "${AppUrl.base_url}/";

      final url = Uri.parse(
        "${baseClean}api/Gallery/GetAllVideoAsyns/$schoolId/${session.value}",
      );
      debugPrint("📥 GET (Videos) => $url");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final parsed = videomodel.fromJson(jsonData);
        mappedCategories.value = parsed.data ?? [];
        debugPrint("🎥 Videos Loaded: ${mappedCategories.length}");
      } else {
        debugPrint("⚠️ Videos API failed: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load video categories");
      }
    } catch (e) {
      debugPrint("❌ Error Loading Videos => $e");
    } finally {
      isLoading(false);
    }
  }

  // ─── Session Change (UI dropdown ke liye) ───────────────────
  void onSessionChanged(String newSession) {
    session.value = newSession;
    fetchGalleryCategories();
    fetchMappedCategories();
  }

  // ─── Helper ──────────────────────────────────────────────────
  DateTime _parseDate(String? dateStr) {
    try {
      return DateTime.parse(dateStr ?? "1970-01-01");
    } catch (_) {
      return DateTime(1970);
    }
  }
}