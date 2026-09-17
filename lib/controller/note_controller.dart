import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/classmodel.dart';
import '../models/pre school student teach stu filter api model.dart';
import '../models/viewsectionmodel.dart';
import '../models/subject_model.dart';
import '../models/vnote_model.dart';
import '../models/new model teacher section attendance.dart'; // 🆕 SectionForAttendanceModel
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData; // 🆕 reuse

class NoteController extends GetxController {
  var token = "";
  var schoolId = "";
  var seassion = "";

  // Observable variables
  var imageFile = Rx<File?>(null);
  var remarks = ''.obs;
  var subject = 0.obs;


  var isLoading = false.obs;
  var isClassLoading = false.obs;
  var isSectionLoading = false.obs;
  var isSubjectLoading = false.obs;
  var isNotesLoading = false.obs;

  // Lists
  var listData = <Dataa>[].obs; // ViewNote data
  var sectionList = <stListData>[].obs;
  var subjectlist = <ListDaataa>[].obs;
  var listDataa = <ListDataa>[].obs;

  // ✅ CHANGED: single select -> multi select (Notification jaisa hi)
  var selectedClassIds = <int>[].obs;
  var selectedSectionIds = <int>[].obs;
  var selectedSubjectIds = <int>[].obs;

  // Model wrapper
  final subjectdata = SubjectModel().obs;

  // 🆕 Role / Teacher-type detection (class & section & subject dropdown ke liye)
  var isStaffLogin = false.obs; // true => "schoolstaff" role
  var isClassTeacherLogin = false.obs; // true => ClassTeacher API se data mila
  var classTeacherList = <ClassTeacherFilterData>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    seassion = await PrefManager().readValue(key: PrefConst.session);

    // 🆕 Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role =
    ((await PrefManager().readValue(key: PrefConst.RName)) ?? "")
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == "schoolstaff";
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    // 🆕 FIX: classes & sections ko ab properly `await`/`Future.wait` kiya
    // jaa raha hai (pehle yeh bina await ke fire-and-forget the, jisse
    // teeno network calls ek saath chal rahi thi aur shared isLoading
    // flag ko random order mein true/false kar rahi thi).
    if (isStaffLogin.value) {
      // 🟢 STAFF — direct staff APIs, parallel-safe (alag flags hain ab)
      await Future.wait([
        fetchClasses(),
        fetchSections(),
      ]);
    } else {
      // 🟡 TEACHER — pehle ClassTeacher filter check, phir uske hisaab se class/section
      await fetchClassTeacherFilter();
      await Future.wait([
        fetchClasses(),
        fetchSections(),
      ]);
    }

