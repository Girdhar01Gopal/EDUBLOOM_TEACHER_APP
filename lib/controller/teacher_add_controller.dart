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

class TeacherAddController extends GetxController {
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

  @override
  void onInit() async {
    super.onInit();

    teacherSearchC.addListener(applyTeacherFilter);
    teacherNameC.addListener(() => _autoCapitalizeFirstLetter(teacherNameC));
    fatherHusbandNameC.addListener(() => _autoCapitalizeFirstLetter(fatherHusbandNameC));

    schoolId = await PrefManager().readValue(key: PrefConst.schollId) ?? "";
    if (schoolId.trim().isEmpty) {
      Get.snackbar("Error", "SchoolId not found");
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
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final jsonData = jsonDecode(res.body);
        sessionList.clear();
        if (jsonData['currentSession'] != null) {
          final cs = session_model.sListDdata(
            sessionId: jsonData['currentSession']['currentSessionId'],
            session: jsonData['currentSession']['currentSession'],
            action: jsonData['currentSession']['action'],
            schoolId: jsonData['currentSession']['schoolId'],
          );
          sessionList.add(cs);
          selectedSession.value = cs;
        } else {
          selectedSession.value = null;
        }
      } else {
        Get.snackbar("Error", "Session API failed: ${res.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "Session error: $e");
    }
  }

  Future<void> fetchDesignations() async {
    try {
      isDesignationLoading(true);
      final url = Uri.parse(
        '${AppUrl.base_url}api/TeacherApp/ViewDesignationApp/$schoolId',
      );
      final res = await http.get(url, headers: {'Content-Type': 'application/json'});
      if (res.statusCode == 200) {
        final parsed = DesignationResponse.fromJson(jsonDecode(res.body));
        designationList.assignAll(parsed.listData);
        if (designation.value != null && !designationNames.contains(designation.value)) {
          designation.value = null;
        }
      } else {
        Get.snackbar("Error", "Designation GET failed: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Designation fetch error: $e");
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
      final res = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (res.statusCode == 200) {
        final parsed = TeacherListResponse.fromJson(jsonDecode(res.body));
        if (parsed.isSuccess == true) {
          teachers.assignAll(parsed.data);
          applyTeacherFilter();
        } else {
          teachers.clear();
          filteredTeachers.clear();
          Get.snackbar("Failed", (parsed.messages ?? "Fetch failed").toString());
        }
      } else {
        Get.snackbar("Error", "Teacher API failed: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Teacher fetch error: $e");
    } finally {
      isTeacherLoading(false);
    }
  }

  void applyTeacherFilter() {
    final q = teacherSearchC.text.trim().toLowerCase();
    if (q.isEmpty) {
      filteredTeachers.assignAll(teachers);
      return;
    }
    filteredTeachers.assignAll(
      teachers.where((t) {
        final id = (t.teacherReg ?? "").toLowerCase();
        final name = (t.name ?? "").toLowerCase();
        final mobile = (t.mobileNo ?? "").toLowerCase();
        final father = (t.fhname ?? "").toLowerCase();
        return id.contains(q) || name.contains(q) || mobile.contains(q) || father.contains(q);
      }).toList(),
    );
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
      Get.snackbar("Error", "Invalid Teacher ID");
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
    Get.snackbar("Status", "Approved/Active: ${row.teacherReg ?? ""}");
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
      Get.snackbar('Error', 'Gallery se file pick failed');
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
      Get.snackbar('Error', 'Camera se photo lena failed');
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
      Get.snackbar('Error', 'File pick failed');
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

  Future<void> submit({int? idForUpdate}) async {
    if (bloodGroup.value == null) { Get.snackbar('Error', 'Blood Group is required'); return; }
    if (gender.value == null) { Get.snackbar('Error', 'Gender is required'); return; }
    if (caste.value == null) { Get.snackbar('Error', 'Caste is required'); return; }
    if (designation.value == null) { Get.snackbar('Error', 'Designation is required'); return; }
    if (!(formKey.currentState?.validate() ?? false)) return;
    await _saveTeacher(idToSend: idForUpdate ?? editingId.value ?? 0, closeDialogOnSuccess: false);
  }

  Future<void> updateTeacherFromDialog() async {
    if (editingId.value == null || editingId.value == 0) {
      Get.snackbar("Error", "Teacher Id missing");
      return;
    }
    if (bloodGroup.value == null) { Get.snackbar('Error', 'Blood Group is required'); return; }
    if (gender.value == null) { Get.snackbar('Error', 'Gender is required'); return; }
    if (caste.value == null) { Get.snackbar('Error', 'Caste is required'); return; }
    if (designation.value == null) { Get.snackbar('Error', 'Designation is required'); return; }
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
      if (schoolIdLocal.isEmpty) { Get.snackbar("Error", "SchoolId not found"); return; }

      final token = await PrefManager().readValue(key: PrefConst.token) ?? "";
      final fullName = teacherNameC.text.trim();
      final nameParts = _splitName(fullName);
      final tdId = _getTdIdFromSelectedDesignation(designation.value);

      final uri = Uri.parse('https://playschool.edubloom.in/api/TeacherApp/AddUpdateTeacher2App/');
      final req = http.MultipartRequest('POST', uri);
      req.followRedirects = false;
      req.maxRedirects = 0;
      req.headers['Accept'] = 'application/json';
      req.headers['Cache-Control'] = 'no-cache';
      if (token.trim().isNotEmpty) req.headers['Authorization'] = 'Bearer ${token.trim()}';

      req.fields['Id'] = idToSend.toString();
      req.fields['UserId'] = "0";
      req.fields['SchoolId'] = schoolIdLocal;
      req.fields['RoleId'] = "0";
      req.fields['FirstName'] = nameParts.$1;
      req.fields['LastName'] = nameParts.$2;
      req.fields['UserEmail'] = emailC.text.trim();
      req.fields['MobileNumber'] = mobileC.text.trim();
      req.fields['IsActive'] = 'true';
      req.fields['RegistrationNo'] = teacherIdC.text.trim();
      req.fields['AadharCardNo'] = totalExpC.text.trim();
      req.fields['AadharNo'] = totalExpC.text.trim();
      req.fields['AadhaarNo'] = totalExpC.text.trim();
      req.fields['Qualification'] = qualificationC.text.trim();
      req.fields['Salary'] = salaryC.text.trim();
      req.fields['Specialization'] = specializationC.text.trim();
      req.fields['TdId'] = tdId.toString();
      req.fields['SpouseName'] = fatherHusbandNameC.text.trim();

      final dobIso = _toIsoDateTimeOrEmpty(dobC.text.trim());
      if (dobIso.isNotEmpty) req.fields['Dob'] = dobIso;

      req.fields['Caste'] = caste.value!;
      req.fields['CreatedBy'] = "Admin";
      req.fields['BloodGroup'] = bloodGroup.value!;
      req.fields['Gender'] = gender.value!;
      req.fields['LastOrganization'] = lastOrgC.text.trim();
      req.fields['TotalExperience'] = totalExpC.text.trim();
      req.fields['BankName'] = bankNameC.text.trim();
      req.fields['AccountNo'] = accountNoC.text.trim();
      req.fields['Ifsccode'] = ifscC.text.trim();

      final dojIso = _toIsoDateTimeOrEmpty(joiningDateC.text.trim());
      if (dojIso.isNotEmpty) req.fields['DateofJoining'] = dojIso;

      req.fields['Address'] = addressC.text.trim();
      req.fields['City'] = cityC.text.trim();
      req.fields['State'] = stateC.text.trim();

      await _attachFileIfPicked(req, 'UserPic', userPic.value);
      await _attachFileIfPicked(req, 'IdProof', idProofPhoto.value);
      await _attachFileIfPicked(req, 'Resume', resumePhoto.value);
      await _attachFileIfPicked(req, 'CallLetter', callLetterPhoto.value);

      final resp = await req.send();

      if (resp.statusCode == 301 || resp.statusCode == 302 ||
          resp.statusCode == 307 || resp.statusCode == 308) {
        Get.snackbar(
          "Redirect (${resp.statusCode})",
          resp.headers['location'] ?? "No Location header",
          duration: const Duration(seconds: 7),
        );
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
      final apiSuccess = decoded?['isSuccess'] == true || decoded?['success'] == true;

      if ((resp.statusCode == 200 || resp.statusCode == 201) && (apiSuccess || decoded == null)) {
        if (closeDialogOnSuccess && (Get.isDialogOpen ?? false)) Get.back();
        Get.snackbar(
          'Success',
          apiMessage?.isNotEmpty == true
              ? apiMessage!
              : (idToSend == 0 ? 'Teacher added successfully' : 'Teacher updated successfully'),
        );
        editingId.value = null;
        await fetchTeachers();
        resetForm();
        return;
      }

      if (resp.statusCode == 200 && !apiSuccess) {
        Get.snackbar('Failed',
            apiMessage?.isNotEmpty == true ? apiMessage! : 'Save failed',
            duration: const Duration(seconds: 7));
        return;
      }

      Get.snackbar('Error',
          apiMessage?.isNotEmpty == true ? apiMessage! : 'Save failed: ${resp.statusCode}\n$body',
          duration: const Duration(seconds: 7));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save teacher: $e', duration: const Duration(seconds: 7));
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
    stateC.clear();
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