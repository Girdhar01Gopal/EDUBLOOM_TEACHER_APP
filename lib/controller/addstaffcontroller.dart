import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../infrastructures/routes/page_constants.dart';
import '../infrastructures/utils/local_storage/local_storage.dart';
import '../infrastructures/utils/local_storage/pref_const.dart';
import '../models/session_model.dart' as session_model;
import '../models/staff_details_model15.dart';
import '../models/stafftypemodel.dart';
import '../res/app_url.dart';

class Addstaffcontroller extends GetxController {
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

  final lastOrgC = TextEditingController();
  final totalExpC = TextEditingController(); // Aadhar No
  final salaryC = TextEditingController(); // Licence No

  final cityC = TextEditingController();
  final joiningDateC = TextEditingController();
  final addressC = TextEditingController();
  final stateC = TextEditingController();

  final bloodGroup = RxnString();
  final gender = RxnString();
  final caste = RxnString();
  final designation = RxnString();

  final bloodGroups = const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final genders = const ['Male', 'Female', 'Other'];
  final castes = const ['General', 'OBC', 'SC', 'ST', 'Other'];

  final isDesignationLoading = false.obs;
  final designationList = <StaffType>[].obs;

  List<String> get designationNames => designationList
      .map((e) => (e.staffType ?? '').trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList();

  final userPic = Rxn<PlatformFile>();
  final idProofPhoto = Rxn<PlatformFile>();
  final resumePhoto = Rxn<PlatformFile>();

  final isSubmitting = false.obs;

  final sessionList = <session_model.sListDdata>[].obs;
  final selectedSession = Rx<session_model.sListDdata?>(null);

  final isTeacherLoading = false.obs;
  final teacherSearchC = TextEditingController();

  final staffList = <StaffDetail15Data>[].obs;
  final filteredTeachers = <StaffDetail15Data>[].obs;

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

    ever(selectedSession, (_) => fetchTeachers());
  }

  @override
  void onClose() {
    teacherNameC.dispose();
    teacherIdC.dispose();
    fatherHusbandNameC.dispose();
    dobC.dispose();
    emailC.dispose();
    mobileC.dispose();
    lastOrgC.dispose();
    totalExpC.dispose();
    salaryC.dispose();
    cityC.dispose();
    joiningDateC.dispose();
    addressC.dispose();
    stateC.dispose();
    teacherSearchC.dispose();
    super.onClose();
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

  String? _normalizeValue(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty || v.toLowerCase() == 'null') return null;
    return v;
  }

