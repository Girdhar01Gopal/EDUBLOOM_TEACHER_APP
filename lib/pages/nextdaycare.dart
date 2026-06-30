// ============================================================
// FILE PATH: lib/pages/next_student_daycare.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../models/session_model.dart' as session_model show sListDdata;
import '../controller/student_controller daycare.dart' as daycare;
import 'next_next_student daycare.dart';

// ─── Palette (same as StudentScreen) ───────────────────────
const _teal          = Color(0xFF00695C);
const _tealLight     = Color(0xFF26A69A);
const _cardBg        = Color(0xFFF8FFFE);
const _surface       = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF607D8B);
const _textPrimary   = Color(0xFF1A2B3C);
const _divider       = Color(0xFFE0F2F1);

class Nextdaycare extends GetView<daycare.StudentControllerdaycare> {
  Nextdaycare({super.key});

  final _formKey       = GlobalKey<FormState>();
  final _phoneCtrl     = TextEditingController();
  final _whatsappCtrl  = TextEditingController();
  bool _sameAsPhone    = false;

  // ── Phone changed → mirror to WhatsApp if checkbox ON ────
  void _onPhoneChanged(String v, StateSetter ss) {
    controller.phone.value = v.trim();
    if (_sameAsPhone) {
      _whatsappCtrl.text = v;
      _whatsappCtrl.selection =
          TextSelection.fromPosition(TextPosition(offset: v.length));
      controller.whatsappNo.value = v.trim();
    }
  }

  // ── Toggle checkbox ───────────────────────────────────────
  void _toggle(bool? val, StateSetter ss) {
    ss(() => _sameAsPhone = val ?? false);
    if (_sameAsPhone) {
      _whatsappCtrl.text = controller.phone.value;
      controller.whatsappNo.value = controller.phone.value;
    } else {
      _whatsappCtrl.clear();
      controller.whatsappNo.value = '';
    }
  }

  // ── InputDecoration ───────────────────────────────────────
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

  // ── Card wrapper ──────────────────────────────────────────
  Widget _buildCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  // ── Section header ────────────────────────────────────────
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

  // ── Required phone field ──────────────────────────────────
  Widget _requiredPhoneField({
    required String label,
    required Function(String) onChanged,
    TextEditingController? extController,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: extController,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDeco(label, icon: icon, required: true),
        validator: (value) {
          final v = (value ?? '').trim();
          if (v.isEmpty) return "Required";
          if (!RegExp(r'^\d{10}$').hasMatch(v)) {
            return "Enter valid 10-digit number";
          }
          return null;
        },
      ),
    );
  }

  // ── Required text field ───────────────────────────────────
  Widget _requiredTextField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        keyboardType: keyboard,
        onChanged: onChanged,
        decoration: _inputDeco(label, icon: icon, required: true),
        validator: (value) =>
        (value == null || value.trim().isEmpty) ? "Required" : null,
      ),
    );
  }

  // ── Optional text field ───────────────────────────────────
  Widget _normalField({
    required String label,
    required Function(String) onChanged,
    TextInputType keyboard = TextInputType.text,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        keyboardType: keyboard,
        onChanged: onChanged,
        decoration: _inputDeco(label, icon: icon),
      ),
    );
  }

  // ── Optional 10-digit phone field ─────────────────────────
  Widget _optional10DigitPhoneField({
    required String label,
    required Function(String) onChanged,
    TextEditingController? extController,
    bool enabled = true,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: TextFormField(
        controller: extController,
        enabled: enabled,
        keyboardType: TextInputType.phone,
        maxLength: 10,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: _inputDeco(label, icon: icon).copyWith(
          fillColor: enabled ? _cardBg : Colors.grey.shade100,
        ),
        validator: (value) {
          final v = (value ?? '').trim();
          if (v.isEmpty) return null;
          if (!RegExp(r'^\d{10}$').hasMatch(v)) {
            return "Enter valid 10-digit number";
          }
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
        onTap: () => _toggle(!_sameAsPhone, ss),
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding:
          EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _sameAsPhone
                ? _teal.withOpacity(0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: _sameAsPhone
                  ? _teal.withOpacity(0.3)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: _sameAsPhone,
                activeColor: _teal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                onChanged: (v) => _toggle(v, ss),
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'WhatsApp same as Phone',
              style: TextStyle(
                  fontSize: 13.sp,
                  color: _sameAsPhone ? _teal : _textSecondary,
                  fontWeight: _sameAsPhone
                      ? FontWeight.w600
                      : FontWeight.w400),
            ),
            const Spacer(),
            Icon(Icons.call,
                color:
                _sameAsPhone ? Colors.green : Colors.grey.shade400,
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
          'Add Daycare Student',
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
                  // 1. CONTACT INFO
                  //    Phone → Checkbox → WhatsApp → Emergency
                  // ══════════════════════════════════
                  _sectionHeader(
                      'Contact Information', Icons.contact_phone_outlined),
                  _buildCard([
                    _requiredPhoneField(
                      label: "Phone",
                      icon: Icons.phone_outlined,
                      extController: _phoneCtrl,
                      onChanged: (v) => _onPhoneChanged(v, setState),
                    ),
                    _checkboxRow(setState),
                    _optional10DigitPhoneField(
                      label: "WhatsApp No",
                      icon: Icons.chat_outlined,
                      extController: _whatsappCtrl,
                      enabled: !_sameAsPhone,
                      onChanged: (v) =>
                      controller.whatsappNo.value = v.trim(),
                    ),
                    _optional10DigitPhoneField(
                      label: "Emergency No",
                      icon: Icons.emergency_outlined,
                      onChanged: (v) =>
                      controller.emergencyNo.value = v.trim(),
                    ),
                  ]),

                  SizedBox(height: 16.h),

                  // ══════════════════════════════════
                  // 2. FAMILY INFO
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
                  // 3. SESSION
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
                          onChanged: (newVal) {
                            controller.selectedSession.value = newVal;
                            controller.session.value =
                                newVal?.session ?? '';
                          },
                          items: controller.sessionList.map((session) {
                            return DropdownMenuItem(
                                value: session,
                                child: Text(
                                    session.session ?? 'No session'));
                          }).toList(),
                          decoration: _inputDeco('Session',
                              icon: Icons.calendar_month_outlined),
                          validator: (val) =>
                          val == null ? "Required" : null,
                        );
                      }),
                    ),
                  ]),

                  SizedBox(height: 28.h),

                  // ══════════════════════════════════
                  // SAVE & NEXT
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
                              color: _teal.withOpacity(0.4),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    NextNextStudentdaycare(),
                              ),
                            );
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