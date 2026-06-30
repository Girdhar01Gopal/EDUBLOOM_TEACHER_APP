import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/feedurationcontroller.dart';
import '../models/feedurationmodel.dart';

class FeeDurationMasterScreen extends StatelessWidget {
  const FeeDurationMasterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "🎓 Fee Duration Master",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal.shade800,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.add), text: "Add Fee Duration"),
              Tab(icon: Icon(Icons.view_list), text: "Fee Duration List"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AddFeeDurationTab(),
            _FeeDurationListTab(),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ADD TAB
// ══════════════════════════════════════════════════════════════
class _AddFeeDurationTab extends GetView<FeeDurationController> {
  const _AddFeeDurationTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
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
              "Add Fee Duration",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 16.h),

            // ── Input field ──────────────────────────────────
            TextField(
              controller: controller.feesDurationController,
              decoration: InputDecoration(
                labelText: 'Fee Duration *',
                hintText: "e.g. One Time, Monthly, Quarterly",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),

            SizedBox(height: 24.h),

            // ── Save button ───────────────────────────────────
            Obx(() => SizedBox(
              width: 140.w,
              height: 46.h,
              child: ElevatedButton(
                onPressed: controller.isPosting.value
                    ? null
                    : controller.addFeeDuration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: controller.isPosting.value
                      ? Colors.grey
                      : Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: controller.isPosting.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// VIEW TAB
// ══════════════════════════════════════════════════════════════
class _FeeDurationListTab extends GetView<FeeDurationController> {
  const _FeeDurationListTab();

  // ✅ Safe date format — nullable DateTime handle karta hai
  static final _df = DateFormat("dd-MMM-yyyy");

  String _fmt(DateTime? dt) => dt == null ? '—' : _df.format(dt);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── Loading ───────────────────────────────────────────
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final list = controller.feeDurationMaster.value?.listData ?? [];

      // ── Empty ─────────────────────────────────────────────
      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_off_outlined,
                  size: 52, color: Colors.grey.shade300),
              SizedBox(height: 10.h),
              Text(
                "No Fee Duration available",
                style:
                TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
              ),
            ],
          ),
        );
      }

      // ── List ──────────────────────────────────────────────
      return Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header + refresh
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Fee Duration List",
                    style: TextStyle(
                        fontSize: 18.sp, fontWeight: FontWeight.w800),
                  ),
                ),
                Obx(() => IconButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.fetchFeeDurations,
                  icon: controller.isLoading.value
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.refresh),
                )),
              ],
            ),
            SizedBox(height: 10.h),

            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                          Colors.teal.shade50),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text("S.No")),
                        DataColumn(label: Text("Fee Duration")),
                        DataColumn(label: Text("Create Date")),
                        DataColumn(label: Text("Update Date")),
                        DataColumn(label: Text("Status")),
                        DataColumn(label: Text("Action")),
                      ],
                      rows: List.generate(list.length, (i) {
                        final FeeDurationItem item = list[i];
                        final isActive = item.action == '1';

                        return DataRow(cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(item.feesDuration)),

                          // ✅ nullable DateTime — safe
                          DataCell(Text(_fmt(item.createDate))),
                          DataCell(Text(_fmt(item.updateDate))),

                          // Status badge
                          DataCell(
                            Container(
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

                          // Edit button
                          DataCell(
                            InkWell(
                              onTap: () =>
                                  controller.openEditFeeDurationDialog(item),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 16,
                                ),
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
          ],
        ),
      );
    });
  }
}