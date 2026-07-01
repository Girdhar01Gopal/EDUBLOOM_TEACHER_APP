import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controller/FeeDailyCollectionController.dart';

class FeeDailyCollectionScreen extends GetView<FeeDailyCollectionController> {
  const FeeDailyCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D); // Axis Bank maroon

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Text(
          "Fee Daily Collection",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: teal,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0x11000000)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() => _dateField(
                      context: context,
                      label: "Start Date",
                      value: controller.fmtUi(controller.startDate.value),
                      onTap: () => controller.pickStartDate(context),
                    )),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Obx(() => _dateField(
                      context: context,
                      label: "End Date",
                      value: controller.fmtUi(controller.endDate.value),
                      onTap: () => controller.pickEndDate(context),
                    )),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      onPressed: controller.fetchDailyCollection,
                      child: Text(
                        "🔎 Search",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // ── Data Table ───────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.items.isEmpty) {
                  return const Center(child: Text("No data found"));
                }

                // ✅ Dynamic columns list
                final cols = controller.dynamicColumns;

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0x11000000)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 52.h,
                        dataRowMinHeight: 50.h,
                        dataRowMaxHeight: 60.h,
                        headingRowColor: MaterialStatePropertyAll(
                          teal,
                        ),
                        headingTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                        // ✅ Pay Date + dynamic columns + Total
                        columns: [
                          const DataColumn(label: Text("Pay Date")),
                          ...cols.map(
                                (key) => DataColumn(label: Text(key)),
                          ),
                          const DataColumn(label: Text("Total")),
                        ],
                        rows: [
                          // ✅ Data rows — dynamic cells
                          ...controller.items.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(Text(r.payDates ?? "-")),
                                ...cols.map((key) => DataCell(
                                  Text(
                                    (r.paymentModeAmounts[key] ?? 0.0)
                                        .toStringAsFixed(0),
                                  ),
                                )),
                                DataCell(
                                  Text(
                                    r.rowTotal.toStringAsFixed(0),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            );
                          }),

                          // ✅ Total row — dynamic
                          DataRow(
                            color: const MaterialStatePropertyAll(
                                Color(0xFFE9ECEF)),
                            cells: [
                              const DataCell(
                                Text("Total",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900)),
                              ),
                              ...cols.map((key) => DataCell(
                                Text(
                                  controller
                                      .columnTotal(key)
                                      .toStringAsFixed(0),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900),
                                ),
                              )),
                              DataCell(
                                Text(
                                  controller.grandTotal.toStringAsFixed(0),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0x22000000)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                        fontSize: 13.sp, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}