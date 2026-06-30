import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../infrastructures/utils/utils.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';
import '../models/vnote_model.dart';
import '../res/app_url.dart';


class NoteController extends GetxController {
  var token = "";
  var schoolId = "";
  var seassion = "";

  // Observable variables
  var imageFile = Rx<File?>(null);
  var remarks = ''.obs;
  var subject = 0.obs;
  var isLoading = false.obs;

  // Lists
  var listData = <Dataa>[].obs; // ViewNote data
  var sectionList = <ListDatta>[].obs;
  var subjectlist = <ListDaataa>[].obs;
  var listDataa = <ListDataa>[].obs;

  // Selected items
  var selectedClass = Rx<ListDataa?>(null);
  var selectedSection = Rx<ListDatta?>(null);
  var selectsubject = Rx<ListDaataa?>(null);

  // Model wrapper
  final subjectdata = SubjectModel().obs;

  @override
  Future<void> onInit() async {
    super.onInit();
   
    schoolId = await PrefManager().readValue(key: PrefConst.schollId);
    seassion = await PrefManager().readValue(key: PrefConst.session);

    await fetchClasses();
    await fetchSections();
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

  /// ---------------------- FETCH NOTES ----------------------
  Future<void> fetchVNotes() async {
    try {
      isLoading(true);
      final uri = Uri.parse(
        '${AppUrl.base_url}api/CommumicationApp/ViewNoteApp/$schoolId?session=$seassion',
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
      } else {
        // Get.snackbar("Error", "Failed to fetch data");
      }
    } catch (e) {
      debugPrint("Fetch Notes Error: $e");
    } finally {
      isLoading(false);
    }
  }

  /// ---------------------- REGISTER NOTE ----------------------
  Future<void> registerNote(int classId, int sectionId, int subjectId, String remarks) async {
    try {
      if (classId == 0 || sectionId == 0 || subjectId == 0) {
        ShortMessage.toast(title: "Please select valid Class, Section, and Subject.");
        return;
      }
      if(remarks.isEmpty) {
        ShortMessage.toast(title: "Please enter remarks for the note.");
        return;
      }

      final uri = Uri.parse("${AppUrl.base_url}api/CommumicationApp/PostNoteApp");
      var request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'Class': classId.toString(),
        'Section': sectionId.toString(),
        'Subject': subjectId.toString(),
        'Session': seassion.toString(),
        'SchoolId': schoolId.toString(),
        'Remarks': remarks,
        'CreateBy': "Admin",

        // ✅ FIX: Action null ja raha tha, ab always 1 jayega
        'Action': '1',
      });

      // ✅ optional safety: image null hai to crash avoid
      if (imageFile.value != null) {
        var file = imageFile.value!;
        var multipartFile = await http.MultipartFile.fromPath('file', file.path);
        request.files.add(multipartFile);
      }

     // request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print('✅ Success: $responseData');
        ShortMessage.toast(title: "Note Added Successfully");
        await fetchVNotes();
        Get.back();
      } else {
        var responseBody = await response.stream.bytesToString();
        print('❌ Error: ${response.statusCode}, $responseBody');
        ShortMessage.toast(title: "Failed to add note. (${response.statusCode})");
      }
    } catch (e) {
      print('⚠️ Exception: $e');
      ShortMessage.toast(title: "An unexpected error occurred.");
    }
  }


  /// ---------------------- FETCH SECTIONS ----------------------
  Future<void> fetchSections() async {
    String url = '${AppUrl.base_url}api/MasterApp/ViewSectionApp/$schoolId';
    try {
      isLoading(true);
      final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final sectionItem = Section.fromJson(jsonDecode(response.body));
        sectionList.value = sectionItem.listData ?? [];
        if (sectionList.isNotEmpty) {
          selectedSection.value = sectionList.first;
        }
      } else {
        Get.snackbar('Error', 'Failed to load sections');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load sections');
    } finally {
      isLoading(false);
    }
  }

  void setSelectedSection(ListDatta? sectionId) {
    selectedSection.value = sectionId;
  }

  /// ---------------------- FETCH CLASSES ----------------------
Future<void> fetchClasses() async {
  try {
    isLoading(true);
    final response = await http.get(
      Uri.parse('${AppUrl.base_url}api/MasterApp/ViewClass/$schoolId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final classItem = ClassItem.fromJson(jsonDecode(response.body));

      // Filter the listData to include only classes where action == "1"
      listDataa.value = classItem.listData
          ?.where((e) => e.action == "1")
          .toList() ?? [];

      // Set the first class as the selected class if available
      if (listDataa.isNotEmpty) {
        selectedClass.value = listDataa.first;
      } else {
        selectedClass.value = null;  // Optional: Set to null if no classes are found
      }
    } else {
      throw Exception('Failed to load classes');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    isLoading(false);
  }
}


  void setSelectedClass(ListDataa? studentClassId) {
    selectedClass.value = studentClassId;
  }

  /// ---------------------- FETCH SUBJECTS ----------------------
  Future<void> fetchsubjectdata() async {
    try {
      isLoading(true);
      final url = Uri.parse('${AppUrl.base_url}${AppUrl.view_subject}$schoolId');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final subjectWrapper = SubjectModel.fromJson(jsonDecode(response.body));
        subjectdata.value = subjectWrapper;
        subjectlist.value = subjectWrapper.listData ?? [];
        if (subjectlist.isNotEmpty) {
          selectsubject.value = subjectlist.first;
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } finally {
      isLoading(false);
    }
  }

  void setsubject(ListDaataa? subjectId) {
    selectsubject.value = subjectId;
  }
}
