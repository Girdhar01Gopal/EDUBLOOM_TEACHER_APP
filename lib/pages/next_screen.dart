// ============================================================
// FILE PATH: lib/pages/next_student.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model;

import '../controller/student_controller.dart';
import 'next_next_student.dart';


// ─── Palette (same as StudentScreen) ───────────────────────
const _teal          = Color(0xFF00695C);
const _tealLight     = Color(0xFF26A69A);
const _cardBg        = Color(0xFFF8FFFE);
const _surface       = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF607D8B);
const _textPrimary   = Color(0xFF1A2B3C);
const _divider       = Color(0xFFE0F2F1);

class NextStudent extends GetView<StudentController> {
  final _formKey           = GlobalKey<FormState>();
  final _studentPhoneCtrl  = TextEditingController();
  final _whatsappCtrl      = TextEditingController();

  // Admission date controller (display only — set by picker)
  final _admissionDateCtrl = TextEditingController();

  // ✅ FIX: RxBool instead of mutable bool field (keeps widget immutable-safe)
  final RxBool _sameAsStudentPhone = false.obs;

  // ── Student phone changed ─────────────────────────────────
  void _onStudentPhoneChanged(String v, StateSetter ss) {
    controller.phone.value = v;
    if (_sameAsStudentPhone.value) {
      _whatsappCtrl.text = v;
      _whatsappCtrl.selection =
          TextSelection.fromPosition(TextPosition(offset: v.length));
      controller.whatsappNo.value = v;
    }
  }

  // ── Toggle checkbox ───────────────────────────────────────
  void _toggle(bool? val, StateSetter ss) {
    ss(() => _sameAsStudentPhone.value = val ?? false);
    if (_sameAsStudentPhone.value) {
      _whatsappCtrl.text = controller.phone.value;
      controller.whatsappNo.value = controller.phone.value;
    } else {
      _whatsappCtrl.clear();
      controller.whatsappNo.value = '';
    }
  }

