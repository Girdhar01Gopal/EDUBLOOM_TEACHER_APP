import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/fee_head_master_controller.dart';
import '../models/session_model.dart' as session_model;
import '../models/classmodel.dart';
import '../models/fee_type_model.dart';
import '../models/feedurationmodel.dart';
import '../models/sectionmodel.dart';

class AddFeeHeadScreen extends GetView<AddFeeHeadController> {
  const AddFeeHeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D); // Axis Bank maroon

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Add Fee Head Master",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: teal,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add Fee Head"),
              Tab(icon: Icon(Icons.view_list), text: "View Fee Head"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddFeeHeadTab(),
            _ViewFeeHeadTab(),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// TAB 1 (ADD) - SAME AS YOUR CODE (UNCHANGED)
/// =======================
class _AddFeeHeadTab extends GetView<AddFeeHeadController> {
  const _AddFeeHeadTab();

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
                    "Add Fee Head",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  /// Session + Class
                  Row(
                    children: [
                      Expanded(child: _session()),
                      SizedBox(width: 8.w),
                      Expanded(child: _class()),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  /// Fee Type + Fee Duration
                  Row(
                    children: [
                      Expanded(child: _feeType()),
                      SizedBox(width: 8.w),
                      Expanded(child: _feeDuration()),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  /// Section + Amount
                  Row(
                    children: [
                      Expanded(child: _section()),
                      SizedBox(width: 8.w),
                      Expanded(child: _amount()),
                    ],
                  ),

                  SizedBox(height: 22.h),

                  SizedBox(
                    width: 160.w,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed:
                      controller.isSaving.value ? null : controller.saveFeeHead,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
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

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: "$label *",
      border: const OutlineInputBorder(),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    );
  }

  Widget _ellipsis(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
    );
  }

  Widget _session() {
    return Obx(() {
      final items = controller.sessionList;
      return DropdownButtonFormField<session_model.sListDdata>(
        value: controller.selectedSession.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select Session"),
        items: items
            .map((s) => DropdownMenuItem(
          value: s,
          child: _ellipsis(s.session ?? ""),
        ))
            .toList(),
        selectedItemBuilder: (_) {
          return items
              .map((s) => Align(
            alignment: Alignment.centerLeft,
            child: _ellipsis(s.session ?? ""),
          ))
              .toList();
        },
        onChanged: (v) async {
          controller.selectedSession.value = v;
          await controller.fetchFeeHeadList(); // ✅ refresh view list
        },
        decoration: _decoration("Session"),
      );
    });
  }

  Widget _class() {
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
        selectedItemBuilder: (_) {
          return items
              .map((c) => Align(
            alignment: Alignment.centerLeft,
            child: _ellipsis(c.className ?? ""),
          ))
              .toList();
        },
        onChanged: (v) => controller.selectedClass.value = v,
        decoration: _decoration("Class"),
      );
    });
  }

  Widget _feeType() {
    return Obx(() {
      final items = controller.feeTypeList;
      return DropdownButtonFormField<fData>(
        value: controller.selectedFeeType.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select Fee Type"),
        items: items
            .map((f) => DropdownMenuItem(
          value: f,
          child: _ellipsis(f.feeType ?? ""),
        ))
            .toList(),
        selectedItemBuilder: (_) {
          return items
              .map((f) => Align(
            alignment: Alignment.centerLeft,
            child: _ellipsis(f.feeType ?? ""),
          ))
              .toList();
        },
        onChanged: (v) => controller.selectedFeeType.value = v,
        decoration: _decoration("Fee Type"),
      );
    });
  }

  Widget _feeDuration() {
    return Obx(() {
      final items = controller.feeDurationList;
      return DropdownButtonFormField<FeeDurationItem>(
        value: controller.selectedFeeDuration.value,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis("Select Fee Duration"),
        items: items
            .map((d) => DropdownMenuItem(
          value: d,
          child: _ellipsis(d.feesDuration),
        ))
            .toList(),
        selectedItemBuilder: (_) {
          return items
              .map((d) => Align(
            alignment: Alignment.centerLeft,
            child: _ellipsis(d.feesDuration),
          ))
              .toList();
        },
        onChanged: (v) => controller.selectedFeeDuration.value = v,
        decoration: _decoration("Fee Duration"),
      );
    });
  }

  Widget _section() {
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
        selectedItemBuilder: (_) {
          return items
              .map((s) => Align(
            alignment: Alignment.centerLeft,
            child: _ellipsis(s.section ?? ""),
          ))
              .toList();
        },
        onChanged: (v) => controller.selectedSection.value = v,
        decoration: _decoration("Section"),
      );
    });
  }

  Widget _amount() {
    return TextField(
      controller: controller.amountController,
      keyboardType: TextInputType.number,
      decoration: _decoration("Amount"),
    );
  }
}

/// =======================
/// TAB 2 (VIEW) - UPDATED: Horizontal + Vertical Scrollable
/// =======================
class _ViewFeeHeadTab extends GetView<AddFeeHeadController> {
  const _ViewFeeHeadTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.feeHeadList;

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
                      "Fee Head List",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.isListLoading.value
                        ? null
                        : controller.fetchFeeHeadList,
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
                    ? const Center(child: Text("No fee head found"))
                    : Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Class")),
                          DataColumn(label: Text("Section")),
                          DataColumn(label: Text("Fee Type")),
                          DataColumn(label: Text("Duration")),
                          DataColumn(label: Text("Amount")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final x = list[i];
                          final isActive = (x.action ?? "") == "1";

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(x.className ?? "-")),
                              DataCell(Text(x.sectionName ?? "-")),
                              DataCell(Text(x.feeType ?? "-")),
                              DataCell(Text(x.feesDurationName ?? "-")),
                              DataCell(Text(x.amount ?? "0")),
                              DataCell(
                                Row(
                                  children: [
                                    // InkWell(
                                    //   onTap: () => controller.openEditDialog(context, x),
                                    //   child: const Icon(
                                    //     Icons.edit,
                                    //     color: Colors.orange,
                                    //   ),
                                    // ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      Icons.check_circle,
                                      color: isActive ? Colors.green : Colors.grey,
                                    ),
                                  ],
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