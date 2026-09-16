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
import '../models/pre school student teach stu filter api model.dart';
import '../models/sectionmodel.dart';
import '../models/session_model.dart';      // ✅ ADD
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel (class teacher sections ke liye)
import '../res/app_url.dart';
import 'mapcategory.dart'; // ✅ ADDED: to refresh gallery view controller after upload
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 class-teacher filter reuse (Notification wala hi)

class Galaryvidevconroller extends GetxController {
  var schoolId = "";
  var token = "";

  var isLoading = true.obs;

  var galleryCategories = <ListData1>[].obs;
  var selectedCategoryIds = <int>[].obs;

  TextEditingController imageheaderController = TextEditingController();

  var classList = <ListDataa>[].obs;
  // ✅ CHANGED: single select -> multi select
  var selectedClassIds = <int>[].obs;

  var sectionList = <ListDatta>[].obs;
  // ✅ CHANGED: single select -> multi select
  var selectedSectionIds = <int>[].obs;

  var session = "".obs;

  // ✅ CHANGE 1: sessionList add karo
  final RxList<String> sessionList = <String>[].obs;
  final RxBool isSessionLoading = false.obs;

  TextEditingController dateController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  var selectedImages = <File>[].obs;

  TextEditingController videoUrlController = TextEditingController();

  // 🆕 Role / Teacher-type detection (class & section dropdown ke liye)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila (teacher hai to bhi class-teacher hai)
  var classTeacherList = <ClassTeacherFilterData>[].obs;

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

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    // ✅ CHANGE 2: hardcoded line hatao, fetchSessionList add karo
    await fetchSessionList();

    fetchGalleryCategories();

    if (isStaffLogin.value) {
      // 🟢 STAFF — jo APIs ab tak chal rahi hain wahi (class/section)
      fetchClasses();
      fetchSections();
    } else {
      // 🟡 TEACHER — pehle ClassTeacher filter check, phir uske hisaab se class/section
      await fetchClassTeacherFilter();
      fetchClasses();
      fetchSections();
    }

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

