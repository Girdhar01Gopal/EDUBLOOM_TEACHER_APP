import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/stafftypecontroller.dart';
import '../models/stafftypemodel.dart';

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
          backgroundColor: Colors.teal.shade800,
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
    return Obx(() {
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
                        child: ElevatedButton(
                          onPressed: controller.isSaving.value ? null : controller.onAddPressed,
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

// ================= VIEW TAB =================
class _ViewTab extends StatelessWidget {
  final Stafftypecontroller controller;
  const _ViewTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<StaffType> list = controller.designationList;

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
                    onPressed: controller.isListLoading.value ? null : controller.fetchDesignations,
                    icon: controller.isListLoading.value
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
                          controller.isListLoading.value ? "Loading..." : "No staff type found",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("S.no")),
                            DataColumn(label: Text("Staff Type")),
                            DataColumn(label: Text("Create Date")),
                            DataColumn(label: Text("Update Date")),
                            DataColumn(label: Text("Action")),
                          ],
                          rows: List.generate(list.length, (i) {
                            final StaffType x = list[i];

                            return DataRow(
                              cells: [
                                DataCell(Text("${i + 1}")),
                                DataCell(Text(x.staffType ?? "-")),
                                DataCell(Text(controller.formatDate(x.createDate != null ? DateTime.tryParse(x.createDate!) : null))),
                                DataCell(Text(controller.formatDate(x.updateDate != null ? DateTime.tryParse(x.updateDate!) : null))),
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
