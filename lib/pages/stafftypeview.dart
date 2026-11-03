import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/stafftypecontroller.dart';
import '../models/stafftypemodel.dart';

// Axis Bank brand color (maroon) — replaces teal everywhere in this file
const Color kAxisMaroon = Color(0xFF97144D);

class Stafftypeview extends StatelessWidget {
  const Stafftypeview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Stafftypecontroller(), permanent: true);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("Staff Type", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: kAxisMaroon,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "Add Staff Type"),
              Tab(text: "View Staff Type"),
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
  final Stafftypecontroller controller;
  const _AddTab({required this.controller});

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    filled: true,
    fillColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            controller.resetForm();
            await controller.fetchDesignations();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Add Staff Type",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 16.h),

                    TextFormField(
                      controller: controller.designationC,
                      validator: (v) => controller.requiredValidator(v, "Staff Type"),
                      decoration: _dec("Staff Type *"),
                    ),

                    SizedBox(height: 18.h),

                    SizedBox(
                      width: 130.w,
                      height: 46.h,
                      child: Obx(() {
                        final saving = controller.isSaving.value;
                        return ElevatedButton(
                          onPressed: saving ? null : controller.onAddPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: saving
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Text(
                            "Save",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        Obx(() => controller.isPageLoading.value
            ? const Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: LinearProgressIndicator(),
        )
            : const SizedBox.shrink()),
      ],
    );
  }
}

// ================= VIEW TAB =================
class _ViewTab extends StatelessWidget {
  final Stafftypecontroller controller;
  const _ViewTab({required this.controller});

  static const List<DataColumn> _columns = [
    DataColumn(label: Text("S.no")),
    DataColumn(label: Text("Staff Type")),
    DataColumn(label: Text("Create Date")),
    DataColumn(label: Text("Update Date")),
    DataColumn(label: Text("Action")),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<StaffType> list = controller.designationList;
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
                      "Staff Type List",
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: loading ? null : controller.fetchDesignations,
                    icon: loading
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              Expanded(
                child: list.isEmpty
                    ? Center(
                  child: Text(
                    loading ? "Loading..." : "No staff type found",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _columns,
                    rows: List.generate(list.length, (i) {
                      final StaffType x = list[i];

                      return DataRow(
                        cells: [
                          DataCell(Text("${i + 1}")),
                          DataCell(Text(x.staffType ?? "-")),
                          DataCell(Text(controller.formatDateStr(x.createDate))),
                          DataCell(Text(controller.formatDateStr(x.updateDate))),
                          DataCell(
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => controller.openEditDialog(x),
                                  child: const Icon(Icons.edit, color: Colors.orange),
                                ),
                                const SizedBox(width: 10),
                                // You said always green tick
                                const Icon(Icons.check_circle, color: Colors.green),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
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