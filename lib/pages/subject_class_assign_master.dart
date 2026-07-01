import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/subject_class_assign_controller.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';
import '../models/subject_model.dart';

class SubjectClassAssignMasterScreen extends GetView<SubjectClassAssignController> {
  const SubjectClassAssignMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF99144E);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Subject Class Assign",
            style: TextStyle(color: Colors.white),
          ),
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

class _AddTab extends GetView<SubjectClassAssignController> {
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
      final duplicate = controller.isDuplicateSelection;

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
                    "Subject Class Assign",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  if (duplicate)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.withOpacity(0.35)),
                      ),
                      child: Text(
                        "This class, section and subject is already assigned.",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),

                  if (duplicate) SizedBox(height: 12.h),

                  Row(
                    children: [
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
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveSubjectClassAssign,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isSaving.value
                            ? Colors.grey
                            : Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (controller.isPageLoading.value)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(),
            ),
        ],
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
            .map(
              (c) => DropdownMenuItem<ListDataa>(
            value: c,
            child: _ellipsis(c.className ?? ""),
          ),
        )
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
            .map(
              (s) => DropdownMenuItem<ListDatta>(
            value: s,
            child: _ellipsis(s.section ?? ""),
          ),
        )
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
            .map(
              (s) => DropdownMenuItem<ListDaataa>(
            value: s,
            child: _ellipsis((s.subject ?? "-").toString()),
          ),
        )
            .toList(),
        onChanged: (v) => controller.selectedSubject.value = v,
        decoration: _dec("Subject"),
      );
    });
  }
}

class _ViewTab extends GetView<SubjectClassAssignController> {
  const _ViewTab();

  String _formatDdMmYyyy(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return "-";
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return dateStr;
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
      final list = controller.filteredSubjectClassAssignList;

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
                      "Subject Class Assign List",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.isListLoading.value
                        ? null
                        : controller.fetchSubjectClassAssignList,
                    icon: controller.isListLoading.value
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
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
                        headingRowColor: WidgetStateProperty.all(
                          const Color(0xFFF7EEF2),
                        ),
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Class")),
                          DataColumn(label: Text("Section")),
                          DataColumn(label: Text("Subject")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final x = list[i];
                          final isActive = x.action == "1";

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(x.className ?? "-")),
                              DataCell(Text(x.sectionName ?? "-")),
                              DataCell(Text(x.subjectName ?? "-")),
                              DataCell(Text(_formatDdMmYyyy(x.createDate))),
                              DataCell(
                                Center(
                                  child: Container(
                                    height: 26,
                                    width: 26,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green
                                          : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isActive ? Icons.check : Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
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