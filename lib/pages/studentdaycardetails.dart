import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../controller/student_controller daycare.dart' as daycare_controller;
import '../controller/student_controller.dart';

// ─── Palette ───────────────────────────────────────────────
const _teal = Color(0xFF00695C);
const _tealLight = Color(0xFF26A69A);
const _surface = Color(0xFFFFFFFF);
const _cardBg = Color(0xFFF8FFFE);
const _textPrimary = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF607D8B);
const _divider = Color(0xFFE0F2F1);

// ═══════════════════════════════════════════════════════════
// StudentDetailScreenday
// ═══════════════════════════════════════════════════════════
class StudentDetailScreenday extends StatelessWidget {
  final dynamic student;
  const StudentDetailScreenday({super.key, required this.student});

  static const String _studentBase =
      "https://playschool.edubloom.in/Upload/student/images/";
  static const String _fatherBase =
      "https://playschool.edubloom.in/Upload/father/images/";
  static const String _motherBase =
      "https://playschool.edubloom.in/Upload/mother/images/";
  static const String _guardianBase =
      "https://playschool.edubloom.in/Upload/guardian/images/";

  // ── Format date ───────────────────────────────────────────
  String _fmt(dynamic value) {
    if (value == null) return "-";
    final raw = value.toString().trim();
    if (raw.isEmpty) return "-";
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";
    } catch (_) {
      return raw;
    }
  }

  // ── Build full image URL ──────────────────────────────────
  String? _url(String? file, String base) {
    if (file == null) return null;
    final f = file.trim();
    if (f.isEmpty) return null;
    if (f.startsWith('http')) return f;
    return "$base$f";
  }

  // ── Normalize gender ──────────────────────────────────────
  String _normalizeGender(String? g) {
    final raw = (g ?? '').trim().toLowerCase();
    if (raw == 'male' || raw == 'm' || raw == 'boy') return 'Boy';
    if (raw == 'female' || raw == 'f' || raw == 'girl') return 'Girl';
    if (raw == 'other') return 'Other';
    return '';
  }

  // ── Get or create preschool controller ───────────────────
  StudentController _getNormalController() {
    if (Get.isRegistered<StudentController>()) {
      return Get.find<StudentController>();
    }
    return Get.put(StudentController());
  }

  // ── Download image URL → temp File ───────────────────────
  Future<File?> _downloadImageAsFile(
      String? url, String fileName) async {
    if (url == null || url.trim().isEmpty) return null;
    try {
      final response =
      await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      debugPrint('Image download error ($fileName): $e');
    }
    return null;
  }

  // ── Zoom helper ───────────────────────────────────────────
  void _showZoom(BuildContext context, Widget imageWidget) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 5.0,
              child: Center(child: imageWidget),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // TRANSFER TO PRESCHOOL
  // ══════════════════════════════════════════════════════════
  Future<void> _transferToPreschool(BuildContext context) async {
    // ── Show loading while downloading images ──────────────
    Get.dialog(
      const Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF1565C0)),
                SizedBox(height: 16),
                Text(
                  "Loading student data...",
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // ── Build all 4 image URLs ────────────────────────────
    final studentImgUrl  = _url(student.studentPic,    _studentBase);
    final fatherImgUrl   = _url(student.fatherPic,     _fatherBase);
    final motherImgUrl   = _url(student.motherPic,     _motherBase);
    final guardianImgUrl = _url(student.guardianImage, _guardianBase);

    debugPrint('📸 Student  URL: $studentImgUrl');
    debugPrint('📸 Father   URL: $fatherImgUrl');
    debugPrint('📸 Mother   URL: $motherImgUrl');
    debugPrint('📸 Guardian URL: $guardianImgUrl');

    // ── Download all 4 images in parallel ─────────────────
    final results = await Future.wait([
      _downloadImageAsFile(studentImgUrl,  'transfer_student.jpg'),
      _downloadImageAsFile(fatherImgUrl,   'transfer_father.jpg'),
      _downloadImageAsFile(motherImgUrl,   'transfer_mother.jpg'),
      _downloadImageAsFile(guardianImgUrl, 'transfer_guardian.jpg'),
    ]);

    debugPrint('📥 Student  File: ${results[0]?.path}');
    debugPrint('📥 Father   File: ${results[1]?.path}');
    debugPrint('📥 Mother   File: ${results[2]?.path}');
    debugPrint('📥 Guardian File: ${results[3]?.path}');

    // ── Close loading dialog ───────────────────────────────
    if (Get.isDialogOpen == true) Get.back();

    // ── Get or create StudentController (preschool) ────────
    final c = _getNormalController();

    // ── Fill all matching fields from daycare student ──────
    c.studentName.value      = student.studentName ?? '';
    c.fatherName.value       = student.fatherName ?? '';
    c.motherName.value       = student.motherName ?? '';
    c.fatherOccupation.value = student.fatherOccupation ?? '';
    c.gender.value           = _normalizeGender(student.gender);

    // DOB
    if (student.dateOfBirth != null &&
        student.dateOfBirth.toString().trim().isNotEmpty) {
      c.dob.text          = _fmt(student.dateOfBirth);
      c.dateOfBirth.value = c.dob.text;
    } else {
      c.dob.text          = '';
      c.dateOfBirth.value = '';
    }

    c.bloodGroup.value     = student.bloodGroup ?? '';
    c.religion.value       = student.religion ?? '';
    c.phone.value          = student.phone ?? '';
    c.whatsappNo.value     = student.whatsAppNo ?? '';
    c.emergencyNo.value    = student.emergencyNo ?? '';
    c.emailController.text = student.email ?? '';
    c.aAdharNo.value       = '';
    c.rollNo.value         = '';
    c.address.value        = '';
    c.actionStatus.value   = '1';

    // ── Assign downloaded images ───────────────────────────
    c.fileImage.value     = results[0]; // student
    c.fatherPic.value     = results[1]; // father
    c.motherPic.value     = results[2]; // mother
    c.guardianImage.value = results[3]; // guardian

    // ── Open Transfer Dialog ───────────────────────────────
    if (context.mounted) {
      _openTransferDialog(context, c);
    }
  }

  // ── Open Transfer Dialog ──────────────────────────────────
  void _openTransferDialog(BuildContext context, StudentController c) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: SafeArea(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom -
                  48,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // ── Header ─────────────────────────────
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Transfer to Pre School",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp),
                              ),
                              Text(
                                "Daycare → Pre School",
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable Body ─────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.r),
                      child: _transferForm(c, context),
                    ),
                  ),

                  // ── Footer ─────────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF1565C0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h),
                            ),
                            child: const Text("Cancel",
                                style: TextStyle(
                                    color: Color(0xFF1565C0))),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF1565C0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h),
                            ),
                            icon: const Icon(
                                Icons.swap_horiz_rounded,
                                size: 18),
                            label: const Text(
                                "Transfer this from Daycare"),
                            onPressed: () async {
                              // Validations
                              if (c.studentName.value
                                  .trim()
                                  .isEmpty) {
                                Get.snackbar("Error",
                                    "Student Name required",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              if (c.phone.value.trim().isEmpty) {
                                Get.snackbar(
                                    "Error", "Phone required",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              if (c.selectedClass.value == null) {
                                Get.snackbar("Error",
                                    "Please select a Class",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              if (c.selectedSection.value == null) {
                                Get.snackbar("Error",
                                    "Please select a Section",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }

                              // Close transfer dialog
                              Navigator.pop(context);

                              // ── Register in preschool API ──
                              // NOTE: student stays in daycare list
                              // (no _removeFromDaycareList call)
                              await c.registerStudent();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Transfer form body ────────────────────────────────────
  Widget _transferForm(StudentController c, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Info banner ──────────────────────────────────
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFF90CAF9)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFF1565C0), size: 18),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  "Daycare data pre-filled. Please fill remaining required fields (Class, Section, Roll No, etc.) before transferring.",
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF1565C0),
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // ── Status ───────────────────────────────────────
        Obx(() {
          final v = c.actionStatus.value.trim().isEmpty
              ? '1'
              : c.actionStatus.value.trim();
          final safeV = (v == "0" || v == "1") ? v : "1";
          return DropdownButtonFormField<String>(
            value: safeV,
            items: const [
              DropdownMenuItem(value: "1", child: Text("Active")),
              DropdownMenuItem(value: "0", child: Text("Inactive")),
            ],
            onChanged: (val) => c.actionStatus.value = val ?? '1',
            decoration: _transferInputDeco('Status',
                icon: Icons.toggle_on_outlined),
          );
        }),
        SizedBox(height: 10.h),

        // ── Pre-filled text fields ───────────────────────
        _tfBlue("Student Name *", c.studentName.value,
                (v) => c.studentName.value = v),
        _tfBlue("Father Name", c.fatherName.value,
                (v) => c.fatherName.value = v),
        _tfBlue("Mother Name", c.motherName.value,
                (v) => c.motherName.value = v),
        _tfBlue("Father Occupation", c.fatherOccupation.value,
                (v) => c.fatherOccupation.value = v),
        _dropdownBlue(
            "Gender", c.gender, const ["Boy", "Girl", "Other"]),
        _dobPickerTransfer(context, c),
        _dropdownBlue("Blood Group", c.bloodGroup,
            const ["A-", "A+", "B-", "B+", "O-", "O+"]),
        _tfBlue("Religion", c.religion.value,
                (v) => c.religion.value = v),
        _tfBlue("Phone *", c.phone.value, (v) => c.phone.value = v,
            keyboardType: TextInputType.phone),
        _tfBlue("WhatsApp No", c.whatsappNo.value,
                (v) => c.whatsappNo.value = v,
            keyboardType: TextInputType.phone),
        _tfBlue("Emergency No", c.emergencyNo.value,
                (v) => c.emergencyNo.value = v,
            keyboardType: TextInputType.phone),
        _tfBlue("Email", c.emailController.text,
                (v) => c.emailController.text = v,
            keyboardType: TextInputType.emailAddress),

        SizedBox(height: 6.h),
        _sectionLabel("Fill These Fields"),
        SizedBox(height: 10.h),

        _tfBlue("Roll No", c.rollNo.value, (v) => c.rollNo.value = v,
            keyboardType: TextInputType.number),
        _tfBlue("Aadhar No.", c.aAdharNo.value,
                (v) => c.aAdharNo.value = v,
            keyboardType: TextInputType.number),
        _tfBlue(
            "Address", c.address.value, (v) => c.address.value = v),

        // ── Class Dropdown ───────────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Obx(() => DropdownButtonFormField(
            value: c.selectedClass.value,
            hint: const Text("Select Class *"),
            isExpanded: true,
            onChanged: (v) => c.selectedClass.value = v,
            items: c.classes
                .map((cl) => DropdownMenuItem(
                value: cl, child: Text(cl.className)))
                .toList(),
            decoration: _transferInputDeco("Select Class *",
                icon: Icons.class_outlined),
          )),
        ),

        // ── Section Dropdown ─────────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Obx(() => DropdownButtonFormField(
            value: c.selectedSection.value,
            hint: const Text("Select Section *"),
            isExpanded: true,
            onChanged: (v) => c.selectedSection.value = v,
            items: c.sectionList
                .map((s) => DropdownMenuItem(
                value: s,
                child: Text(s.section ?? 'No section')))
                .toList(),
            decoration: _transferInputDeco("Select Section *",
                icon: Icons.group_outlined),
          )),
        ),

        // ── Transport ────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Obx(() => DropdownButtonFormField<String>(
            value: c.transportUser.value.isEmpty
                ? null
                : c.transportUser.value,
            hint: const Text("Transport User"),
            items: ["Yes", "No"]
                .map((o) => DropdownMenuItem(
                value: o, child: Text(o)))
                .toList(),
            onChanged: (v) =>
            c.transportUser.value = v ?? '',
            decoration: _transferInputDeco("Transport User",
                icon: Icons.directions_bus_outlined),
          )),
        ),

        // ── Add Daycare — default No ──────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Obx(() {
            if (c.addDaycareStudent.value.isEmpty) {
              c.addDaycareStudent.value = 'No';
            }
            return DropdownButtonFormField<String>(
              value: c.addDaycareStudent.value,
              items: ["Yes", "No"]
                  .map((o) => DropdownMenuItem(
                  value: o, child: Text(o)))
                  .toList(),
              onChanged: (v) =>
              c.addDaycareStudent.value = v ?? 'No',
              decoration: _transferInputDeco(
                  "Add Daycare Student",
                  icon: Icons.child_care_outlined),
            );
          }),
        ),

        SizedBox(height: 14.h),
        _sectionLabel("Photos (Downloaded from Daycare)"),
        SizedBox(height: 10.h),

        // ── Image rows — File if downloaded, else network URL ──
        _imageRowBlue(
          context: context,
          title: "Student Photo",
          pickedRx: c.fileImage,
          oldUrl: _url(student.studentPic, _studentBase),
          onPick: () => _pickImgBlue(context, c, c.fileImage),
        ),
        _imageRowBlue(
          context: context,
          title: "Father Photo",
          pickedRx: c.fatherPic,
          oldUrl: _url(student.fatherPic, _fatherBase),
          onPick: () => _pickImgBlue(context, c, c.fatherPic),
        ),
        _imageRowBlue(
          context: context,
          title: "Mother Photo",
          pickedRx: c.motherPic,
          oldUrl: _url(student.motherPic, _motherBase),
          onPick: () => _pickImgBlue(context, c, c.motherPic),
        ),
        _imageRowBlue(
          context: context,
          title: "Guardian Photo",
          pickedRx: c.guardianImage,
          oldUrl: _url(student.guardianImage, _guardianBase),
          onPick: () =>
              _pickImgBlue(context, c, c.guardianImage),
        ),
      ],
    );
  }

  // ── Blue-themed section label ─────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
                color: const Color(0xFF1565C0),
                borderRadius: BorderRadius.circular(2))),
        SizedBox(width: 8.w),
        Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: const Color(0xFF1565C0))),
      ],
    );
  }

  // ── Blue text field (for transfer form) ──────────────────
  Widget _tfBlue(
      String label,
      String initial,
      Function(String) onChanged, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _transferInputDeco(label),
      ),
    );
  }

  // ── Blue dropdown (for transfer form) ────────────────────
  Widget _dropdownBlue(
      String label, RxString valueRx, List<String> items) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Obx(() {
        final current = valueRx.value.trim();
        final safe = (current.isEmpty || !items.contains(current))
            ? null
            : current;
        return DropdownButtonFormField<String>(
          value: safe,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => valueRx.value = v ?? '',
          decoration: _transferInputDeco(label),
        );
      }),
    );
  }

  // ── DOB picker for transfer form ──────────────────────────
  Widget _dobPickerTransfer(
      BuildContext context, StudentController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: c.dob,
        readOnly: true,
        decoration: _transferInputDeco("Date of Birth",
            icon: Icons.calendar_month_outlined),
        onTap: () async {
          DateTime initial = DateTime.now();
          final txt = c.dob.text.trim();
          if (txt.isNotEmpty) {
            final parts = txt.split('-');
            if (parts.length == 3) {
              final d = int.tryParse(parts[0]);
              final m = int.tryParse(parts[1]);
              final y = int.tryParse(parts[2]);
              if (d != null && m != null && y != null) {
                initial = DateTime(y, m, d);
              }
            }
          }
          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (ctx, child) => Theme(
              data: ThemeData.light().copyWith(
                  colorScheme:
                  const ColorScheme.light(primary: _teal)),
              child: child!,
            ),
          );
          if (picked != null) {
            final dd   = picked.day.toString().padLeft(2, '0');
            final mm   = picked.month.toString().padLeft(2, '0');
            final yyyy = picked.year.toString();
            c.dob.text          = "$dd-$mm-$yyyy";
            c.dateOfBirth.value = c.dob.text;
          }
        },
      ),
    );
  }

  // ── Image row for transfer form ───────────────────────────
  Widget _imageRowBlue({
    required BuildContext context,
    required String title,
    required Rx<File?> pickedRx,
    required String? oldUrl,
    required VoidCallback onPick,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: _textPrimary)),
          ),
          Obx(() {
            final picked = pickedRx.value;
            Widget preview;
            if (picked != null) {
              // Show downloaded File
              preview = ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.file(picked,
                    height: 56, width: 56, fit: BoxFit.cover),
              );
            } else if (oldUrl != null) {
              // Fallback: network URL
              preview = ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(oldUrl,
                    height: 56,
                    width: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _smallPlaceholder()),
              );
            } else {
              preview = _smallPlaceholder();
            }
            return Row(children: [
              preview,
              SizedBox(width: 8.w),
              OutlinedButton(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                      color: Color(0xFF1565C0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 8.h),
                ),
                child: Text("Pick",
                    style: TextStyle(
                        color: const Color(0xFF1565C0),
                        fontSize: 12.sp)),
              ),
            ]);
          }),
        ],
      ),
    );
  }

  // ── Image picker for transfer form ────────────────────────
  Future<void> _pickImgBlue(
      BuildContext context,
      StudentController c,
      Rx<File?> target,
      ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Choose Photo',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: _textPrimary)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: _teal),
            title: const Text("Gallery"),
            onTap: () =>
                Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined,
                color: _teal),
            title: const Text("Camera"),
            onTap: () =>
                Navigator.pop(context, ImageSource.camera),
          ),
        ]),
      ),
    );
    if (source != null) {
      final picked = await c.picker.pickImage(source: source);
      if (picked != null) {
        target.value = File(picked.path);
      }
    }
  }

  // ── Transfer input decoration ─────────────────────────────
  InputDecoration _transferInputDeco(String label,
      {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textSecondary, fontSize: 13.sp),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: const Color(0xFF1565C0))
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(
            color: Color(0xFF1565C0), width: 1.5),
      ),
      filled: true,
      fillColor: _cardBg,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      isDense: true,
    );
  }

  // ══════════════════════════════════════════════════════════
  // BUILD — ORIGINAL WORD TO WORD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final studentUrl = _url(student.studentPic, _studentBase);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          student?.studentName ?? 'Student Details',
          style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 17),
        ),
        actions: [
          Tooltip(
            message: "Edit Student",
            child: IconButton(
              onPressed: () => _openEditDialog(context),
              icon: const Icon(Icons.edit_outlined,
                  color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            _profileHeader(context, studentUrl),
            SizedBox(height: 20.h),
            _infoCard('Personal Information', [
              _detailRow('Father', student.fatherName),
              _detailRow('Mother', student.motherName),
              _detailRow('Gender', student.gender),
              _detailRow('Date of Birth', _fmt(student.dateOfBirth)),
              _detailRow('Religion', student.religion),
              _detailRow('Blood Group', student.bloodGroup),
              _detailRow('Father Occupation', student.fatherOccupation),
            ]),
            SizedBox(height: 12.h),
            _infoCard('Admission Details', [
              _detailRow('Admission Date', _fmt(student.admissionDate)),
              _detailRow('Registration No', student.registrationNo),
            ]),
            SizedBox(height: 12.h),
            _infoCard('Contact Information', [
              _detailRow('Phone', student.phone),
              _detailRow('WhatsApp', student.whatsAppNo),
              _detailRow('Emergency No', student.emergencyNo),
              _detailRow('Email', student.email),
            ]),
            SizedBox(height: 12.h),
            _imagesCard(context),
            SizedBox(height: 16.h),

            // ── Transfer to Pre School Button ─────────────
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color:
                      const Color(0xFF1565C0).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded,
                      color: Colors.white, size: 22),
                  label: Text(
                    'Transfer to Pre School',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  onPressed: () => _transferToPreschool(context),
                ),
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // ── Profile header — original ─────────────────────────────
  Widget _profileHeader(BuildContext context, String? studentUrl) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00897B), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: studentUrl != null
                ? () => _showZoom(
              context,
              Image.network(
                studentUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 60),
              ),
            )
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                height: 80.w,
                width: 80.w,
                color: Colors.white.withOpacity(0.2),
                child: (studentUrl != null)
                    ? Image.network(
                  studentUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: 44.w,
                      color: Colors.white70),
                )
                    : Icon(Icons.person,
                    size: 44.w, color: Colors.white70),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName ?? '-',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Session: ${student.session ?? '-'}',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info card — original ──────────────────────────────────
  Widget _infoCard(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 12.h),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13.sp,
                color: _teal,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  // ── Images card — original ────────────────────────────────
  Widget _imagesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 12.h),
            child: Text(
              'Photos',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: _teal,
                  letterSpacing: 0.3),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _photoBox(context, 'Father', student.fatherPic,
                    _fatherBase),
                _photoBox(context, 'Mother', student.motherPic,
                    _motherBase),
                _photoBox(context, 'Guardian',
                    student.guardianImage, _guardianBase),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail row — original ─────────────────────────────────
  Widget _detailRow(String title, dynamic value,
      {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
                color: _textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: TextStyle(
                fontSize: 13.sp,
                color: isHighlight ? _teal : _textPrimary,
                fontWeight: isHighlight
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Photo box — original ──────────────────────────────────
  Widget _photoBox(BuildContext context, String title,
      String? file, String base) {
    final url = _url(file, base);
    return Column(
      children: [
        GestureDetector(
          onTap: url != null
              ? () => _showZoom(
            context,
            Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image,
                  color: Colors.white70,
                  size: 60),
            ),
          )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: (url != null)
                ? Image.network(url,
                height: 70.w,
                width: 70.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _photoPlaceholder())
                : _photoPlaceholder(),
          ),
        ),
        SizedBox(height: 4.h),
        Text(title,
            style: TextStyle(
                fontSize: 11.sp,
                color: _textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person_outline, color: _tealLight),
    );
  }

  Widget _smallPlaceholder() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_outlined, color: _tealLight),
    );
  }

  // ══════════════════════════════════════════════════════════
  // EDIT DIALOG — ORIGINAL WORD TO WORD
  // ══════════════════════════════════════════════════════════
  void _openEditDialog(BuildContext context) {
    final c = Get.find<daycare_controller.StudentControllerdaycare>();

    c.studentName.value      = student.studentName ?? '';
    c.fatherName.value       = student.fatherName ?? '';
    c.motherName.value       = student.motherName ?? '';
    c.fatherOccupation.value = student.fatherOccupation ?? '';
    c.gender.value           = _normalizeGender(student.gender);

    if (student.dateOfBirth != null &&
        student.dateOfBirth.toString().trim().isNotEmpty) {
      c.dob.text          = _fmt(student.dateOfBirth);
      c.dateOfBirth.value = c.dob.text;
    } else {
      c.dob.text          = '';
      c.dateOfBirth.value = '';
    }

    // ── Admission Date: parse and set properly ─────────────
    final ad = (student.admissionDate ?? '').toString().trim();
    if (ad.isNotEmpty) {
      c.admissionDate.value           = _fmt(ad);
      c.admissionDateController.text  = c.admissionDate.value;
    } else {
      c.admissionDate.value           = '';
      c.admissionDateController.text  = '';
    }

    c.bloodGroup.value     = student.bloodGroup ?? '';
    c.religion.value       = student.religion ?? '';
    c.phone.value          = student.phone ?? '';
    c.whatsappNo.value     = student.whatsAppNo ?? '';
    c.emergencyNo.value    = student.emergencyNo ?? '';
    c.emailController.text = student.email ?? '';
    c.fromTime.value       = student.fromTime?.toString() ?? '';
    c.toTime.value         = student.toTime?.toString() ?? '';
    c.actionStatus.value   = (student.action ?? '1').toString();

    c.fileImage.value     = null;
    c.fatherPic.value     = null;
    c.motherPic.value     = null;
    c.guardianImage.value = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: SafeArea(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom -
                  48,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [_tealLight, _teal]),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Edit Daycare Student",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.r),
                      child: _editForm(c, context),
                    ),
                  ),

                  // Footer
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _teal),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h),
                            ),
                            child: const Text("Cancel",
                                style: TextStyle(color: _teal)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12)),
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.h),
                            ),
                            icon: const Icon(Icons.save_outlined,
                                size: 18),
                            label: const Text("Update Student"),
                            onPressed: () {
                              if (student.studentID == null) {
                                Get.snackbar(
                                    "Error", "StudentID missing",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              if (c.studentName.value
                                  .trim()
                                  .isEmpty) {
                                Get.snackbar("Error",
                                    "Student Name required",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              if (c.phone.value.trim().isEmpty) {
                                Get.snackbar(
                                    "Error", "Phone required",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              c.updateStudentByPostApi(
                                  studentId: student.studentID!);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Edit form — original + admission date picker FIXED ────
  Widget _editForm(
      daycare_controller.StudentControllerdaycare c,
      BuildContext context,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),

        // Status
        Obx(() {
          final v = c.actionStatus.value.trim().isEmpty
              ? '1'
              : c.actionStatus.value.trim();
          final safeV = (v == "0" || v == "1") ? v : "1";
          return DropdownButtonFormField<String>(
            value: safeV,
            items: const [
              DropdownMenuItem(value: "1", child: Text("Active")),
              DropdownMenuItem(
                  value: "0", child: Text("Inactive")),
            ],
            onChanged: (val) =>
            c.actionStatus.value = val ?? '1',
            decoration: _editInputDeco('Status',
                icon: Icons.toggle_on_outlined),
          );
        }),
        SizedBox(height: 10.h),

        _tfEdit("Student Name *", c.studentName.value,
                (v) => c.studentName.value = v),
        _tfEdit("Father Name", c.fatherName.value,
                (v) => c.fatherName.value = v),
        _tfEdit("Mother Name", c.motherName.value,
                (v) => c.motherName.value = v),
        _tfEdit("Father Occupation", c.fatherOccupation.value,
                (v) => c.fatherOccupation.value = v),
        _dropdownEdit(
            label: "Gender",
            valueRx: c.gender,
            items: const ["Boy", "Girl", "Other"]),

        // ── DOB picker — original ──────────────────────
        _dobPickerEdit(context, c),

        // ── Admission Date picker — FIXED (same as DOB) ──
        _admissionDatePickerEdit(context, c),

        _dropdownEdit(
            label: "Blood Group",
            valueRx: c.bloodGroup,
            items: const ["A-", "A+", "B-", "B+", "O-", "O+"]),
        _tfEdit("Religion", c.religion.value,
                (v) => c.religion.value = v),
        _tfEdit("Phone *", c.phone.value,
                (v) => c.phone.value = v,
            keyboardType: TextInputType.phone),
        _tfEdit("WhatsApp No", c.whatsappNo.value,
                (v) => c.whatsappNo.value = v,
            keyboardType: TextInputType.phone),
        _tfEdit("Emergency No", c.emergencyNo.value,
                (v) => c.emergencyNo.value = v,
            keyboardType: TextInputType.phone),
        _tfEdit("Email", c.emailController.text,
                (v) => c.emailController.text = v,
            keyboardType: TextInputType.emailAddress),
        _tfEdit("From Time", c.fromTime.value,
                (v) => c.fromTime.value = v),
        _tfEdit("To Time", c.toTime.value,
                (v) => c.toTime.value = v),

        SizedBox(height: 14.h),
        Text("Update Photos",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: _teal)),
        SizedBox(height: 10.h),

        _imageRowEdit(
            context: context,
            title: "Student Photo",
            pickedRx: c.fileImage,
            oldUrl: _url(student.studentPic, _studentBase),
            onPick: () =>
                _pickImgEdit(context, c, c.fileImage)),
        _imageRowEdit(
            context: context,
            title: "Father Photo",
            pickedRx: c.fatherPic,
            oldUrl: _url(student.fatherPic, _fatherBase),
            onPick: () =>
                _pickImgEdit(context, c, c.fatherPic)),
        _imageRowEdit(
            context: context,
            title: "Mother Photo",
            pickedRx: c.motherPic,
            oldUrl: _url(student.motherPic, _motherBase),
            onPick: () =>
                _pickImgEdit(context, c, c.motherPic)),
        _imageRowEdit(
            context: context,
            title: "Guardian Photo",
            pickedRx: c.guardianImage,
            oldUrl: _url(student.guardianImage, _guardianBase),
            onPick: () =>
                _pickImgEdit(context, c, c.guardianImage)),
      ],
    );
  }

  // ── DOB picker — original ─────────────────────────────────
  Widget _dobPickerEdit(
      BuildContext context,
      daycare_controller.StudentControllerdaycare c,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: c.dob,
        readOnly: true,
        decoration: _editInputDeco("Date of Birth",
            icon: Icons.calendar_month_outlined),
        onTap: () async {
          DateTime initial = DateTime.now();
          final txt = c.dob.text.trim();
          if (txt.isNotEmpty) {
            final parts = txt.split('-');
            if (parts.length == 3) {
              final d = int.tryParse(parts[0]);
              final m = int.tryParse(parts[1]);
              final y = int.tryParse(parts[2]);
              if (d != null && m != null && y != null) {
                initial = DateTime(y, m, d);
              }
            }
          }
          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (ctx, child) => Theme(
              data: ThemeData.light().copyWith(
                  colorScheme:
                  const ColorScheme.light(primary: _teal)),
              child: child!,
            ),
          );
          if (picked != null) {
            final dd   = picked.day.toString().padLeft(2, '0');
            final mm   = picked.month.toString().padLeft(2, '0');
            final yyyy = picked.year.toString();
            c.dob.text          = "$dd-$mm-$yyyy";
            c.dateOfBirth.value = c.dob.text;
          }
        },
      ),
    );
  }

  // ── Admission Date picker — FIXED ────────────────────────
  Widget _admissionDatePickerEdit(
      BuildContext context,
      daycare_controller.StudentControllerdaycare c,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: c.admissionDateController,
        readOnly: true,
        decoration: _editInputDeco("Admission Date",
            icon: Icons.calendar_month_outlined),
        onTap: () async {
          // Parse existing value so picker opens on correct date
          DateTime initial = DateTime.now();
          final txt = c.admissionDateController.text.trim();
          if (txt.isNotEmpty) {
            final parts = txt.split('-');
            if (parts.length == 3) {
              final d = int.tryParse(parts[0]);
              final m = int.tryParse(parts[1]);
              final y = int.tryParse(parts[2]);
              if (d != null && m != null && y != null) {
                initial = DateTime(y, m, d);
              }
            }
          }
          final picked = await showDatePicker(
            context: context,
            initialDate: initial,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
              data: ThemeData.light().copyWith(
                  colorScheme:
                  const ColorScheme.light(primary: _teal)),
              child: child!,
            ),
          );
          if (picked != null) {
            final dd   = picked.day.toString().padLeft(2, '0');
            final mm   = picked.month.toString().padLeft(2, '0');
            final yyyy = picked.year.toString();
            c.admissionDateController.text = "$dd-$mm-$yyyy";
            c.admissionDate.value          = "$dd-$mm-$yyyy";
          }
        },
      ),
    );
  }

  // ── Edit text field ───────────────────────────────────────
  Widget _tfEdit(
      String label,
      String initial,
      Function(String) onChanged, {
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _editInputDeco(label),
      ),
    );
  }

  // ── Edit dropdown ─────────────────────────────────────────
  Widget _dropdownEdit({
    required String label,
    required RxString valueRx,
    required List<String> items,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Obx(() {
        final current = valueRx.value.trim();
        final safeValue =
        (current.isEmpty || !items.contains(current))
            ? null
            : current;
        return DropdownButtonFormField<String>(
          value: safeValue,
          items: items
              .map((e) =>
              DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => valueRx.value = v ?? '',
          decoration: _editInputDeco(label),
        );
      }),
    );
  }

  // ── Edit image row ────────────────────────────────────────
  Widget _imageRowEdit({
    required BuildContext context,
    required String title,
    required Rx<File?> pickedRx,
    required String? oldUrl,
    required VoidCallback onPick,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: _textPrimary)),
          ),
          Obx(() {
            final picked = pickedRx.value;
            Widget preview;
            if (picked != null) {
              preview = ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.file(picked,
                    height: 56, width: 56, fit: BoxFit.cover),
              );
            } else if (oldUrl != null) {
              preview = ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.network(oldUrl,
                    height: 56,
                    width: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _smallPlaceholder()),
              );
            } else {
              preview = _smallPlaceholder();
            }
            return Row(children: [
              preview,
              SizedBox(width: 8.w),
              OutlinedButton(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _teal),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 8.h),
                ),
                child: Text("Pick",
                    style: TextStyle(
                        color: _teal, fontSize: 12.sp)),
              ),
            ]);
          }),
        ],
      ),
    );
  }

  // ── Edit image picker ─────────────────────────────────────
  Future<void> _pickImgEdit(
      BuildContext context,
      daycare_controller.StudentControllerdaycare c,
      Rx<File?> target,
      ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Choose Photo',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    color: _textPrimary)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: _teal),
            title: const Text("Gallery"),
            onTap: () =>
                Navigator.pop(context, ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined,
                color: _teal),
            title: const Text("Camera"),
            onTap: () =>
                Navigator.pop(context, ImageSource.camera),
          ),
        ]),
      ),
    );
    if (source != null) {
      await c.pickImage(target: target, source: source);
    }
  }

  // ── Edit input decoration ─────────────────────────────────
  InputDecoration _editInputDeco(String label,
      {IconData? icon, Color? fillColor}) {
    return InputDecoration(
      labelText: label,
      labelStyle:
      TextStyle(color: _textSecondary, fontSize: 13.sp),
      prefixIcon: icon != null
          ? Icon(icon, size: 18, color: _tealLight)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: _teal, width: 1.5),
      ),
      filled: true,
      fillColor: fillColor ?? _cardBg,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      isDense: true,
    );
  }
}