        // ✅ ADDED: debug print so you can verify session used for upload
        debugPrint("📅 [UPLOAD SCREEN] Session set to: ${session.value}");
      }
    } catch (e) {
      debugPrint("Session fetch error: $e");
    } finally {
      isSessionLoading(false);
    }
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo (Notification wala hi logic)
  Future<void> fetchClassTeacherFilter() async {
    try {
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      if (userId == null || userId.trim().isEmpty) {
        debugPrint("⚠️ userId empty — skipping class teacher filter fetch");
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session.value)}'
            '&userId=${Uri.encodeComponent(userId)}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('ClassTeacher status: ${response.statusCode}');
      debugPrint('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];

        // 🆕 Agar ClassTeacher API se class data mila, to matlab ye class teacher hai
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
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

  // 🆕 3-way class fetch: Staff -> existing API | Class Teacher -> ClassTeacher API
  // | Normal Teacher -> GetClassTeacher API | fallback -> existing (staff) API
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF — ye wahi API hai jo ab tak chal rahi thi, ismein koi change nahi
    if (isStaffLogin.value) {
      await _fetchClassesStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
        classList.value = classTeacherList.map((e) {
          return ListDataa.fromJson({
            'classId': e.classId,
            'class': e.className,
            'studentClassId': e.studentClassId,
            'action': e.action,
            'createDate': e.createDate,
            'updateDate': e.updateDate,
            'createBy': e.createBy,
            'updateBy': e.updateBy,
            'schoolId': e.schoolId,
            'sqno': e.sqno,
          });
        }).toList();
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        classList.value = [];
      }

      if (classList.isEmpty) {
        debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
        await _fetchClassesStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session.value)}'
            '&userId=${Uri.encodeComponent(userId ?? '')}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GetClassTeacher status: ${response.statusCode}');
      debugPrint('GetClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'] as List<dynamic>? ?? [];

        classList.value = data.map((e) => ListDataa.fromJson(e)).toList();
      } else {
        classList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetClassTeacher classes: $e");
      classList.value = [];
    }

    if (classList.isEmpty) {
      debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
      await _fetchClassesStaffApi();
    }
  }

  // 🔁 Ye wahi ViewClass API hai jo pehle se is file me lagi hui thi — bina kisi change ke.
  // Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final classItem = ClassItem.fromJson(jsonDecode(response.body));

        classList.value = classItem.listData
            ?.where((e) => e.action == "1")
            .toList() ?? [];

        // ✅ CHANGED: single auto-select hataya, ab user khud multiple select karega
      }
    } catch (e) {
      print("⚠️ Error fetching classes: $e");
    }
  }

  // 🆕 3-way section fetch: Staff -> existing API | Class Teacher -> SectionTeacher API
  // | Normal Teacher -> getSectionTeacher API | fallback -> existing (staff) API
  Future<void> fetchSections() async {
    // 1️⃣ STAFF — ye wahi API hai jo ab tak chal rahi thi, ismein koi change nahi
    if (isStaffLogin.value) {
      await _fetchSectionsStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — SectionTeacher API (jo Attendance/Notification me use hoti hai)
    if (isClassTeacherLogin.value) {
      try {
        final userId = await PrefManager().readValue(key: PrefConst.Userid);

        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=${Uri.encodeComponent(schoolId)}'
              '&Session=${Uri.encodeComponent(session.value)}'
              '&userId=${Uri.encodeComponent(userId ?? '')}',
        );

        final response = await http.get(
          url,
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
          },
        );

        debugPrint('SectionTeacher status: ${response.statusCode}');
        debugPrint('SectionTeacher body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final model = SectionForAttendanceModel.fromJson(decoded);

          sectionList.value = (model.data ?? []).map((e) {
            return ListDatta.fromJson({
              'sectionId': e.sectionId,
              'section': e.section,
              'action': e.action,
              'createDate': e.createDate,
              'updateDate': e.updateDate,
              'createBy': e.createBy,
              'updateBy': e.updateBy,
              'schoolId': e.schoolId,
            });
          }).toList();
        } else {
          sectionList.value = [];
        }
      } catch (e) {
        debugPrint("⚠️ Error fetching SectionTeacher sections: $e");
        sectionList.value = [];
      }

      if (sectionList.isEmpty) {
        debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
        await _fetchSectionsStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — getSectionTeacher API
    try {
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.getSectionTeacher}'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session.value)}'
            '&userId=${Uri.encodeComponent(userId ?? '')}',
      );

      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GetSectionTeacher status: ${response.statusCode}');
      debugPrint('GetSectionTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // 🔧 FIX: is endpoint ka actual response 'data' key me list deta hai,
        // 'listData' me nahi (staff wale ViewSectionApp se alag).
        final list = (jsonResponse['data'] as List<dynamic>?) ?? [];
        sectionList.value = list.map((e) => ListDatta.fromJson(e)).toList();
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetSectionTeacher sections: $e");
      sectionList.value = [];
    }

    if (sectionList.isEmpty) {
      debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
      await _fetchSectionsStaffApi();
    }
  }

  // 🔁 Ye wahi ViewSectionApp API hai jo pehle se is file me lagi hui thi — bina kisi change ke.
  // Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        sectionList.value = (jsonDecode(response.body)['listData'] as List)
            .map((e) => ListDatta.fromJson(e))
            .toList();

        // ✅ CHANGED: single auto-select hataya, ab user khud multiple select karega
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
    }
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      selectedImages.value = picked.map((e) => File(e.path)).toList();
    }
  }

  Future<void> uploadGalleryImages() async {
    try {
      // ✅ FIX #1: validate images selected
      if (selectedImages.isEmpty) {
        _showError("Please select images first");
        return;
      }

      // ✅ FIX #2: validate date BEFORE calling DateTime.parse
      // Previously: empty date string caused DateTime.parse() to throw a
      // FormatException, which was silently swallowed by the catch block
      // below and shown only as a generic "Something went wrong" error.
      // The request never reached the server in that case.
      if (dateController.text.trim().isEmpty) {
        _showError("Please select a date");
        return;
      }

      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(dateController.text.trim());
      } catch (e) {
        _showError("Invalid date selected. Please pick the date again.");
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
      request.fields['Date'] = parsedDate.toIso8601String();

      for (var img in selectedImages) {
        request.files.add(
          await http.MultipartFile.fromPath("UploadImagePaths", img.path),
        );
      }

      // ✅ ADDED: log exactly what session/school this upload is going to,
      // so you can compare against what the view screen queries later
      debugPrint("📤 Sending Multipart Request...");
      debugPrint("   SchoolId: $schoolId");
      debugPrint("   Session:  ${session.value}");
      debugPrint("   Date:     ${parsedDate.toIso8601String()}");
      debugPrint("   Images:   ${selectedImages.length}");

      var response = await request.send();

      // ✅ FIX #3: read and print the actual response body instead of
      // only checking statusCode. Some APIs return 200 even when the
      // save silently failed on the server side (e.g. validation issue),
      // so the body often reveals the real problem.
      final responseBody = await response.stream.bytesToString();
      debugPrint("📥 Upload Response Code: ${response.statusCode}");
      debugPrint("📥 Upload Response Body: $responseBody");

      Navigator.of(Get.context!, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        _showSuccess("Images Uploaded Successfully");

        // ✅ FIX #4: refresh the gallery view controller if it's already
        // alive in memory. Without this, GetX keeps serving the old
        // in-memory list because Mapcategorycontroller.onInit() only runs
        // once when that controller is first created — it won't re-run
        // just because you navigated back to that screen.
        if (Get.isRegistered<Mapcategorycontroller>()) {
          debugPrint("🔄 Refreshing gallery view after upload...");
          Get.find<Mapcategorycontroller>().fetchGalleryCategories();
        }

        selectedImages.clear();
        imageheaderController.clear();
        dateController.clear();
      } else {
        debugPrint("❌ FAILED ${response.statusCode}");
        _showError("Upload Failed (${response.statusCode})");
      }
    } catch (e, stack) {
      if (Get.isDialogOpen ?? false) {
        Navigator.of(Get.context!, rootNavigator: true).pop();
      }
      debugPrint("❌ Exception: $e");
      debugPrint("$stack");
      _showError("Something went wrong");
    }
  }

  Future<void> uploadVideo() async {
    // ✅ CHANGED: single id check -> multi list empty check
    if (selectedClassIds.isEmpty ||
        selectedSectionIds.isEmpty ||
        videoUrlController.text.trim().isEmpty) {
      _showError("Class, Section & Video URL are required!");
      return;
    }

    final url = Uri.parse(
      "https://playschool.edubloom.in/api/Gallery/PostVideo",
    );

    final body = {
      "videoId": 0,
      // ✅ CHANGED: multiple selected class & section ids bhejenge
      "class": selectedClassIds,
      "section": selectedSectionIds,
      "videoUrl": videoUrlController.text.trim(),
      "action": "1",
      "createBy": "Admin",
      "updateBy": "Admin",
      "session": session.value,
      "schoolId": schoolId,
    };

    debugPrint("📤 Sending Video => $body");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    debugPrint("📥 Upload Video Response Code: ${response.statusCode}");
    debugPrint("📥 Upload Video Response Body: ${response.body}");

    if (response.statusCode == 200) {
      _showSuccess("Video Uploaded Successfully");

      // ✅ ADDED: also refresh gallery view videos tab after successful upload
      if (Get.isRegistered<Mapcategorycontroller>()) {
        Get.find<Mapcategorycontroller>().fetchMappedCategories();
      }

      videoUrlController.clear();
      selectedClassIds.clear();
      selectedSectionIds.clear();
    } else {
      debugPrint("❌ Response: ${response.body}");
      _showError("Failed to upload video");
    }
  }
}