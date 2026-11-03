import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/designation model.dart';
import '../models/teacher list model.dart';
import '../res/app_url.dart';
import '../models/session_model.dart' as session_model;
import '../utils/app_snackbar.dart';

class TeacherAddController extends GetxController {
  static const _jsonHeaders = {'Content-Type': 'application/json'};

  final formKey = GlobalKey<FormState>();
  final dialogFormKey = GlobalKey<FormState>();

  final editingId = RxnInt();
  bool get isEditMode => editingId.value != null;

  final teacherNameC = TextEditingController();
  final teacherIdC = TextEditingController(text: _autoTeacherId());

  final fatherHusbandNameC = TextEditingController();
  final dobC = TextEditingController();
  final emailC = TextEditingController();
  final mobileC = TextEditingController();

  final qualificationC = TextEditingController();
  final lastOrgC = TextEditingController();
  final totalExpC = TextEditingController();
  final salaryC = TextEditingController();

  final cityC = TextEditingController();
  final joiningDateC = TextEditingController();
  final addressC = TextEditingController();
  final specializationC = TextEditingController();
  final stateC = TextEditingController();

  final bankNameC = TextEditingController();
  final accountNoC = TextEditingController();
  final ifscC = TextEditingController();

  final bloodGroup = RxnString();
  final gender = RxnString();
  final caste = RxnString();
  final designation = RxnString();

  final bloodGroups = const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final genders = const ['Male', 'Female', 'Other'];
  final castes = const ['General', 'OBC', 'SC', 'ST', 'Other'];

  final isDesignationLoading = false.obs;
  final designationList = <DesignationModel>[].obs;

