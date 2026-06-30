import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/student_controller.dart';
import '../models/student_model.dart';

// ─── Palette ───────────────────────────────────────────────
const _teal = Color(0xFF00695C);
const _tealLight = Color(0xFF26A69A);
const _surface = Color(0xFFFFFFFF);
const _cardBg = Color(0xFFF8FFFE);
const _textPrimary = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF607D8B);

class StudentDetailScreen extends StatelessWidget {
  final StudentData student;
  const StudentDetailScreen({super.key, required this.student});

  // ── helpers ──────────────────────────────────────────────
  static String _fmt(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";
    } catch (_) {
      return dateString;
    }
  }

  String _normalizeGender(String? g) {
    final v = (g ?? '').trim().toLowerCase();
    if (v == 'male' || v == 'm' || v == 'boy') return 'Boy';
    if (v == 'female' || v == 'f' || v == 'girl') return 'Girl';
    if (v == 'other') return 'Other';
    return '';
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
                  child:
                  const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentUrl =
    (student.studentPic != null && student.studentPic!.isNotEmpty)
        ? "https://playschool.edubloom.in/Upload/student/images/${student.studentPic}"
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          student.studentName ?? 'Student Details',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: "Edit Student",
            onPressed: () => _openEditDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profileHeader(context, studentUrl),
            SizedBox(height: 16.h),
            _infoCard('Personal Information', [
              _detailRow('Father', student.fatherName),
              _detailRow('Mother', student.motherName),
              _detailRow('Father Occupation', student.fatherOccupation),
              _detailRow('Gender', student.gender),
              _detailRow(
                  'DOB',
                  student.dateOfBirth != null
                      ? _fmt(student.dateOfBirth!)
                      : '-'),
              _detailRow('Religion', student.religion),
              _detailRow('Blood Group', student.bloodGroup),
              _detailRow('Address', student.address),
              _detailRow('Aadhar No.', student.aAdharNo ?? '-'),
            ]),
            SizedBox(height: 12.h),
            _infoCard('Academic Details', [
              _detailRow('Class', student.className),
              _detailRow('Section', student.sectionName),
              _detailRow('Roll No', student.rollNo),
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
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

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
                  errorBuilder: (_, __, ___) => Icon(Icons.person,
                      size: 44.w, color: Colors.white70),
                )
                    : Icon(Icons.person, size: 44.w, color: Colors.white70),
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
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        student.session ?? '-',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              title,
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
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _imagesCard(BuildContext context) {
    String? fatherUrl;
    String? motherUrl;
    String? guardianUrl;

    if (student.fatherPic != null && student.fatherPic!.isNotEmpty) {
      fatherUrl =
      "https://playschool.edubloom.in/Upload/father/images/${student.fatherPic}";
    }
    if (student.motherPic != null && student.motherPic!.isNotEmpty) {
      motherUrl =
      "https://playschool.edubloom.in/Upload/mother/images/${student.motherPic}";
    }
    if (student.guardianImage != null && student.guardianImage!.isNotEmpty) {
      guardianUrl =
      "https://playschool.edubloom.in/Upload/guardian/images/${student.guardianImage}";
    }

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
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                _photoBox(context, 'Father', fatherUrl),
                _photoBox(context, 'Mother', motherUrl),
                _photoBox(context, 'Guardian', guardianUrl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, dynamic value, {bool isHighlight = false}) {
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
                  color: _textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: TextStyle(
                fontSize: 13.sp,
                color: isHighlight ? _teal : _textPrimary,
                fontWeight:
                isHighlight ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoBox(BuildContext context, String title, String? url) {
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
                errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
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

  Widget _placeholder() {
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

  // ── Edit Dialog ───────────────────────────────────────────
  void _openEditDialog(BuildContext context) {
    final c = Get.find<StudentController>();

    c.studentName.value = student.studentName ?? '';
    c.fatherName.value = student.fatherName ?? '';
    c.motherName.value = student.motherName ?? '';
    c.fatherOccupation.value = student.fatherOccupation ?? '';
    c.gender.value = _normalizeGender(student.gender);

    if (student.dateOfBirth != null && student.dateOfBirth!.trim().isNotEmpty) {
      c.dob.text = _fmt(student.dateOfBirth!);
      c.dateOfBirth.value = c.dob.text;
    } else {
      c.dob.text = '';
      c.dateOfBirth.value = '';
    }

    c.bloodGroup.value = student.bloodGroup ?? '';
    c.religion.value = student.religion ?? '';
    c.rollNo.value = student.rollNo ?? '';
    c.address.value = student.address ?? '';
    c.aAdharNo.value = student.aAdharNo ?? '';
    c.phone.value = student.phone ?? '';
    c.whatsappNo.value = student.whatsAppNo ?? '';
    c.emergencyNo.value = student.emergencyNo ?? '';
    c.emailController.text = student.email ?? '';

    final act = (student.action ?? '').trim();
    c.actionStatus.value = act.isEmpty ? '1' : act;

    c.fileImage.value = null;
    c.fatherPic.value = null;
    c.motherPic.value = null;
    c.guardianImage.value = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                            colors: [_tealLight, _teal])),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text("Edit Student Details",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp)),
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
                      border:
                      Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _teal),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                              EdgeInsets.symmetric(vertical: 12.h),
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
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                              EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            icon: const Icon(Icons.save_outlined, size: 18),
                            label: const Text("Update Student"),
                            onPressed: () {
                              if (student.studentID == null) {
                                Get.snackbar("Error", "StudentID missing",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              if (c.studentName.value.trim().isEmpty) {
                                Get.snackbar(
                                    "Error", "Student Name required",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white);
                                return;
                              }
                              if (c.phone.value.trim().isEmpty) {
                                Get.snackbar("Error", "Phone required",
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

  Widget _editForm(StudentController c, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
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
            decoration: _editDeco("Status", icon: Icons.toggle_on_outlined),
          );
        }),
        SizedBox(height: 10.h),
        _tf("Student Name *", c.studentName.value,
                (v) => c.studentName.value = v),
        _tf("Father Name", c.fatherName.value, (v) => c.fatherName.value = v),
        _tf("Mother Name", c.motherName.value, (v) => c.motherName.value = v),
        _tf("Father Occupation", c.fatherOccupation.value,
                (v) => c.fatherOccupation.value = v),
        _dropdown("Gender", c.gender, const ["Boy", "Girl", "Other"]),
        _dobPicker(context, c),
        _dropdown("Blood Group", c.bloodGroup,
            const ["A-", "A+", "B-", "B+", "O-", "O+"]),
        _tf("Religion", c.religion.value, (v) => c.religion.value = v),
        _tf("Roll No", c.rollNo.value, (v) => c.rollNo.value = v),
        _tf("Phone *", c.phone.value, (v) => c.phone.value = v,
            keyboardType: TextInputType.phone),
        _tf("WhatsApp No", c.whatsappNo.value, (v) => c.whatsappNo.value = v,
            keyboardType: TextInputType.phone),
        _tf("Emergency No", c.emergencyNo.value,
                (v) => c.emergencyNo.value = v,
            keyboardType: TextInputType.phone),
        _tf("Email", c.emailController.text, (v) => c.emailController.text = v,
            keyboardType: TextInputType.emailAddress),
        _tf("Address", c.address.value, (v) => c.address.value = v,
            maxLines: 2),
        _tf("Aadhar No.", c.aAdharNo.value, (v) => c.aAdharNo.value = v),
        SizedBox(height: 14.h),
        Text("Update Photos",
            style: TextStyle(
                fontWeight: FontWeight.w700, fontSize: 14.sp, color: _teal)),
        SizedBox(height: 10.h),
        _imageRow(
          "Student Photo",
          c.fileImage,
          (student.studentPic?.isNotEmpty ?? false)
              ? "https://playschool.edubloom.in/Upload/student/images/${student.studentPic}"
              : null,
              () => _pickImg(context, c, c.fileImage),
        ),
        _imageRow(
          "Father Photo",
          c.fatherPic,
          (student.fatherPic?.isNotEmpty ?? false)
              ? "https://playschool.edubloom.in/Upload/father/images/${student.fatherPic}"
              : null,
              () => _pickImg(context, c, c.fatherPic),
        ),
        _imageRow(
          "Mother Photo",
          c.motherPic,
          (student.motherPic?.isNotEmpty ?? false)
              ? "https://playschool.edubloom.in/Upload/mother/images/${student.motherPic}"
              : null,
              () => _pickImg(context, c, c.motherPic),
        ),
        _imageRow(
          "Guardian Photo",
          c.guardianImage,
          (student.guardianImage?.isNotEmpty ?? false)
              ? "https://playschool.edubloom.in/Upload/guardian/images/${student.guardianImage}"
              : null,
              () => _pickImg(context, c, c.guardianImage),
        ),
      ],
    );
  }

  Widget _tf(
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
        decoration: _editDeco(label),
      ),
    );
  }

  Widget _dropdown(String label, RxString valueRx, List<String> items) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Obx(() {
        final current = valueRx.value.trim();
        final safe =
        (current.isEmpty || !items.contains(current)) ? null : current;
        return DropdownButtonFormField<String>(
          value: safe,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => valueRx.value = v ?? '',
          decoration: _editDeco(label),
        );
      }),
    );
  }

  Widget _dobPicker(BuildContext context, StudentController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: TextFormField(
        controller: c.dob,
        readOnly: true,
        decoration:
        _editDeco("Date of Birth", icon: Icons.calendar_month_outlined),
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
                  colorScheme: const ColorScheme.light(primary: _teal)),
              child: child!,
            ),
          );
          if (picked != null) {
            final dd = picked.day.toString().padLeft(2, '0');
            final mm = picked.month.toString().padLeft(2, '0');
            final yyyy = picked.year.toString();
            c.dob.text = "$dd-$mm-$yyyy";
            c.dateOfBirth.value = c.dob.text;
          }
        },
      ),
    );
  }

  Widget _imageRow(
      String title, Rx<File?> pickedRx, String? oldUrl, VoidCallback onPick) {
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
                      height: 56, width: 56, fit: BoxFit.cover));
            } else if (oldUrl != null) {
              preview = ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.network(oldUrl,
                      height: 56,
                      width: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _smallPlaceholder()));
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
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                ),
                child: Text("Pick",
                    style: TextStyle(color: _teal, fontSize: 12.sp)),
              ),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _smallPlaceholder() {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.image_outlined, color: _tealLight),
    );
  }

  Future<void> _pickImg(BuildContext context, StudentController c,
      Rx<File?> targetRx) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
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
            leading: const Icon(Icons.camera_alt_outlined, color: _teal),
            title: const Text("Camera"),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading:
            const Icon(Icons.photo_library_outlined, color: _teal),
            title: const Text("Gallery"),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
        ]),
      ),
    );
    if (source == null) return;
    final picked = await c.picker.pickImage(source: source);
    if (picked != null) {
      targetRx.value = File(picked.path);
    }
  }

  InputDecoration _editDeco(String label,
      {IconData? icon, Color? fillColor}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textSecondary, fontSize: 13.sp),
      prefixIcon:
      icon != null ? Icon(icon, size: 18, color: _tealLight) : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _teal, width: 1.5)),
      filled: true,
      fillColor: fillColor ?? _cardBg,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      isDense: true,
    );
  }
}