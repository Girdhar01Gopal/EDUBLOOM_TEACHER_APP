import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/ClassWiseFeeStructureController.dart';

class ClassWiseFeeStructureScreen extends GetView<ClassWiseFeeStructureController> {
  const ClassWiseFeeStructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teal = const Color(0xFF97144D);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
        title: Obx(() => controller.isSearching.value
            ? TextField(
          controller: controller.searchTextController,
          autofocus: true,
          cursorColor: Colors.white,
          style: TextStyle(fontSize: 16.sp, color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search class name...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: (v) => controller.searchQuery.value = v,
        )
            : Text(
          "Class Wise Fee Structure",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        )),
        centerTitle: true,
        backgroundColor: teal,
        elevation: 4,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isSearching.value ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: controller.toggleSearch,
          )),
          // CHANGED: AppBar share -> complete data
          IconButton(
            tooltip: "Share all classes",
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: controller.shareAllFeeStructure,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session dynamic + Search button
            Row(
              children: [
                Expanded(
                  child: Obx(() => TextFormField(
                    key: ValueKey(controller.session.value),
                    initialValue: controller.session.value,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Session",
                      border: OutlineInputBorder(),
                    ),
                  )),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: controller.fetchFeeStructure,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: const Text(
                      "🔎 Search",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),

            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (controller.tableRows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(child: Text("No Data")),
                );
              }

              final ids = controller.rowClassIds;

              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0x22000000)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(Colors.green),
                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    columns: const [
                      DataColumn(label: Text("S.No")),
                      DataColumn(label: Text("Class")),
                      DataColumn(label: Text("Fee Type")),
                      DataColumn(label: Text("Fees Duration")),
                      DataColumn(label: Text("Amount")),
                      // NEW: per-class share column
                      DataColumn(label: Text("Share")),
                    ],
                    rows: [
                      ...controller.tableRows.asMap().entries.map((entry) {
                        final i = entry.key;
                        final r = entry.value;
                        final classId = i < ids.length ? ids[i] : null;

                        return DataRow(
                          cells: [
                            DataCell(Text(r.sno)),
                            DataCell(Text(r.classBatch)),
                            DataCell(Text(r.feeType)),
                            DataCell(Text(r.feeDuration)),
                            DataCell(Text(r.amount)),
                            // NEW: sirf class ki pehli row par share icon
                            DataCell(
                              classId == null
                                  ? const SizedBox.shrink()
                                  : IconButton(
                                tooltip: "Share this class",
                                icon: const Icon(
                                  Icons.share,
                                  color: Colors.green,
                                ),
                                onPressed: () => controller
                                    .shareClassFeeStructure(classId),
                              ),
                            ),
                          ],
                        );
                      }),

                      DataRow(
                        color: MaterialStateProperty.all(Colors.grey.shade200),
                        cells: [
                          const DataCell(Text(
                            "Grand Total",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          const DataCell(Text("")),
                          const DataCell(Text("")),
                          const DataCell(Text("")),
                          DataCell(Text(
                            controller.grandTotal == 0
                                ? ""
                                : controller.grandTotal.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )),
                          const DataCell(Text("")),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}