import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/day_care_fee_master.dart';
import '../models/session_model.dart' as session_model;
import '../models/fee_type_model.dart';

class AddDayCareFeeMasterScreen extends StatelessWidget {
  const AddDayCareFeeMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // keep controller alive for tabs
    final controller = Get.put(DayCareFeeMasterController(), permanent: true);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Day Care Fee", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: const Color(0xFF97144D),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "Add Day Care Fee"),
              Tab(text: "View Day Care Fee"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _AddTab(controller: controller),
            _ViewTab(controller: controller),
          ],
        ),
      ),
    );
  }
}

// ================= ADD TAB =================
class _AddTab extends StatelessWidget {
  final DayCareFeeMasterController controller;
  const _AddTab({required this.controller});

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    filled: true,
    fillColor: Colors.white,
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
                    "Add Day Care Fee",
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          final items = controller.sessionList;
                          return DropdownButtonFormField<session_model.sListDdata>(
                            value: controller.selectedSession.value,
                            isExpanded: true,
                            menuMaxHeight: 320,
                            hint: _ellipsis("Select Session"),
                            items: items
                                .map((s) => DropdownMenuItem(
                              value: s,
                              child: _ellipsis(s.session ?? ""),
                            ))
                                .toList(),
                            onChanged: (v) async {
                              controller.selectedSession.value = v;
                              // change session => refresh view list
                              await controller.fetchDaycareFees();
                            },
                            decoration: _dec("Session *"),
                          );
                        }),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Obx(() {
                          final items = controller.feeTypeList;
                          return DropdownButtonFormField<fData>(
                            value: controller.selectedFeeType.value,
                            isExpanded: true,
                            menuMaxHeight: 320,
                            hint: _ellipsis("Select Fee Type"),
                            items: items
                                .map((f) => DropdownMenuItem(
                              value: f,
                              child: _ellipsis(f.feeType ?? ""),
                            ))
                                .toList(),
                            onChanged: (v) => controller.selectedFeeType.value = v,
                            decoration: _dec("Fee Type *"),
                          );
                        }),
                      ),
                    ],
                  ),

                  SizedBox(height: 14.h),

                  TextField(
                    controller: controller.amountController,
                    keyboardType: TextInputType.number,
                    decoration: _dec("Amount *"),
                  ),

                  SizedBox(height: 18.h),

                  Obx(() {
                    return SizedBox(
                      width: 120.w,
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: controller.isSaving.value ? null : controller.saveDayCareFee,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  }),
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
}

// ================= VIEW TAB (UPDATED: H + V scroll) =================
class _ViewTab extends StatelessWidget {
  final DayCareFeeMasterController controller;
  const _ViewTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.daycareFeeList;

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
                      "Daycare Fee List",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.isListLoading.value ? null : controller.fetchDaycareFees,
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
                    ? Center(
                  child: Text(
                    "No daycare fee found",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                )
                    : Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical, // ✅ vertical
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // ✅ horizontal
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Fee Type")),
                          DataColumn(label: Text("Amount")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Update Date")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final x = list[i];
                          final isActive = (x.action ?? "") == "1";

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(x.feeTypeName ?? "-")),
                              DataCell(Text(x.amount ?? "0")),
                              DataCell(Text(controller.formatDate(x.createDate))),
                              DataCell(Text(controller.formatDate(x.updateDate))),
                              DataCell(
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () => controller.openEditDialog(context, x),
                                      child: const Icon(Icons.edit, color: Colors.orange),
                                    ),
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