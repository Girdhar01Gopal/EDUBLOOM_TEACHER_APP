import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/class_teacher_controller.dart';
import '../models/teacher list model.dart';
import '../models/classmodel.dart';
import '../models/sectionmodel.dart';

class ClassTeacherScreen extends GetView<ClassTeacherController> {
  const ClassTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Class Teacher", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: teal,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.white,
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

class _AddTab extends GetView<ClassTeacherController> {
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
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                    "Class Teacher",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 16.h),

                  // Teacher + Class
                  Row(
                    children: [
                      Expanded(child: _teacherDropdown()),
                      SizedBox(width: 10.w),
                      Expanded(child: _classDropdown()),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // ✅ Section dropdown (same style)
                  _sectionDropdown(),
                  SizedBox(height: 18.h),

                  SizedBox(
                    width: 150.w,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value ? null : controller.saveClassTeacher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
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
          child: _ellipsis(c.className ?? "-"),
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
          child: _ellipsis((s.section ?? "-").toString()),
        ))
            .toList(),
        onChanged: (v) => controller.selectedSection.value = v,
        decoration: _dec("Section"),
      );
    });
  }
}

class _ViewTab extends GetView<ClassTeacherController> {
  const _ViewTab();

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";

    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(dt);
    } catch (e) {
      return dateStr; // fallback if API gives weird format
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.classTeacherList;


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
                      "Teacher Class Assign List",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () {}, // dummy
                    icon: const Icon(Icons.refresh),
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
                          DataColumn(label: Text("Registration No")),
                          DataColumn(label: Text("Class")),
                          DataColumn(label: Text("Section")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Create By")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final x = list[i]; // x is Data (your model)
                          final isActive = (x.action ?? "1") == "1";

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(x.name ?? "-")),
                              DataCell(Text(x.regrationNo ?? "-")),
                              DataCell(Text(x.className ?? "-")),
                              DataCell(Text(x.sectionName ?? "-")),
                              DataCell(
                                Text(
                                  _formatDate(x.createDate),
                                ),
                              ),
                              DataCell(Text(x.createBy ?? "-")),
                              DataCell(
                                Icon(
                                  Icons.check_circle,
                                  color: isActive ? Colors.green : Colors.grey,
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