  // ── Date Picker (today ya past only, dd/mm/yyyy format) ───
  Future<void> _pickAdmissionDate(
      BuildContext context, StateSetter ss) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000),   // sabse pehli allowed date
      lastDate: today,             // future dates disabled
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _teal,
              onPrimary: Colors.white,
              onSurface: _textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _teal),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // dd/mm/yyyy format
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/'
          '${picked.month.toString().padLeft(2, '0')}/'
          '${picked.year}';
      ss(() {
        _admissionDateCtrl.text = formatted;
        controller.admissionDate.value = formatted;
      });
    }
  }

  // ── InputDecoration (same as AddStudentTab._inputDeco) ────
  InputDecoration _inputDeco(String label,
      {IconData? icon, bool required = false}) {
    return InputDecoration(
      labelText: required ? '$label *' : label,
      labelStyle: TextStyle(color: _textSecondary, fontSize: 14.sp),
      prefixIcon:
      icon != null ? Icon(icon, size: 20, color: _tealLight) : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _divider)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _teal, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red, width: 1.2)),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      filled: true,
      fillColor: _cardBg,
      contentPadding:
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      counterText: '',
    );
  }

  // ── Card wrapper (same as AddStudentTab._buildCard) ───────
  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── Section header (same as AddStudentTab._sectionHeader) ─
  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
      child: Row(children: [
        Icon(icon, size: 18, color: _teal),
        SizedBox(width: 6.w),
        Text(title,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: _teal,
                letterSpacing: 0.5)),
      ]),
    );
  }

  // ── Required TextField ────────────────────────────────────
  Widget _requiredTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
    TextEditingController? extController,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: extController,
        onChanged: onChanged,
        keyboardType: keyboard,
        maxLength: maxLength,
        inputFormatters: keyboard == TextInputType.phone
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: _inputDeco(label, icon: icon, required: true),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          if (keyboard == TextInputType.phone &&
              maxLength == 10 &&
              v.length != 10) return 'Must be 10 digits';
          return null;
        },
      ),
    );
  }

  // ── Optional TextField ────────────────────────────────────
  Widget _normalField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboard = TextInputType.text,
    int? maxLength,
    TextEditingController? extController,
    bool enabled = true,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: extController,
        enabled: enabled,
        onChanged: onChanged,
        keyboardType: keyboard,
        maxLength: maxLength,
        inputFormatters: keyboard == TextInputType.phone
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: _inputDeco(label, icon: icon).copyWith(
          fillColor: enabled ? _cardBg : Colors.grey.shade100,
        ),
      ),
    );
  }

  // ── Admission Date Picker Field ───────────────────────────
  Widget _admissionDateField(BuildContext context, StateSetter ss) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: _admissionDateCtrl,
        readOnly: true,                      // keyboard nahi aayega
        onTap: () => _pickAdmissionDate(context, ss),
        decoration: _inputDeco(
          'Admission Date',
          icon: Icons.calendar_today_outlined,
          required: true,
        ).copyWith(
          hintText: 'dd/mm/yyyy',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
          suffixIcon: Icon(Icons.arrow_drop_down, color: _tealLight),
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Required';
          return null;
        },
      ),
    );
  }

  // ── WhatsApp checkbox row ─────────────────────────────────
  Widget _checkboxRow(StateSetter ss) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: InkWell(
        onTap: () => _toggle(!_sameAsStudentPhone.value, ss),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding:
          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _sameAsStudentPhone.value
                ? _teal.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: _sameAsStudentPhone.value
                  ? _teal.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: _sameAsStudentPhone.value,
                activeColor: _teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (v) => _toggle(v, ss),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'WhatsApp same as Student Phone',
              style: TextStyle(
                  fontSize: 13.sp,
                  color:
                  _sameAsStudentPhone.value ? _teal : _textSecondary,
                  fontWeight: _sameAsStudentPhone.value
                      ? FontWeight.w600
                      : FontWeight.w400),
            ),
            const Spacer(),
            Icon(Icons.call,
                color: _sameAsStudentPhone.value
                    ? Colors.green
                    : Colors.grey.shade400,
                size: 20),
          ]),
        ),
      ),
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
          'Guardian & Contact Details',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 0.3),
        ),
      ),
      body: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ══════════════════════════════════
                  // 1. ADMISSION DATE  ← UPDATED: Calendar picker
                  // ══════════════════════════════════
                  _sectionHeader(
                      'Admission Details', Icons.event_note_outlined),
                  _buildCard([
                    _admissionDateField(context, setState),  // ← NEW
                  ]),

                  SizedBox(height: 16.h),

                  // ══════════════════════════════════
                  // 2. GUARDIAN PHONE
                  // ══════════════════════════════════
                  _sectionHeader(
                      'Guardian Information', Icons.shield_outlined),
                  _buildCard([
                    _requiredTextField(
                      label: "Guardian Phone",
                      icon: Icons.phone_outlined,
                      keyboard: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (v) =>
                      controller.guardianPhone.value = v,
                    ),
                  ]),

                  SizedBox(height: 16.h),

                  // ══════════════════════════════════
                  // 3. FAMILY INFO
                  // ══════════════════════════════════
                  _sectionHeader(
                      'Family Information', Icons.family_restroom_outlined),
                  _buildCard([
                    _normalField(
                      label: "Father Occupation",
                      icon: Icons.work_outline,
                      onChanged: (v) =>
                      controller.fatherOccupation.value = v,
                    ),
                    _requiredTextField(
                      label: "Father Name",
                      icon: Icons.person_outline,
                      onChanged: (v) =>
                      controller.fatherName.value = v,
                    ),
                    _requiredTextField(
                      label: "Mother Name",
                      icon: Icons.person_outline,
                      onChanged: (v) =>
                      controller.motherName.value = v,
                    ),
                  ]),

                  SizedBox(height: 16.h),

                  // ══════════════════════════════════
                  // 4. STUDENT CONTACT
                  //    Student Phone → Checkbox → WhatsApp → Emergency
                  // ══════════════════════════════════
                  _sectionHeader(
                      'Student Contact', Icons.contact_phone_outlined),
                  _buildCard([
                    _requiredTextField(
                      label: "Phone no",
                      icon: Icons.smartphone_outlined,
                      keyboard: TextInputType.phone,
                      maxLength: 10,
                      extController: _studentPhoneCtrl,
                      onChanged: (v) =>
                          _onStudentPhoneChanged(v, setState),
                    ),
                    _checkboxRow(setState),
                    _normalField(
                      label: "WhatsApp No",
                      icon: Icons.chat_outlined,
                      keyboard: TextInputType.phone,
                      maxLength: 10,
                      extController: _whatsappCtrl,
                      enabled: !_sameAsStudentPhone.value,
                      onChanged: (v) =>
                      controller.whatsappNo.value = v,
                    ),
                    _normalField(
                      label: "Emergency No",
                      icon: Icons.emergency_outlined,
                      keyboard: TextInputType.phone,
                      maxLength: 10,
                      onChanged: (v) =>
                      controller.emergencyNo.value = v,
                    ),
                  ]),

                  SizedBox(height: 16.h),

                  // ══════════════════════════════════
                  // 5. SESSION
                  // ══════════════════════════════════
                  _sectionHeader(
                      'Academic Session', Icons.school_outlined),
                  _buildCard([
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Obx(() {
                        return DropdownButtonFormField<
                            session_model.sListDdata>(
                          value: controller.selectedSession.value,
                          hint: Text('Select Session',
                              style: TextStyle(
                                  color: _textSecondary,
                                  fontSize: 14.sp)),
                          onChanged: (v) {
                            controller.selectedSession.value = v;
                            controller.session.value =
                                v?.session ?? '';
                          },
                          items: controller.sessionList.map((s) {
                            return DropdownMenuItem(
                                value: s,
                                child:
                                Text(s.session ?? 'No session'));
                          }).toList(),
                          decoration: _inputDeco('Session',
                              icon: Icons.calendar_month_outlined),
                        );
                      }),
                    ),
                  ]),

                  SizedBox(height: 28.h),

                  // ══════════════════════════════════
                  // SAVE & NEXT (same style as AddStudentTab)
                  // ══════════════════════════════════
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [
                              Color(0xFF00897B),
                              Color(0xFF00695C)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                              color: _teal.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(14.r)),
                        ),
                        icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white),
                        label: Text('Save & Next',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            if (controller.guardianPhone.value
                                .length !=
                                10) {
                              Get.snackbar(
                                'Error',
                                'Guardian Phone must be 10 digits',
                                backgroundColor: Colors.red.shade700,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }
                            if (controller.phone.value.length != 10) {
                              Get.snackbar(
                                'Error',
                                'Student Phone must be 10 digits',
                                backgroundColor: Colors.red.shade700,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.TOP,
                              );
                              return;
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Next2Student()));
                          }
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}