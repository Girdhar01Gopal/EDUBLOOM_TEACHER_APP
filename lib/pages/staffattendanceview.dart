import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../binding/staffattendancecontroller.dart';
import '../models/session_model.dart' as session_model;
import '../models/teacher_attendance.dart';

class Staffattendanceview extends StatelessWidget {
  const Staffattendanceview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Staffattendancecontroller(), permanent: true);

    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "✅ Staff Attendance",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _AddSection(controller: controller),
                Expanded(child: _ListSection(controller: controller)),
              ],
            ),
            if (controller.isPageLoading.value)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      );
    });
  }
}

// ======================== ADD SECTION ========================
class _AddSection extends StatelessWidget {
  final Staffattendancecontroller controller;
  const _AddSection({required this.controller});

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 8.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Session + Date Row
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return SizedBox(
                      height: 52.h,
                      child: DropdownButtonFormField<session_model.sListDdata>(
                        value: controller.selectedSession.value,
                        hint: const Text("Select Session"),
                        isExpanded: true,
                        items: controller.sessionList.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(
                              s.session ?? "No session",
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: controller.setSession,
                        decoration: _dec("Session *"),
                      ),
                    );
                  }),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: controller.pickDate,
                    child: AbsorbPointer(
                      child: Obx(() {
                        return SizedBox(
                          height: 52.h,
                          child: TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                                text: controller.displayDate),
                            textAlignVertical: TextAlignVertical.center,
                            style: TextStyle(fontSize: 14.sp),
                            decoration: _dec("Date *").copyWith(
                              suffixIcon:
                              const Icon(Icons.calendar_today, size: 18),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            // Manage Attendance Button
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: Obx(() {
                return ElevatedButton.icon(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.loadAttendanceFromAddTab,
                  icon: controller.isSaving.value
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.manage_accounts,
                      size: 20, color: Colors.white),
                  label: Text(
                    controller.isSaving.value ? "Loading..." : "Manage Attendance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.orange.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== LIST SECTION ========================
class _ListSection extends StatelessWidget {
  final Staffattendancecontroller controller;
  const _ListSection({required this.controller});

  String _safeName(TeacherUser t) {
    final n = "${t.firstName ?? ""} ${t.lastName ?? ""}".trim();
    return n.isEmpty ? "-" : n;
  }

  String _safeReg(TeacherUser t) {
    return t.additionalDetail?.registrationNo?.trim().isNotEmpty == true
        ? t.additionalDetail!.registrationNo!.trim()
        : "-";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.w, 16.w, 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(.06),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Attendance List",
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.w800),
                  ),
                ),
                Obx(() {
                  return IconButton(
                    tooltip: "Refresh",
                    onPressed: controller.isViewLoading.value
                        ? null
                        : controller.refreshListTab,
                    icon: controller.isViewLoading.value
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.refresh),
                  );
                }),
              ],
            ),

            SizedBox(height: 8.h),

            // Table
            Expanded(
              child: Obx(() {
                if (controller.isViewLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.teacherUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.list_alt,
                            size: 48, color: Colors.grey.shade300),
                        SizedBox(height: 8.h),
                        Text(
                          "Click 'Manage Attendance' to load",
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Obx(() {
                      // ignore: unused_local_variable
                      final _ = controller.mapVersion.value;

                      return DataTable(
                        headingRowColor: MaterialStateProperty.all(
                            Colors.teal.shade50),
                        headingTextStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal.shade800,
                        ),
                        dataTextStyle: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black87,
                        ),
                        columnSpacing: 14,
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Staff Id")),
                          DataColumn(label: Text("Staff Name")),
                          DataColumn(label: Text("Date")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("In/Out")),
                        ],
                        rows: List.generate(
                          controller.teacherUsers.length,
                              (i) {
                            final t = controller.teacherUsers[i];
                            final userId = t.userId;

                            return DataRow(
                              cells: [
                                // S.no
                                DataCell(Text("${i + 1}")),

                                // Staff Id
                                DataCell(Text(_safeReg(t))),

                                // Staff Name
                                DataCell(Text(_safeName(t))),

                                // Date
                                DataCell(Text(
                                  controller.displayDate
                                      .replaceAll("/", "-"),
                                )),

                                // Status
                                DataCell(
                                  SizedBox(
                                    width: 130.w,
                                    child: userId == null
                                        ? const Text("-")
                                        : DropdownButtonFormField<String>(
                                      value: controller.statusForUser(t),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                            value: "PRESENT",
                                            child: Text("Present")),
                                        DropdownMenuItem(
                                            value: "ABSENT",
                                            child: Text("Absent")),
                                        DropdownMenuItem(
                                            value: "HOLD",
                                            child: Text("Holiday")),
                                      ],
                                      onChanged: (v) {
                                        if (v == null || userId == null)
                                          return;
                                        controller.setStatusForUser(
                                            userId, v);
                                      },
                                      decoration:
                                      const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding:
                                        EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10),
                                      ),
                                    ),
                                  ),
                                ),

                                // In/Out — dropdown + In time btn + Out time btn
                                DataCell(
                                  userId == null
                                      ? const Text("-")
                                      : SizedBox(
                                    width: 270.w,
                                    child: Row(
                                        children: [
                                        // IN / OUT dropdown
                                        SizedBox(
                                        width: 78.w,
                                        child:
                                        DropdownButtonFormField
                                        <String>(
                                        value: controller
                                        .inOutForUser(userId),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                          value: "IN",
                                          child: Text("IN")),
                                      DropdownMenuItem(
                                          value: "OUT",
                                          child: Text("OUT")),
                                    ],
                                    onChanged: (v) {
                                      if (v == null) return;
                                      controller
                                          .setInOutForUser(
                                          userId, v);
                                    },
                                    decoration:
                                    const InputDecoration(
                                      border:
                                      OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding:
                                      EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 10),
                                    ),
                                  ),
                                ),

                                SizedBox(width: 6.w),

                                // Check-IN time button
                                _TimeButton(
                                  label: "In",
                                  time: controller
                                      .inTimeForUser(userId),
                                  color: Colors.teal.shade700,
                                  onTap: () => controller
                                      .pickInTimeForUser(userId),
                                ),

                                SizedBox(width: 5.w),

                                // Check-OUT time button
                                _TimeButton(
                                  label: "Out",
                                  time: controller
                                      .outTimeForUser(userId),
                                  color: Colors.red.shade700,
                                  onTap: () => controller
                                      .pickOutTimeForUser(userId),
                                ),
                              ],
                            ),
                            ),
                            ),
                            ],
                            );
                          },
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),

            SizedBox(height: 12.h),

            // Save Attendance Button
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: Obx(() {
                return ElevatedButton.icon(
                  onPressed: controller.isViewSaving.value
                      ? null
                      : controller.saveAttendanceFromView,
                  icon: controller.isViewSaving.value
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.save_alt,
                      size: 20, color: Colors.white),
                  label: Text(
                    controller.isViewSaving.value
                        ? "Saving..."
                        : "Save Attendance",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== TIME BUTTON ========================
class _TimeButton extends StatelessWidget {
  final String label;
  final DateTime? time;
  final VoidCallback onTap;
  final Color color;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
    required this.color,
  });

  String _fmt(DateTime? dt) {
    if (dt == null) return "--:--";
    return "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final bool hasTime = time != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: hasTime ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: hasTime ? color : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: hasTime ? color : Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: hasTime ? color : Colors.grey.shade400,
                ),
                SizedBox(width: 3.w),
                Text(
                  _fmt(time),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight:
                    hasTime ? FontWeight.w700 : FontWeight.normal,
                    color: hasTime ? color : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}