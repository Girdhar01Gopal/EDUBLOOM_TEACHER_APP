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

  // 🆕 CHANGED: single select -> multi select (Notification jaisa hi)
  var classList = <ListDataa>[].obs;
  var selectedClassIds = <int>[].obs;

  var sectionList = <stListData>[].obs;
  var selectedSectionIds = <int>[].obs;

  var isLoading = false.obs;

  var token = "";
  var schoolId = "";

  final RxList<ListData> eventList = <ListData>[].obs;

  var schoolIdController = TextEditingController();
  var sessionController = TextEditingController();

  // 🆕 Role / Teacher-type detection (class & section fetch ke liye) — Notification jaisa hi
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

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

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role = ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
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

      if (classList.isEmpty) {
        debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
        await _fetchClassesStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
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

    if (classList.isEmpty) {
      debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
      await _fetchClassesStaffApi();
    }
  }

  // 🔁 Ye wahi ViewClass API hai — Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      debugPrint('ViewClass status: ${response.statusCode}');

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

          selectedSectionIds.clear();
        } else {
          sectionList.value = [];
        }
      } catch (e) {
        debugPrint("⚠️ Error fetching SectionTeacher sections: $e");
        sectionList.value = [];
      } finally {
        isLoading(false);
      }

      if (sectionList.isEmpty) {
        debugPrint("↩️ SectionTeacher sections empty — falling back to staff API");
        await _fetchSectionsStaffApi();
      }
      return;
    }

    // 3️⃣ NORMAL TEACHER — getSectionTeacher API
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
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('GetSectionTeacher status: ${response.statusCode}');
      debugPrint('GetSectionTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final sectionModel = sectionmodel.fromJson(jsonResponse);

        sectionList.value = sectionModel.listData ?? [];
        selectedSectionIds.clear();
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetSectionTeacher sections: $e");
      sectionList.value = [];
    } finally {
      isLoading(false);
    }

    if (sectionList.isEmpty) {
      debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
      await _fetchSectionsStaffApi();
    }
  }

  // 🔁 Ye wahi ViewSectionApp API hai — Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      debugPrint('ViewSectionApp status: ${response.statusCode}');

      if (response.statusCode == 200) {
        sectionList.value = (json.decode(response.body)['listData'] as List)
            .map((e) => stListData.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
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

  // ─────────────────────────────────────────────────────────────
  // 🆕 FIXED: pehle har class×section combo ke liye ALAG POST request jaati thi,
  // jisse backend ka "EventName already exists" uniqueness check baar-baar
  // trigger hota tha (1st request 200, baaki 409 "Event name already exists").
  // Ab admin ke working code jaisa hi — SAB selected classes aur sections ek
  // hi single POST request me multiple 'Class' / 'Section' fields ke through
  // bhejte hain, taaki backend ek hi call me sab combinations insert kar le
  // aur duplicate-name conflict na aaye.
  Future<void> registerEvent() async {
    if (selectedClassIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one class.");
      return;
    }

    if (selectedSectionIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one section.");
      return;
    }

    if (eventName.value.trim().isEmpty) {
      ShortMessage.toast(title: "Please enter a valid Event Name.");
      return;
    }

    if (eventPlace.value.trim().isEmpty) {
      ShortMessage.toast(title: "Please enter a valid Event Place.");
      return;
    }

    if (description.value.trim().isEmpty) {
      ShortMessage.toast(title: "Please enter a valid Description.");
      return;
    }

    if (imageFile.value == null) {
      ShortMessage.toast(title: "Please select an image.");
      return;
    }

    isLoading(true);

    try {
      final cb =
      createdBy.value.trim().isNotEmpty ? createdBy.value.trim() : "Admin";

      final uri =
      Uri.parse("${AppUrl.base_url}api/CommumicationApp/PostEventApp");
      final request = http.MultipartRequest('POST', uri);

      // ── Scalar (single value) fields ──
      request.fields['EventName'] = eventName.value.trim();
      request.fields['EventDate'] = getApiDate();
      request.fields['EventPlace'] = eventPlace.value.trim();
      request.fields['Descripation'] = description.value.trim();
      request.fields['Session'] = session.value;
      request.fields['SchoolId'] = schoolId;
      request.fields['schoolId'] = schoolId; // backend case-insensitive hai, safety ke liye dono
      request.fields['CreateBy'] = cb;
      request.fields['Action'] = '1';
      request.fields['action'] = '1';

      // ── Array fields: Class[] aur Section[] ──
      // Same field-name multiple baar files list mein daal rahe hain,
      // taaki backend isko List<int> ki tarah bind kare, ek hi request mein.
      for (final classId in selectedClassIds) {
        request.files.add(
          http.MultipartFile.fromString('Class', classId.toString()),
        );
      }

      for (final sectionId in selectedSectionIds) {
        request.files.add(
          http.MultipartFile.fromString('Section', sectionId.toString()),
        );
      }

      // ✅ IMAGE VERIFICATION — confirm file exists before attaching
      final f = imageFile.value!;
      final exists = await f.exists();
      final length = exists ? await f.length() : 0;

      debugPrint("🖼️ Image path: ${f.path}");
      debugPrint("🖼️ Exists: $exists | size: $length bytes");

      final multipartFile = await http.MultipartFile.fromPath('file', f.path);
      request.files.add(multipartFile);

      debugPrint(
          "📤 POST EVENT -> Classes:$selectedClassIds Sections:$selectedSectionIds");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("📥 Status: ${response.statusCode}");
      debugPrint("📥 Body: $responseBody");

      if (response.statusCode == 200) {
        debugPrint('✅ Success');
        ShortMessage.toast(title: "Events Added Successfully");

        // Reset form
        eventName.value = '';
        description.value = '';
        eventPlace.value = '';
        imageFile.value = null;
        file.value = '';
        selectedClassIds.clear();
        selectedSectionIds.clear();

        await fetchVEvents();
        Get.back();
      } else {
        debugPrint('❌ Error (${response.statusCode})');

        // 🆕 backend ka asli error title dikhate hain (jaise "Event name
        // already exists, try a different name") generic message ki jagah.
        String errorMsg = "Failed to add event.";
        try {
          final decoded = jsonDecode(responseBody);
          if (decoded is Map && decoded['title'] != null) {
            errorMsg = decoded['title'].toString();
          }
        } catch (_) {}

        ShortMessage.toast(title: errorMsg);
      }
    } catch (e) {
      debugPrint('⚠️ POST EVENT EXCEPTION -> $e');
      ShortMessage.toast(
          title: "An error occurred while adding the event.");
    } finally {
      isLoading(false);
    }
  }

  // ✅ UPDATED API: TeacherViewEventApp
  // Ab UserId bhi query param me bhej rahe hai jaise naye endpoint me required hai.
  Future<void> fetchVEvents() async {
    try {
      isLoading(true);

      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final uri = Uri.parse(
        'https://playschool.edubloom.in/api/CommumicationApp/TeacherViewEventApp/$schoolId',
      ).replace(queryParameters: {
        'session': session.value,
        'UserId': userId ?? '',
      });

      final response = await http.get(uri);

      debugPrint('TeacherViewEventApp status: ${response.statusCode}');
      debugPrint('TeacherViewEventApp body: ${response.body}');

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
        debugPrint("📊 FETCHED EVENT COUNT -> ${eventList.length}");
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