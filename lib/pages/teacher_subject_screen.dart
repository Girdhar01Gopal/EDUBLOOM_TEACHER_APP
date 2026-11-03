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

  static const Color _teal = Color(0xFF99144E);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Teacher Subject", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: _teal,
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

// ================= ADD TAB =================
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

  // Chaaron dropdown ek hi generic helper se bante hain.
  Widget _dropdown<T>({
    required String label,
    required RxList<T> items,
    required Rx<T?> selected,
    required String Function(T) text,
  }) {
    return Obx(() {
      return DropdownButtonFormField<T>(
        value: selected.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select $label"),
        items: items
            .map((e) => DropdownMenuItem<T>(value: e, child: _ellipsis(text(e))))
            .toList(),
        onChanged: (v) => selected.value = v,
        decoration: _dec(label),
      );
    });
  }

  Widget _duplicateWarning() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.red.withOpacity(0.35)),
      ),
      child: const Row(
        children: [
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final duplicate = controller.isDuplicateSelection;
      final saving = controller.isSaving.value;

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

                  // duplicate warning
                  if (duplicate) ...[
                    _duplicateWarning(),
                    SizedBox(height: 12.h),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: _dropdown<TeacherModel>(
                          label: "Teacher",
                          items: controller.teacherList,
                          selected: controller.selectedTeacher,
                          text: (t) => (t.name ?? "-").toString(),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _dropdown<ListDataa>(
                          label: "Class",
                          items: controller.classList,
                          selected: controller.selectedClass,
                          text: (c) => c.className ?? "",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  Row(
                    children: [
                      Expanded(
                        child: _dropdown<ListDatta>(
                          label: "Section",
                          items: controller.sectionList,
                          selected: controller.selectedSection,
                          text: (s) => s.section ?? "",
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _dropdown<ListDaataa>(
                          label: "Subject",
                          items: controller.subjectList,
                          selected: controller.selectedSubject,
                          text: (s) => (s.subject ?? "-").toString(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.h),

                  SizedBox(
                    width: 150.w,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: saving ? null : controller.saveTeacherSubjectAssign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: duplicate ? Colors.grey : Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: saving
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
}

// ================= VIEW TAB =================
class _ViewTab extends GetView<TeacherSubjectController> {
  const _ViewTab();

  // CreateDate format dd-MM-yyyy
  String _formatDdMmYyyy(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return "-";
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr; // unknown format => show as-is
    return "${dt.day.toString().padLeft(2, '0')}-"
        "${dt.month.toString().padLeft(2, '0')}-${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.teacherSubjectList;
      final loading = controller.isListLoading.value;

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
                    onPressed: loading ? null : controller.fetchTeacherSubjectList,
                    icon: loading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              Expanded(
                child: loading
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
                        ],
                        rows: List.generate(list.length, (i) {
                          final x = list[i];
                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(x.teacherName ?? "-")),
                              DataCell(Text(x.className ?? "-")),
                              DataCell(Text(x.sectionName ?? "-")),
                              DataCell(Text(x.subjectName ?? "-")),
                              DataCell(Text(_formatDdMmYyyy(x.createDate))),
                              DataCell(Text(x.createBy ?? "-")),
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