  List<String> get designationNames => designationList
      .map((e) => e.designation.trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  final userPic = Rxn<PlatformFile>();
  final idProofPhoto = Rxn<PlatformFile>();
  final resumePhoto = Rxn<PlatformFile>();
  final callLetterPhoto = Rxn<PlatformFile>();

  final isSubmitting = false.obs;

  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  final isTeacherLoading = false.obs;
  final teacherSearchC = TextEditingController();

  final teachers = <TeacherModel>[].obs;
  final filteredTeachers = <TeacherModel>[].obs;

  String schoolId = "";

  // Raw exception / API text kabhi nahi dikhta — sirf friendly line.
  void _showError(Object? error, {int? statusCode}) => AppSnackbar.error(
      AppSnackbar.friendlyMessage(error, statusCode: statusCode));

  @override
  void onInit() async {
    super.onInit();

    teacherSearchC.addListener(applyTeacherFilter);
    teacherNameC.addListener(() => _autoCapitalizeFirstLetter(teacherNameC));
    fatherHusbandNameC.addListener(() => _autoCapitalizeFirstLetter(fatherHusbandNameC));

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    if (schoolId.trim().isEmpty) {
      AppSnackbar.error('School information not found. Please login again.');
      return;
    }

    await fetchSessions();
    await fetchDesignations();
    await fetchTeachers();
  }

  void _autoCapitalizeFirstLetter(TextEditingController c) {
    final text = c.text;
    if (text.isEmpty) return;
    final first = text[0];
    final capFirst = first.toUpperCase();
    if (first == capFirst) return;
    final newText = capFirst + text.substring(1);
    c.value = c.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  Future<void> fetchSessions() async {
    try {
      final res = await http.get(
        Uri.parse('${AppUrl.base_url}api/MasterApp/ViewSessionApp/$schoolId'),
        headers: _jsonHeaders,
      );

      if (res.statusCode != 200) {
        _showError(null, statusCode: res.statusCode);
        return;
      }

      final jsonData = jsonDecode(res.body);
      sessionList.clear();
      final current = jsonData['currentSession'];
      if (current != null) {
        final cs = session_model.sListDdata(
          sessionId: current['currentSessionId'],
          session: current['currentSession'],
          action: current['action'],
          schoolId: current['schoolId'],
        );
        sessionList.add(cs);
        selectedSession.value = cs;
      } else {
        selectedSession.value = null;
      }
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> fetchDesignations() async {
    try {
      isDesignationLoading(true);
      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ViewDesignationApp/$schoolId',
      );
      final res = await http.get(url, headers: _jsonHeaders);
      if (res.statusCode == 200) {
        final parsed = DesignationResponse.fromJson(jsonDecode(res.body));
        designationList.assignAll(parsed.listData);
        if (designation.value != null && !designationNames.contains(designation.value)) {
          designation.value = null;
        }
      } else {
        _showError(null, statusCode: res.statusCode);
      }
    } catch (e) {
      _showError(e);
    } finally {
      isDesignationLoading(false);
    }
  }

  Future<void> fetchTeachers() async {
    final session = selectedSession.value?.session;
    if (session == null || session.trim().isEmpty) return;

    try {
      isTeacherLoading(true);
      final uri = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/GetAllTeachersAsyncApp'
            '?schoolId=$schoolId&currentSession=$session',
      );
      final res = await http.get(uri, headers: _jsonHeaders);

      if (res.statusCode == 200) {
        final parsed = TeacherListResponse.fromJson(jsonDecode(res.body));
        if (parsed.isSuccess == true) {
          teachers.assignAll(parsed.data);
          applyTeacherFilter();
        } else {
          teachers.clear();
          filteredTeachers.clear();
          AppSnackbar.error((parsed.messages ?? "Fetch failed").toString(), title: 'Failed');
        }
      } else {
        _showError(null, statusCode: res.statusCode);
      }
    } catch (e) {
      _showError(e);
    } finally {
      isTeacherLoading(false);
    }
  }

  void applyTeacherFilter() {
    final q = teacherSearchC.text.trim().toLowerCase();

    List<TeacherModel> result;
    if (q.isEmpty) {
      result = List<TeacherModel>.from(teachers);
    } else {
      result = teachers.where((t) {
        final id = (t.teacherReg ?? "").toLowerCase();
        final name = (t.name ?? "").toLowerCase();
        final mobile = (t.mobileNo ?? "").toLowerCase();
        final father = (t.fhname ?? "").toLowerCase();
        return id.contains(q) || name.contains(q) || mobile.contains(q) || father.contains(q);
      }).toList();
    }

    // Latest created teacher sabse upar (createDate descending)
    result.sort((a, b) {
      final da = DateTime.tryParse(a.createDate ?? '') ?? DateTime(1970);
      final db = DateTime.tryParse(b.createDate ?? '') ?? DateTime(1970);
      final c = db.compareTo(da);
      return c != 0 ? c : (b.id ?? 0).compareTo(a.id ?? 0);
    });

    filteredTeachers.assignAll(result);
  }

  void onTeacherEdit(TeacherModel row) {
    fillTeacherForDialogEdit(row);
  }

  void fillTeacherForDialogEdit(TeacherModel teacher) {
    editingId.value = teacher.id ?? 0;
    teacherNameC.text = teacher.name ?? '';
    teacherIdC.text = teacher.teacherReg ?? _autoTeacherId();
    fatherHusbandNameC.text = teacher.fhname ?? '';
    dobC.text = teacher.dob != null && teacher.dob!.isNotEmpty ? formatDate(teacher.dob) : '';
    emailC.text = teacher.emailid ?? '';
    mobileC.text = teacher.mobileNo ?? '';
    qualificationC.text = teacher.qualification ?? '';
    lastOrgC.text = teacher.lastOrganization ?? '';
    totalExpC.text = teacher.totalExperience ?? '';
    salaryC.text = teacher.salary ?? '';
    cityC.text = teacher.city ?? '';
    joiningDateC.text = teacher.dateofJoining != null && teacher.dateofJoining!.isNotEmpty
        ? formatDate(teacher.dateofJoining)
        : '';
    addressC.text = teacher.address ?? '';
    specializationC.text = teacher.specialization ?? '';
    stateC.text = teacher.state ?? '';
    bankNameC.text = teacher.bankName ?? '';
    accountNoC.text = teacher.accountNo ?? '';
    ifscC.text = teacher.ifsccode ?? '';

    bloodGroup.value = _normalizeDropdownValue(teacher.bloodGroup, bloodGroups);
    gender.value = _normalizeDropdownValue(teacher.gender, genders);
    caste.value = _normalizeDropdownValue(teacher.caste, castes);
    designation.value = _normalizeDropdownValue(teacher.designation, designationNames);

    userPic.value = null;
    idProofPhoto.value = null;
    resumePhoto.value = null;
    callLetterPhoto.value = null;
  }

  String? _normalizeDropdownValue(String? value, List<String> options) {
    if (value == null || value.trim().isEmpty) return null;
    for (final item in options) {
      if (item.trim().toLowerCase() == value.trim().toLowerCase()) return item;
    }
    return null;
  }

  /// ── Navigate to TeacherDetailScreen ──────────────────────────────────────
  void onTeacherView(TeacherModel row) {
    final id = row.id;
    if (id == null || id == 0) {
      AppSnackbar.error('Invalid Teacher ID');
      return;
    }
    Get.toNamed(
      RouteName.teacherdetailview,
      arguments: {
        'teacherId': id,
        'schoolId': schoolId,
        'currentSession': selectedSession.value?.session ?? '',
      },
    );
  }

  void onTeacherApprove(TeacherModel row) {
    AppSnackbar.success("Approved/Active: ${row.teacherReg ?? ""}", title: 'Status');
  }

  /// ── Active / Inactive toggle ──────────────────────────────────────────────
  final RxnInt statusLoadingId = RxnInt();

  Future<void> toggleTeacherStatus(TeacherModel row) async {
    final id = row.id;
    if (id == 0) {
      AppSnackbar.error('Invalid Teacher ID');
      return;
    }

    statusLoadingId.value = id;
    try {
      final uri = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/TeachearActiveandInactive'
            '?SchoolId=$schoolId&id=$id',
      );

      final res = await http.post(uri, headers: _jsonHeaders);

      if (res.statusCode == 200) {
        AppSnackbar.success(
          row.isActive ? "Teacher marked Inactive" : "Teacher marked Active",
        );
        await fetchTeachers();
      } else {
        _showError(null, statusCode: res.statusCode);
      }
    } catch (e) {
      _showError(e);
    } finally {
      statusLoadingId.value = null;
    }
  }

  String formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return "-";
    try {
      final d = DateTime.parse(iso);
      return "${d.day.toString().padLeft(2, '0')}-${_m(d.month)}-${d.year}";
    } catch (_) {
      return iso;
    }
  }

