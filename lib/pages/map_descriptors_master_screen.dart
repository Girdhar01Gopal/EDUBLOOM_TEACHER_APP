import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/map_descriptors_controller.dart';
import '../models/classmodel.dart';
import '../models/descriptors_model.dart';
import '../models/subject_model.dart';

class MapDescriptorsMasterScreen extends GetView<MapDescriptorsController> {
  const MapDescriptorsMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Map Descriptors",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
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

// ============================================================
// ADD TAB
// ============================================================
class _AddTab extends GetView<MapDescriptorsController> {
  const _AddTab();

  InputDecoration _dec(String label) => InputDecoration(
    labelText: "$label *",
    border: const OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.teal.shade800),
    ),
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Map Descriptors",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ── Duplicate warning ──
                  if (duplicate)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8.r),
                        border:
                        Border.all(color: Colors.red.withOpacity(0.35)),
                      ),
                      child: Text(
                        "This combination is already mapped.",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  if (duplicate) SizedBox(height: 12.h),

                  // ── Row 1: Class + Section ──
                  Row(
                    children: [
                      Expanded(child: _classDropdown()),
                      SizedBox(width: 10.w),
                      Expanded(child: _sectionDropdown()), // ✅ NEW
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // ── Row 2: Subject (full width) ──
                  _subjectDropdown(),
                  SizedBox(height: 14.h),

                  // ── Row 3: Descriptor (full width) ──
                  _descriptorDropdown(),
                  SizedBox(height: 20.h),

                  // ── Save Button ──
                  Obx(() => SizedBox(
                    width: 120.w,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveMap,
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
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text(
                        "Save",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),

          // ── Page-level loader ──
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

  // ── Class Dropdown ──
  Widget _classDropdown() {
    return Obx(() => DropdownButtonFormField<ListDataa>(
      value: controller.selectedClass.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Class"),
      items: controller.classList
          .map((c) => DropdownMenuItem<ListDataa>(
        value: c,
        child: _ellipsis(c.className ?? ""),
      ))
          .toList(),
      onChanged: (v) => controller.selectedClass.value = v,
      decoration: _dec("Class"),
    ));
  }

  // ── ✅ Section Dropdown ──
  Widget _sectionDropdown() {
    return Obx(() => DropdownButtonFormField<dynamic>(
      value: controller.selectedSection.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Section"),
      items: controller.sectionList
          .map((s) => DropdownMenuItem<dynamic>(
        value: s,
        child: _ellipsis((s.section ?? "").toString()),
      ))
          .toList(),
      onChanged: (v) => controller.selectedSection.value = v,
      decoration: _dec("Section"),
    ));
  }

  // ── Subject Dropdown ──
  Widget _subjectDropdown() {
    return Obx(() => DropdownButtonFormField<ListDaataa>(
      value: controller.selectedSubject.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Subject"),
      items: controller.subjectList
          .map((s) => DropdownMenuItem<ListDaataa>(
        value: s,
        child: _ellipsis((s.subject ?? "-").toString()),
      ))
          .toList(),
      onChanged: (v) => controller.selectedSubject.value = v,
      decoration: _dec("Subject"),
    ));
  }

  // ── ✅ Descriptor Dropdown (from ViewSubjectProgress API) ──
  Widget _descriptorDropdown() {
    return Obx(() => DropdownButtonFormField<SubjectProgressItem>(
      value: controller.selectedDescriptor.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Descriptor"),
      items: controller.descriptorList
          .map((d) => DropdownMenuItem<SubjectProgressItem>(
        value: d,
        child: _ellipsis((d.descriptors ?? "").toString()),
      ))
          .toList(),
      onChanged: (v) => controller.selectedDescriptor.value = v,
      decoration: _dec("Descriptor"),
    ));
  }
}

// ============================================================
// VIEW TAB
// ============================================================
class _ViewTab extends GetView<MapDescriptorsController> {
  const _ViewTab();

  @override
  Widget build(BuildContext context) {
    final DateFormat df = DateFormat("dd-MMM-yyyy");
    final ScrollController verticalCtrl = ScrollController();
    final ScrollController horizontalCtrl = ScrollController();

    return Obx(() {
      final list = controller.mapDescriptorList;

      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Map Descriptors List",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.isListLoading.value
                        ? null
                        : controller.fetchMapDescriptors,
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

              // ── Table ──
              Expanded(
                child: controller.isListLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : list.isEmpty
                    ? RefreshIndicator(
                  onRefresh: controller.fetchMapDescriptors,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 180),
                      Center(child: Text("No record found")),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: controller.fetchMapDescriptors,
                  child: Scrollbar(
                    controller: verticalCtrl,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: verticalCtrl,
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Scrollbar(
                        controller: horizontalCtrl,
                        thumbVisibility: true,
                        notificationPredicate: (n) => n.depth == 1,
                        child: SingleChildScrollView(
                          controller: horizontalCtrl,
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints:
                            BoxConstraints(minWidth: 1200.w),
                            child: DataTable(
                              columnSpacing: 24,
                              headingRowHeight: 48,
                              dataRowMinHeight: 52,
                              dataRowMaxHeight: 60,
                              headingRowColor:
                              WidgetStateProperty.all(
                                  Colors.grey.shade100),
                              border: TableBorder.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                              columns: const [
                                DataColumn(label: Text("S.no")),
                                DataColumn(label: Text("Class")),
                                DataColumn(label: Text("Section")), // ✅
                                DataColumn(label: Text("Subject")),  // ✅ shows subject field
                                DataColumn(label: Text("Descriptor")),
                                DataColumn(label: Text("Create Date")),
                                DataColumn(label: Text("Create By")),
                                DataColumn(label: Text("Status")),
                              ],
                              rows: List.generate(list.length, (i) {
                                final item = list[i];
                                final bool isActive =
                                    (item.action ?? "") == "1";
                                final DateTime? dt =
                                controller.parseDate(item.createDate);

                                return DataRow(cells: [
                                  DataCell(Text("${i + 1}")),
                                  DataCell(Text(item.className ?? "")),
                                  // ✅ Section
                                  DataCell(Text(item.section ?? "-")),
                                  // ✅ subject field (not subjectName)
                                  DataCell(SizedBox(
                                    width: 120.w,
                                    child: Text(
                                      item.subject ?? item.subjectName ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                                  DataCell(SizedBox(
                                    width: 200.w,
                                    child: Text(
                                      item.descriptors ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )),
                                  DataCell(Text(
                                    dt == null ? "" : df.format(dt),
                                  )),
                                  DataCell(Text(item.createBy ?? "")),
                                  DataCell(
                                    Container(
                                      height: 28,
                                      width: 28,
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? Colors.green
                                            : Colors.grey,
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                      child: Icon(
                                        isActive
                                            ? Icons.check
                                            : Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ]);
                              }),
                            ),
                          ),
                        ),
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