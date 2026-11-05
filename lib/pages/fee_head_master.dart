import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/fee_head_master_controller.dart';
import '../models/session_model.dart' as session_model;
import '../models/class_list_model.dart';
import '../models/fee_type_model.dart';
import '../models/feedurationmodel.dart';
import '../models/viewsectionmodel.dart';

class AddFeeHeadScreen extends GetView<AddFeeHeadController> {
  const AddFeeHeadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D);
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
/// TAB 1 (ADD) - Class, Section, Fee Type, Fee Duration are multi-select
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

  // ============================================================
  // 🆕 MULTI-SELECT inside the SAME dropdown UI
  // (menu niche hi khulta hai, har item par checkbox, "Select All" upar,
  //  tap karne par menu band nahi hota)
  // ============================================================
  Widget _checkRow({
    required bool checked,
    required String text,
    required VoidCallback onTap,
    bool bold = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                activeColor: const Color(0xFF97144D),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (_) => onTap(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _multiSelectField<T>({
    required String label,
    required String hint,
    required RxList<T> items,
    required RxList<T> selected,
    required String Function(T) labelOf,
  }) {
    const Object selectAllKey = '__select_all__';

    return Obx(() {
      final List<T> sel = selected.toList();
      final List<T> all = items.toList();

      String text;
      if (sel.isEmpty) {
        text = hint;
      } else if (all.isNotEmpty && sel.length == all.length) {
        text = "All selected (${sel.length})";
      } else {
        text = sel.map(labelOf).join(", ");
      }

      // items: [Select All] + saare items (enabled:false => tap par menu band nahi hota)
      final List<DropdownMenuItem<Object>> menuItems = [
        DropdownMenuItem<Object>(
          value: selectAllKey,
          enabled: false,
          child: Obx(() => _checkRow(
            checked: items.isNotEmpty && selected.length == items.length,
            text: "Select All",
            bold: true,
            onTap: () {
              if (items.isNotEmpty && selected.length == items.length) {
                selected.clear();
              } else {
                selected.assignAll(items);
              }
            },
          )),
        ),
        ...all.map(
              (it) => DropdownMenuItem<Object>(
            value: it as Object,
            enabled: false,
            child: Obx(() => _checkRow(
              checked: selected.contains(it),
              text: labelOf(it),
              onTap: () {
                if (selected.contains(it)) {
                  selected.remove(it);
                } else {
                  selected.add(it);
                }
              },
            )),
          ),
        ),
      ];

      return DropdownButtonFormField<Object>(
        // value sirf display ke liye (selectedItemBuilder joined text dikhata hai)
        value: sel.isEmpty ? null : sel.first as Object,
        isExpanded: true,
        menuMaxHeight: 300,
        hint: _ellipsis(hint),
        items: menuItems,
        selectedItemBuilder: (_) => List<Widget>.generate(
          menuItems.length,
              (_) => Align(
            alignment: Alignment.centerLeft,
            child: _ellipsis(text),
          ),
        ),
        onChanged: (_) {},
        decoration: _decoration(label),
      );
    });
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

  // ✅ Class dropdown (multi-select) — notification's ClassData model
  Widget _class() {
    return _multiSelectField<ClassData>(
      label: "Class",
      hint: "Select Class",
      items: controller.classList,
      selected: controller.selectedClasses,
      labelOf: (c) => c.className,
    );
  }

  // 🆕 Fee Type dropdown (multi-select)
  Widget _feeType() {
    return _multiSelectField<fData>(
      label: "Fee Type",
      hint: "Select Fee Type",
      items: controller.feeTypeList,
      selected: controller.selectedFeeTypes,
      labelOf: (f) => f.feeType ?? "",
    );
  }

  /// ✅ Fee Duration dropdown (multi-select)
  Widget _feeDuration() {
    return _multiSelectField<FeeDurationItem>(
      label: "Fee Duration",
      hint: "Select Fee Duration",
      items: controller.feeDurationList,
      selected: controller.selectedFeeDurations,
      labelOf: (d) => d.feesDuration,
    );
  }

  // ✅ Section dropdown (multi-select) — notification's stListData model
  Widget _section() {
    return _multiSelectField<stListData>(
      label: "Section",
      hint: "Select Section",
      items: controller.sectionList,
      selected: controller.selectedSections,
      labelOf: (s) => s.section ?? "",
    );
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
/// TAB 2 (VIEW) - UNCHANGED
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