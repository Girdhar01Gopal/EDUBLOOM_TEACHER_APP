import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/classmodel.dart'; // 🆕 ListDataa, ClassItem (Galaryvideo wale multi-select class model)
import '../models/sectionmodel.dart'; // 🆕 ListDatta (Galaryvideo wale multi-select section model)
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel (class teacher ke sections ke liye)
import '../models/notificationAll_model.dart';
import '../models/notification_model.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../res/app_url.dart';
import 'fees_controller.dart' hide ListData;
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 ClassTeacherFilterModel / ClassTeacherFilterData reuse ke liye

class NotificationController extends GetxController {
  var title = ''.obs;
  var message = ''.obs;

  var createDate = DateTime.now().obs;
  var updateDate = DateTime.now().obs;
  var notificationFile = ''.obs;
  var imageFile = Rx<File?>(null);
  var isLoading = false.obs;
  final notificationall = NotificationAllModel().obs;

  // 🆕 CHANGED: single select -> multi select (Galaryvideo/uploadVideo jaisa hi)
  var classList = <ListDataa>[].obs;
  var selectedClassIds = <int>[].obs;

  var sectionList = <ListDatta>[].obs;
  var selectedSectionIds = <int>[].obs;

  var token = "";
  var schoolId = "";
  var session = "";

  var schoolIdController = TextEditingController().obs;
  var sessionController = TextEditingController().obs;

  var notificationList = <ListData>[].obs;

  // 🆕 Role / Teacher-type detection (class & section fetch ke liye) — Galaryvideo jaisa hi
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    if (isStaffLogin.value) {
      // 🟢 STAFF — direct staff APIs
      fetchClasses();
      fetchSections();
    } else {
      // 🟡 TEACHER — pehle ClassTeacher filter check, phir uske hisaab se class/section
      await fetchClassTeacherFilter();
      fetchClasses();
      fetchSections();
    }

