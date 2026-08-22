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
import '../models/class_list_model.dart';
import '../models/notificationAll_model.dart';
import '../models/notification_model.dart';
import '../models/viewsectionmodel.dart';
import '../res/app_url.dart';
import 'fees_controller.dart' hide ListData;

class NotificationController extends GetxController {
  var title = ''.obs;
  var message = ''.obs;
  var section = ''.obs;

  final Rxn<stListData> selectedSection = Rxn<stListData>();
  var studentClass = ''.obs;
  var createDate = DateTime.now().obs;
  var updateDate = DateTime.now().obs;
  var notificationFile = ''.obs;
  var imageFile = Rx<File?>(null);
  var isLoading = false.obs;
  final notificationall = NotificationAllModel().obs;

  var sectionList = <stListData>[].obs;
  var classes = <ClassData>[].obs;
  var selectedClass = Rx<ClassData?>(null);
  var selectedClasses = <ClassData>[].obs;

  var token = "";
  var schoolId = "";
  var session = "";

  var schoolIdController = TextEditingController().obs;
  var sessionController = TextEditingController().obs;

  var notificationList = <ListData>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    session = await PrefManager().readValue(key: PrefConst.session) ?? "";

    await fetchSections();
    await fetchClasses();
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

  Future<void> fetchAllNotifications() async {
    try {
      isLoading(true);
      final String apiUrl =
          '${AppUrl.base_url}api/CommumicationApp/GetAllNotificationAsynsApp?schoolId=$schoolId&currentSession=$session';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        notificationall.value = NotificationAllModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchSections() async {
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
        final sectionModel = sectionmodel.fromJson(jsonResponse);

        sectionList.assignAll(sectionModel.listData ?? []);
        selectedSection.value = null;
        section.value = '';
      } else {
        Get.snackbar('Error', 'Failed to load sections');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sections');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSection(stListData? sectionData) {
    selectedSection.value = sectionData;
  }

  /// Fixed: compare by classId for correct equality
  void toggleClassSelection(ClassData classItem) {
    final exists =
    selectedClasses.any((c) => c.classId == classItem.classId);
    if (exists) {
      selectedClasses.removeWhere((c) => c.classId == classItem.classId);
    } else {
      selectedClasses.add(classItem);
    }
    studentClass.value = getSelectedClassIds();
  }

  String getSelectedClassIds() {
    return selectedClasses
        .map((classItem) => classItem.classId.toString())
        .join(',');
  }

  Future<void> fetchClasses() async {
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

        if (jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'] ?? [];

          // ❌ action filter hata diya — GetClassTeacher me action null aata hai
          classes.value = data.map((e) => ClassData.fromJson(e)).toList();

          if (classes.isNotEmpty) {
            selectedClass.value = classes.first;
          } else {
            selectedClass.value = null;
          }
        } else {
          classes.value = [];
          selectedClass.value = null;
        }
      } else {
        Get.snackbar(
          "Error",
          "Failed to fetch classes: ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("Error loading classes: $e");
    } finally {
      isLoading(false);
    }
  }

  void setSelectedClass(ClassData? classItem) {
    selectedClass.value = classItem;
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

  Future<void> registerNote() async {
    try {
      // ✅ FIX: selectedClass (single dropdown) check karo
      if (selectedClass.value == null) {
        ShortMessage.toast(title: "Please select at least one class.");
        return;
      }

      if (section.value.isEmpty || section.value == '0') {
        ShortMessage.toast(title: "Please provide valid Section.");
        return;
      }

      if (message.value.isEmpty || title.value.isEmpty) {
        ShortMessage.toast(title: "Please provide valid Title and Message.");
        return;
      }

      final uri =
      Uri.parse("${AppUrl.base_url}api/CommumicationApp/PostNotificationApp");
      var request = http.MultipartRequest('POST', uri);

      request.fields['Title'] = title.value;
      request.fields['Message'] = message.value;
      request.fields['SectionId'] = section.value.toString();
      request.fields['SchoolId'] = schoolId.toString();
      request.fields['Session'] = session.toString();
      request.fields['Action'] = "1";
      request.fields['CreateBy'] = "Admin";

      // ✅ FIX: selectedClass.value.classId use karo directly
      request.fields['ClassIDs'] =
          selectedClass.value!.classId.toString();

      if (imageFile.value != null) {
        var file = imageFile.value!;
        var stream = http.ByteStream(file.openRead().cast());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          'Notificationfile',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        debugPrint('Success: $responseData');
        ShortMessage.toast(title: "Notification Added Successfully");

        // ✅ Reset all fields
        title.value = '';
        message.value = '';
        section.value = '';
        selectedSection.value = null;
        selectedClass.value = null;       // ✅ single class reset
        selectedClasses.clear();
        studentClass.value = '';
        imageFile.value = null;
        notificationFile.value = '';

        await fetchAllNotifications();
        Get.back();
      } else {
        var responseBody = await response.stream.bytesToString();
        debugPrint('Error: ${response.statusCode}, Details: $responseBody');
        ShortMessage.toast(title: "Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Exception: $e');
      ShortMessage.toast(title: "An error occurred while adding the notification.");
    }
  }
}