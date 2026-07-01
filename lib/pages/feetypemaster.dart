/*import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/feetypemaster.dart';

class FeeTypeMasterScreen extends StatelessWidget {
  const FeeTypeMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FeeTypeController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "📘 Fee Type Master",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add Fee Type"),
              Tab(icon: Icon(Icons.view_list), text: "Fee Type List"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddFeeTypeTab(),
            _FeeTypeListTab(),
          ],
        ),
      ),
    );
  }
}

// ================= ADD TAB =================
class _AddFeeTypeTab extends GetView<FeeTypeController> {
  const _AddFeeTypeTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fee Type",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),

          TextField(
            controller: controller.feeTypeController,
            decoration: InputDecoration(
              hintText: "Enter Fee Type",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          Obx(() {
            return ElevatedButton(
              onPressed: controller.isPosting.value ? null : controller.addFeeType,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: controller.isPosting.value
                  ? SizedBox(
                height: 18.sp,
                width: 18.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                "Save",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ================= LIST TAB (UPDATED: H + V SCROLL) =================
class _FeeTypeListTab extends GetView<FeeTypeController> {
  const _FeeTypeListTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.feeTypeMaster.value;
      final list = data?.listData ?? [];

      if (list.isEmpty) {
        return const Center(child: Text("No Fee Type available"));
      }

      final df = DateFormat("dd-MMM-yyyy");

      return Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fee Type List",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12.h),

            /// ✅ BOTH SCROLL (Vertical + Horizontal) + Scrollbar
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 900.w),
                      child: DataTable(
                        headingRowHeight: 44.h,
                        dataRowMinHeight: 46.h,
                        dataRowMaxHeight: 60.h,
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Fee Type")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Update Date")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final item = list[i];

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(item.feeType)),
                              DataCell(Text(df.format(item.createDate))),
                              DataCell(
                                Text(
                                  item.updateDate == null
                                      ? ""
                                      : df.format(item.updateDate!),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Green Tick
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Edit
                                    InkWell(
                                      onTap: () =>
                                          controller.openEditFeeTypeDialog(item),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
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
            ),
          ],
        ),
      );
    });
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/feetypemaster.dart';

// ─── Axis Bank maroon accent ───────────────────────────────────────────────
const Color kAxisMaroon = Color(0xFF97144D);

class FeeTypeMasterScreen extends StatelessWidget {
  const FeeTypeMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(FeeTypeController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "📘 Fee Type Master",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: kAxisMaroon,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add Fee Type"),
              Tab(icon: Icon(Icons.view_list), text: "Fee Type List"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddFeeTypeTab(),
            _FeeTypeListTab(),
          ],
        ),
      ),
    );
  }
}

// ================= ADD TAB =================
class _AddFeeTypeTab extends GetView<FeeTypeController> {
  const _AddFeeTypeTab();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fee Type",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10.h),

          TextField(
            controller: controller.feeTypeController,
            decoration: InputDecoration(
              hintText: "Enter Fee Type",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),

          SizedBox(height: 20.h),

          Obx(() {
            return ElevatedButton(
              onPressed: controller.isPosting.value ? null : controller.addFeeType,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: controller.isPosting.value
                  ? SizedBox(
                height: 18.sp,
                width: 18.sp,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                "Save",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ================= LIST TAB (UPDATED: H + V SCROLL) =================
class _FeeTypeListTab extends GetView<FeeTypeController> {
  const _FeeTypeListTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.feeTypeMaster.value;
      final list = data?.listData ?? [];

      if (list.isEmpty) {
        return const Center(child: Text("No Fee Type available"));
      }

      final df = DateFormat("dd-MMM-yyyy");

      return Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fee Type List",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 900.w),
                      child: DataTable(
                        headingRowHeight: 44.h,
                        dataRowMinHeight: 46.h,
                        dataRowMaxHeight: 60.h,
                        columns: const [
                          DataColumn(label: Text("S.no")),
                          DataColumn(label: Text("Fee Type")),
                          DataColumn(label: Text("Create Date")),
                          DataColumn(label: Text("Update Date")),
                          DataColumn(label: Text("Action")),
                        ],
                        rows: List.generate(list.length, (i) {
                          final item = list[i];

                          return DataRow(
                            cells: [
                              DataCell(Text("${i + 1}")),
                              DataCell(Text(item.feeType)),
                              DataCell(Text(df.format(item.createDate))),
                              DataCell(
                                Text(
                                  item.updateDate == null
                                      ? ""
                                      : df.format(item.updateDate!),
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await controller.toggleFeeTypeStatus(item);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: item.action == "1" ? Colors.green : Colors.red,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    InkWell(
                                      onTap: () => controller.openEditFeeTypeDialog(item),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
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
            ),
          ],
        ),
      );
    });
  }
}