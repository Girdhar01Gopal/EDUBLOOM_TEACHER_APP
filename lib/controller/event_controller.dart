import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';


import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/classmodel.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/viewsectionmodel.dart';
import '../models/vevent_model.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse

class EventController extends GetxController {
  var eventId = 0.obs;
  var eventName = ''.obs;
  var eventClass = ''.obs;
  var eventDate = DateTime.now().obs;
  var description = ''.obs;
  var eventPlace = ''.obs;
  var createdBy = ''.obs;

  var file = ''.obs;
  var imageFile = Rx<File?>(null);

  var session = "".obs;

  var classes = <ClassItem>[].obs;
  var listDataa = <ListDataa>[].obs;
  var selectedClass = Rx<ListDataa?>(null);

  void setSelectedClass(ListDataa? val) {
    selectedClass.value = val;
  }

  var sectionList = <stListData>[].obs;
  var selectedSection = Rxn<stListData>();
  var section = ''.obs;

  void setSelectedSection(stListData? val) {
    selectedSection.value = val;
    section.value = val?.section?.toString() ?? '';
  }

  var isLoading = false.obs;

  var token = "";
  var schoolId = "";

  final RxList<ListData> eventList = <ListData>[].obs;

  var schoolIdController = TextEditingController();
  var sessionController = TextEditingController();

  // 🆕 Class Teacher filter
  var classTeacherList = <ClassTeacherFilterData>[].obs;
  var isClassTeacherLogin = false.obs;

  @override
  void onInit() async {
    super.onInit();

    session.value = await PrefManager().readValue(key: PrefConst.session);
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);

    try {
      final storedName = await PrefManager().readValue(key: PrefConst.Name);
      if (storedName != null && storedName.toString().trim().isNotEmpty) {
        createdBy.value = storedName.toString().trim();
      }
    } catch (_) {}

    await fetchClassTeacherFilter(); // 🆕 pehle
    await fetchClasses();
    await fetchSections();
    await fetchVEvents();
  }

  String getDisplayDate() => DateFormat('dd-MM-yyyy').format(eventDate.value);

  String getApiDate() => DateFormat('yyyy-MM-dd').format(eventDate.value);

  void setEventDate(DateTime date) {
    eventDate.value = date;
  }

  void pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: eventDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != eventDate.value) {
      setEventDate(pickedDate);
    }
  }

  // 🆕 Logged-in teacher ke assigned classes fetch karo
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
          'accept': '/',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('ClassTeacher status: ${response.statusCode}');
      debugPrint('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final model = ClassTeacherFilterModel.fromJson(jsonResponse);

        classTeacherList.value = model.data ?? [];
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  Future<void> fetchSections() async {
    // 🆕 Class teacher login → SectionTeacher API
    if (isClassTeacherLogin.value) {
      try {
        isLoading(true);

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
            'accept': '/',
            'Content-Type': 'application/json',
          },
        );

        debugPrint('SectionTeacher status: ${response.statusCode}');
        debugPrint('SectionTeacher body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = json.decode(response.body);
          final model = SectionForAttendanceModel.fromJson(decoded);

          sectionList.value = (model.data ?? []).map((e) {
            return stListData.fromJson({
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
      return;
    }

    // 🔁 Normal teacher — existing
    try {
      isLoading(true);

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
          'accept': '/',
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

  Future<void> fetchClasses() async {
    // 🆕 Class teacher login → ClassTeacher API data se hi banao
    if (isClassTeacherLogin.value) {
      listDataa.value = classTeacherList.map((e) {
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

      if (listDataa.isNotEmpty) {
        selectedClass.value = listDataa.first;
      } else {
        selectedClass.value = null;
      }
      return;
    }

    // 🔁 Normal teacher — existing
    try {
      isLoading(true);
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
          'accept': '/',
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
          listDataa.value = data.map((e) => ListDataa.fromJson(e)).toList();

          if (listDataa.isNotEmpty) {
            selectedClass.value = listDataa.first;
          } else {
            selectedClass.value = null;
          }
        } else {
          listDataa.value = [];
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

  Future<void> pickImage(Rx<File?> imageFile) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
      file.value = pickedFile.path;
    }
  }

  Future<void> registerEvent(
      String eventName,
      int sectionId,
      String eventDateApi,
      String eventPlace,
      String description,
      String eventClass,
      ) async {
    try {
      if (imageFile.value == null) {
        ShortMessage.toast(title: "Please select an image.");
        return;
      }

      if (sectionId == 0) {
        ShortMessage.toast(title: "Please select a valid Section.");
        return;
      }

      if (eventClass.isEmpty) {
        ShortMessage.toast(title: "Please select a valid Class.");
        return;
      }
      if (eventName.trim().isEmpty) {
        ShortMessage.toast(title: "Please enter a valid Event Name.");
        return;
      }
      if (eventPlace.trim().isEmpty) {
        ShortMessage.toast(title: "Please enter a valid Event Place.");
        return;
      }
      if (description.trim().isEmpty) {
        ShortMessage.toast(title: "Please enter a valid Description.");
        return;
      }

      final cb = createdBy.value.trim().isNotEmpty ? createdBy.value.trim() : "Admin";

      final url =
      Uri.parse("${AppUrl.base_url}api/CommumicationApp/PostEventApp");
      final request = http.MultipartRequest('POST', url);

      request.fields['EventName'] = eventName.trim();
      request.fields['Section'] = sectionId.toString();
      request.fields['EventDate'] = eventDateApi;
      request.fields['EventPlace'] = eventPlace.trim();
      request.fields['Descripation'] = description.trim();
      request.fields['Session'] = session.value;
      request.fields['schoolId'] = schoolId;
      request.fields['CreateBy'] = cb;
      request.fields['Class'] = eventClass.toString();
      request.fields['action'] = '1';
      request.fields['Action'] = '1';

      final f = imageFile.value!;
      final multipartFile = await http.MultipartFile.fromPath('file', f.path);
      request.files.add(multipartFile);

      final response = await request.send();

      if (response.statusCode == 200) {
        ShortMessage.toast(title: "Event Added Successfully");
        imageFile.value = null;
        file.value = '';
        this.eventName.value = '';
        this.description.value = '';
        this.eventPlace.value = '';
        selectedClass.value = null;
        selectedSection.value = null;

        await fetchVEvents();
        Get.back();
      } else {
        ShortMessage.toast(title: "Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('registerEvent Error: $e');
      ShortMessage.toast(title: "Something went wrong");
    }
  }

  Future<void> fetchVEvents() async {
    try {
      isLoading(true);

      final uri = Uri.parse(
        '${AppUrl.base_url}api/CommumicationApp/ViewEventApp/$schoolId',
      ).replace(queryParameters: {
        'session': session.value,
      });

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final vEventResponse = VEventResponse.fromJson(jsonResponse);

        final events = (vEventResponse.listData ?? []).toList();

        events.sort((a, b) {
          DateTime da;
          DateTime db;

          try {
            da = DateTime.parse(a.createDate ?? "");
          } catch (_) {
            da = DateTime.fromMillisecondsSinceEpoch(0);
          }

          try {
            db = DateTime.parse(b.createDate ?? "");
          } catch (_) {
            db = DateTime.fromMillisecondsSinceEpoch(0);
          }

          return db.compareTo(da);
        });

        eventList.assignAll(events);
      } else {
        debugPrint("fetchVEvents failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("fetchVEvents error: $e");
    } finally {
      isLoading(false);
    }
  }
}