  String _m(int m) {
    const mm = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    if (m < 1 || m > 12) return "NA";
    return mm[m - 1];
  }

  Future<void> pickDate({
    required TextEditingController controller,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    DateTime init = initialDate ?? now;

    if (controller.text.trim().isNotEmpty) {
      try {
        final parts = controller.text.trim().split('-');
        if (parts.length == 3) {
          init = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: Get.context!,
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime(now.year + 2),
      initialDate: init,
    );

    if (picked != null) {
      controller.text =
      '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
    }
  }

  // ── File / Image Picker ───────────────────────────────────────────────────

  Future<void> pickFile(Rxn<PlatformFile> target) async {
    final context = Get.context;
    if (context == null) return;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.teal),
              title: const Text('Gallery '),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFromGallery(target);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orange),
              title: const Text('Camera '),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFromCamera(target);
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file, color: Colors.blue),
              title: const Text('File choose from (PDF/DOC)'),
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFromFiles(target);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery(Rxn<PlatformFile> target) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        target.value = result.files.first;
      }
    } catch (_) {
      AppSnackbar.error('Gallery se file pick failed');
    }
  }

  Future<void> _pickFromCamera(Rxn<PlatformFile> target) async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        target.value = PlatformFile(
          name: photo.name,
          path: photo.path,
          size: await File(photo.path).length(),
        );
      }
    } catch (_) {
      AppSnackbar.error('Camera se photo lena failed');
    }
  }

  Future<void> _pickFromFiles(Rxn<PlatformFile> target) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: false,
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.isNotEmpty) {
        target.value = result.files.first;
      }
    } catch (_) {
      AppSnackbar.error('File pick failed');
    }
  }

  void clearFile(Rxn<PlatformFile> target) => target.value = null;

  // ── Validators ────────────────────────────────────────────────────────────

  String? requiredValidator(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  String? emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'E-Mail is required';
    if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
    return null;
  }

  String? mobileValidator(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Mobile No is required';
    if (!RegExp(r'^\d{10}$').hasMatch(s)) return 'Enter 10 digit mobile number';
    return null;
  }

  String? numberOptionalValidator(String? v, String label) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null;
    if (double.tryParse(s) == null) return 'Enter valid $label';
    return null;
  }

  /// Dropdowns ka required-check (pehli missing field ka snackbar dikhata hai).
  bool _dropdownsValid() {
    final checks = <String, String?>{
      'Blood Group': bloodGroup.value,
      'Gender': gender.value,
      'Caste': caste.value,
      'Designation': designation.value,
    };
    for (final e in checks.entries) {
      if (e.value == null) {
        AppSnackbar.error('${e.key} is required');
        return false;
      }
    }
    return true;
  }

  Future<void> submit({int? idForUpdate}) async {
    if (!_dropdownsValid()) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    await _saveTeacher(idToSend: idForUpdate ?? editingId.value ?? 0, closeDialogOnSuccess: false);
  }

  Future<void> updateTeacherFromDialog() async {
    if (editingId.value == null || editingId.value == 0) {
      AppSnackbar.error('Teacher Id missing');
      return;
    }
    if (!_dropdownsValid()) return;
    if (!(dialogFormKey.currentState?.validate() ?? false)) return;
    await _saveTeacher(idToSend: editingId.value!, closeDialogOnSuccess: true);
  }

  Future<void> _saveTeacher({
    required int idToSend,
    required bool closeDialogOnSuccess,
  }) async {
    isSubmitting.value = true;
    try {
      final schoolIdLocal = schoolId.trim();
      if (schoolIdLocal.isEmpty) {
        AppSnackbar.error('School information not found. Please login again.');
        return;
      }

      final token = await PrefManager().readValue(key: PrefConst.token) ?? "";
      final nameParts = _splitName(teacherNameC.text.trim());
      final tdId = _getTdIdFromSelectedDesignation(designation.value);

      final uri = Uri.parse('https://playschool.edubloom.in/api/TeacherApp/AddUpdateTeacher2App/');
      final req = http.MultipartRequest('POST', uri);
      req.followRedirects = false;
      req.maxRedirects = 0;
      req.headers['Accept'] = 'application/json';
      req.headers['Cache-Control'] = 'no-cache';
      if (token.trim().isNotEmpty) req.headers['Authorization'] = 'Bearer ${token.trim()}';

      req.fields.addAll({
        'Id': idToSend.toString(),
        'UserId': "0",
        'SchoolId': schoolIdLocal,
        'RoleId': "0",
        'FirstName': nameParts.$1,
        'LastName': nameParts.$2,
        'UserEmail': emailC.text.trim(),
        'MobileNumber': mobileC.text.trim(),
        'IsActive': 'true',
        'RegistrationNo': teacherIdC.text.trim(),
        'AadharCardNo': totalExpC.text.trim(),
        'AadharNo': totalExpC.text.trim(),
        'AadhaarNo': totalExpC.text.trim(),
        'Qualification': qualificationC.text.trim(),
        'Salary': salaryC.text.trim(),
        'Specialization': specializationC.text.trim(),
        'TdId': tdId.toString(),
        'SpouseName': fatherHusbandNameC.text.trim(),
        'Caste': caste.value!,
        'CreatedBy': "Admin",
        'BloodGroup': bloodGroup.value!,
        'Gender': gender.value!,
        'LastOrganization': lastOrgC.text.trim(),
        'TotalExperience': totalExpC.text.trim(),
        'BankName': bankNameC.text.trim(),
        'AccountNo': accountNoC.text.trim(),
        'Ifsccode': ifscC.text.trim(),
        'Address': addressC.text.trim(),
        'City': cityC.text.trim(),
        'State': stateC.text.trim(),
      });

      final dobIso = _toIsoDateTimeOrEmpty(dobC.text.trim());
      if (dobIso.isNotEmpty) req.fields['Dob'] = dobIso;

      final dojIso = _toIsoDateTimeOrEmpty(joiningDateC.text.trim());
      if (dojIso.isNotEmpty) req.fields['DateofJoining'] = dojIso;

      await _attachFileIfPicked(req, 'UserPic', userPic.value);
      await _attachFileIfPicked(req, 'IdProof', idProofPhoto.value);
      await _attachFileIfPicked(req, 'Resume', resumePhoto.value);
      await _attachFileIfPicked(req, 'CallLetter', callLetterPhoto.value);

      final resp = await req.send();
      final status = resp.statusCode;

      // Redirect aaya — location / URL user ko nahi dikhana.
      if (status == 301 || status == 302 || status == 307 || status == 308) {
        _showError(null, statusCode: status);
        return;
      }

      final body = await resp.stream.bytesToString();
      Map<String, dynamic>? decoded;
      try {
        final tmp = jsonDecode(body);
        if (tmp is Map<String, dynamic>) decoded = tmp;
      } catch (_) {}

      final apiMessage = decoded?['messages']?.toString() ??
          decoded?['message']?.toString() ??
          decoded?['Message']?.toString();
      final hasApiMessage = apiMessage?.isNotEmpty == true;
      final apiSuccess = decoded?['isSuccess'] == true || decoded?['success'] == true;

      if ((status == 200 || status == 201) && (apiSuccess || decoded == null)) {
        if (closeDialogOnSuccess && (Get.isDialogOpen ?? false)) Get.back();
        AppSnackbar.success(
            idToSend == 0 ? 'Teacher added successfully' : 'Teacher updated successfully');
        editingId.value = null;
        await fetchTeachers();
        resetForm();
        return;
      }

      // API ne khud bola save nahi hua — message sanitize hoke dikhega
      // (lamba / technical hua to generic line).
      if (status == 200) {
        AppSnackbar.error(hasApiMessage ? apiMessage! : 'Save failed', title: 'Failed');
        return;
      }

      AppSnackbar.error(hasApiMessage
          ? apiMessage!
          : AppSnackbar.friendlyMessage(null, statusCode: status));
    } catch (e) {
      _showError(e);
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _attachFileIfPicked(
      http.MultipartRequest req, String fieldName, PlatformFile? file) async {
    if (file == null) return;
    final path = file.path;
    if (path == null || path.trim().isEmpty) return;
    final f = File(path);
    if (!await f.exists()) return;
    req.files.add(await http.MultipartFile.fromPath(
      fieldName, path,
      filename: file.name.isNotEmpty ? file.name : p.basename(path),
    ));
  }

  String _toIsoDateTimeOrEmpty(String input) {
    if (input.trim().isEmpty) return '';
    try {
      final d = input.split(' ')[0].split('-');
      if (d.length != 3) return '';
      return DateTime(int.parse(d[2]), int.parse(d[1]), int.parse(d[0])).toIso8601String();
    } catch (_) {
      return '';
    }
  }

  (String, String) _splitName(String fullName) {
    final clean = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return ('', '');
    final parts = clean.split(' ');
    if (parts.length == 1) return (parts[0], '');
    return (parts.first, parts.sublist(1).join(' '));
  }

  int _getTdIdFromSelectedDesignation(String? selectedName) {
    if (selectedName == null) return 0;
    final match = designationList.firstWhereOrNull(
          (d) => d.designation.trim().toLowerCase() == selectedName.trim().toLowerCase(),
    );
    if (match == null) return 0;
    try {
      final dyn = match as dynamic;
      final v = dyn.tdId ?? dyn.id ?? dyn.designationId ?? dyn.designationID ?? 0;
      return int.tryParse(v.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  void resetForm() {
    editingId.value = null;
    teacherNameC.clear();
    teacherIdC.text = _autoTeacherId();
    fatherHusbandNameC.clear();
    dobC.clear();
    emailC.clear();
    mobileC.clear();
    qualificationC.clear();
    lastOrgC.clear();
    totalExpC.clear();
    salaryC.clear();
    stateC.clear();
    cityC.clear();
    joiningDateC.clear();
    addressC.clear();
    specializationC.clear();
    bankNameC.clear();
    accountNoC.clear();
    ifscC.clear();
    bloodGroup.value = null;
    gender.value = null;
    caste.value = null;
    designation.value = null;
    userPic.value = null;
    idProofPhoto.value = null;
    resumePhoto.value = null;
    callLetterPhoto.value = null;
  }

  @override
  void onClose() {
    teacherNameC.dispose();
    teacherIdC.dispose();
    fatherHusbandNameC.dispose();
    dobC.dispose();
    emailC.dispose();
    mobileC.dispose();
    qualificationC.dispose();
    lastOrgC.dispose();
    totalExpC.dispose();
    salaryC.dispose();
    stateC.dispose();
    cityC.dispose();
    joiningDateC.dispose();
    addressC.dispose();
    specializationC.dispose();
    bankNameC.dispose();
    accountNoC.dispose();
    ifscC.dispose();
    teacherSearchC.dispose();
    super.onClose();
  }

  static String _autoTeacherId() {
    final ms = DateTime.now().millisecondsSinceEpoch.toString();
    return 'TPS_F${ms.substring(ms.length - 6)}';
  }
}