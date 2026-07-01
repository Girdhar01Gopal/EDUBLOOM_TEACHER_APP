import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/teacher_subject_controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/teacher list model.dart';
import '../models/subject_model.dart';

class TeacherSubjectScreen extends GetView<TeacherSubjectController> {
  const TeacherSubjectScreen({super.key});
//
  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF99144E);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Teacher Subject", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: teal,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add"),
              Tab(icon: Icon(Icons.view_list), text: "View"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddTab(),
            _ViewTab(),
          ],
        ),
      ),
    );
  }
}

class _AddTab extends GetView<TeacherSubjectController> {
  const _AddTab();

  InputDecoration _dec(String label) => InputDecoration(
    labelText: "$label *",
    border: const OutlineInputBorder(),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
  );

  Widget _ellipsis(String t) => Text(
    t,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    softWrap: false,
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final duplicate = controller.isDuplicateSelection; // ✅ added in controller (see note below)

      return Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Teacher Subject",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 12.h),

                  // ✅ show duplicate warning in UI
                  if (duplicate)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.withOpacity(0.35)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Already assigned for this session (duplicate).",
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (duplicate) SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(child: _teacherDropdown()),
                      SizedBox(width: 10.w),
                      Expanded(child: _classDropdown()),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  Row(
                    children: [
                      Expanded(child: _sectionDropdown()),
                      SizedBox(width: 10.w),
                      Expanded(child: _subjectDropdown()),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  SizedBox(
                    width: 150.w,
                    height: 46.h,
                    child: ElevatedButton(
                      // ✅ FIX: missing comma + block when duplicate
                      onPressed: controller.isSaving.value ? null : controller.saveTeacherSubjectAssign,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: duplicate ? Colors.grey : Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text(
                        "Save",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (controller.isPageLoading.value)
            const Positioned(left: 0, right: 0, top: 0, child: LinearProgressIndicator()),
        ],
      );
    });
  }

  Widget _teacherDropdown() {
    return Obx(() {
      final items = controller.teacherList;
      return DropdownButtonFormField<TeacherModel>(
        value: controller.selectedTeacher.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select Teacher"),
        items: items
            .map((t) => DropdownMenuItem(
          value: t,
          child: _ellipsis((t.name ?? "-").toString()),
        ))
            .toList(),
        onChanged: (v) => controller.selectedTeacher.value = v,
        decoration: _dec("Teacher"),
      );
    });
  }

  Widget _classDropdown() {
    return Obx(() {
      final items = controller.classList;
      return DropdownButtonFormField<ListDataa>(
        value: controller.selectedClass.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select Class"),
        items: items
            .map((c) => DropdownMenuItem(
          value: c,
          child: _ellipsis(c.className ?? ""),
        ))
            .toList(),
        onChanged: (v) => controller.selectedClass.value = v,
        decoration: _dec("Class"),
      );
    });
  }

  Widget _sectionDropdown() {
    return Obx(() {
      final items = controller.sectionList;
      return DropdownButtonFormField<ListDatta>(
        value: controller.selectedSection.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select Section"),
        items: items
            .map((s) => DropdownMenuItem(
          value: s,
          child: _ellipsis(s.section ?? ""),
        ))
            .toList(),
        onChanged: (v) => controller.selectedSection.value = v,
        decoration: _dec("Section"),
      );
    });
  }

  Widget _subjectDropdown() {
    return Obx(() {
      final items = controller.subjectList;
      return DropdownButtonFormField<ListDaataa>(
        value: controller.selectedSubject.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select Subject"),
        items: items
            .map((s) => DropdownMenuItem(
          value: s,
          child: _ellipsis((s.subject ?? "-").toString()),
        ))
            .toList(),
        onChanged: (v) => controller.selectedSubject.value = v,
        decoration: _dec("Subject"),
      );
    });
  }
}

class _ViewTab extends GetView<TeacherSubjectController> {
  const _ViewTab();
  // ✅ Added: CreateDate format dd-MM-yyyy (no other changes)
  String _formatDdMmYyyy(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return "-";
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr; // unknown format => show as-is
      final dd = dt.day.toString().padLeft(2, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final yyyy = dt.year.toString();
      return "$dd-$mm-$yyyy";
    } catch (_) {
      return dateStr;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.teacherSubjectList;

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Teacher Subject List",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.isListLoading.value ? null : controller.fetchTeacherSubjectList,
                    icon: controller.isListLoading.value
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              Expanded(
                child: controller.isListLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : list.isEmpty
                    ? const Center(child: Text("No record found"))
                    : Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Teacher")),
                          DataColumn(label: Text("Class")),
                          DataColumn(label: Text("Section")),
                          DataColumn(label: Text("Subject")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Create By")),
                          // DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final x = list[i];
                          final isActive = x.action == "1";
                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(x.teacherName ?? "-")),
                              DataCell(Text(x.className ?? "-")),
                              DataCell(Text(x.sectionName ?? "-")),
                              DataCell(Text(x.subjectName ?? "-")),
                              DataCell(Text(_formatDdMmYyyy(x.createDate))),
                              DataCell(Text(x.createBy ?? "-")),
                              // DataCell(
                              //   Row(
                              //     children: [
                              //       InkWell(
                              //         onTap: () => controller.openEditDialog(context, x),
                              //         child: const Icon(Icons.edit, color: Colors.orange),
                              //       ),
                              //       const SizedBox(width: 10),
                              //       Icon(Icons.check_circle, color: isActive ? Colors.green : Colors.grey),
                              //     ],
                              //   ),
                              // ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}