import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/all_fee_model.dart';
import '../models/class_list_model.dart';
import '../models/classmodel.dart';
import '../models/new model teacher section attendance.dart'; // SectionForAttendanceModel
import '../models/pre school student teach stu filter api model.dart';
import '../res/app_url.dart';
import 'student_controller.dart'
    show ClassTeacherFilterModel, ClassTeacherFilterData;

/// Which students the type dropdown shows.
enum FeeTypeFilter { all, preschool, daycare }

/// Payment-status chip; `none` shows every status.
enum FeeStatusFilter { none, fullyPaid, due, pending }

/// Section with its real id (from the API) and display name.
class SectionOption {
  final int id;
  final String name;
  const SectionOption(this.id, this.name);
}

class AllFeesController extends GetxController {
  String schoolId = '';
  String session = '';
  String token = '';
  String userId = '';

  // ROLE / TEACHER-TYPE DETECTION (same as Discount controller)
  final isStaffLogin = false.obs; // true => "schoolstaff" role
  final isClassTeacherLogin = false.obs; // true => ClassTeacher API returned data
  final classTeacherList = <ClassTeacherFilterData>[].obs;

  final classList = <ClassData>[].obs;
  // null means "All classes".
  final selectedClassId = RxnInt();

  // Sections with real ids; null id means "All sections".
  final sectionList = <SectionOption>[].obs;
  final selectedSectionId = RxnInt();
  // Name of the selected section (used for the client-side safety filter).
  final selectedSection = RxnString();

  final searchQuery = ''.obs;

  final allStudents = <AllFeeStudent>[].obs;
  final typeFilter = FeeTypeFilter.all.obs;
  final statusFilter = FeeStatusFilter.none.obs;

  final isLoading = false.obs;

  @override
  void onInit() async {
    super.onInit();
    schoolId =
        (await PrefManager().readValue(key: PrefConst.schollId))?.toString() ??
            '';
    session =
        (await PrefManager().readValue(key: PrefConst.session))?.toString() ??
            '';
    userId =
        (await PrefManager().readValue(key: PrefConst.Userid))?.toString() ??
            '';

    // Staff vs Teacher role check — PrefConst.RName == "schoolstaff"
    final role = ((await PrefManager().readValue(key: PrefConst.RName)) ?? '')
        .toString()
        .trim()
        .toLowerCase();
    isStaffLogin.value = role == 'schoolstaff';
    debugPrint("👤 Role read: '$role' | isStaffLogin: ${isStaffLogin.value}");

    if (schoolId.trim().isEmpty) {
      Get.snackbar('Error', 'SchoolId not found');
      return;
    }

    isLoading(true);
    // An empty session makes Getallfee redirect to the login page.
    if (session.trim().isEmpty || session == 'null') {
      try {
        session = await _fetchCurrentSession();
      } catch (e) {
        Get.snackbar('Error', 'Session API error: $e');
      }
    }

    // Teacher: first find the assigned classes (ClassTeacher API).
    if (!isStaffLogin.value) {
      await fetchClassTeacherFilter();
    }

    try {
      classList.assignAll(await _fetchClasses());
    } catch (e) {
      Get.snackbar('Error', 'Class API error: $e');
    }
    try {
      sectionList.assignAll(await _fetchSections());
    } catch (e) {
      Get.snackbar('Error', 'Section API error: $e');
    }

    // Pehli class aur pehla section by default select
    final firstClass = classList.firstWhereOrNull((c) => c.classId != null);
    if (firstClass != null) {
      selectedClassId.value = firstClass.classId;
    }
    if (sectionList.isNotEmpty) {
      selectedSectionId.value = sectionList.first.id;
      selectedSection.value = sectionList.first.name;
    }

    await fetchAllFees();
  }

  // Logged-in teacher ke assigned classes fetch karo
  Future<void> fetchClassTeacherFilter() async {
    try {
      if (userId.trim().isEmpty) {
        debugPrint('⚠️ userId empty — skipping class teacher filter fetch');
        return;
      }

      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ClassTeacher'
            '?schoolId=$schoolId&Session=$session&userId=$userId',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('ClassTeacher status: ${response.statusCode}');
      debugPrint('ClassTeacher body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final model = ClassTeacherFilterModel.fromJson(decoded);

        classTeacherList.value = model.data ?? [];
        isClassTeacherLogin.value = classTeacherList.isNotEmpty;
      }
    } catch (e) {
      debugPrint('Error loading ClassTeacher filter: $e');
    }
  }

  int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

  /// Removes empty names and duplicate ids.
  List<SectionOption> _uniqueSections(Iterable<SectionOption> items) {
    final seen = <int>{};
    return items.where((s) => s.name.isNotEmpty && seen.add(s.id)).toList();
  }

