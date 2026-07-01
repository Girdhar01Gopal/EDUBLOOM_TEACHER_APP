import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/home_page_controller.dart'; // ← DashboardScreenController
import '../controller/tc_certificate_controllerdownload.dart';
import '../models/classmodel.dart';
import '../models/session_model.dart' as session_model;
import '../models/tc_certificate_modeldownload.dart';
import '../res/app_url.dart'; // ← AppUrl.dashurl

class TcCertificateScreen extends GetView<TcCertificateController> {
  const TcCertificateScreen({Key? key}) : super(key: key);

  // ── Dynamic school logo URL — same as AppDrawer ──────────────
  String get _dynamicSchoolLogoUrl {
    try {
      final dashCtrl = Get.find<DashboardScreenController>();
      final logoPath = dashCtrl.schoollogo.value;
      if (logoPath.isNotEmpty) {
        return '${AppUrl.dashurl}/$logoPath';
      }
    } catch (_) {}
    return '';
  }

  // ── School Logo Widget — white circle avatar ─────────────────
  Widget _buildSchoolLogoAvatar() {
    final logoUrl = _dynamicSchoolLogoUrl;
    return Container(
      height: 70,
      width: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: logoUrl.isNotEmpty
            ? Image.network(
          logoUrl,
          height: 70,
          width: 70,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.school,
            size: 36,
            color: Color(0xFF99144E),
          ),
        )
            : const Icon(
          Icons.school,
          size: 36,
          color: Color(0xFF99144E),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "📚 Transfer Certificate",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF99144E),
        elevation: 4,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final TcStudentData? student = controller.studentDetail.value;

        if (student == null) {
          return const Center(
            child: Text(
              "No data found.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── School Header ──────────────────────────────
                Center(
                  child: Column(
                    children: [
                      // ── Dynamic logo in white circle avatar ──
                      _buildSchoolLogoAvatar(),
                      const SizedBox(height: 6),
                      Text(
                        student.schoolName ?? "",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        student.schoolAddress ?? "",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding:
                        const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            "📚 Transfer Certificate",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── SR No + Registration No ────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        label: "Sr.no",
                        fieldController: controller.srNoController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        label: "Registration No",
                        fieldController:
                        controller.registrationNoController,
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Session Dropdown ───────────────────────────
                _buildSessionDropdown(),
                const SizedBox(height: 14),

                _buildField(
                  label: "1. Name of the Pupil",
                  fieldController: controller.studentNameController,
                ),
                const SizedBox(height: 14),

                _buildField(
                  label: "2. Mother's Name",
                  fieldController: controller.motherNameController,
                ),
                const SizedBox(height: 14),

                _buildField(
                  label: "3. Father's Name",
                  fieldController: controller.fatherNameController,
                ),
                const SizedBox(height: 14),

                _buildField(
                  label: "4. Date of Admission",
                  fieldController:
                  controller.admissionDateController,
                  readOnly: true,
                ),
                const SizedBox(height: 14),

                _buildField(
                  label: "5. Date of Birth",
                  fieldController: controller.dobController,
                  readOnly: true,
                ),
                const SizedBox(height: 14),

                // ── Class Last Studied Dropdown ────────────────
                _buildClassDropdown(),
                const SizedBox(height: 14),

                _buildField(
                  label: "7. Month up to which fees paid",
                  fieldController: controller.feesPaidController,
                ),
                const SizedBox(height: 14),

                _buildDateField(context),
                const SizedBox(height: 14),

                _buildField(
                  label: "9. Reason for Leaving",
                  fieldController: controller.reasonController,
                ),
                const SizedBox(height: 14),

                _buildField(
                  label: "10. Remarks",
                  fieldController: controller.remarksController,
                ),
                const SizedBox(height: 30),

                // ── Save & Next Button ─────────────────────────
                Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null // disable while saving
                      : () => controller.saveTcCertificate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF99144E),
                    disabledBackgroundColor:
                    const Color(0xFFD195AF),
                    padding:
                    const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "Save Transfer Certificate",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Session Dropdown Widget ────────────────────────────────
  Widget _buildSessionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Session",
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() => DropdownButtonFormField<session_model.sListDdata>(
          value: controller.selectedSession.value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
              BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: const Text("Select Session"),
          items: controller.sessionList
              .map((s) => DropdownMenuItem(
            value: s,
            child: Text(s.session ?? ""),
          ))
              .toList(),
          onChanged: (val) {
            if (val != null)
              controller.setSelectedSession(val);
          },
        )),
      ],
    );
  }

  // ── Class Last Studied Dropdown Widget ────────────────────
  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "6. Class Last Studied",
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Obx(() => DropdownButtonFormField<ListDataa>(
          value: controller.selectedClass.value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
              BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          hint: const Text("Select Class"),
          items: controller.classList
              .map((c) => DropdownMenuItem(
            value: c,
            child: Text(c.className ?? ""),
          ))
              .toList(),
          onChanged: (val) {
            if (val != null) controller.setSelectedClass(val);
          },
        )),
      ],
    );
  }

  // ── Text Field Widget ──────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController fieldController,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: fieldController,
          readOnly: readOnly,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor:
            readOnly ? Colors.grey.shade100 : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "8. Date of Issue",
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller.dateOfIssueController,
          readOnly: true,
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              controller.dateOfIssueController.text =
              "${picked.day.toString().padLeft(2, '0')}-"
                  "${picked.month.toString().padLeft(2, '0')}-"
                  "${picked.year}";
            }
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            suffixIcon:
            const Icon(Icons.calendar_today, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: "dd-mm-yyyy",
          ),
        ),
      ],
    );
  }
}