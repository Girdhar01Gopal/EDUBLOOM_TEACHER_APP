import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/map_foundational_skills_controller.dart';
import '../models/classmodel.dart';
import '../models/foundational_skills_model.dart';

class MapFoundationalSkillsScreen
    extends GetView<MapFoundationalSkillsController> {
  const MapFoundationalSkillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Map Foundational Skills",
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
class _AddTab extends GetView<MapFoundationalSkillsController> {
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
    return Obx(
          () => Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Map Foundational Skills",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ── Row 1: Class + Section ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _classDropdown()),
                      SizedBox(width: 12.w),
                      Expanded(child: _sectionDropdown()), // ✅ NEW
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // ── Row 2: Foundational Skill (full width) ──
                  _skillsDropdown(),
                  SizedBox(height: 14.h),

                  // ── Row 3: Level (half width) ──
                  SizedBox(
                    width: 250.w,
                    child: _levelField(),
                  ),
                  SizedBox(height: 18.h),

                  // ── Save Button ──
                  Obx(() => SizedBox(
                    width: 120.w,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveMapFoundationalSkill,
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

          // ── Page loader ──
          if (controller.isPageLoading.value)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // ── Class Dropdown ──
  Widget _classDropdown() {
    return Obx(() => DropdownButtonFormField<ListDataa>(
      value: controller.selectedClass.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Class"),
      decoration: _dec("Class"),
      items: controller.classList
          .map((item) => DropdownMenuItem<ListDataa>(
        value: item,
        child: _ellipsis(item.className ?? ""),
      ))
          .toList(),
      onChanged: (value) => controller.selectedClass.value = value,
    ));
  }

  // ── ✅ Section Dropdown ──
  Widget _sectionDropdown() {
    return Obx(() => DropdownButtonFormField<dynamic>(
      value: controller.selectedSection.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Section"),
      decoration: _dec("Section"),
      items: controller.sectionList
          .map((s) => DropdownMenuItem<dynamic>(
        value: s,
        child: _ellipsis((s.section ?? "").toString()),
      ))
          .toList(),
      onChanged: (value) => controller.selectedSection.value = value,
    ));
  }

  // ── ✅ Foundational Skills Dropdown (from API) ──
  Widget _skillsDropdown() {
    return Obx(() => DropdownButtonFormField<FoundationalSkillItem>(
      value: controller.selectedSkill.value,
      isExpanded: true,
      menuMaxHeight: 300,
      hint: _ellipsis("Select Foundational Skill"),
      decoration: _dec("Foundational Skill"),
      items: controller.foundationalSkillList
          .map((item) => DropdownMenuItem<FoundationalSkillItem>(
        value: item,
        child: _ellipsis(item.foundationalSkills),
      ))
          .toList(),
      onChanged: (value) => controller.selectedSkill.value = value,
    ));
  }

  // ── Level TextField ──
  Widget _levelField() {
    return TextFormField(
      controller: controller.levelController,
      decoration: _dec("Level"),
    );
  }
}

// ============================================================
// VIEW TAB
// ============================================================
class _ViewTab extends GetView<MapFoundationalSkillsController> {
  const _ViewTab();

  @override
  Widget build(BuildContext context) {
    final DateFormat df = DateFormat("dd-MMM-yyyy");

    return Obx(
          () => Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Text(
                    "Map Foundational Skills List",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.isListLoading.value
                        ? null
                        : controller.refreshViewList,
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
              SizedBox(height: 12.h),

              // ── Table ──
              Expanded(
                child: controller.isListLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.mapFoundationalSkillList.isEmpty
                    ? RefreshIndicator(
                  onRefresh: controller.refreshViewList,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Divider(color: Colors.grey.shade300),
                      SizedBox(height: 14.h),
                      Center(
                        child: Text(
                          "No data found.",
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: controller.refreshViewList,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                          WidgetStateProperty.all(
                              Colors.grey.shade100),
                          border: TableBorder.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(label: Text("S.no")),
                            DataColumn(label: Text("Class")),
                            DataColumn(label: Text("Section")), // ✅
                            DataColumn(label: Text("Foundational Skill")),
                            DataColumn(label: Text("Level")),
                            DataColumn(label: Text("Create Date")),
                            DataColumn(label: Text("Create By")),
                          ],
                          rows: List.generate(
                            controller
                                .mapFoundationalSkillList.length,
                                (index) {
                              final item = controller
                                  .mapFoundationalSkillList[index];

                              return DataRow(cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(
                                    Text(item.className ?? "")),
                                // ✅ Section column
                                DataCell(
                                    Text(item.section ?? "-")),
                                DataCell(Text(
                                    item.foundationalSkills ?? "")),
                                DataCell(Text(item.level ?? "")),
                                DataCell(Text(
                                  item.createDate == null
                                      ? ""
                                      : df.format(item.createDate!),
                                )),
                                DataCell(
                                    Text(item.createBy ?? "")),
                              ]);
                            },
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
      ),
    );
  }
}