// ============================================================
// FILE PATH: lib/pages/guardian_image_picker daycare.dart
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controller/student_controller daycare.dart';

// ─── Palette ───────────────────────────────────────────────
const _teal      = Color(0xFF00695C);
const _tealLight = Color(0xFF26A69A);
const _surface   = Color(0xFFFFFFFF);
const _cardBg    = Color(0xFFF8FFFE);
const _textPrimary   = Color(0xFF1A2B3C);
const _textSecondary = Color(0xFF607D8B);

class GuardianImagePickerdaycare extends GetView<StudentControllerdaycare> {
  GuardianImagePickerdaycare({super.key});

  // Override controller with Get.put to ensure it's found
  @override
  StudentControllerdaycare get controller =>
      Get.put(StudentControllerdaycare());

  // ── Bottom sheet image picker ─────────────────────────────
  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ImageSourceSheet(title: "Guardian's Photo"),
    );
    if (source == null) return;

    final XFile? picked = await controller.picker.pickImage(source: source);
    if (picked != null) {
      controller.guardianImage.value = File(picked.path);
    } else {
      Get.snackbar('Notice', 'No image selected.',
          backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  // ── Time picker helper ────────────────────────────────────
  Future<void> _pickTime(
      BuildContext context, RxString target, String label) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: _teal),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      target.value = picked.format(context);
    }
  }

  InputDecoration _timeDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textSecondary, fontSize: 14.sp),
      prefixIcon: Icon(icon, size: 20, color: _tealLight),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE0F2F1))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _teal, width: 1.5)),
      filled: true,
      fillColor: _cardBg,
      suffixIcon: const Icon(Icons.access_time_outlined, color: _tealLight),
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Guardian's Photo",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            _StepIndicator(current: 4, total: 4),
            SizedBox(height: 16.h),

            // Completion banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: _teal, size: 18),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Last step! Set daycare timings, add guardian photo, then submit.',
                      style: TextStyle(
                          color: _teal,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // ── Daycare Timing Card ──────────────────────────
            _sectionHeader('Daycare Timing', Icons.schedule_outlined),
            Container(
              padding: EdgeInsets.all(16.r),
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
                children: [
                  // From Time
                  GestureDetector(
                    onTap: () =>
                        _pickTime(context, controller.fromTime, 'From Time'),
                    child: AbsorbPointer(
                      child: Obx(() => TextFormField(
                        controller: TextEditingController(
                            text: controller.fromTime.value),
                        decoration: _timeDeco(
                            'From Time', Icons.play_circle_outline),
                      )),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // To Time
                  GestureDetector(
                    onTap: () =>
                        _pickTime(context, controller.toTime, 'To Time'),
                    child: AbsorbPointer(
                      child: Obx(() => TextFormField(
                        controller: TextEditingController(
                            text: controller.toTime.value),
                        decoration: _timeDeco(
                            'To Time', Icons.stop_circle_outlined),
                      )),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── Image Preview ────────────────────────────────
            _ImagePreviewCard(
              pickedRx: controller.guardianImage,
              placeholder: 'Guardian',
              icon: Icons.shield_outlined,
            ),

            SizedBox(height: 20.h),

            // Pick Photo button
            _PickButton(
              label: "Select Guardian's Photo",
              icon: Icons.add_a_photo_outlined,
              onTap: () => _pickImage(context),
            ),

            SizedBox(height: 14.h),

            // Submit button (red gradient)
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFC62828)],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  icon: const Icon(Icons.check_circle_outline,
                      color: Colors.white),
                  label: Text(
                    'Submit & Register Student',
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  onPressed: () {
                    controller.registerStudent();
                  },
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _teal),
          SizedBox(width: 6.w),
          Text(title,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: _teal,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i < current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: active ? 28.w : 10.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: active ? _teal : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  final Rx<File?> pickedRx;
  final String placeholder;
  final IconData icon;
  const _ImagePreviewCard({
    required this.pickedRx,
    required this.placeholder,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Obx(() {
            final file = pickedRx.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: file != null
                  ? Image.file(file,
                  height: 200.h, width: 200.h, fit: BoxFit.cover)
                  : Container(
                height: 200.h,
                width: 200.h,
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: Colors.teal.shade100, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 60.w, color: _tealLight),
                    SizedBox(height: 8.h),
                    Text(placeholder,
                        style: TextStyle(
                            color: _textSecondary,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: 4.h),
                    Text('No photo selected',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11.sp)),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 12.h),
          Obx(() => pickedRx.value != null
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  color: Color(0xFF43A047), size: 16),
              SizedBox(width: 6.w),
              Text('Photo selected',
                  style: TextStyle(
                      color: const Color(0xFF43A047),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600)),
            ],
          )
              : Text('Tap below to add a photo',
              style:
              TextStyle(color: _textSecondary, fontSize: 12.sp))),
        ],
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PickButton(
      {required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: _teal),
        label: Text(label,
            style: TextStyle(
                color: _teal, fontWeight: FontWeight.w600, fontSize: 14.sp)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _teal, width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r)),
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  final String title;
  const _ImageSourceSheet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2)),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined, color: _teal),
              SizedBox(width: 10.w),
              Text('Choose Photo — $title',
                  style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A2B3C))),
            ],
          ),
          SizedBox(height: 20.h),
          _SourceTile(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            subtitle: 'Take a new photo',
            color: _teal,
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          SizedBox(height: 12.h),
          _SourceTile(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            subtitle: 'Choose from photos',
            color: Colors.indigo,
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: color, size: 22),
            ),
            SizedBox(width: 14.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: const Color(0xFF1A2B3C))),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.sp, color: const Color(0xFF607D8B))),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}