  String? _pickValidValue(String? apiValue, List<String> options) {
    final v = _normalizeValue(apiValue);
    if (v == null) return null;
    for (final item in options) {
      if (item.trim().toLowerCase() == v.toLowerCase()) return item;
    }
    return null;
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
      final url = Uri.parse('${AppUrl.base_url}api/StaffApp/ViewStaffTypeApp/$schoolId');
      final res = await http.get(url, headers: {'Content-Type': 'application/json', 'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final parsed = StaffTypeResponse.fromJson(jsonDecode(res.body));
        designationList.assignAll(parsed.listData ?? []);
        if (designation.value != null) {
          designation.value = _pickValidValue(designation.value, designationNames);
        }
      } else {
        Get.snackbar("Error", "GET failed: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "Fetch error: $e");
    } finally {
      isDesignationLoading(false);
    }
  }

  Future<void> fetchTeachers() async {
    final session = selectedSession.value?.session;
    if (session == null || session.trim().isEmpty) {
      Get.snackbar("Error", "Session not selected");
      return;
    }
    try {
      isTeacherLoading(true);
      final uri = Uri.parse('https://playschool.edubloom.in/api/StaffApp/GetAllStaffAsyncApp');
      final body = {"currentSession": session, "schoolId": schoolId};
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode(body));

      if (res.statusCode == 200) {
        final parsed = StaffDetail15Model.fromJson(jsonDecode(res.body));
        if (parsed.isSuccess == true) {
          staffList.assignAll(parsed.data ?? []);
          applyTeacherFilter();
        } else {
          staffList.clear();
          filteredTeachers.clear();
          Get.snackbar("Failed", parsed.messages ?? "No data found");
        }
      } else {
        staffList.clear();
        filteredTeachers.clear();
        Get.snackbar("Error", "Staff API failed: ${res.statusCode}\n${res.body}");
      }
    } catch (e) {
      staffList.clear();
      filteredTeachers.clear();
      Get.snackbar("Error", "Staff fetch error: $e");
    } finally {
      isTeacherLoading(false);
    }
  }

  void applyTeacherFilter() {
    final q = teacherSearchC.text.trim().toLowerCase();
    if (q.isEmpty) {
      filteredTeachers.assignAll(staffList);
      return;
    }
    filteredTeachers.assignAll(
      staffList.where((t) {
        final id = (t.staffReg ?? "").toLowerCase();
        final name = (t.name ?? "").toLowerCase();
        final mobile = (t.mobileNo ?? "").toLowerCase();
        final father = (t.fhname ?? "").toLowerCase();
        final aadhar = (t.aadharNo ?? "").toLowerCase();
        return id.contains(q) || name.contains(q) || mobile.contains(q) || father.contains(q) || aadhar.contains(q);
      }).toList(),
    );
  }

  void onTeacherEdit(StaffDetail15Data row) {
    fillTeacherForDialogEdit(row);
  }

  void fillTeacherForDialogEdit(StaffDetail15Data teacher) {
    editingId.value = teacher.id ?? 0;
    teacherNameC.text = (teacher.name ?? '').trim();
    teacherIdC.text = (teacher.staffReg ?? _autoTeacherId()).trim();
    fatherHusbandNameC.text = (teacher.fhname ?? '').trim();
    dobC.text = teacher.dob != null ? formatDateFromDateTime(teacher.dob) : '';
    emailC.text = (teacher.emailid ?? '').trim();
    mobileC.text = (teacher.mobileNo ?? '').trim();
    totalExpC.text = (teacher.aadharNo ?? '').trim();
    salaryC.text = (teacher.licenceNo ?? '').trim();
    cityC.text = (teacher.city ?? '').trim();
    joiningDateC.text = teacher.dateofJoining != null ? formatDateFromDateTime(teacher.dateofJoining) : '';
    addressC.text = (teacher.address ?? '').trim();
    stateC.text = (teacher.state ?? '').trim();

    bloodGroup.value = _pickValidValue(teacher.bloodGroup, bloodGroups);
    gender.value = _pickValidValue(teacher.gender, genders);
    caste.value = _pickValidValue(teacher.caste, castes);
    designation.value = _pickValidValue(teacher.staffType ?? teacher.designation, designationNames);

    userPic.value = null;
    idProofPhoto.value = null;
    resumePhoto.value = null;
  }

  /// ── Navigate to StaffDetailScreen ────────────────────────────────────────
  void onTeacherView(StaffDetail15Data row) {
    final id = row.id;
    if (id == null || id == 0) {
      Get.snackbar("Error", "Invalid Staff ID");
      return;
    }
    Get.toNamed(
      RouteName.staffdetailview,
      arguments: {
        'staffId': id,
        'schoolId': schoolId,
        'currentSession': selectedSession.value?.session ?? '',
      },
    );
  }

  void onTeacherApprove(StaffDetail15Data row) {
    Get.snackbar("Status", "Approved/Active: ${row.staffReg ?? ""}");
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

  String formatDateFromDateTime(DateTime? date) {
    if (date == null) return "-";
    return "${date.day.toString().padLeft(2, '0')}-${_m(date.month)}-${date.year}";
  }

  String _m(int m) {
    const mm = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
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
    DateTime pickedInitial = initialDate ?? now;
    if (controller.text.trim().isNotEmpty) {
      final parts = controller.text.trim().split('-');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) pickedInitial = DateTime(y, m, d);
      }
    }
    final picked = await showDatePicker(
      context: Get.context!,
      firstDate: firstDate ?? DateTime(1950),
      lastDate: lastDate ?? DateTime(now.year + 2),
      initialDate: pickedInitial,
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
              title: const Text('Gallery'),
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
      Get.snackbar('Error', 'Gallery file pick failed');
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
      Get.snackbar('Error', 'Camera photo failed');
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
    if (designation.value == null) { Get.snackbar('Error', 'Staff Type is required'); return; }
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSubmitting.value = true;
    try {
      final schoolIdLocal = schoolId.trim();
      if (schoolIdLocal.isEmpty) { Get.snackbar("Error", "SchoolId not found"); return; }

      final token = await PrefManager().readValue(key: PrefConst.token) ?? "";
      final fullName = teacherNameC.text.trim();
      final nameParts = _splitName(fullName);
      final tdId = _getTdIdFromSelectedDesignation(designation.value);
      final uri = Uri.parse('https://playschool.edubloom.in/api/StaffApp/PostAddStaffApp');
      final idToSend = idForUpdate ?? editingId.value ?? 0;

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
      req.fields['Licences'] = salaryC.text.trim();
      req.fields['StaffTypeId'] = tdId.toString();
      req.fields['SpouseName'] = fatherHusbandNameC.text.trim();

      final dobIso = _toIsoDateTimeOrEmpty(dobC.text.trim());
      if (dobIso.isNotEmpty) req.fields['Dob'] = dobIso;

      req.fields['Caste'] = caste.value!;
      req.fields['CreatedBy'] = "Admin";
      req.fields['BloodGroup'] = bloodGroup.value!;
      req.fields['Gender'] = gender.value!;

      final dojIso = _toIsoDateTimeOrEmpty(joiningDateC.text.trim());
      if (dojIso.isNotEmpty) req.fields['DateofJoining'] = dojIso;

      req.fields['Address'] = addressC.text.trim();
      req.fields['City'] = cityC.text.trim();
      req.fields['State'] = stateC.text.trim();

      await _attachFileIfPicked(req, 'UserPic', userPic.value);
      await _attachFileIfPicked(req, 'IdProof', idProofPhoto.value);
      await _attachFileIfPicked(req, 'Licence', resumePhoto.value);

      final resp = await req.send();

      if (resp.statusCode == 301 || resp.statusCode == 302 ||
          resp.statusCode == 307 || resp.statusCode == 308) {
        Get.snackbar("Redirect (${resp.statusCode})",
            resp.headers['location'] ?? "No Location header", duration: const Duration(seconds: 7));
        return;
      }

      final body = await resp.stream.bytesToString();
      Map<String, dynamic>? decoded;
      try {
        final temp = jsonDecode(body);
        if (temp is Map<String, dynamic>) decoded = temp;
      } catch (_) {}

      final apiSuccess = decoded?['isSuccess'] == true || decoded?['success'] == true;

      if ((resp.statusCode == 200 || resp.statusCode == 201) && (apiSuccess || decoded == null)) {
        // ✅ FIXED: Server ka message ignore karke apna message show karo
        Get.snackbar('Success', idToSend == 0 ? 'Staff added successfully' : 'Staff updated successfully');
        editingId.value = null;
        await fetchTeachers();
        resetForm(keepStaffTypeList: true, regenerateId: true);
        return;
      }

      if (resp.statusCode == 200 && !apiSuccess) {
        final apiMessage = decoded?['messages']?.toString() ?? decoded?['message']?.toString() ?? decoded?['Message']?.toString();
        Get.snackbar('Failed', apiMessage?.isNotEmpty == true ? apiMessage! : 'Save failed', duration: const Duration(seconds: 7));
        return;
      }

      final apiMessage = decoded?['messages']?.toString() ?? decoded?['message']?.toString() ?? decoded?['Message']?.toString();
      Get.snackbar('Error', apiMessage?.isNotEmpty == true ? apiMessage! : 'Save failed: ${resp.statusCode}\n$body', duration: const Duration(seconds: 7));
    } catch (e) {
      Get.snackbar('Error', 'Failed to save staff: $e', duration: const Duration(seconds: 7));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> updateTeacherFromDialog() async {
    if (editingId.value == null || editingId.value == 0) { Get.snackbar("Error", "Staff Id missing"); return; }
    if (bloodGroup.value == null) { Get.snackbar('Error', 'Blood Group is required'); return; }
    if (gender.value == null) { Get.snackbar('Error', 'Gender is required'); return; }
    if (caste.value == null) { Get.snackbar('Error', 'Caste is required'); return; }
    if (designation.value == null) { Get.snackbar('Error', 'Staff Type is required'); return; }
    if (!(dialogFormKey.currentState?.validate() ?? false)) return;

    isSubmitting.value = true;
    try {
      final schoolIdLocal = schoolId.trim();
      if (schoolIdLocal.isEmpty) { Get.snackbar("Error", "SchoolId not found"); return; }

      final token = await PrefManager().readValue(key: PrefConst.token) ?? "";
      final fullName = teacherNameC.text.trim();
      final nameParts = _splitName(fullName);
      final tdId = _getTdIdFromSelectedDesignation(designation.value);
      final uri = Uri.parse('https://playschool.edubloom.in/api/StaffApp/PostAddStaffApp');

      final req = http.MultipartRequest('POST', uri);
      req.followRedirects = false;
      req.maxRedirects = 0;
      req.headers['Accept'] = 'application/json';
      req.headers['Cache-Control'] = 'no-cache';
      if (token.trim().isNotEmpty) req.headers['Authorization'] = 'Bearer ${token.trim()}';

      req.fields['Id'] = editingId.value.toString();
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
      req.fields['Licences'] = salaryC.text.trim();
      req.fields['StaffTypeId'] = tdId.toString();
      req.fields['SpouseName'] = fatherHusbandNameC.text.trim();

      final dobIso = _toIsoDateTimeOrEmpty(dobC.text.trim());
      if (dobIso.isNotEmpty) req.fields['Dob'] = dobIso;

      req.fields['Caste'] = caste.value!;
      req.fields['CreatedBy'] = "Admin";
      req.fields['BloodGroup'] = bloodGroup.value!;
      req.fields['Gender'] = gender.value!;

      final dojIso = _toIsoDateTimeOrEmpty(joiningDateC.text.trim());
      if (dojIso.isNotEmpty) req.fields['DateofJoining'] = dojIso;

      req.fields['Address'] = addressC.text.trim();
      req.fields['City'] = cityC.text.trim();
      req.fields['State'] = stateC.text.trim();

      await _attachFileIfPicked(req, 'UserPic', userPic.value);
      await _attachFileIfPicked(req, 'IdProof', idProofPhoto.value);
      await _attachFileIfPicked(req, 'Licence', resumePhoto.value);

      final resp = await req.send();
      final body = await resp.stream.bytesToString();
      Map<String, dynamic>? decoded;
      try {
        final temp = jsonDecode(body);
        if (temp is Map<String, dynamic>) decoded = temp;
      } catch (_) {}

      final apiMessage = decoded?['messages']?.toString() ?? decoded?['message']?.toString() ?? decoded?['Message']?.toString();
      final apiSuccess = decoded?['isSuccess'] == true || decoded?['success'] == true;

      if ((resp.statusCode == 200 || resp.statusCode == 201) && (apiSuccess || decoded == null)) {
        if (Get.isDialogOpen ?? false) Get.back();
        // ✅ FIXED: Server ka message ignore karke apna message show karo
        Get.snackbar('Success', 'Staff updated successfully');
        await fetchTeachers();
        resetForm();
        return;
      }

      Get.snackbar('Error',
          apiMessage?.isNotEmpty == true ? apiMessage! : 'Update failed: ${resp.statusCode}\n$body',
          duration: const Duration(seconds: 7));
    } catch (e) {
      Get.snackbar('Error', 'Failed to update staff: $e', duration: const Duration(seconds: 7));
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _attachFileIfPicked(http.MultipartRequest req, String fieldName, PlatformFile? file) async {
    if (file == null) return;
    final path = file.path;
    if (path == null || path.trim().isEmpty) return;
    final f = File(path);
    if (!await f.exists()) return;
    req.files.add(await http.MultipartFile.fromPath(fieldName, path,
        filename: file.name.isNotEmpty ? file.name : p.basename(path)));
  }

  (String, String) _splitName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).toList();
    if (parts.isEmpty) return ("", "");
    if (parts.length == 1) return (parts.first, "");
    return (parts.first, parts.sublist(1).join(" "));
  }

  int _getTdIdFromSelectedDesignation(String? selectedValue) {
    if (selectedValue == null || selectedValue.trim().isEmpty) return 0;
    final selected = selectedValue.trim().toLowerCase();
    for (final item in designationList) {
      if ((item.staffType ?? '').trim().toLowerCase() == selected) return item.staffTypeId ?? 0;
    }
    return 0;
  }

  String _toIsoDateTimeOrEmpty(String ddmmyyyy) {
    try {
      if (ddmmyyyy.trim().isEmpty) return '';
      final parts = ddmmyyyy.split('-');
      if (parts.length != 3) return '';
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0])).toIso8601String();
    } catch (_) {
      return '';
    }
  }

  void resetForm({bool keepStaffTypeList = true, bool regenerateId = true}) {
    editingId.value = null;
    teacherNameC.clear();
    fatherHusbandNameC.clear();
    dobC.clear();
    emailC.clear();
    mobileC.clear();
    lastOrgC.clear();
    totalExpC.clear();
    salaryC.clear();
    cityC.clear();
    joiningDateC.clear();
    addressC.clear();
    stateC.clear();
    if (regenerateId) teacherIdC.text = _autoTeacherId();
    bloodGroup.value = null;
    gender.value = null;
    caste.value = null;
    designation.value = null;
    userPic.value = null;
    idProofPhoto.value = null;
    resumePhoto.value = null;
  }

  static String _autoTeacherId() {
    final now = DateTime.now();
    return 'TPS_S${now.microsecondsSinceEpoch.toString().substring(7)}';
  }
}