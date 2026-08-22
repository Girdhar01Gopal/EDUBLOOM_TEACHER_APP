import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/session_model.dart' as session_model;
import '../models/classmodel.dart';

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/parent_Search enquiry model.dart';
import '../models/parent_View enquiry model.dart';
import '../res/app_url.dart';

class EnquiryController extends GetxController {
  RxList<SearchEnquiryModel> searchEnquiryList = <SearchEnquiryModel>[].obs;
  RxBool isSearchLoading = false.obs;
  RxString searchError = ''.obs;

  Rx<DateTime> startDate =
      DateTime.now().subtract(const Duration(days: 7)).obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  RxList<ViewEnquiryModel> viewEnquiryList = <ViewEnquiryModel>[].obs;
  RxBool isViewLoading = false.obs;
  RxString viewError = ''.obs;

  // Jis id ka reply post ho raha hai uska loading track karne ke liye
  RxSet<int> replyingIds = <int>{}.obs;
  RxString replyError = ''.obs;

  var session = ''.obs;

  String token = "";
  String schoolId = "";

  // ── Classes (Teacher-specific) ─────────────────────────────────────
  final listDataa = <ListDataa>[].obs;
  final selectedClass = Rx<ListDataa?>(null);

  @override
  void onInit() async {
    super.onInit();
    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    await fetchCurrentSession();
    await fetchClasses();
    await Future.wait([
      fetchSearchEnquiry(),
      fetchViewEnquiry(),
    ]);
  }

  /// ViewSessionApp se current session utha ke `session` me set karte hain
  Future<void> fetchCurrentSession() async {
    final String apiUrl =
        '${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['currentSession'] != null) {
          session.value = jsonData['currentSession']['currentSession'] ?? '';
        } else if (jsonData['listData'] != null) {
          final List<dynamic> data = jsonData['listData'] as List<dynamic>;
          final list =
          data.map((e) => session_model.sListDdata.fromJson(e)).toList();
          if (list.isNotEmpty) {
            session.value = list.first.session ?? '';
          }
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load session: $e");
    }
  }

  // ── Fetch Classes (Teacher-specific) ────────────────────────────────
  Future<void> fetchClasses() async {
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
      debugPrint("Error fetching classes: $e");
    }
  }

  void setSelectedClass(ListDataa? c) => selectedClass.value = c;

  // ---------- Date pickers ----------

  Future<void> pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) startDate.value = picked;
  }

  Future<void> pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) endDate.value = picked;
  }

  /// UI + API dono ke liye same format: dd-MM-yyyy
  String fmtUi(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d-$m-$y';
  }

  // ---------- API calls (GET) ----------

  /// GET api/EnquiryApp/SearchEnquiry/{fromDate}/{toDate}/{session}
  Future<void> fetchSearchEnquiry() async {
    try {
      isSearchLoading.value = true;
      searchError.value = '';

      final from = fmtUi(startDate.value);
      final to = fmtUi(endDate.value);
      final url = Uri.parse(
        '${AppUrl.base_url}api/EnquiryApp/SearchEnquiry/$from/$to/${session.value}/$schoolId',
      );
      final response = await http.get(
        url,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        searchEnquiryList.assignAll(searchEnquiryModelFromJson(data));
      } else {
        searchError.value = 'SearchEnquiry API fail: ${response.statusCode}';
      }
    } catch (e) {
      searchError.value = e.toString();
    } finally {
      isSearchLoading.value = false;
    }
  }

  /// GET api/EnquiryApp/ViewEnquiry1/{session}/{schoolId}
  Future<void> fetchViewEnquiry() async {
    try {
      isViewLoading.value = true;
      viewError.value = '';

      final url = Uri.parse(
        '${AppUrl.base_url}api/EnquiryApp/ViewEnquiry1/${session.value}/$schoolId',
      );
      final response = await http.get(
        url,
        headers: {
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        viewEnquiryList.assignAll(viewEnquiryModelFromJson(data));
      } else {
        viewError.value = 'ViewEnquiry1 API fail: ${response.statusCode}';
      }
    } catch (e) {
      viewError.value = e.toString();
    } finally {
      isViewLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchSearchEnquiry(), fetchViewEnquiry()]);
  }

  // ---------- Reply (POST) ----------
  //
  // Actual API: POST /api/EnquiryApp/PostEnquiry
  // Body me original enquiry ki poori details + naya reply text bhejte hain,
  // taaki backend record match karke update kar sake.
  Future<bool> sendReply({
    required int enquiryId,
    required String replyText,
    String? parentId,
    String? studentName,
    int? classId,
    int? sectionId,
    String? title,
    String? type,
    String? subject,
    String? teacherReg,
    String? createBy,
    String? originalMessage,
    int? replyId,
  }) async {
    if (replyText.trim().isEmpty) {
      replyError.value = 'Reply khaali nahi ho sakta';
      return false;
    }
    try {
      replyingIds.add(enquiryId);
      replyError.value = '';

      final url = Uri.parse(
        '${AppUrl.base_url}api/EnquiryApp/PostEnquiry',
      );

      final body = {
        'id': enquiryId,
        'parentId': parentId ?? '',
        'studentName': studentName ?? '',
        'classId': classId ?? 0,
        'sectionId': sectionId ?? 0,
        'title': title ?? '',
        'message': originalMessage ?? '',
        'type': type ?? '',
        'session': session.value,
        'schoolId': schoolId,
        'createBy': createBy ?? '',
        'replyId': replyId ?? 0,
        'subject': subject ?? '',
        'teacherReg': teacherReg ?? '',
        'reply': replyText.trim(),
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final bool apiSuccess = jsonData['isSuccess'] == true;

        if (apiSuccess) {
          // Reply successful -> list refresh, status apne aap green ho jayega
          await refreshAll();
          return true;
        } else {
          replyError.value =
              jsonData['messages']?.toString() ?? 'Reply submit fail hua';
          return false;
        }
      } else {
        replyError.value = 'Reply post fail: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      replyError.value = e.toString();
      return false;
    } finally {
      replyingIds.remove(enquiryId);
    }
  }

  bool isReplying(int id) => replyingIds.contains(id);
}