    await fetchsubjectdata();
    await fetchVNotes();
  }

  /// ---------------------- IMAGE PICKER ----------------------
  Future<void> pickImage(Rx<File?> imageFile) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile.value = File(pickedFile.path);
    }
  }

  /// ---------------------- MULTI-SELECT TOGGLES ----------------------
  void toggleClassSelection(int classId) {
    if (selectedClassIds.contains(classId)) {
      selectedClassIds.remove(classId);
    } else {
      selectedClassIds.add(classId);
    }
  }

  void toggleSectionSelection(int sectionId) {
    if (selectedSectionIds.contains(sectionId)) {
      selectedSectionIds.remove(sectionId);
    } else {
      selectedSectionIds.add(sectionId);
    }
  }

  void toggleSubjectSelection(int subjectId) {
    if (selectedSubjectIds.contains(subjectId)) {
      selectedSubjectIds.remove(subjectId);
    } else {
      selectedSubjectIds.add(subjectId);
    }
  }

  /// ---------------------- FETCH NOTES ----------------------
  // ✅ UPDATED API: TeacherViewNoteApp
  Future<void> fetchVNotes() async {
    try {
      isLoading(true);
      isNotesLoading(true);

      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final uri = Uri.parse(
        'https://playschool.edubloom.in/api/CommumicationApp/TeacherViewNoteApp/$schoolId'
            '?session=${Uri.encodeComponent(seassion)}'
            '&UserId=${Uri.encodeComponent(userId ?? '')}',
      );

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(uri, headers: headers);
      debugPrint("[fetchVNotes] API URL: $uri");
      debugPrint("[fetchVNotes] status: ${response.statusCode}");
      debugPrint("[fetchVNotes] body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final vNoteModel = VNoteModel.fromJson(jsonResponse as Map<String, dynamic>);

        final notes = (vNoteModel.listData ?? []).toList();

        // ✅ SORT: latest first (top)
        notes.sort((a, b) {
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

          return db.compareTo(da); // descending
        });

        listData.assignAll(notes);

        // 🆕 ADDED: exact fetched count print — Notification jaisa hi debug
        debugPrint("📊 FETCHED NOTES COUNT -> ${listData.length}");
      } else {
        // Get.snackbar("Error", "Failed to fetch data");
      }
    } catch (e) {
      debugPrint("Fetch Notes Error: $e");
    } finally {
      isLoading(false);
      isNotesLoading(false);
    }
  }

  Future<void> registerNote(String remarksText) async {
    if (selectedClassIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one class.");
      return;
    }

    if (selectedSectionIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one section.");
      return;
    }

    if (selectedSubjectIds.isEmpty) {
      ShortMessage.toast(title: "Please select at least one subject.");
      return;
    }

    if (remarksText.isEmpty) {
      ShortMessage.toast(title: "Please enter remarks for the note.");
      return;
    }

    isLoading(true);

    int successCount = 0;
    int failCount = 0;

    try {
      // ✅ Saari class-section-subject combinations ek saath (parallel)
      // bheji jaati hain, taaki total time sabse slowest single request
      // jitna hi lage.
      final futures = <Future<bool>>[];
      for (final classId in selectedClassIds) {
        for (final sectionId in selectedSectionIds) {
          for (final subjectId in selectedSubjectIds) {
            futures.add(
              _postSingleNote(
                classId: classId,
                sectionId: sectionId,
                subjectId: subjectId,
                remarksText: remarksText,
              ),
            );
          }
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
          "📊 POST NOTE MULTI-SUBMIT DONE -> success:$successCount fail:$failCount");

      if (successCount > 0 && failCount == 0) {
        ShortMessage.toast(
            title: successCount == 1
                ? "Note Added Successfully"
                : "$successCount Notes Added Successfully");
      } else if (successCount > 0 && failCount > 0) {
        ShortMessage.toast(
            title:
            "$successCount added, $failCount failed. Please check and retry.");
      } else {
        ShortMessage.toast(
            title: "Failed to add note(s). Please try again.");
      }

      if (successCount > 0) {
        // ✅ Reset selections after at least one success
        selectedClassIds.clear();
        selectedSectionIds.clear();
        selectedSubjectIds.clear();
        remarks.value = '';
        imageFile.value = null;

        await fetchVNotes();
        Get.back();
      }
    } finally {
      isLoading(false);
    }
  }

  /// Helper: posts ONE note for one class+section+subject combination.
  /// Returns true on success (status 200), false otherwise.
  /// Also verifies & prints whether the image actually reached the server.
  Future<bool> _postSingleNote({
    required int classId,
    required int sectionId,
    required int subjectId,
    required String remarksText,
  }) async {
    try {
      final uri = Uri.parse("${AppUrl.base_url}api/CommumicationApp/PostNoteApp");
      var request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'Class': classId.toString(),
        'Section': sectionId.toString(),
        'Subject': subjectId.toString(),
        'Session': seassion.toString(),
        'SchoolId': schoolId.toString(),
        'Remarks': remarksText,
        'CreateBy': "Admin",

        // ✅ FIX: Action null ja raha tha, ab always 1 jayega
        'Action': '1',
      });

      // ✅ IMAGE VERIFICATION — confirm file exists & is being attached
      // before it's sent, so we can be sure whether it actually reaches
      // the backend or not.
      if (imageFile.value != null) {
        var file = imageFile.value!;
        final exists = await file.exists();
        final length = exists ? await file.length() : 0;

        debugPrint("🖼️ [C:$classId S:$sectionId Sub:$subjectId] Image path: ${file.path}");
        debugPrint("🖼️ [C:$classId S:$sectionId Sub:$subjectId] Exists: $exists | size: $length bytes");

        var multipartFile = await http.MultipartFile.fromPath('file', file.path);
        request.files.add(multipartFile);

        debugPrint("🖼️ [C:$classId S:$sectionId Sub:$subjectId] Attached 'file' -> filename: ${multipartFile.filename}, length: ${multipartFile.length}");
      } else {
        debugPrint("🖼️ [C:$classId S:$sectionId Sub:$subjectId] No image selected for this note.");
      }

      debugPrint("📤 POST NOTE -> Class:$classId Section:$sectionId Subject:$subjectId");

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint("📥 [C:$classId S:$sectionId Sub:$subjectId] Status: ${response.statusCode}");
      debugPrint("📥 [C:$classId S:$sectionId Sub:$subjectId] Body: $responseBody");

      if (response.statusCode == 200) {
        debugPrint("✅ [C:$classId S:$sectionId Sub:$subjectId] Success — check next 'fetchVNotes' log for the saved file name to confirm image reached server.");
        return true;
      } else {
        debugPrint("❌ [C:$classId S:$sectionId Sub:$subjectId] Failed with status ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint('⚠️ [C:$classId S:$sectionId Sub:$subjectId] Exception: $e');
      return false;
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
            '&Session=${Uri.encodeComponent(seassion)}'
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
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint("Error loading ClassTeacher filter: $e");
    }
  }

  /// ---------------------- FETCH CLASSES (3-way) ----------------------
  // 1️⃣ STAFF -> ViewClass API | 2️⃣ CLASS TEACHER -> ClassTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetClassTeacher API | fallback -> staff API
  Future<void> fetchClasses() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      await _fetchClassesStaffApi();
      return;
    }

    // 2️⃣ CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      try {
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
      } catch (e) {
        debugPrint("⚠️ Error mapping ClassTeacher classes: $e");
        listDataa.value = [];
      }

      // if (listDataa.isEmpty) {
      //   debugPrint("↩️ ClassTeacher classes empty — falling back to staff API");
      //   await _fetchClassesStaffApi();
      // }
      return;
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    try {
      isLoading(true);
      isClassLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(seassion)}'
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
          listDataa.value = data.map((e) => ListDataa.fromJson(e)).toList();
        } else {
          listDataa.value = [];
        }
      } else {
        listDataa.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetClassTeacher classes: $e");
      listDataa.value = [];
    } finally {
      isLoading(false);
      isClassLoading(false);
    }

    // if (listDataa.isEmpty) {
    //   debugPrint("↩️ GetClassTeacher classes empty — falling back to staff API");
    //   await _fetchClassesStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchClassesStaffApi() async {
    try {
      isLoading(true);
      isClassLoading(true);
      final url = Uri.parse("${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final classItem = ClassItem.fromJson(jsonDecode(response.body));

        listDataa.value = classItem.listData
            ?.where((e) => e.action == "1")
            .toList() ?? [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching classes: $e");
    } finally {
      isLoading(false);
      isClassLoading(false);
    }
  }

  /// ---------------------- FETCH SECTIONS (3-way) ----------------------
  // 1️⃣ STAFF -> ViewSectionApp API | 2️⃣ CLASS TEACHER -> SectionTeacher API
  // | 3️⃣ NORMAL TEACHER -> getSectionTeacher API | fallback -> staff API
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
        isSectionLoading(true);

        final userId = await PrefManager().readValue(key: PrefConst.Userid);

        final url = Uri.parse(
          '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
              '?schoolId=${Uri.encodeComponent(schoolId)}'
              '&Session=${Uri.encodeComponent(seassion)}'
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
        } else {
          sectionList.value = [];
        }
      } catch (e) {
        debugPrint("⚠️ Error fetching SectionTeacher sections: $e");
        sectionList.value = [];
      } finally {
        isLoading(false);
        isSectionLoading(false);
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
      isSectionLoading(true);

      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.getSectionTeacher}'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(seassion)}'
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
        final sectionItem = sectionmodel.fromJson(jsonDecode(response.body));
        sectionList.value = sectionItem.listData ?? [];
      } else {
        sectionList.value = [];
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching GetSectionTeacher sections: $e");
      sectionList.value = [];
    } finally {
      isLoading(false);
      isSectionLoading(false);
    }

    // if (sectionList.isEmpty) {
    //   debugPrint("↩️ GetSectionTeacher sections empty — falling back to staff API");
    //   await _fetchSectionsStaffApi();
    // }
  }

  // 🔁 Staff ke liye main path, Teacher ke liye fallback.
  Future<void> _fetchSectionsStaffApi() async {
    try {
      isLoading(true);
      isSectionLoading(true);
      final url =
      Uri.parse("${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        sectionList.value = (jsonDecode(response.body)['listData'] as List)
            .map((e) => stListData.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Error fetching sections (staff): $e");
    } finally {
      isLoading(false);
      isSectionLoading(false);
    }
  }

  /// ---------------------- FETCH SUBJECTS (2-way: teacher -> staff fallback) ----------------------
  Future<void> fetchsubjectdata() async {
    // 1️⃣ STAFF — direct staff API
    if (isStaffLogin.value) {
      await _fetchSubjectsStaffApi();
      return;
    }

    // 2️⃣ TEACHER — existing teacher subject API
    try {
      isLoading(true);
      isSubjectLoading(true);
      final userId = await PrefManager().readValue(key: PrefConst.Userid);

      final url = Uri.parse(
        '${AppUrl.base_url}${AppUrl.get_subject_teacher}'
            '?schoolId=${Uri.encodeComponent(schoolId)}'
            '&Session=${Uri.encodeComponent(seassion)}'
            '&userId=${Uri.encodeComponent(userId ?? '')}',
      );
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      debugPrint('GetSubjectTeacher status: ${response.statusCode}');
      debugPrint('GetSubjectTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);


        List<dynamic>? rawList;
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['listData'] != null) {
            rawList = jsonResponse['listData'] as List<dynamic>;
          } else if (jsonResponse['data'] != null) {
            rawList = jsonResponse['data'] as List<dynamic>;
          }
        }

        if (rawList != null) {
          subjectlist.value =
              rawList.map((e) => ListDaataa.fromJson(e)).toList();
        } else {
          subjectlist.value = [];
        }
      } else {
        subjectlist.value = [];
      }
    } catch (e) {
      debugPrint('Error loading teacher subjects: $e');
      subjectlist.value = [];
    } finally {
      isLoading(false);
      isSubjectLoading(false);
    }

    // 🆕 FALLBACK: teacher API empty aaya to staff wali API try karo
    // if (subjectlist.isEmpty) {
    //   debugPrint("↩️ Teacher subjects empty — falling back to staff API");
    //   await _fetchSubjectsStaffApi();
    // }
  }

  // 🆕 Staff subject API (admin project se liya gaya URL pattern)
  // final url = '${AppUrl.base_url}${AppUrl.view_subject}$schoolId';
  Future<void> _fetchSubjectsStaffApi() async {
    try {
      isLoading(true);
      isSubjectLoading(true);
      final url = '${AppUrl.base_url}${AppUrl.view_subject}$schoolId';

      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      debugPrint('ViewSubject (staff) status: ${response.statusCode}');
      debugPrint('ViewSubject (staff) body: ${response.body}');

      if (response.statusCode == 200) {
        final subjectWrapper = SubjectModel.fromJson(jsonDecode(response.body));
        subjectdata.value = subjectWrapper;
        subjectlist.value = subjectWrapper.listData ?? [];
        debugPrint("📊 Staff subjectlist length -> ${subjectlist.length}");
      }
    } catch (e) {
      debugPrint('Error loading staff subjects: $e');
    } finally {
      isLoading(false);
      isSubjectLoading(false);
    }
  }
}