  // =========================
  // SECTIONS (3-way)
  // =========================
  // 1️⃣ STAFF -> ViewSectionApp API | 2️⃣ CLASS TEACHER -> SectionTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetSectionTeacher API
  Future<List<SectionOption>> _fetchSections() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      return _fetchSectionsStaffApi();
    }

    // 2️⃣ CLASS TEACHER — SectionTeacher API
    if (isClassTeacherLogin.value) {
      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/SectionTeacher'
            '?schoolId=$schoolId&Session=$session&userId=$userId',
      );

      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('SectionTeacher status: ${res.statusCode}');
      debugPrint('SectionTeacher body: ${res.body}');

      if (res.statusCode != 200) {
        throw 'Section API failed: ${res.statusCode}';
      }
      final model = SectionForAttendanceModel.fromJson(
          _decode(res.body, 'Section API'));
      return _uniqueSections((model.data ?? []).map((e) =>
          SectionOption(_toInt(e.sectionId), (e.section ?? '').toString())));
    }

    // 3️⃣ NORMAL TEACHER — GetSectionTeacher API
    final url = Uri.parse(
      '${AppUrl.base_url}api/TeacherApp/GetSectionTeacher'
          '?schoolId=$schoolId&Session=$session&userId=$userId',
    );

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200) {
      throw 'Section API failed: ${res.statusCode}';
    }
    final json = _decode(res.body, 'Section API');
    final raw = json is Map ? (json['data'] ?? json['listData']) : null;
    if (raw is! List) return [];
    return _uniqueSections(raw.whereType<Map>().map((e) =>
        SectionOption(_toInt(e['sectionId']), (e['section'] ?? '').toString())));
  }

  Future<List<SectionOption>> _fetchSectionsStaffApi() async {
    final res = await http.get(
      Uri.parse('${AppUrl.base_url}${AppUrl.view_section}$schoolId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw 'Section API failed: ${res.statusCode}';
    }
    final json = _decode(res.body, 'Section API');
    final list = json is Map ? json['listData'] : null;
    if (list is! List) return [];
    return _uniqueSections(list
        .whereType<Map>()
        .where((e) => e['action']?.toString() == '1')
        .map((e) => SectionOption(
        _toInt(e['sectionId']), (e['section'] ?? '').toString())));
  }

  Future<String> _fetchCurrentSession() async {
    final res = await http.get(
      Uri.parse('${AppUrl.base_url}${AppUrl.view_session}$schoolId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw 'Session API failed: ${res.statusCode}';
    }
    final json = _decode(res.body, 'Session API');
    return (json['currentSession']?['currentSession'] ?? '').toString();
  }

  // =========================
  // CLASSES (3-way)
  // =========================
  // 1️⃣ STAFF -> ViewClass API | 2️⃣ CLASS TEACHER -> ClassTeacher API
  // | 3️⃣ NORMAL TEACHER -> GetClassTeacher API
  Future<List<ClassData>> _fetchClasses() async {
    // 1️⃣ STAFF
    if (isStaffLogin.value) {
      return _fetchClassesStaffApi();
    }

    // 2️⃣ CLASS TEACHER — assigned classes ClassTeacher API se hi
    if (isClassTeacherLogin.value && classTeacherList.isNotEmpty) {
      return classTeacherList.map((e) {
        return ClassData.fromJson({
          'classId': e.classId,
          'class': e.className,
          'className': e.className,
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
    }

    // 3️⃣ NORMAL TEACHER — GetClassTeacher API
    if (session.trim().isEmpty) {
      throw 'Session not found';
    }

    final url = Uri.parse(
      '${AppUrl.base_url}api/TeacherApp/GetClassTeacher'
          '?schoolId=$schoolId&Session=$session&userId=$userId',
    );

    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200) {
      throw 'Class API failed: ${res.statusCode}';
    }
    // GetClassTeacher me action null aata hai, isliye filter nahi lagayenge
    final parsed = ClassListModel.fromJson(_decode(res.body, 'Class API'));
    return parsed.listData;
  }

  Future<List<ClassData>> _fetchClassesStaffApi() async {
    final res = await http.get(
      Uri.parse('${AppUrl.base_url}${AppUrl.viewClass}$schoolId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 200) {
      throw 'Class API failed: ${res.statusCode}';
    }
    final json = _decode(res.body, 'Class API');
    final list = json is Map ? json['listData'] : null;
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .where((e) => e['action']?.toString() == '1')
        .map((e) => ClassData.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Fails with a readable message when the server sends HTML (e.g. a login
  /// redirect page) instead of JSON.
  dynamic _decode(String body, String api, [Uri? url]) {
    final trimmed = body.trimLeft();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      throw '$api returned an invalid response'
          '${url != null ? ' for $url' : ''}';
    }
    return jsonDecode(trimmed);
  }

  /// classId and sectionId are both dynamic. sectionId 0 = all sections.
  Future<List<AllFeeStudent>> _fetchForClass(int classId, int sectionId) async {
    final url = Uri.parse('${AppUrl.base_url}${AppUrl.getAllFee}'
        '${schoolId.trim()}/${session.trim()}/$classId/$sectionId');
    debugPrint('All Fee API URL: $url');
    final res =
    await http.get(url, headers: {'Content-Type': 'application/json'});
    debugPrint('All Fee status: ${res.statusCode}');
    debugPrint(
        'All Fee body: ${res.body.length > 300 ? res.body.substring(0, 300) : res.body}');
    if (res.statusCode != 200) {
      throw 'All Fee API failed: ${res.statusCode}';
    }
    if (res.body.trim().isEmpty) return [];
    return AllFeeStudent.listFromJson(_decode(res.body, 'All Fee API', url));
  }

  /// The API returns pre-school students for one class per call. The selected
  /// section id is sent in the URL. For "All classes" every class is fetched
  /// in parallel and merged; the daycare list is identical in every response,
  /// so it is taken once.
  Future<void> fetchAllFees() async {
    try {
      isLoading(true);
      final classId = selectedClassId.value;
      final sectionId = selectedSectionId.value ?? 0;
      final ids = classId != null
          ? [classId]
          : classList.map((c) => c.classId).whereType<int>().toList();

      if (ids.isEmpty) {
        // classId 0 returns placeholder pre-school rows; keep daycare only.
        final list = await _fetchForClass(0, 0);
        allStudents.assignAll(
            list.where((s) => s.category == FeeCategory.daycare));
        return;
      }

      final results =
      await Future.wait(ids.map((id) => _fetchForClass(id, sectionId)));
      allStudents.assignAll([
        for (final list in results)
          ...list.where((s) => s.category == FeeCategory.preschool),
        ...results.first.where((s) => s.category == FeeCategory.daycare),
      ]);
    } catch (e) {
      allStudents.clear();
      Get.snackbar('Error', 'All Fee API error: $e');
    } finally {
      isLoading(false);
    }
  }

  void setClass(int? classId) {
    if (classId == selectedClassId.value) return;
    selectedClassId.value = classId;
    fetchAllFees();
  }

  void setSection(int? sectionId) {
    if (sectionId == selectedSectionId.value) return;
    selectedSectionId.value = sectionId;
    selectedSection.value = sectionId == null
        ? null
        : sectionList.firstWhereOrNull((s) => s.id == sectionId)?.name;
    fetchAllFees();
  }

  void setSearch(String query) => searchQuery.value = query;

  void setTypeFilter(FeeTypeFilter val) => typeFilter.value = val;

  /// Tapping the active chip again clears it.
  void toggleStatusFilter(FeeStatusFilter val) =>
      statusFilter.value = statusFilter.value == val ? FeeStatusFilter.none : val;

  /// Students matching the type and section dropdowns (totals are based on
  /// this). The section filter applies to pre-school rows only; daycare rows
  /// have no section. Name match is a safety net in case the server returns
  /// other sections too.
  List<AllFeeStudent> get typeStudents {
    final section = selectedSection.value;
    bool sectionMatch(AllFeeStudent s) =>
        section == null ||
            s.category == FeeCategory.daycare ||
            s.section.trim().toLowerCase() == section.trim().toLowerCase();

    switch (typeFilter.value) {
      case FeeTypeFilter.preschool:
        return allStudents
            .where((s) => s.category == FeeCategory.preschool && sectionMatch(s))
            .toList();
      case FeeTypeFilter.daycare:
        return allStudents
            .where((s) => s.category == FeeCategory.daycare)
            .toList();
      case FeeTypeFilter.all:
        return allStudents.where(sectionMatch).toList();
    }
  }

  /// Students matching the dropdowns, the status chip and the name search.
  List<AllFeeStudent> get filteredStudents {
    final query = searchQuery.value.trim().toLowerCase();
    final list = query.isEmpty
        ? typeStudents
        : typeStudents
        .where((s) => s.studentName.toLowerCase().contains(query))
        .toList();
    switch (statusFilter.value) {
      case FeeStatusFilter.fullyPaid:
        return list.where((s) => s.status == FeeStatus.fullyPaid).toList();
      case FeeStatusFilter.due:
        return list.where((s) => s.status == FeeStatus.due).toList();
      case FeeStatusFilter.pending:
        return list.where((s) => s.status == FeeStatus.pending).toList();
      case FeeStatusFilter.none:
        return list;
    }
  }

  double get totalCollection =>
      typeStudents.fold(0.0, (sum, s) => sum + s.paidFee);

  double get totalDue => typeStudents.fold(0.0, (sum, s) => sum + s.due);

  /// Amount owed by students who have not paid anything yet.
  double get totalPending => typeStudents
      .where((s) => s.status == FeeStatus.pending)
      .fold(0.0, (sum, s) => sum + s.due);

  int countFor(FeeStatus status) =>
      typeStudents.where((s) => s.status == status).length;
}