    await fetchAllNotifications();
  }

  void pickDate(BuildContext context, bool isCreateDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isCreateDate ? createDate.value : updateDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      if (isCreateDate) {
        createDate.value = pickedDate;
      } else {
        updateDate.value = pickedDate;
      }
    }
  }

  String getFormattedDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  /// Updated: accepts ImageSource (camera or gallery)
  Future<void> pickImage(Rx<File?> imageFileTarget,
      [ImageSource source = ImageSource.gallery]) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      imageFileTarget.value = File(pickedFile.path);
      notificationFile.value = pickedFile.path;
    }
  }

  // ✅ UPDATED API: TeacherGetAllNotificationAsynsApp
  Future<void> fetchAllNotifications() async {
    try {
      isLoading(true);

      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final String apiUrl =
          'https://playschool.edubloom.in/api/CommumicationApp/TeacherGetAllNotificationAsynsApp'
          '?schoolId=${Uri.encodeComponent(schoolId)}'
          '&currentSession=${Uri.encodeComponent(session)}'
          '&UserId=${Uri.encodeComponent(userId ?? '')}';

      final response = await http.get(Uri.parse(apiUrl));

      debugPrint('TeacherGetAllNotificationAsynsApp status: ${response.statusCode}');
      debugPrint('TeacherGetAllNotificationAsynsApp body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        notificationall.value = NotificationAllModel.fromJson(jsonResponse);
        debugPrint("📊 FETCHED NOTIFICATION COUNT -> ${notificationall.value.data?.length}");
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // 🆕 3-way class fetch: Staff -> existing API | Class Teacher -> ClassTeacher API
  // | Normal Teacher -> GetClassTeacher API | fallback -> existing (staff) API
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF
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

      // if (classList.isEmpty) {
      //   debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
      //   await _fetchClassesStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session)}'
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
        final jsonResponse = json.decode(response.body);
        final data = jsonResponse['data'] as List<dynamic>? ?? [];

        classList.value = data.map((e) => ListDataa.fromJson(e)).toList();
      } else {
        classList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetClassTeacher classes: $e");
      classList.value = [];
    } finally {
      isLoading(false);
    }

    // if (classList.isEmpty) {
    //   debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
    //   await _fetchClassesStaffApi();
    // }
  }

  // 🔁 Ye wahi ViewClass API hai — Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final classItem = ClassItem.fromJson(json.decode(response.body));

        classList.value = classItem.listData
            ?.where((e) => e.action == "1")
            .toList() ?? [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching classes: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🆕 3-way section fetch: Staff -> existing API | Class Teacher -> SectionTeacher API
  // | Normal Teacher -> getSectionTeacher API | fallback -> existing (staff) API
  Future<void> fetchSections() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchSectionsStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — SectionTeacher API
    if (isClassTeacherLogin.value) {
      try {
        isLoading(true);
        final userId = await PrefManager().readValue(key: PrefConst.Userid);

        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=${Uri.encodeComponent(schoolId)}'
              '&Session=${Uri.encodeComponent(session)}'
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
          final decoded = json.decode(response.body);
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
      } finally {
        isLoading(false);
      }

      // if (sectionList.isEmpty) {
      //   debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
      //   await _fetchSectionsStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — getSectionTeacher API
    try {
      isLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.getSectionTeacher}'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(session)}'
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
        final jsonResponse = json.decode(response.body);
        final list = (jsonResponse['data'] as List<dynamic>?) ?? [];
        sectionList.value = list.map((e) => ListDatta.fromJson(e)).toList();
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetSectionTeacher sections: $e");
      sectionList.value = [];
    } finally {
      isLoading(false);
    }

    // if (sectionList.isEmpty) {
    //   debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
    //   await _fetchSectionsStaffApi();
    // }
  }

  // 🔁 Ye wahi ViewSectionApp API hai — Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        sectionList.value = (json.decode(response.body)['listData'] as List)
            .map((e) => ListDatta.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
    } finally {
      isLoading(false);
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
            '&Session=${Uri.encodeComponent(session)}'
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
        final jsonResponse = json.decode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];

        // 🆕 Agar ClassTeacher API se class data mila, to matlab ye class teacher hai
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  void fetchNotifications() async {
    if (schoolId.isEmpty || session.isEmpty) {
      Get.snackbar("Error", "Please enter both School ID and Session");
      return;
    }

    try {
      isLoading(true);

      final url =
          '${AppUrl.base_url}api/Communcation/ViewNotification/$schoolId?session=$session';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        NotificationModel notificationModel =
        NotificationModel.fromJson(jsonData);
        notificationList.value = notificationModel.listData ?? [];
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading(false);
    }
  }


  // ─────────────────────────────────────────────────────────────
  Future<void> registerNote() async {
    if (selectedClassIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one class.");
      return;
    }

    if (selectedSectionIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one section.");
      return;
    }

    if (message.value.isEmpty || title.value.isEmpty) {
      ShortMessage.toast(title: "Please provide valid Title and Message.");
      return;
    }

    isLoading(true);

    int successCount = 0;
    int failCount = 0;

    try {

      final futures = <Future<bool>>[];
      for (final classId in selectedClassIds) {
        for (final sectionId in selectedSectionIds) {
          futures.add(
            _postSingleNotification(classId: classId, sectionId: sectionId),
          );
        }
      }

      final results = await Future.wait(futures);
      for (final ok in results) {
        if (ok) {
          successCount++;
        } else {
          failCount++;
        }
      }

      debugPrint(
          "📊 POST NOTIF MULTI-SUBMIT DONE -> success:$successCount fail:$failCount");

      if (successCount > 0 && failCount == 0) {
        ShortMessage.toast(
            title: successCount == 1
                ? "Notification Added Successfully"
                : "$successCount Notifications Added Successfully");
      } else if (successCount > 0 && failCount > 0) {
        ShortMessage.toast(
            title:
            "$successCount added, $failCount failed. Please check and retry.");
      } else {
        ShortMessage.toast(
            title: "Failed to add notification(s). Please try again.");
      }

      if (successCount > 0) {
        // ✅ Reset all fields only when at least one combination succeeded
        title.value = '';
        message.value = '';
        selectedClassIds.clear();
        selectedSectionIds.clear();
        imageFile.value = null;
        notificationFile.value = '';

        await fetchAllNotifications();
        Get.back();
      }
    } catch (e) {
      debugPrint('❌ POST NOTIF EXCEPTION -> $e');
      ShortMessage.toast(
          title: "An error occurred while adding the notification.");
    } finally {
      isLoading(false);
    }
  }


  Future<bool> _postSingleNotification({
    required int classId,
    required int sectionId,
  }) async {
    try {
      final uri = Uri.parse(
          "${AppUrl.base_url}api/CommumicationApp/PostNotificationApp");
      var request = http.MultipartRequest('POST', uri);

      request.fields['Title'] = title.value;
      request.fields['Message'] = message.value;
      request.fields['SchoolId'] = schoolId.toString();
      request.fields['Session'] = session.toString();
      request.fields['Action'] = "1";
      request.fields['CreateBy'] = "Admin";

      // Ek hi class aur ek hi section per request -> count hamesha 1 == 1,
      // isliye backend ka "count must be same" check kabhi fail nahi hoga.
      request.files.add(
        http.MultipartFile.fromString('ClassIDs', classId.toString()),
      );
      request.files.add(
        http.MultipartFile.fromString('SectionId', sectionId.toString()),
      );

      // ✅ IMAGE VERIFICATION — confirm file exists before attaching
      if (imageFile.value != null) {
        var file = imageFile.value!;
        final exists = await file.exists();
        final length = exists ? await file.length() : 0;

        debugPrint("🖼️ [Class:$classId Section:$sectionId] Image path: ${file.path}");
        debugPrint("🖼️ [Class:$classId Section:$sectionId] Exists: $exists | size: $length bytes");

        var stream = http.ByteStream(file.openRead().cast());
        var multipartFile = http.MultipartFile(
          'Notificationfile',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);

        debugPrint("🖼️ [Class:$classId Section:$sectionId] Attached 'Notificationfile' -> filename: ${multipartFile.filename}, length: ${multipartFile.length}");
      }

      debugPrint("📤 POST NOTIF -> Class:$classId Section:$sectionId");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("📥 [Class:$classId Section:$sectionId] Status: ${response.statusCode}");
      debugPrint("📥 [Class:$classId Section:$sectionId] Body: $responseBody");

      if (response.statusCode == 200) {
        debugPrint("✅ [Class:$classId Section:$sectionId] Success — check next 'TeacherGetAllNotificationAsynsApp' log for the saved notificationfile name to confirm image reached server.");
        return true;
      } else {
        debugPrint("❌ [Class:$classId Section:$sectionId] Failed with status ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [Class:$classId Section:$sectionId] Exception: $e');
      return false;
    }
  }
}